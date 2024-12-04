import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final double radius;

  const Avatar({super.key, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).focusColor,
      child: Icon(Icons.person, size: radius * 1.5),
    );
  }
}
