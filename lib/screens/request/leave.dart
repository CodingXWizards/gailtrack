import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gailtrack/components/my_button.dart';
import 'package:gailtrack/state/user/model.dart';
import 'package:gailtrack/state/user/provider.dart';

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
              Text(
                "User",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: user.displayName,
                decoration: InputDecoration(
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Theme.of(context).dividerColor)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Theme.of(context).dividerColor)),
                ),
                items: [
                  DropdownMenuItem(
                    value: user.displayName,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/profile.jpg'),
                          radius: 16,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          user.displayName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                "Title",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: "Title of the leave",
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Theme.of(context).dividerColor)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Theme.of(context).dividerColor)),
                ),
              ),
              const SizedBox(height: 16),

              // Label
              Text(
                "Label",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedLabel,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Theme.of(context).dividerColor)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Theme.of(context).dividerColor)),
                ),
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

              // SelectDate
              Text(
                "Select Date",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDateRange = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 1, color: Theme.of(context).dividerColor)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 1, color: Theme.of(context).dividerColor)),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  ),
                  child: Text(
                    selectedDateRange == null
                        ? 'Aug 1, 2024 - Aug 13, 2024' // Default
                        : '${selectedDateRange!.start.toString().split(' ')[0]} - ${selectedDateRange!.end.toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reason
              Text(
                "Reason",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: "I want to take an urgent leave from the office...",
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Theme.of(context).dividerColor)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Theme.of(context).dividerColor)),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: MyButton(
                      text: "Request a leave",
                      bgColor: Theme.of(context).colorScheme.surface,
                      textColor: Theme.of(context).focusColor,
                      onTap: () {}),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
