import 'package:flutter/material.dart';
import 'package:gailtrack/constants/colors.dart';

class BoxContainer extends StatelessWidget {
  final Widget child;
  const BoxContainer({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: AppColorsDark.border)),
      child: child,
    );
  }
}
