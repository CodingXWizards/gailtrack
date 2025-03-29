import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gailtrack/firebase_options.dart';
import 'package:gailtrack/screens/clock.dart';
import 'package:gailtrack/vpn/vpn_detector.dart';
import 'package:gailtrack/websocket/manager.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:logging/logging.dart';
import 'package:gailtrack/app/index.dart';
import 'package:gailtrack/app/providers.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Hazard/HazardAlertservice.dart';
import 'controller/network_controller.dart';
import 'controller/working_controller.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // print('${record.level.name}: ${record.time}: ${record.message}');
  });
  //* Ensures Firebase is Initialised Properly
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  debugPrint = (String? message, {int? wrapWidth}) {
    print(message);
  };

  WebSocketManager().init();

  //* Accessing Mapbox access token from .env
  String mapboxAccessToken =
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? 'default_value';

  //* Setting access token to the map
  MapboxOptions.setAccessToken(mapboxAccessToken);

  //* Initializing Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ClockService().initialize();

  //* Initializes all the providers inside App Provider
  runApp(VpnCheckWrapper(child: AppProviders.initialize(child: const MyApp())));

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettingsIOS =
      DarwinInitializationSettings(); // Ensure iOS settings are provided
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  // Initialize notification tap handler
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) {},
  );
  final hazardAlertService = HazardAlertService();
  hazardAlertService.initialize(dotenv.env['API_URL']!.trim());

  if (!Get.isRegistered<NetworkController>()) {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
  // Add this with other initialization code
  if (!Get.isRegistered<WorkingController>()) {
    Get.put<WorkingController>(WorkingController(), permanent: true);
  }
}
