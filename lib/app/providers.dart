import 'package:flutter/material.dart';
import 'package:gailtrack/state/attendance/provider.dart';
import 'package:gailtrack/state/request/provider.dart';

import 'package:gailtrack/state/user/provider.dart';
import 'package:provider/provider.dart';

class AppProviders {
  static MultiProvider initialize({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WorkingProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
      ],
      child: child,
    );
  }
}
