import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final Color bgColor;
  final Color textColor;

  const MyButton(
      {super.key,
      required this.text,
      required this.bgColor,
      required this.textColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(bgColor),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
