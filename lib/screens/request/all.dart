import 'package:flutter/material.dart';

class RequestAll extends StatefulWidget {
  const RequestAll({super.key});

  @override
  State<RequestAll> createState() => RequestAllState();
}

class RequestAllState extends State<RequestAll> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "All Requests",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        body: const Padding(padding: EdgeInsets.all(16.0)));
  }
}
