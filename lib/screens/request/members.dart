import 'package:flutter/material.dart';

class RequestMembers extends StatefulWidget {
  const RequestMembers({super.key});

  @override
  State<RequestMembers> createState() => RequestMembersState();
}

class RequestMembersState extends State<RequestMembers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Manage Members",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        body: const Padding(padding: EdgeInsets.all(16.0)));
  }
}
