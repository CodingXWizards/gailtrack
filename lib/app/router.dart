import 'package:flutter/material.dart';

import 'package:gailtrack/screens/home/index.dart';
import 'package:gailtrack/screens/login/index.dart';
import 'package:gailtrack/screens/onboarding/index.dart';
import 'package:gailtrack/screens/calendar/index.dart';
import 'package:gailtrack/screens/page_not_found.dart';
import 'package:gailtrack/screens/report/report.dart';
import 'package:gailtrack/screens/request/router.dart';
import 'package:gailtrack/utils/page_animation.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => const Home());
      case '/signin':
        return MaterialPageRoute(builder: (context) => const Login());
      case '/onboarding':
        return MaterialPageRoute(builder: (context) => const Onboarding());
      case '/report':
        return PageAnimation(page: const Report());
      case '/calendar':
        return PageAnimation(page: const Calendar());
      default:
        if (settings.name!.startsWith('/request')) {
          return RequestRouter.generateRoute(
            RouteSettings(
              name: settings.name!.replaceFirst('/request', ''),
              arguments: settings.arguments,
            ),
          );
        }

        return PageAnimation(page: const PageNotFound());
    }
  }
}
