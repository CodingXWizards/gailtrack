import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void onInit() async {
    super.onInit();
    await _initDatabase();
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
    if (!_isDatabaseInitialized.value || !isInPolygon) return;

    try {
      // Get current date and time
      final now = DateTime.now();
      final currentDate = DateFormat('yyyy-MM-dd').format(now);
      final currentTime = DateFormat('HH:mm:ss').format(now);

      // Check if there's an existing unclosed check-in for today
        User _userId = await fetchUser();

        final existingCheckIns = await _database.query(
          'working',
          where: 'uuid_firebase = ? AND date = ? AND checkout IS NULL',
          whereArgs: [_userId.uuidFirebase, currentDate],
        );

        // If no existing unclosed check-in, perform check-in
        if (existingCheckIns.isEmpty) {
          // Insert new check-in record
          await _sendCheckInToServer(currentTime, currentDate);
          final checkInId = await _database.insert('working', {
            'uuid_firebase': _userId.uuidFirebase,
            'checkin': currentTime,
            'date': currentDate,
            'checkout': null,
          });

          // Send check-in to API


          debugPrint('Check-in performed at $currentTime on $currentDate');
        }

    } catch (e) {
      debugPrint('Error performing check-in: $e');
    }
  }

  // Send check-in to server
  Future<void> _sendCheckInToServer(String checkInTime, String date) async {
    try {
        User user = await fetchUser();
      final response = await http.post(
        Uri.parse(_checkInUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uuid_firebase': user.uuidFirebase,
          'checkin': checkInTime,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Check-in sent to server successfully');
      } else {
        debugPrint('Failed to send check-in. Status code: ${response.statusCode}');
        return;
      }
    } catch (e) {
      debugPrint('Error sending check-in to server: $e');
    }
  }

  // Perform check-out when user leaves polygon
  Future<void> performCheckOut(bool isInPolygon) async {
    if (!_isDatabaseInitialized.value || isInPolygon) return;

    try {
      User user = await fetchUser();
      String _userId = user.uuidFirebase;
      // Get current date and time
      final now = DateTime.now();
      final currentDate = DateFormat('yyyy-MM-dd').format(now);
      final currentTime = DateFormat('HH:mm:ss').format(now);

      // Find the latest unclosed check-in for today
      final existingCheckIns = await _database.query(
        'working',
        where: 'uuid_firebase = ? AND date = ? AND checkout IS NULL',
        whereArgs: [_userId, currentDate],
        orderBy: 'id DESC',
        limit: 1,
      );

      // If an unclosed check-in exists, perform check-out
      if (existingCheckIns.isNotEmpty) {
        final checkInRecord = existingCheckIns.first;
        final checkInId = checkInRecord['id'] as int;

        // Send check-out to API first
        await _sendCheckOutToServer(currentTime, currentDate);

        // Delete the check-in row after successful check-out
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
    try {
      User user = await fetchUser();
      String _userId = user.uuidFirebase;
      final response = await http.post(
        Uri.parse(_checkOutUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uuid_firebase': _userId.toString(),
            'checkout': checkOutTime,
          // 'date': date,
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