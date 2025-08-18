import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:gailtrack/state/attendance/model.dart';
import 'package:gailtrack/state/attendance/service.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gailtrack/controller/network_controller.dart';
import 'dart:async';

class WorkingProvider extends ChangeNotifier {
  List<Working> _working = [];
  bool _isLoading = false;
  String? _error;
  late IO.Socket _socket;
  Timer? _autoCheckoutTimer;

  List<Working> get working => _working;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WorkingProvider() {
    _initializeSocket();
    loadWorking();
    _initializeAutoCheckout();
  }

  void _initializeSocket() {
    _socket = IO.io('${dotenv.env['API_URL']?.trim()}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print('Connected to WebSocket');
    });

    _socket.on('newcheck', (data) {
      try {
        // Check if the data is a list, extract the first item
        final eventData = (data is List && data.isNotEmpty)
            ? data.first as Map<String, dynamic>
            : data as Map<String, dynamic>;

        print('New check-in received: $eventData');
        _processNewCheckIn(eventData);
      } catch (e) {
        print('Error processing new check-in: $e');
      }
    });

    _socket.onDisconnect((_) => print('Disconnected from WebSocket'));
  }

  // Initialize auto checkout timer
  void _initializeAutoCheckout() {
    // Calculate time until next 8 PM
    final now = DateTime.now();
    DateTime nextCheckoutTime =
        DateTime(now.year, now.month, now.day, 20, 0); // 8 PM

    // If it's already past 8 PM today, schedule for tomorrow
    if (now.isAfter(nextCheckoutTime)) {
      nextCheckoutTime = nextCheckoutTime.add(const Duration(days: 1));
    }

    final timeUntilCheckout = nextCheckoutTime.difference(now);

    debugPrint('Auto checkout scheduled for: $nextCheckoutTime');
    debugPrint(
        'Time until auto checkout: ${timeUntilCheckout.inHours}h ${timeUntilCheckout.inMinutes % 60}m');

    // Schedule the first auto checkout
    _autoCheckoutTimer = Timer(timeUntilCheckout, () {
      _performAutoCheckout();
      // Then schedule it to run daily at 8 PM
      _scheduleDailyAutoCheckout();
    });
  }

  // Schedule daily auto checkout at 8 PM
  void _scheduleDailyAutoCheckout() {
    _autoCheckoutTimer?.cancel();
    _autoCheckoutTimer = Timer.periodic(const Duration(days: 1), (_) {
      _performAutoCheckout();
    });
  }

  // Perform automatic checkout at 8 PM
  Future<void> _performAutoCheckout() async {
    try {
      debugPrint('Auto checkout triggered at ${DateTime.now()}');

      // Check if user is currently checked in
      if (!isCurrentlyCheckedIn()) {
        debugPrint('User not checked in, no auto checkout needed');
        return;
      }

      // Get the current working session
      final currentWorking = getCurrentWorkingSession();
      if (currentWorking == null) {
        debugPrint('No current working session found');
        return;
      }

      debugPrint(
          'Auto checking out user from session started at ${currentWorking.checkIn}');

      // Perform the checkout
      final success = await manualCheckOut();
      if (success) {
        debugPrint('Auto checkout successful');
        // Show a notification or update UI
        _error = "Auto checkout completed at 8:00 PM";
        notifyListeners();

        // Show a snackbar notification if possible
        _showAutoCheckoutNotification();
      } else {
        debugPrint('Auto checkout failed: $_error');
      }
    } catch (e) {
      debugPrint('Error during auto checkout: $e');
    }
  }

  // Show auto checkout notification
  void _showAutoCheckoutNotification() {
    try {
      // Try to show a snackbar using GetX
      Get.snackbar(
        'Auto Checkout',
        'You have been automatically checked out at 8:00 PM',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        duration: const Duration(seconds: 5),
        icon: Icon(Icons.timer, color: Colors.orange.shade600),
      );
    } catch (e) {
      debugPrint('Could not show auto checkout notification: $e');
    }
  }

  void _processNewCheckIn(Map<String, dynamic> eventData) {
    try {
      final newEntry = Working.fromJson(eventData);

      // Print for debugging to ensure the check-out data is received
      print('Received check-out data: ${newEntry.checkOut}');

      // Update the existing entry if it matches, otherwise add a new one
      final existingIndex =
          _working.indexWhere((entry) => entry.id == newEntry.id);
      if (existingIndex != -1) {
        _working[existingIndex] = newEntry;
        print('Updated existing entry with ID: ${newEntry.id}');
      } else {
        _working.add(newEntry);
        print('Added new entry with ID: ${newEntry.id}');
      }

      notifyListeners();
    } catch (e) {
      print('Error adding new entry: $e');
    }
  }

  Future<void> loadWorking() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _working = await fetchWorking();
      print("Loaded working entries: ${_working.length}");
    } catch (e) {
      _error = e.toString();
      print("Error loading working entries: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user is currently checked in for today
  bool isCurrentlyCheckedIn() {
    final today = DateTime.now();
    final todayFormatted = DateFormat('yyyy-MM-dd').format(today);

    return _working.any((working) {
      final workingDateFormatted =
          DateFormat('yyyy-MM-dd').format(working.date);
      return workingDateFormatted == todayFormatted && working.checkOut == null;
    });
  }

  // Check if user is within geofence
  Future<bool> isUserWithinGeofence() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Get current position
        final Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
          ),
        );

        debugPrint(
            'User location: ${position.latitude}, ${position.longitude}');

        // Try to get geofence data and check if user is within any active geofence
        final geofenceData = await _getGeofenceData();
        if (geofenceData != null && geofenceData.isNotEmpty) {
          // Use actual geofence data to check location
          return await _checkLocationAgainstGeofences(
              position.latitude, position.longitude, geofenceData);
        } else {
          // Try to use NetworkController's built-in geofence checking method
          try {
            final networkController = Get.find<NetworkController>();
            final bool isInGeofence =
                networkController.isLocationInActiveGeofences(
                    position.latitude, position.longitude);
            debugPrint(
                'NetworkController geofence check result: $isInGeofence');
            return isInGeofence;
          } catch (e) {
            debugPrint('Could not use NetworkController geofence check: $e');
          }

          // Fallback to basic geofence check
          return await _basicGeofenceCheck(
              position.latitude, position.longitude);
        }
      } else {
        // Permission denied
        return false;
      }
    } catch (e) {
      debugPrint('Error checking geofence: $e');
      return false;
    }
  }

  // Basic geofence check (placeholder - should be replaced with actual geofence data)
  Future<bool> _basicGeofenceCheck(double latitude, double longitude) async {
    try {
      // This is a placeholder implementation
      // In a real app, you would:
      // 1. Get geofence data from NetworkController or API
      // 2. Check if the user's location is within any active geofence
      // 3. Return true/false based on the actual geofence boundaries

      // For now, we'll implement a simple distance-based check
      // You can replace this with actual geofence polygon checking

      // Example: Check if user is within 100 meters of a predefined work location
      // This should be replaced with your actual work location coordinates
      const double workLatitude = 0.0; // Replace with actual work location
      const double workLongitude = 0.0; // Replace with actual work location
      const double maxDistance = 100.0; // 100 meters

      if (workLatitude == 0.0 && workLongitude == 0.0) {
        // If no coordinates set, allow check-out (for development)
        debugPrint('No geofence coordinates set - allowing check-out');
        return true;
      }

      final double distance = Geolocator.distanceBetween(
          workLatitude, workLongitude, latitude, longitude);

      final bool isWithinGeofence = distance <= maxDistance;
      debugPrint(
          'Distance from work location: ${distance.toStringAsFixed(2)}m');
      debugPrint('Within geofence: $isWithinGeofence');

      return isWithinGeofence;
    } catch (e) {
      debugPrint('Error in basic geofence check: $e');
      return false;
    }
  }

  // Get today's working record
  Working? getTodayWorkingRecord() {
    final today = DateTime.now();
    final todayFormatted = DateFormat('yyyy-MM-dd').format(today);

    try {
      return _working.firstWhere((working) {
        final workingDateFormatted =
            DateFormat('yyyy-MM-dd').format(working.date);
        return workingDateFormatted == todayFormatted;
      });
    } catch (e) {
      return null;
    }
  }

  // Get current working session (if user is currently checked in)
  Working? getCurrentWorkingSession() {
    final today = DateTime.now();
    final todayFormatted = DateFormat('yyyy-MM-dd').format(today);

    try {
      return _working.firstWhere((working) {
        final workingDateFormatted =
            DateFormat('yyyy-MM-dd').format(working.date);
        return workingDateFormatted == todayFormatted &&
            (working.checkOut == null || working.checkOut!.isEmpty);
      });
    } catch (e) {
      return null;
    }
  }

  // Manual check-in
  Future<bool> manualCheckIn() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if already checked in today
      if (isCurrentlyCheckedIn()) {
        _error = "You are already checked in today";
        notifyListeners();
        return false;
      }

      // Ensure user is within geofence before allowing check-in
      final bool isWithinGeofence = await isUserWithinGeofence();
      if (!isWithinGeofence) {
        _error = "You must be within the work area to check in";
        notifyListeners();
        return false;
      }

      final now = DateTime.now();
      final currentDate = DateFormat('yyyy-MM-dd').format(now);
      final currentTime = DateFormat('HH:mm:ss').format(now);

      final String? uuidFirebase = FirebaseAuth.instance.currentUser?.uid;
      if (uuidFirebase == null) {
        _error = "User not authenticated";
        notifyListeners();
        return false;
      }

      // Send check-in to server
      final url = Uri.parse(
          '${dotenv.env['API_URL']?.trim() ?? "https://gailtrack-api.onrender.com"}/checkin');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uuid_firebase': uuidFirebase,
          'checkin': currentTime,
          'date': currentDate,
        }),
      );

      if (response.statusCode == 200) {
        // Small delay to ensure server processes the request
        await Future.delayed(const Duration(milliseconds: 500));
        // Reload working data to get the new entry
        await loadWorking();
        // Force a UI refresh to show the latest data
        notifyListeners();
        return true;
      } else {
        _error = "Failed to check in. Status: ${response.statusCode}";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Error during check-in: $e";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manual check-out
  Future<bool> manualCheckOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if currently checked in
      if (!isCurrentlyCheckedIn()) {
        _error = "You are not currently checked in";
        notifyListeners();
        return false;
      }

      // Check if user is within geofence
      final bool isWithinGeofence = await isUserWithinGeofence();
      if (isWithinGeofence) {
        _error = "You must be outside the work area to check out";
        notifyListeners();
        return false;
      }

      final now = DateTime.now();
      final currentTime = DateFormat('HH:mm:ss').format(now);

      final String? uuidFirebase = FirebaseAuth.instance.currentUser?.uid;
      if (uuidFirebase == null) {
        _error = "User not authenticated";
        notifyListeners();
        return false;
      }

      // Send check-out to server
      final url = Uri.parse(
          '${dotenv.env['API_URL']?.trim() ?? "https://gailtrack-api.onrender.com"}/checkout');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uuid_firebase': uuidFirebase,
          'checkout': currentTime,
        }),
      );

      if (response.statusCode == 200) {
        // Small delay to ensure server processes the request
        await Future.delayed(const Duration(milliseconds: 500));
        // Reload working data to get the updated entry
        await loadWorking();
        // Force a UI refresh to show the latest data
        notifyListeners();
        return true;
      } else {
        _error = "Failed to check out. Status: ${response.statusCode}";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Error during check-out: $e";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Manually trigger auto checkout (for testing purposes)
  Future<void> triggerAutoCheckout() async {
    debugPrint('Manual auto checkout trigger');
    await _performAutoCheckout();
  }

  // Get auto checkout status
  String getAutoCheckoutStatus() {
    if (_autoCheckoutTimer == null) {
      return 'Not scheduled';
    }

    final now = DateTime.now();
    final nextCheckoutTime =
        DateTime(now.year, now.month, now.day, 20, 0); // 8 PM

    if (now.isAfter(nextCheckoutTime)) {
      // Already past 8 PM today, next is tomorrow
      final tomorrowCheckout = nextCheckoutTime.add(const Duration(days: 1));
      return 'Next: ${DateFormat('MMM dd, 8:00 PM').format(tomorrowCheckout)}';
    } else {
      return 'Today at 8:00 PM';
    }
  }

  // Check if auto checkout is enabled
  bool isAutoCheckoutEnabled() {
    return _autoCheckoutTimer != null;
  }

  // Toggle auto checkout on/off
  void toggleAutoCheckout() {
    if (isAutoCheckoutEnabled()) {
      _autoCheckoutTimer?.cancel();
      _autoCheckoutTimer = null;
      debugPrint('Auto checkout disabled');
    } else {
      _initializeAutoCheckout();
      debugPrint('Auto checkout enabled');
    }
    notifyListeners();
  }

  // Refresh today's working data specifically
  Future<void> refreshTodayData() async {
    try {
      await loadWorking();
      // Force UI update to show latest data
      notifyListeners();
    } catch (e) {
      print("Error refreshing today's data: $e");
    }
  }

  // Get geofence data from NetworkController
  Future<List<dynamic>?> _getGeofenceData() async {
    try {
      // Try to get NetworkController instance
      final networkController = Get.find<NetworkController>();
      if (networkController != null) {
        final geofences = networkController.getActiveGeofences();
        debugPrint(
            'Retrieved ${geofences.length} active geofences from NetworkController');
        return geofences;
      }
    } catch (e) {
      debugPrint('NetworkController not found: $e');
    }
    return null;
  }

  // Check if point is within polygon (ray casting algorithm)
  bool _isPointInPolygon(
      double latitude, double longitude, List<dynamic> polygonCoords) {
    int intersectCount = 0;
    int vertexCount = polygonCoords.length;

    for (int i = 0; i < vertexCount; i++) {
      int j = (i + 1) % vertexCount;

      // Handle different coordinate formats
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

      // Ray-casting algorithm
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

  // Check if point is within circle
  bool _isPointInCircle(double latitude, double longitude, double centerLat,
      double centerLng, double radius) {
    double distance =
        Geolocator.distanceBetween(centerLat, centerLng, latitude, longitude);
    return distance <= radius;
  }

  // Check location against multiple geofences
  Future<bool> _checkLocationAgainstGeofences(
      double latitude, double longitude, List<dynamic> geofences) async {
    for (var geofence in geofences) {
      try {
        dynamic coordinates;
        String geofenceType = 'Polygon'; // Default to Polygon

        // Determine the geofence type and coordinates
        if (geofence['cords'] != null && geofence['cords']['type'] != null) {
          geofenceType = geofence['cords']['type'];
        }

        // Handle different possible coordinate structures
        if (geofence['cords'] != null &&
            geofence['cords']['coordinates'] != null) {
          coordinates = geofence['cords']['coordinates'];
        } else if (geofence['coordinates'] != null) {
          coordinates = geofence['coordinates'];
        } else if (geofence['cords'] != null) {
          coordinates = geofence['cords'];
        } else {
          debugPrint('Unexpected geofence coordinate structure');
          continue;
        }

        // Check based on geofence type
        if (geofenceType == 'Polygon') {
          if (_isPointInPolygon(latitude, longitude, coordinates)) {
            debugPrint('User is within polygon geofence');
            return true;
          }
        } else if (geofenceType == 'Circle') {
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

            if (_isPointInCircle(
                latitude, longitude, centerLat, centerLng, radius)) {
              debugPrint('User is within circle geofence');
              return true;
            }
          }
        }
      } catch (e) {
        debugPrint('Error checking geofence: $e');
        continue;
      }
    }

    debugPrint('User is not within any active geofence');
    return false;
  }

  @override
  void dispose() {
    _socket.disconnect();
    _autoCheckoutTimer?.cancel();
    super.dispose();
  }
}
