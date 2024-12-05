import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gailtrack/state/user/model.dart';
import 'package:gailtrack/components/avatar.dart';
import 'package:gailtrack/state/user/provider.dart';
import 'package:gailtrack/screens/home/wrappers/box_container.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Avatar(
              radius: 20,
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                  text: "${user.displayName}!\n",
                  style: Theme.of(context).textTheme.titleSmall,
                  children: [
                    TextSpan(
                        text: user.dept,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey))
                  ]),
            ),
            const Spacer(),
            const Icon(
              Icons.logout_rounded,
              size: 28,
            )
          ],
        ),
        const SizedBox(height: 28),
        Text("Today's Tasks", style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        const TaskCard(
          smallHead: "Remote",
          largeHead: "Prepare Presentation",
          time: "12:00 AM",
        ),
        const SizedBox(height: 20),
        const TaskCard(
          smallHead: "Remote",
          largeHead: "Write Video Script",
          time: "12:00 AM",
        ),
        const SizedBox(height: 20),
        const TaskCard(
          smallHead: "Remote",
          largeHead: "Check Figma Design",
          time: "12:00 AM",
        ),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  final String smallHead;
  final String largeHead;
  final String time;

  const TaskCard(
      {super.key,
      required this.smallHead,
      required this.largeHead,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return BoxContainer(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(smallHead,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
            Text(time,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey))
          ],
        ),
        const SizedBox(height: 12),
        Text(
          largeHead,
          style: Theme.of(context).textTheme.titleLarge,
        )
      ],
    ));
  }
}
