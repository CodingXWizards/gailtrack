import 'package:flutter/material.dart';

enum ButtonType { primary, secondary }

class MyButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final double? width;
  final Color? bgColor;
  final Color? textColor;
  final ButtonType type;
  final bool isLoading;
  final EdgeInsets padding;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    this.textColor,
    this.bgColor,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    this.isLoading = false,
    this.type = ButtonType.primary,
  });

  Color getColor(List<Color> colors, context) {
    switch (type) {
      case ButtonType.primary:
        return colors[0];
      case ButtonType.secondary:
        return colors[1];
      default:
        return colors[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll<EdgeInsets>(padding),
          backgroundColor: WidgetStatePropertyAll<Color>(getColor([
            Theme.of(context).colorScheme.surface,
            Theme.of(context).focusColor
          ], context)),
          foregroundColor: WidgetStatePropertyAll<Color>(getColor(
              [Theme.of(context).focusColor, Theme.of(context).primaryColor],
              context)),
        ),
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
