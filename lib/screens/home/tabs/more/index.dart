import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gailtrack/screens/home/wrappers/box_container.dart';

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

  void onTap(String path) async {
    switch (path) {
      case "/logout":
        _storage.deleteAll();
        await FirebaseAuth.instance.signOut();
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => Navigator.popAndPushNamed(context, '/signin'));
        break;
      default:
        return;
    }
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
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ))
          .toList(),
    );
  }
}
