import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../screens/clock.dart';
import '../state/user/model.dart';
import '../state/user/service.dart';

class WorkingController extends GetxController {
  // Database instance
  late Database _database;
  final RxBool _isDatabaseInitialized = false.obs;

  // API endpoints
  static String API_URL = dotenv.env['API_URL']?.trim() ?? "https://gailtrack-api.onrender.com";
  static  String _checkInUrl = API_URL + '/checkin';
  static  String _checkOutUrl = API_URL + '/checkout';

  // User ID (currently hardcoded to 1)
  // static const int _userId = 1;
  final Rx<User?> _currentUser = Rx<User?>(null);
  User? get currentUser => _currentUser.value;

  @override
  void onInit() async {
    super.onInit();
    await _initDatabase();

    try {
      _currentUser.value = await fetchUser();
    } catch (e) {
      debugPrint('Error fetching user: $e');
      _currentUser.value = null;
    }
  }

  // Initialize SQLite database for working hours tracking
  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'dbworking10.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE working (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid_firebase TEXT NOT NULL,
            checkin TEXT,
            date TEXT,
            checkout TEXT
          )
        ''');
      },
    );

    _isDatabaseInitialized.value = true;
  }

  // Check and perform check-in when user enters polygon
  Future<void> performCheckIn(bool isInPolygon) async {
    if (!_isDatabaseInitialized.value || !isInPolygon || _currentUser.value == null) return;

    try {
      final now = DateTime.now();
      final currentDate = DateFormat('yyyy-MM-dd').format(now);
      final currentTime = ClockService().getFormattedTime();

      final existingCheckIns = await _database.query(
        'working',
        where: 'uuid_firebase = ? AND date = ? AND checkout IS NULL',
        whereArgs: [_currentUser.value!.uuidFirebase, currentDate],
      );

      if (existingCheckIns.isEmpty) {
        await _sendCheckInToServer(currentTime, currentDate);
        await _database.insert('working', {
          'uuid_firebase': _currentUser.value!.uuidFirebase,
          'checkin': currentTime,
          'date': currentDate,
          'checkout': null,
        });

        debugPrint('Check-in performed at $currentTime on $currentDate');
      }
    } catch (e) {
      debugPrint('Error performing check-in: $e');
    }
  }

  // Send check-in to server
  Future<void> _sendCheckInToServer(String checkInTime, String date) async {
    if (_currentUser.value == null) return;

    try {
      final response = await http.post(
        Uri.parse(_checkInUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uuid_firebase': _currentUser.value!.uuidFirebase,
          'checkin': checkInTime,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Check-in sent to server successfully');
      } else {
        debugPrint('Failed to send check-in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending check-in to server: $e');
    }
  }

  // Perform check-out when user leaves polygon
  Future<void> performCheckOut(bool isInPolygon) async {
    if (!_isDatabaseInitialized.value || isInPolygon || _currentUser.value == null) return;

    try {
      final now = DateTime.now();
      final currentDate = DateFormat('yyyy-MM-dd').format(now);
      final currentTime = ClockService().getFormattedTime();

      final existingCheckIns = await _database.query(
        'working',
        where: 'uuid_firebase = ? AND date = ? AND checkout IS NULL',
        whereArgs: [_currentUser.value!.uuidFirebase, currentDate],
        orderBy: 'id DESC',
        limit: 1,
      );

      if (existingCheckIns.isNotEmpty) {
        final checkInRecord = existingCheckIns.first;
        final checkInId = checkInRecord['id'] as int;

        await _sendCheckOutToServer(currentTime, currentDate);

        await _database.delete(
          'working',
          where: 'id = ?',
          whereArgs: [checkInId],
        );
      }
    } catch (e) {
      debugPrint('Error performing check-out: $e');
    }
  }

  // Send check-out to server
  Future<void> _sendCheckOutToServer(String checkOutTime, String date) async {
    if (_currentUser.value == null) return;

    try {
      await http.post(
        Uri.parse(_checkOutUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uuid_firebase': _currentUser.value!.uuidFirebase,
          'checkout': checkOutTime,
        }),
      );
    } catch (e) {
      debugPrint('Error sending check-out to server: $e');
    }
  }


  @override
  void onClose() {
    _database.close();
    super.onClose();
  }
}