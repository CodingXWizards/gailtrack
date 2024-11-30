import 'package:flutter/material.dart';

class RequestOffsite extends StatefulWidget {
  const RequestOffsite({super.key});

  @override
  State<RequestOffsite> createState() => _RequestOffsiteState();
}

class _RequestOffsiteState extends State<RequestOffsite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Offsite Request",
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      body: const Center(
        child: Text("Request Offsite Page"),
      ),
    );
  }
}
