import 'package:flutter/material.dart';
import 'package:gailtrack/screens/login/provider.dart';
import 'package:provider/provider.dart';

class AppProviders {
  static MultiProvider initialize({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: child,
    );
  }
}
