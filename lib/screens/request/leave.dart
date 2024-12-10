import 'package:flutter/material.dart';
import 'package:gailtrack/components/input.dart';
import 'package:gailtrack/state/request/model.dart';
import 'package:gailtrack/state/request/service.dart';
import 'package:gailtrack/state/user/model.dart';
import 'package:gailtrack/state/user/provider.dart';
import 'package:intl/intl.dart';

import 'package:gailtrack/components/my_button.dart';
import 'package:provider/provider.dart';

class RequestLeave extends StatefulWidget {
  const RequestLeave({super.key});

  @override
  State<RequestLeave> createState() => _RequestLeaveState();
}

class _RequestLeaveState extends State<RequestLeave> {
  String selectedLabel = 'Medical Leave';
  DateTimeRange? selectedDateRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user;

    TextEditingController titleController = TextEditingController();
    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();
    TextEditingController reasonController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Offsite Leave",
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Input(
                label: "Title",
                placeholder: "Title of the leave",
                controller: titleController,
              ),
              const SizedBox(height: 16),
              Text(
                "Label",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedLabel,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          width: 1, color: Theme.of(context).dividerColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          width: 1, color: Theme.of(context).dividerColor)),
                ),
                borderRadius: BorderRadius.circular(12),
                items: [
                  DropdownMenuItem(
                    value: 'Medical Leave',
                    child: Text('Medical Leave',
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  DropdownMenuItem(
                    value: 'Casual Leave',
                    child: Text('Casual Leave',
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  DropdownMenuItem(
                    value: 'Earned Leave',
                    child: Text('Earned Leave',
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child: Text('Other',
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedLabel = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Input(
                label: "Start Date",
                placeholder: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                controller: startDateController,
                onDateSelected: (selectedDate) {
                  if (selectedDate.isBefore(DateTime.now())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          content: Text(
                            "Start date cannot be earlier than today.",
                            style:
                                TextStyle(color: Theme.of(context).focusColor),
                          )),
                    );
                  } else {
                    startDateController.text =
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                    endDateController.text =
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                  }
                },
                type: FieldType.date,
              ),
              const SizedBox(height: 16),
              Input(
                label: "End Date",
                placeholder: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                controller: endDateController,
                onDateSelected: (selectedDate) {
                  final startDate = startDateController.text.isNotEmpty
                      ? DateFormat("dd/MM/yyyy").parse(startDateController.text)
                      : null;

                  if (startDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          content: Text(
                            "Please select a start date first.",
                            style:
                                TextStyle(color: Theme.of(context).focusColor),
                          )),
                    );
                  } else if (selectedDate.isBefore(startDate)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          content: Text(
                            "End date cannot be earlier than the start date.",
                            style:
                                TextStyle(color: Theme.of(context).focusColor),
                          )),
                    );
                  } else {
                    endDateController.text =
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                  }
                },
                type: FieldType.date,
              ),
              const SizedBox(height: 16),
              Input(
                label: "Reason",
                placeholder:
                    "I want to take an urgent leave from the office...",
                controller: reasonController,
                type: FieldType.textarea,
              ),
              const SizedBox(height: 32),
              MyButton(
                  width: double.infinity,
                  text: "Request a leave",
                  onTap: () async {
                    try {
                      // Parse dates from the controllers
                      final startDate = DateFormat("dd/MM/yyyy")
                          .parse(startDateController.text);
                      final endDate = DateFormat("dd/MM/yyyy")
                          .parse(endDateController.text);

                      // Create the request object
                      Request req = Request(
                        id: 1, // Replace with a valid unique ID
                        label: selectedLabel,
                        reason: reasonController.text,
                        startDate: startDate,
                        endDate: endDate,
                        uuidFirebase: user.uuidFirebase,
                      );

                      // Call the postRequest function
                      await postRequest(req);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Leave request sent successfully."),
                        ),
                      );
                      Navigator.of(context).pop();

                      // Clear the form
                      titleController.clear();
                      startDateController.clear();
                      endDateController.clear();
                      reasonController.clear();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          content: Text(
                            "Failed to send leave request: $e",
                            style:
                                TextStyle(color: Theme.of(context).focusColor),
                          ),
                        ),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
