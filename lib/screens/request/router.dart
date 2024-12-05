import 'package:flutter/material.dart';

import 'package:gailtrack/utils/page_animation.dart';
import 'package:gailtrack/screens/request/all.dart';
import 'package:gailtrack/screens/page_not_found.dart';
import 'package:gailtrack/screens/request/leave.dart';
import 'package:gailtrack/screens/request/members.dart';
import 'package:gailtrack/screens/request/offsite.dart';

class RequestRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/offsite':
        return PageAnimation(page: const RequestOffsite());
      case '/leave':
        return PageAnimation(page: const RequestLeave());
      case '/members':
        return PageAnimation(page: const RequestMembers());
      case '/all':
        return PageAnimation(page: const RequestAll());
      default:
        return PageAnimation(page: const PageNotFound());
    }
  }
}
