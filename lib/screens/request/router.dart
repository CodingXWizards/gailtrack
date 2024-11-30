import 'package:flutter/material.dart';
import 'package:gailtrack/screens/page_not_found.dart';
import 'package:gailtrack/screens/request/leave.dart';
import 'package:gailtrack/screens/request/offsite.dart';
import 'package:gailtrack/utils/page_animation.dart';

class RequestRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/offsite':
        return PageAnimation(page: const RequestOffsite());
      case '/leave':
        return PageAnimation(page: const RequestLeave());
      default:
        return PageAnimation(page: const PageNotFound());
    }
  }
}
