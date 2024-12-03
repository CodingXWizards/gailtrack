import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gailtrack/app/index.dart';
import 'package:gailtrack/app/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gailtrack/firebase_options.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:logging/logging.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  //* Ensures Firebase is Initialised Properly
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  String mapboxAccessToken =
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? 'default_value';

  MapboxOptions.setAccessToken(mapboxAccessToken);

  //* Initializing Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //* Initializes all the providers inside App Provider
  runApp(AppProviders.initialize(child: const MyApp()));
}
