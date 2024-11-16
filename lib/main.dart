import 'package:flutter/material.dart';
import 'package:gailtrack/app/index.dart';
import 'package:gailtrack/app/providers.dart';

void main() {
  //* Initializes all the providers inside App Provider
  runApp(AppProviders.initialize(child: const MyApp()));
}
