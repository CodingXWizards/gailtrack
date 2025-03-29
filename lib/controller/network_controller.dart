import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gailtrack/screens/clock.dart';
import 'package:gailtrack/state/user/model.dart';
import 'package:gailtrack/state/user/service.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gailtrack/controller/working_controller.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../Hazard/HazardAlertDetailsPage.dart';

class NetworkController extends GetxController {
  // Connectivity instance
  final Connectivity _connectivity = Connectivity();
  bool _isInitialized = false;
  // SQLite Database
  late Database _database;
  final RxBool _isDatabaseInitialized = false.obs;

  // Reactive variables to track connection status
  final RxBool isConnected = false.obs;
  final Rx<ConnectivityResult> connectionType = ConnectivityResult.none.obs;

  String get currentConnectionType =>
      connectionType.value.toString().split('.').last;

  // Local Notifications
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Stream subscriptions
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _offlineLocationTracker;
  Timer? _onlineLocationTracker;
  Timer? _polygonRefreshTimer;

  // API endpoints
  static String API_URL =
      dotenv.env['API_URL']?.trim() ?? "https://gailtrack-api.onrender.com";
  static final String _apiUrl = API_URL + '/currentcords';
  static String _getCordsUrl = API_URL + 'getcords';

  // Polygon storage
  List<dynamic> _activePolygons = [];

  final Rx<User?> _currentUser = Rx<User?>(null);
  User? get currentUser => _currentUser.value;

  IO.Socket? _socket;

  bool _isLocationInCircle(double latitude, double longitude, double centerLat,
      double centerLng, double radius) {
    // Calculate the distance between the point and the circle's center
    double distance =
        Geolocator.distanceBetween(centerLat, centerLng, latitude, longitude);
    return distance <= radius;
  }

  @override
  void onInit() async {
    // Add a check to prevent multiple initialization
    try {
      _currentUser.value = await fetchUser();
      await _initDatabase();
      await _requestNotificationPermission();
      await _initializeNotifications();

      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          print('Connectivity subscription error: $error');
          isConnected.value = false;
        },
      );

      // Fetch polygons on initialization
      await _fetchPolygons();

