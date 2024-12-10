import 'package:flutter/material.dart';
import 'package:gailtrack/utils/helper.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:gailtrack/state/user/model.dart';
import 'package:gailtrack/state/user/provider.dart';
import 'package:gailtrack/state/attendance/model.dart';
import 'package:gailtrack/state/attendance/provider.dart';
import 'package:gailtrack/screens/home/components/custom_card.dart';
import 'package:gailtrack/screens/home/wrappers/box_container.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user;
    List<Working> workingList = Provider.of<WorkingProvider>(context).working;
    Working latestWorking = workingList.isNotEmpty
        ? workingList.reduce((latest, current) =>
            current.date.isAfter(latest.date) ? current : latest)
        : Working.noWork();

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
                    Text(latestWorking.checkIn.substring(0, 5),
                        style: Theme.of(context).textTheme.titleMedium),
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
                    Text(latestWorking.checkOut.substring(0, 5),
                        style: Theme.of(context).textTheme.titleMedium),
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
                  workingList.isNotEmpty
                      ? getWorkingTimeForToday(workingList)
                      : "----",
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        const SizedBox(height: 32),
        CustomCard(
          title:
              user.userType == UserType.hr ? "Check Requests" : "Offisite Work",
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
          description: "You can request a leave from a work to your superiors.",
          buttonText: "Request a leave",
          imagePath: "assets/images/bg1.png",
          onPressed: () => Navigator.pushNamed(context, '/request/leave'),
        ),
        const SizedBox(height: 32),
        if (user.userType == UserType.hr)
          ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(Colors.white)),
              onPressed: () => Navigator.pushNamed(context, '/request/members'),
              child: Text(
                "Manage Members",
                style: Theme.of(context).textTheme.labelSmall,
              ))
      ],
    );
  }
}
