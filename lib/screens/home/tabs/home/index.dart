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

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, WorkingProvider>(
      builder: (context, userProvider, workingProvider, child) {
        User user = userProvider.user;
        List<Working> workingList = workingProvider.working;
        Working latestWorking = workingList.isNotEmpty
            ? workingList.reduce(
                (latest, current) => current.id > latest.id ? current : latest)
            : Working.noWork();

        bool isLatestWorkingToday = isToday(latestWorking.date);

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
                          isLatestWorkingToday &&
                                  latestWorking.checkIn.isNotEmpty
                              ? latestWorking.checkIn.substring(0, 5)
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
                          isLatestWorkingToday &&
                                  (latestWorking.checkOut?.isNotEmpty ?? false)
                              ? latestWorking.checkOut!.substring(0, 5)
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
                    "Working Hours",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    isLatestWorkingToday && workingList.isNotEmpty
                        ? (latestWorking.getCurrentWorkingDuration().inHours > 0
                            ? '${latestWorking.getCurrentWorkingDuration().inHours}h '
                                '${latestWorking.getCurrentWorkingDuration().inMinutes % 60}m'
                            : '${latestWorking.getCurrentWorkingDuration().inMinutes}m')
                        : "---",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomCard(
              title: user.userType == UserType.hr
                  ? "Check Requests"
                  : "Offisite Work",
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
                      : "/request/offsite"),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
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
