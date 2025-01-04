import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gailtrack/state/user/model.dart';
import 'package:gailtrack/state/user/provider.dart';
import 'package:gailtrack/state/attendance/model.dart';
import 'package:gailtrack/state/attendance/provider.dart';
import 'package:gailtrack/screens/home/components/custom_card.dart';
import 'package:gailtrack/screens/home/wrappers/box_container.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Method to calculate total working time for today
  String getTotalWorkingTime(List<Working> workingList) {
    Duration totalDuration = Duration.zero;

    for (var working in workingList) {
      if (isToday(working.date)) {
        final checkInTime = DateTime.parse(
            '${working.date.toIso8601String().split('T')[0]}T${working.checkIn}');
        DateTime checkOutTime;

        if (working.checkOut == null || working.checkOut!.isEmpty) {
          checkOutTime = DateTime.now();
        } else {
          checkOutTime = DateTime.parse(
              '${working.date.toIso8601String().split('T')[0]}T${working.checkOut!}');
        }

        totalDuration += checkOutTime.difference(checkInTime);
      }
    }

    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;

    return (hours > 0) ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, WorkingProvider>(
      builder: (context, userProvider, workingProvider, child) {
        User user = userProvider.user;
        List<Working> workingList = workingProvider.working;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: BoxContainer(
                    child: Column(
                      children: [
                        Text(
                          "Checked-in",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          workingList.isNotEmpty &&
                                  workingList.last.checkIn.isNotEmpty
                              ? workingList.last.checkIn.substring(0, 5)
                              : "---",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BoxContainer(
                    child: Column(
                      children: [
                        Text(
                          "Checked-out",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          workingList.isNotEmpty &&
                                  (workingList.last.checkOut?.isNotEmpty ??
                                      false)
                              ? workingList.last.checkOut!.substring(0, 5)
                              : "---",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BoxContainer(
              child: Column(
                children: [
                  Text(
                    "Working Hours Today",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    getTotalWorkingTime(workingList),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomCard(
              title: user.userType == UserType.hr
                  ? "Check Requests"
                  : "Offsite Work",
              description: user.userType == UserType.hr
                  ? "You can check your employee requests take action upon it."
                  : "You can request to work offsite if you're unable to come in.",
              buttonText: user.userType == UserType.hr
                  ? "Requests"
                  : "Request Offsite Work",
              imagePath: "assets/images/bg1.png",
              onPressed: () => Navigator.of(context).pushNamed(
                user.userType == UserType.hr
                    ? "/request/all"
                    : "/request/offsite",
              ),
            ),
            const SizedBox(height: 32),
            CustomCard(
              title: "Request a leave or HalfDay",
              description:
                  "You can request a leave from work to your superiors.",
              buttonText: "Request a leave",
              imagePath: "assets/images/bg1.png",
              onPressed: () => Navigator.pushNamed(context, '/request/leave'),
            ),
            const SizedBox(height: 32),
            if (user.userType == UserType.hr)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () =>
                    Navigator.pushNamed(context, '/request/members'),
                child: Text(
                  "Manage Members",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
          ],
        );
      },
    );
  }
}
