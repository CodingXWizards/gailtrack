import 'package:flutter/material.dart';
import 'package:gailtrack/state/tasks/model.dart';
import 'package:gailtrack/state/tasks/provider.dart';
import 'package:intl/intl.dart';
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
    List<Task> taskList = Provider.of<TaskProvider>(context).taskList;

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
                        style: Theme.of(context).textTheme.bodySmall)
                  ]),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text("Today's Tasks", style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        if (taskList.isNotEmpty)
          ...taskList.map(
            (task) => BoxContainer(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(0),
              child: ListTile(
                title: Text(
                  task.task,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                subtitle: Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text:
                              "${DateFormat("dd MMM yyyy").format(task.deadline)}\n"),
                      TextSpan(
                          text: DateFormat("hh:mm a").format(task.deadline)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (taskList.isEmpty)
          const Center(
            child: Text("No Tasks Alotted"),
          )
      ],
    );
  }
}
