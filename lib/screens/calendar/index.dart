import 'package:flutter/material.dart';
import 'package:gailtrack/state/attendance/model.dart';
import 'package:gailtrack/state/attendance/provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    // Get the working data
    List<Working> workingList =
        Provider.of<WorkingProvider>(context, listen: false).working;

    // Filter working sessions for the selected day
    List<Working> getWorkingForDay(DateTime day) {
      return workingList
          .where((working) => isSameDay(working.date, day))
          .toList();
    }

    List<Working> selectedDayWorkingList =
        getWorkingForDay(_selectedDay ?? _focusedDay);

    // Function to calculate the total working hours for the day
    String calculateTotalWorkingHours(List<Working> workingList) {
      if (workingList.isEmpty) return '---';

      Duration totalDuration = Duration();

      for (var working in workingList) {
        if (working.checkIn.isEmpty) continue;

        DateTime checkIn = DateFormat('HH:mm').parse(working.checkIn);
        DateTime checkOut =
            working.checkOut != null && working.checkOut!.isNotEmpty
                ? DateFormat('HH:mm').parse(working.checkOut!)
                : DateTime.now(); // If check-out is null, use current time

        totalDuration += checkOut.difference(checkIn);
      }

      int hours = totalDuration.inHours;
      int minutes = totalDuration.inMinutes % 60;
      return '${hours > 0 ? '$hours h ' : ''}${minutes > 0 ? '$minutes m' : ''}';
    }

    // Prepare the table data for both selected and focused days
    List<Map<String, String>> tableData = [
      {
        "label": "Date",
        "value": DateFormat('dd MMM yyyy').format(_focusedDay),
      },
      {
        "label": "Check-In",
        "value": selectedDayWorkingList.isNotEmpty
            ? selectedDayWorkingList.first.checkIn.substring(0, 5)
            : "---",
      },
      {
        "label": "Check-Out",
        "value": selectedDayWorkingList.isNotEmpty
            ? selectedDayWorkingList.last.checkOut?.substring(0, 5) ?? "---"
            : "---",
      },
      {
        "label": "Working Hours",
        "value": calculateTotalWorkingHours(selectedDayWorkingList),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Calendar",
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            availableGestures: AvailableGestures.all,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Theme.of(context).dividerColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Table(
              children: tableData
                  .map(
                    (Map<String, String> data) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(data["label"] ?? ""),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            data["value"] ?? "",
                            textAlign: TextAlign.right,
                          ),
                        )
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
          const Spacer(), // Added to push the location to the bottom
          Padding(
  padding: const EdgeInsets.symmetric(vertical: 16.0),
  child: Text(
    "NIT Srinagar",
    style: Theme.of(context).textTheme.titleSmall?.copyWith(
      // Change to a more visible color - using black or a contrasting color
      color: Colors.white, // or Theme.of(context).primaryColor
      fontWeight: FontWeight.w500,
    ),
  ),
),
        ],
      ),
    );
  }
}