      _isInitialized = true;
      _initializeSocket();
    } catch (e) {
      debugPrint('NetworkController initialization error: $e');
      _currentUser.value = null;
    }
  }

  void _initializeSocket() {
    try {
      // Use the base API_URL, removing any trailing slashes
      String socketUrl = API_URL.replaceAll(RegExp(r'\/+$'), '');

      _socket = IO.io(socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      _socket?.on('connect', (_) {
        debugPrint('Socket connected');
      });

      // Listen for fence updates
      _socket?.on('updatedfence', (data) {
        debugPrint('Received fence update: $data');
        _fetchPolygons(); // Fetch polygons when update is received
      });

      _socket?.on('disconnect', (_) {
        debugPrint('Socket disconnected');
      });

      _socket?.on('connect_error', (error) {
        debugPrint('Socket connection error: $error');
      });
    } catch (e) {
      debugPrint('Socket initialization error: $e');
    }
  }

  // Initialize local notifications
  Future<void> _initializeNotifications() async {
    try {
      // Android notification channel configuration
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'location_tracking_channel', // id
        'Location Tracking', // title
        description: 'Notification for continuous location tracking',
        importance: Importance.low,
        playSound: true,
      );

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      // Create an Android Notification Channel
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Notification initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          // Handle notification tap if needed
          debugPrint('Notification tapped');
          if (details.payload != null) {
            try {
              // Parse the payload
              final Map<String, dynamic> payload =
                  jsonDecode(details.payload!) as Map<String, dynamic>;

              // Get the current context
              final BuildContext? context = Get.context;

              if (context != null) {
                // Convert duration from minutes to seconds
                final int durationInSeconds = (payload['duration'] as int) * 60;

                // Use the showHazardDetailsPage function
                showHazardDetailsPage(
                  context,
                  hazard: payload['hazard'] as String,
                  department: payload['department'] as String,
                  duration: durationInSeconds,
                  alertTime: DateTime.parse(payload['alertTime'] as String),
                );
              }
            } catch (e) {
              debugPrint('Error parsing notification payload: $e');
            }
          }
        },
      );

      print('Notifications initialized successfully');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      print('Initial connectivity check failed: $e');
      isConnected.value = false;
      _showNoInternetSnackbar();
    }
  }

  // Initialize SQLite database
  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'offlinedb2.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE locations (
            sno INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            lat REAL,
            long REAL,
            date TEXT,
            time TEXT
          )
        ''');
      },
    );

    _isDatabaseInitialized.value = true;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        try {
          // Use permission request from notification settings
          await androidImplementation.requestNotificationsPermission();
          debugPrint('Notification permissions request completed');
        } catch (e) {
          debugPrint('Error requesting notification permissions: $e');
        }
      }
    }
  }

  // Show persistent location tracking notification
  Future<void> _showLocationTrackingNotification(bool isOnline) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'location_tracking_channel', // must match the channel id in initialization
        'Location Tracking',
        channelDescription: 'Notification for continuous location tracking',
        importance: Importance.low,
        priority: Priority.min,
        ongoing: true,
        autoCancel: false,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        1, // Notification ID
        'Location Tracking Active',
        isOnline
            ? 'Online Mode: Location tracking in progress'
            : 'Offline Mode: Location tracking and storing locally',
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint('Error showing location tracking notification: $e');
    }
  }

  // Fetch active polygons
  Future<void> _fetchPolygons() async {
    try {
      // Use the existing fetchUser method to get the current user
      final user = await fetchUser();

      // Prepare the request payload with the user's email
      final payload = {"email": user.email};

      final response = await http.post(Uri.parse('$API_URL/getinfo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Extract the fence list from the response
        final List fenceList = responseBody['fence'] ?? [];

        // Filter and store only active polygons
        _activePolygons = fenceList
            .where((fence) =>
                fence['status'] == 'active' &&
                fence['cords'] != null &&
                fence['cords']['coordinates'] != null)
            .toList();

        debugPrint(
            'Fetched ${_activePolygons.length} active polygons for department: ${user.dept}');
      } else {
        debugPrint(
            'Failed to fetch polygons. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching polygons: $e');
    }
  }

  bool _isPointInPolygon(
      double latitude, double longitude, List<dynamic> polygonCoords) {
    int intersectCount = 0;
    int vertexCount = polygonCoords.length;

    for (int i = 0; i < vertexCount; i++) {
      int j = (i + 1) % vertexCount;

      // Explicitly handle 'lat'/'lng' keys
      double vertexILat = polygonCoords[i]['lat'] is double
          ? polygonCoords[i]['lat']
          : double.parse(polygonCoords[i]['lat'].toString());
      double vertexILon = polygonCoords[i]['lng'] is double
          ? polygonCoords[i]['lng']
          : double.parse(polygonCoords[i]['lng'].toString());

      double vertexJLat = polygonCoords[j]['lat'] is double
          ? polygonCoords[j]['lat']
          : double.parse(polygonCoords[j]['lat'].toString());
      double vertexJLon = polygonCoords[j]['lng'] is double
          ? polygonCoords[j]['lng']
          : double.parse(polygonCoords[j]['lng'].toString());

      // Ray-casting algorithm with explicit coordinate comparison
      bool rayIntersectsSegment =
          ((vertexILon > longitude) != (vertexJLon > longitude)) &&
              (latitude <
                  (vertexJLat - vertexILat) *
                          (longitude - vertexILon) /
                          (vertexJLon - vertexILon) +
                      vertexILat);

      if (rayIntersectsSegment) {
        intersectCount++;
      }
    }

    return intersectCount % 2 == 1;
  }

// Modified method to handle multiple polygons
  bool _isLocationInActivePolygons(double latitude, double longitude) {
    for (var polygon in _activePolygons) {
      dynamic coordinates;
      String geofenceType = 'Polygon'; // Default to Polygon

      // Determine the geofence type and coordinates
      if (polygon['cords'] != null && polygon['cords']['type'] != null) {
        geofenceType = polygon['cords']['type'];
      }

      // Handle different possible coordinate structures
      if (polygon['cords'] != null && polygon['cords']['coordinates'] != null) {
        coordinates = polygon['cords']['coordinates'];
      } else if (polygon['coordinates'] != null) {
        coordinates = polygon['coordinates'];
      } else if (polygon['cords'] != null) {
        coordinates = polygon['cords'];
      } else {
        debugPrint('Unexpected polygon coordinate structure');
        continue;
      }

      try {
        // Check based on geofence type
        if (geofenceType == 'Polygon') {
          // Existing polygon check
          if (_isPointInPolygon(latitude, longitude, coordinates)) {
            return true;
          }
        } else if (geofenceType == 'Circle') {
          // New circle check
          // Assuming circle coordinates are in the format:
          // [{"lat": centerLat, "lng": centerLng, "radius": radius}]
          if (coordinates.isNotEmpty) {
            final circleData = coordinates[0];
            final centerLat = circleData['lat'] is double
                ? circleData['lat']
                : double.parse(circleData['lat'].toString());
            final centerLng = circleData['lng'] is double
                ? circleData['lng']
                : double.parse(circleData['lng'].toString());
            final radius = circleData['radius'] is double
                ? circleData['radius']
                : double.parse(circleData['radius'].toString());

            if (_isLocationInCircle(
                latitude, longitude, centerLat, centerLng, radius)) {
              return true;
            }
          }
        }
      } catch (e) {
        debugPrint('Error checking geofence: $e');
        debugPrint('Geofence details: $coordinates');
      }
    }

    print('Location is OUTSIDE all geofences');
    return false;
  }

  // Track location when offline
  Future<void> _trackOfflineLocation() async {
    if (!isConnected.value && _isDatabaseInitialized.value) {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best);

          // Check if location is in active polygons
          final bool isInPolygon = _isLocationInActivePolygons(
              position.latitude, position.longitude);

          // Handle working check-in/check-out
          final WorkingController workingController =
              Get.find<WorkingController>();
          await workingController.performCheckIn(isInPolygon);
          await workingController.performCheckOut(isInPolygon);

          try {
            // Store location in local database
            if (_currentUser.value != null) {
              await _database.insert('locations', {
                'user_id': _currentUser.value!.uuidFirebase,
                'lat': position.latitude,
                'long': position.longitude,
                'date': DateFormat("yyyy-MM-dd").format(DateTime.now()),
                'time': ClockService().getFormattedTime(),
              });
            }
            print(
                'Offline location stored: ${position.latitude}, ${position.longitude} , ${ClockService().getFormattedTime()}');
            // print('In Polygon: $isInPolygon');
          } catch (e) {
            debugPrint("user not logged in");
          }
        }
      } catch (e) {
        debugPrint('Offline location tracking error: $e');
      }
    }
  }

  // Periodic online location tracking
  Future<void> _trackOnlineLocation() async {
    if (isConnected.value && _isDatabaseInitialized.value) {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best);

          // Check if location is in active polygons
          final bool isInPolygon = _isLocationInActivePolygons(
              position.latitude, position.longitude);

          // Handle working check-in/check-out
          final WorkingController workingController =
              Get.find<WorkingController>();
          await workingController.performCheckIn(isInPolygon);
          await workingController.performCheckOut(isInPolygon);

          // Prepare payload for location upload
          final payload = {
            "user_id": "1",
            "latitude": position.latitude,
            "longitude": position.longitude,
            "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
            "Time": ClockService().getFormattedTime(),
            'online': true,
            'working': isInPolygon
          };
          try {
            // Store location in local database
            if (_currentUser.value != null) {
              await _database.insert('locations', {
                'user_id': _currentUser.value!.uuidFirebase,
                'lat': position.latitude,
                'long': position.longitude,
                'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                'time': ClockService().getFormattedTime(),
              });
            }
          } catch (e) {
            debugPrint("User not logged in");
          }

          debugPrint(
              'Online location tracked: ${position.latitude}, ${position.longitude}, ${ClockService().getFormattedTime()}');
          debugPrint('In Polygon: $isInPolygon');
        }
      } catch (e) {
        print('Online location tracking error: $e');
      }
    }
  }

  // New method to bulk upload locations to server
  Future<void> _bulkUploadLocations() async {
    if (isConnected.value && _isDatabaseInitialized.value) {
      try {
        final locations = await _database.query('locations');

        if (locations.isNotEmpty) {
          for (var location in locations) {
            try {
              final isInPolygon = _isLocationInActivePolygons(
                  location['lat'] as double, location['long'] as double);
              final payload = {
                "uuid_firebase": location['user_id'],
                "latitude": location['lat'].toString(),
                "longitude": location['long'].toString(),
                "date": location['date'], // Ensure correct format
                "Time": location['time'],
                'online': true,
                'working': isInPolygon
              };

              // Upload individual location
              final response = await http.post(
                Uri.parse(_apiUrl),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(payload),
              );

              if (response.statusCode == 200) {
                // Delete the specific location after successful upload
                await _database.delete(
                  'locations',
                  where: 'sno = ?',
                  whereArgs: [location['sno']],
                );
                debugPrint('Location upload successful: ${location['sno']}');
              } else {
                debugPrint(
                    'Location upload failed. Status code: ${response.statusCode}');
                debugPrint(response.body);
              }

              // Small delay between uploads to prevent overwhelming the server
              await Future.delayed(const Duration(seconds: 5));
            } catch (individualError) {
              debugPrint(
                  'Error uploading individual location: $individualError');
            }
          }

          debugPrint('Bulk location upload process completed.');
        }
      } catch (e) {
        debugPrint('Bulk location upload error: $e');
      }
    }
  }

  // Upload stored locations
  Future<void> _uploadLocationsToServer(
      List<Map<String, dynamic>> locations) async {
    try {
      for (var location in locations) {
        final isInPolygon =
            _isLocationInActivePolygons(location['lat'], location['long']);

        final payload = {
          "uuid_firebase": location['user_id'],
          "latitude": location['lat'].toString(),
          "longitude": location['long'].toString(),
          "date": location['date'],
          "Time": location['time'],
          'online': false,
          'working': isInPolygon // New field for offline locations
        };

        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          print('Location uploaded successfully: $payload');
        } else {
          // print(
          //     'Failed to upload location. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error uploading locations: $e');
    }
  }

  // Print and upload stored locations
  Future<void> _printAndClearStoredLocations() async {
    if (_isDatabaseInitialized.value) {
      final locations = await _database.query('locations');

      locations.forEach((location) {
        print('''
          Lat: ${location['lat']}, 
          Long: ${location['long']}, 
          Date: ${location['date']}, 
          Time: ${location['time']}
        ''');
      });

      await _uploadLocationsToServer(locations);
      await _database.delete('locations');
    }
  }

  // Update connection status
  void _updateConnectionStatus(List<ConnectivityResult> result) async {
    final connectivityResult = result.first;
    connectionType.value = connectivityResult;

    switch (connectivityResult) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
        isConnected.value = true;
        _handleInternetConnection(
            connectivityResult.toString().split('.').last);
        await _printAndClearStoredLocations();
        _offlineLocationTracker?.cancel();

        // Show online tracking notification
        _showLocationTrackingNotification(true);

        // Start periodic online location tracking
        _onlineLocationTracker = Timer.periodic(
            const Duration(seconds: 10), (_) => _trackOnlineLocation());

        // Start polygon refresh
        _polygonRefreshTimer = Timer.periodic(
            const Duration(seconds: 20), (_) => _bulkUploadLocations());

        // Polygon refresh every 2 hours (separate timer)
        Timer.periodic(const Duration(hours: 2), (_) => _fetchPolygons());
        break;

      case ConnectivityResult.none:
        isConnected.value = false;
        _showNoInternetSnackbar();
        _onlineLocationTracker?.cancel();
        _polygonRefreshTimer?.cancel();

        // Show offline tracking notification
        _showLocationTrackingNotification(false);

        _offlineLocationTracker = Timer.periodic(
            const Duration(seconds: 10), (_) => _trackOfflineLocation());
        break;

      default:
        isConnected.value = false;
        _showNoInternetSnackbar();
    }
  }

  // Handle internet connection
  void _handleInternetConnection(String connectionType) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    print('Internet connected via $connectionType');
  }

  // Show no internet snackbar
  void _showNoInternetSnackbar() {
    if (!Get.isSnackbarOpen) {
      Get.rawSnackbar(
        messageText: const Text(
          'No Internet Connection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        titleText: const Text(
          'Connection Lost',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        isDismissible: false,
        duration: const Duration(days: 1),
        backgroundColor: Colors.red[400]!,
        icon: const Icon(
          Icons.wifi_off,
          color: Colors.white,
          size: 35,
        ),
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
      );
    }
  }

  // Cleanup on close
  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _offlineLocationTracker?.cancel();
    _onlineLocationTracker?.cancel();
    _polygonRefreshTimer?.cancel();
    _database.close();
    _flutterLocalNotificationsPlugin.cancel(1);
    ClockService().dispose();
    _socket?.dispose();
    _socket = null;
    super.onClose();
  }
}
