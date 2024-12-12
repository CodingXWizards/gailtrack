import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gailtrack/screens/home/wrappers/box_container.dart';
import 'package:intl/intl.dart'; // For formatting time

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  final _storage = const FlutterSecureStorage();

  List<Map<String, dynamic>> settings = [
    {"name": "Profile", "path": "/profile"},
    {"name": "Info", "path": "/info"},
    {"name": "Manage members", "path": "/manage-members"},
    {"name": "Report", "path": "/report"},
    {"name": "Support", "path": "/support"},
    {"name": "Change Language", "path": "/change-language"},
    {"name": "Restrictions", "path": "/restrictions"},
    {"name": "SOS", "path": "/sos"},
    {"name": "Logout", "path": "/logout"}
  ];

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  void onTap(String path) async {
    switch (path) {
      case "/logout":
        _storage.deleteAll();
        await FirebaseAuth.instance.signOut();
        WidgetsBinding.instance.addPostFrameCallback(
                (_) => Navigator.popAndPushNamed(context, '/signin'));
        break;
      case "/restrictions":
        _showTimeRestrictionDialog();
        break;
      default:
        return;
    }
  }

  void _showTimeRestrictionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Set Time Restrictions"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Start Time"),
                trailing: Text(startTime != null
                    ? DateFormat.jm().format(
                    DateTime(0, 0, 0, startTime!.hour, startTime!.minute))
                    : "Not set"),
                onTap: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (selectedTime != null) {
                    setState(() => startTime = selectedTime);
                  }
                },
              ),
              ListTile(
                title: const Text("End Time"),
                trailing: Text(endTime != null
                    ? DateFormat.jm().format(
                    DateTime(0, 0, 0, endTime!.hour, endTime!.minute))
                    : "Not set"),
                onTap: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (selectedTime != null) {
                    setState(() => endTime = selectedTime);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (startTime != null && endTime != null) {
                  _saveTimeRestrictions(startTime!, endTime!);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please set both times.")),
                  );
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _saveTimeRestrictions(TimeOfDay startTime, TimeOfDay endTime) {
    final start = "${startTime.hour}:${startTime.minute}";
    final end = "${endTime.hour}:${endTime.minute}";

    setState(() {
      this.startTime = startTime;
      this.endTime = endTime;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Time restrictions saved: $start - $end")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: settings
          .map((setting) => InkWell(
        onTap: () => onTap(setting['path']),
        child: BoxContainer(
          margin: const EdgeInsets.only(bottom: 12),
          child: Text(
            setting['name'],
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ))
          .toList(),
    );
  }
}