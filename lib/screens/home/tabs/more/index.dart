import 'package:flutter/material.dart';
import 'package:gailtrack/screens/home/wrappers/box_container.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  List<Map<String, dynamic>> settings = [
    {"name": "Profile", "path": "/profile"},
    {"name": "Info", "path": "/info"},
    {"name": "Manage members", "path": "/manage-members"},
    {"name": "Report", "path": "/report"},
    {"name": "Support", "path": "/support"},
    {"name": "Change Language", "path": "/change-language"},
    {"name": "Restrictions", "path": "/restrictions"},
    {"name": "SOS", "path": "/sos"},
    {"name": "Logout", "path": "/logout"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: settings
          .map((setting) => BoxContainer(
                margin: const EdgeInsets.only(bottom: 12),
                child: Text(
                  setting['name'],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ))
          .toList(),
    );
  }
}
