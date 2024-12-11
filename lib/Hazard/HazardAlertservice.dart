import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'hazardalertsoundplayer.dart';

class HazardAlertService {
  static final HazardAlertService _instance = HazardAlertService._internal();
  factory HazardAlertService() => _instance;

  HazardAlertService._internal();

  late io.Socket _socket;
  final HazardAlertSoundPlayer _soundPlayer = HazardAlertSoundPlayer();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void initialize(String socketUrl) {
    // Socket initialization remains the same
    _socket = io.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.on('connect', (_) {
      debugPrint('Socket Connected');
    });

    _socket.on('disconnect', (_) {
      debugPrint('Socket Disconnected');
    });

    _socket.on('hazard_alert', (data) {
      _handleHazardAlert(data);
    });

    _initializeNotifications();
  }

  void _initializeNotifications() {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS
    );

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _handleHazardAlert(dynamic data) {
    final String hazard = data['hazard'] ?? 'Unknown Hazard';
    final String department = data['department'] ?? 'Unknown Department';
    final bool sound = data['sound'] ?? false;
    final int duration = data['duration'] ?? 60;

    _showIrremovableNotification(hazard, department, duration);

    if (sound) {
      _playSoundAlert(duration);
    }
  }

  void _showIrremovableNotification(String hazard, String department, int duration) async {
    // Prepare payload as a JSON string
    final DateTime alertTime = DateTime.now();

    // Prepare payload as a JSON string
    final String payloadString = jsonEncode({
      'hazard': hazard,
      'department': department,
      'duration': duration,
      'alertTime': alertTime.toIso8601String(),
    });

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'hazard_channel',
      'Hazard Alerts',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      color: Colors.red,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      actions: [],
    );

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // Show the irremovable notification with payload
    await _flutterLocalNotificationsPlugin.show(
      0,
      'CRITICAL HAZARD ALERT',
      'Hazard: $hazard\nDepartment Concerned: $department',
      platformChannelSpecifics,
      payload: payloadString,
    );

    // Automatically cancel notification after specified duration
    Future.delayed(Duration(minutes: duration), () {
      _flutterLocalNotificationsPlugin.cancel(0);
    });
  }

  void _playSoundAlert(int duration) async {
    _soundPlayer.playAlertSound(soundFilePath: 'assets/hazard_alert.wav',duration: 30,loop: true);
  }

  void dispose() {
    _socket.dispose();
    _soundPlayer.dispose();
    _flutterLocalNotificationsPlugin.cancelAll();
  }
}

// Optional: Full-screen Blocking Notification Widget
class HazardAlertScreen extends StatelessWidget {
  final String hazard;
  final String department;
  final int duration;

  const HazardAlertScreen({
    super.key,
    required this.hazard,
    required this.department,
    required this.duration
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back button
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 100
              ),
              Text(
                'CRITICAL HAZARD ALERT',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Hazard: $hazard',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18
                ),
              ),
              Text(
                'Department Concerned: $department',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18
                ),
              ),
              SizedBox(height: 20),
              // Optional: Countdown timer
              StreamBuilder(
                stream: Stream.periodic(
                    Duration(seconds: 1),
                        (x) => duration - x - 1
                ).take(duration),
                builder: (context, snapshot) {
                  return Text(
                    'Alert will clear in: ${snapshot.data ?? duration} seconds',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}