import 'package:flutter/material.dart';

class Attendace extends StatefulWidget {
  const Attendace({super.key});

  @override
  State<Attendace> createState() => _AttendaceState();
}

class _AttendaceState extends State<Attendace> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Attendace Page"),
    );
  }
}
