import 'package:flutter/material.dart';

enum FieldType { text, date, textarea }

class Input extends StatelessWidget {
  final String label;
  final String? placeholder;
  final TextEditingController controller;
  final Icon? icon;
  final FieldType type;
  final Function(DateTime)? onDateSelected; // For date picker
  final int? maxLines; // For textarea

  const Input({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.icon,
    this.type = FieldType.text,
    this.onDateSelected,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (type == FieldType.text) ...[
          // Text input
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: Theme.of(context).textTheme.bodyMedium,
              icon: icon,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(width: 1, color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(width: 1, color: Theme.of(context).dividerColor),
              ),
            ),
          ),
        ] else if (type == FieldType.date) ...[
          // Date picker input
          GestureDetector(
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null && onDateSelected != null) {
                onDateSelected!(selectedDate);
              }
            },
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        width: 1, color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        width: 1, color: Theme.of(context).dividerColor),
                  ),
                ),
              ),
            ),
          ),
        ] else if (type == FieldType.textarea) ...[
          // Textarea input
          TextField(
            controller: controller,
            maxLines: maxLines ?? 5,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: Theme.of(context).textTheme.bodyMedium,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(width: 1, color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(width: 1, color: Theme.of(context).dividerColor),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
