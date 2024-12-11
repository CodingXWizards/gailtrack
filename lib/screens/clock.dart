import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClockService {
  static final ClockService _instance = ClockService._internal();
  factory ClockService() => _instance;
  ClockService._internal();

  late Timer _timer;
  int _hours = 12;
  int _minutes = 0;
  int _seconds = 0;

  Future<void> initialize() async {
    await _initializeClock();
  }

  Future<void> _initializeClock() async {
    try {
      // Fetch time from the new API (timezonedb.com) for Kolkata
      final response = await http.get(Uri.parse('https://api.timezonedb.com/v2.1/get-time-zone?key=B7COYERF6GPP&format=json&by=zone&zone=Asia/Kolkata'))
          .timeout(const Duration(seconds: 10)); // Add a timeout

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Extract the formatted time string from the API response
        String formattedTime = data['formatted'];
        // Parse the datetime string into a DateTime object
        DateTime kolkataTime = DateTime.parse(formattedTime);

        // Set the initial time
        _hours = kolkataTime.hour;
        _minutes = kolkataTime.minute;
        _seconds = kolkataTime.second;
      } else {
        // Fallback to system time if API call fails
        _setSystemTime();
      }
    } catch (e) {
      // If any error occurs (network, parsing, etc.), use system time
      print('Error fetching time: $e');
      _setSystemTime();
    }

    _startClock();
  }

  void _setSystemTime() {
    // Use current system time
    DateTime now = DateTime.now();
    _hours = now.hour;
    _minutes = now.minute;
    _seconds = now.second;
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _incrementTime();
    });
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

  Future<void> _saveClockState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastSavedTimestamp', DateTime.now().millisecondsSinceEpoch);
  }

  String getFormattedTime() {
    return "${_hours.toString().padLeft(2, '0')}:" +
        "${_minutes.toString().padLeft(2, '0')}:" +
        "${_seconds.toString().padLeft(2, '0')}";
  }

  void dispose() {
    _saveClockState();
    _timer.cancel();
  }
}
