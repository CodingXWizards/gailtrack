import 'package:flutter/material.dart';

class PageAnimation<T> extends PageRouteBuilder<T> {
  final Widget page;

  PageAnimation({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide effect
            const begin = Offset(1.0, 0.0); // Start from the right
            const end = Offset.zero; // Slide to center
            const curve = Curves.easeInOut;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final slideAnimation = animation.drive(tween);

            // Fade effect
            final fadeAnimation =
                Tween<double>(begin: 0.0, end: 1.0).animate(animation);

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
        );
}
