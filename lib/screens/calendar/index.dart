import 'package:flutter/material.dart';
import 'package:gailtrack/state/attendance/model.dart';
import 'package:gailtrack/state/attendance/provider.dart';
import 'package:gailtrack/utils/helper.dart';
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
    List<Working> workingList =
        Provider.of<WorkingProvider>(context, listen: false).working;
    Working latestWorking = workingList.isNotEmpty
        ? workingList.reduce((latest, current) =>
            current.date.isAfter(latest.date) ? current : latest)
        : Working.noWork();

    List<Map<String, String>> tableData = [
      {
        "label": "Date",
        "value": DateFormat('dd MMM yyyy').format(_focusedDay),
      },
      {
        "label": "Check-In",
        "value": latestWorking.checkIn.substring(0, 5),
      },
      {
        "label": "Check-Out",
        "value": latestWorking.checkOut?.substring(0, 5) ?? "---",
      },
      {
        "label": "Working Hours",
        "value": workingList.isNotEmpty
            ? getWorkingTimeForToday(workingList)
            : "----",
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
          )
        ],
      ),
    );
  }
}
