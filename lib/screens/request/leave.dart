import 'package:flutter/material.dart';

class RequestLeave extends StatefulWidget {
  const RequestLeave({super.key});

  @override
  State<RequestLeave> createState() => _RequestLeaveState();
}

class _RequestLeaveState extends State<RequestLeave> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Offsite Leave",
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      body: const Center(
        child: Text("Request Leave Page"),
      ),
    );
  }
}
