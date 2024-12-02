import 'package:flutter/material.dart';
import 'package:gailtrack/constants/colors.dart';

class BoxContainer extends StatelessWidget {
  final EdgeInsets margin;
  final Widget child;

  const BoxContainer(
      {super.key, required this.child, this.margin = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: AppColorsDark.border)),
      child: child,
    );
  }
}
