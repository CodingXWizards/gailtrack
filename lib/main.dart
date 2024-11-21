import 'package:flutter/material.dart';
import 'package:gailtrack/app/index.dart';
import 'package:gailtrack/app/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gailtrack/firebase_options.dart';

void main() async {
  //* Ensures Firebase is Initialised Properly
  WidgetsFlutterBinding.ensureInitialized();

  //* Initializing Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //* Initializes all the providers inside App Provider
  runApp(AppProviders.initialize(child: const MyApp()));
}
