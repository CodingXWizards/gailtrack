import 'package:flutter/material.dart';
import 'package:gailtrack/components/my_button.dart';
import 'package:gailtrack/screens/home/wrappers/box_container.dart';
import 'package:gailtrack/state/attendance/model.dart';
import 'package:gailtrack/state/attendance/provider.dart';
import 'package:gailtrack/state/user/model.dart';
import 'package:gailtrack/state/user/provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user;
    List<Working> workingList = Provider.of<WorkingProvider>(context).working;

    return SingleChildScrollView(
      child: Column(
        children: [
          BoxContainer(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                if (workingList.isNotEmpty)
                  ...workingList.map(
                    (working) => BoxContainer(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('d MMMM, yyyy').format(working.date),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                working.checkIn.substring(0, 5),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                working.checkOut?.substring(0, 5) ?? "---",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                if (workingList.isEmpty) const Text("No Attendance Found"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyButton(
                text: "Calendar",
                onTap: () => Navigator.pushNamed(context, '/calendar'),
              ),
              MyButton(
                text: "Report",
                onTap: () => Navigator.pushNamed(context, '/report'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
