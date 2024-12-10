import 'package:flutter/material.dart';
import 'package:gailtrack/components/input.dart';
import 'package:gailtrack/components/my_button.dart';
import 'package:intl/intl.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Report",
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Input(
              label: "Title",
              placeholder: "Enter the title",
              controller: titleController,
            ),
            const SizedBox(height: 20),
            Input(
              label: "Select Date",
              placeholder: DateFormat("dd/MM/yyyy").format(DateTime.now()),
              icon: const Icon(Icons.calendar_month_rounded),
              controller: dateController,
              type: FieldType.date,
              onDateSelected: (selectedDate) {
                if (selectedDate.isBefore(DateTime.now())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      content: Text(
                        "Date cannot be earlier than today.",
                        style: TextStyle(color: Theme.of(context).focusColor),
                      ),
                    ),
                  );
                } else {
                  dateController.text =
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                }
              },
            ),
            const SizedBox(height: 20),
            Input(
              label: "Description",
              placeholder: "Complaint...",
              controller: descriptionController,
              type: FieldType.textarea,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyButton(
                  text: "Cancel",
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                MyButton(
                  text: "Submit",
                  type: ButtonType.secondary,
                  onTap: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
