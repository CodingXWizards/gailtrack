import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
<<<<<<< Updated upstream
import 'package:gailtrack/app/index.dart';
import 'package:gailtrack/app/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gailtrack/firebase_options.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:logging/logging.dart';
=======
import 'package:gailtrack/firebase_options.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:logging/logging.dart';
import 'package:gailtrack/app/index.dart';
import 'package:gailtrack/app/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'detection/devmode.dart';
import 'detection/vpnd.dart';
>>>>>>> Stashed changes

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Show developer mode check first
  runApp(const SecurityCheckApp());
}

class SecurityCheckApp extends StatelessWidget {
  const SecurityCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DeveloperModeCheckPage(
        onDevModeOff: () {
          // When developer mode is off, proceed to VPN check
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => VPNCheckApp(),
            ),
          );
        },
      ),
    );
  }
}

class VPNCheckApp extends StatelessWidget {
  const VPNCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VPNDetectionPage(
        onVPNOff: () async {
          // Initialize main app when VPN is off
          await initializeMainApp(context);
        },
      ),
    );
  }
}

Future<void> initializeMainApp(BuildContext context) async {
  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Initialize Mapbox
    String mapboxAccessToken =
        dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? 'default_value';
    MapboxOptions.setAccessToken(mapboxAccessToken);

    // Initialize Firebase
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // Run the main app with providers
    runApp(AppProviders.initialize(child: const MyApp()));
  } catch (e) {
    print('Initialization error: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e'),
        ),
      ),
    ));
  }
}
