import 'package:flutter/material.dart';
import 'package:gailtrack/state/attendance/provider.dart';
import 'package:gailtrack/state/request/provider.dart';
import 'package:gailtrack/state/tasks/provider.dart';

import 'package:gailtrack/state/user/provider.dart';
import 'package:gailtrack/websocket/tasks_service.dart';
import 'package:provider/provider.dart';

class AppProviders {
  static MultiProvider initialize({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WorkingProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),

        //WebSocket Providers
        Provider(create: (_) => TaskWebSocketService())
      ],
      child: child,
    );
  }
}
