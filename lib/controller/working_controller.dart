import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WorkingController extends GetxController {
  // Database instance
  late Database _database;
  final RxBool _isDatabaseInitialized = false.obs;

  // API endpoints
  static const String _checkInUrl = 'https://gailtrack-api.onrender.com/checkin';
  static const String _checkOutUrl = 'https://gailtrack-api.onrender.com/checkout';

  // User ID (currently hardcoded to 1)
  static const int _userId = 1;

  @override
  void onInit() async {
    super.onInit();
    await _initDatabase();
  }

  // Initialize SQLite database for working hours tracking
  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'workingdb1.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE working (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            checkin TEXT,
            date TEXT,
            checkout TEXT
          )
        ''');
      },
    );

    _isDatabaseInitialized.value = true;
    print('Working database initialized');
  }

  // Check and perform check-in when user enters polygon
  Future<void> performCheckIn(bool isInPolygon) async {
    if (!_isDatabaseInitialized.value || !isInPolygon) return;

    try {
      // Get current date and time
      final now = DateTime.now();
      final currentDate = DateFormat('yyyy-dd-MM').format(now);
      final currentTime = DateFormat('HH:mm:ss').format(now);

      // Check if there's an existing unclosed check-in for today
      final existingCheckIns = await _database.query(
        'working',
        where: 'user_id = ? AND date = ? AND checkout IS NULL',
        whereArgs: [_userId, currentDate],
      );

      // If no existing unclosed check-in, perform check-in
      if (existingCheckIns.isEmpty) {
        // Insert new check-in record
        final checkInId = await _database.insert('working', {
          'user_id': _userId,
          'checkin': currentTime,
          'date': currentDate,
          'checkout': null,
        });

        // Send check-in to API
        await _sendCheckInToServer(currentTime, currentDate);

        print('Check-in performed at $currentTime on $currentDate');
      }
    } catch (e) {
      print('Error performing check-in: $e');
    }
  }

  // Send check-in to server
  Future<void> _sendCheckInToServer(String checkInTime, String date) async {
    try {
      final response = await http.post(
        Uri.parse(_checkInUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId.toString(),
          'checkin': checkInTime,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        print('Check-in sent to server successfully');
      } else {
        print('Failed to send check-in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending check-in to server: $e');
    }
  }

  // Perform check-out when user leaves polygon
  Future<void> performCheckOut(bool isInPolygon) async {
    if (!_isDatabaseInitialized.value || isInPolygon) return;

    try {
      // Get current date and time
      final now = DateTime.now();
      final currentDate = DateFormat('yyyy-dd-MM').format(now);
      final currentTime = DateFormat('HH:mm:ss').format(now);

      // Find the latest unclosed check-in for today
      final existingCheckIns = await _database.query(
        'working',
        where: 'user_id = ? AND date = ? AND checkout IS NULL',
        whereArgs: [_userId, currentDate],
        orderBy: 'id DESC',
        limit: 1,
      );

      // If an unclosed check-in exists, perform check-out
      if (existingCheckIns.isNotEmpty) {
        final checkInRecord = existingCheckIns.first;
        final checkInId = checkInRecord['id'] as int;

        // Update the record with checkout time
        await _database.update(
          'working',
          {'checkout': currentTime},
          where: 'id = ?',
          whereArgs: [checkInId],
        );

        // Send check-out to API
        await _sendCheckOutToServer(currentTime, currentDate);

        print('Check-out performed at $currentTime on $currentDate');
      }
    } catch (e) {
      print('Error performing check-out: $e');
    }
  }

  // Send check-out to server
  Future<void> _sendCheckOutToServer(String checkOutTime, String date) async {
    try {
      final response = await http.post(
        Uri.parse(_checkOutUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId.toString(),
          'checkout': checkOutTime,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        print('Check-out sent to server successfully');
      } else {
        print('Failed to send check-out. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending check-out to server: $e');
    }
  }

  @override
  void onClose() {
    _database.close();
    super.onClose();
  }
}