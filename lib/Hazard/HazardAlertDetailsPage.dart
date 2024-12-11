import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HazardDetailsPage extends StatefulWidget {
  final String hazard;
  final String department;
  final int duration; // Total duration in seconds
  final DateTime alertTime; // Time when the alert was originally sent

  const HazardDetailsPage({
    Key? key,
    required this.hazard,
    required this.department,
    required this.duration,
    required this.alertTime,
  }) : super(key: key);

  @override
  _HazardDetailsPageState createState() => _HazardDetailsPageState();
}

class _HazardDetailsPageState extends State<HazardDetailsPage> {
  late int _remainingDuration;

  @override
  void initState() {
    super.initState();

    // Calculate remaining duration based on the original alert time
    final DateTime now = DateTime.now();
    final Duration elapsedTime = now.difference(widget.alertTime);

    // Calculate remaining duration
    _remainingDuration = widget.duration - elapsedTime.inSeconds;

    // Ensure remaining duration is not negative
    _remainingDuration = _remainingDuration < 0 ? 0 : _remainingDuration;

    // Start countdown timer
    startCountdown();
  }

  void startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _remainingDuration--;
        });

        if (_remainingDuration > 0) {
          startCountdown();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Hazard Alert Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hazard Section
            const Text(
              'Hazard:',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.hazard,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

            // Department Section
            const Text(
              'Department:',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.department,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

            // Time Received Section
            const Text(
              'Time:',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.alertTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

            // Remaining Duration Section
            const Text(
              'Duration:',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_remainingDuration seconds',
                style: TextStyle(
                  color: _remainingDuration <= 10 ? Colors.red : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper method to show the hazard details page
void showHazardDetailsPage(BuildContext context, {
  required String hazard,
  required String department,
  required int duration,
  required DateTime alertTime, // Add this parameter
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => HazardDetailsPage(
        hazard: hazard,
        department: department,
        duration: duration,
        alertTime: alertTime,
      ),
    ),
  );
}