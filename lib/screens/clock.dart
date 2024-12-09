import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ClockApp extends StatelessWidget {
  const ClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Persistent Independent Clock"),
        ),
        body: const Center(
          child: IndependentClock(),
        ),
      ),
    );
  }
}

class IndependentClock extends StatefulWidget {
  const IndependentClock({super.key});

  @override
  State<IndependentClock> createState() => _IndependentClockState();
}

class _IndependentClockState extends State<IndependentClock> {
  late Timer _timer;
  late int _hours;
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _initializeClock();
  }

  Future<void> _initializeClock() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSavedTimestamp = prefs.getInt('lastSavedTimestamp');
    if (lastSavedTimestamp == null) {
      // Initialize with a custom starting time
      _hours = 12;
      _minutes = 0;
      _seconds = 0;
    } else {
      // Calculate the elapsed time since the app was closed
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - lastSavedTimestamp;
      final elapsedSeconds = (elapsed ~/ 1000) % 60;
      final elapsedMinutes = (elapsed ~/ 1000 ~/ 60) % 60;
      final elapsedHours = (elapsed ~/ 1000 ~/ 60 ~/ 60) % 24;

      _seconds = elapsedSeconds;
      _minutes = elapsedMinutes;
      _hours = elapsedHours;
    }

    _startClock();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _incrementTime();
      });
    });
  }

  Future<void> _saveClockState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastSavedTimestamp', DateTime.now().millisecondsSinceEpoch);
  }

  void _incrementTime() {
    _seconds++;
    if (_seconds >= 60) {
      _seconds = 0;
      _minutes++;
    }
    if (_minutes >= 60) {
      _minutes = 0;
      _hours++;
    }
    if (_hours >= 24) {
      _hours = 0;
    }
  }

  @override
  void dispose() {
    _saveClockState();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedTime(),
      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
    );
  }

  String _formattedTime() {
    return "${_hours.toString().padLeft(2, '0')}:${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}";
  }
}
