import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gailtrack/firebase_options.dart';
import 'package:gailtrack/vpn/vpn_detector.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:logging/logging.dart';
import 'package:gailtrack/app/index.dart';
import 'package:gailtrack/app/providers.dart';
import 'package:firebase_core/firebase_core.dart';

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

  //* Accessing Mapbox access token from .env
  String mapboxAccessToken =
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? 'default_value';

  //* Setting access token to the map
  MapboxOptions.setAccessToken(mapboxAccessToken);

  //* Initializing Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //* Initializes all the providers inside App Provider
  runApp(VpnCheckWrapper(
      child: AppProviders.initialize(child: const MyApp())
  ));

  if (!Get.isRegistered<NetworkController>()) {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
  // Add this with other initialization code
  if (!Get.isRegistered<WorkingController>()) {
    Get.put<WorkingController>(WorkingController(), permanent: true);
  }
}