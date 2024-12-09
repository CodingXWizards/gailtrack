import 'package:flutter/material.dart';
import 'package:gailtrack/constants/colors.dart';

class BoxContainer extends StatelessWidget {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double? height;
  final double? width;
  final Widget child;

  const BoxContainer(
      {super.key,
      required this.child,
      this.height,
      this.width,
      this.padding = const EdgeInsets.all(16),
      this.margin = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: AppColorsDark.border)),
      child: child,
    );
  }
}
