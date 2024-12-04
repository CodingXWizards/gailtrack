import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final Color bgColor;
  final Color textColor;
  final bool isLoading;

  const MyButton(
      {super.key,
      required this.text,
      required this.bgColor,
      required this.textColor,
      this.isLoading = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(bgColor),
            foregroundColor: WidgetStatePropertyAll<Color>(textColor)),
        onPressed: onTap,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  strokeCap: StrokeCap.round,
                ),
              )
            : Text(
                text,
              ),
      ),
    );
  }
}
