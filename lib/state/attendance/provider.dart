import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:gailtrack/state/attendance/model.dart';
import 'package:gailtrack/state/attendance/service.dart';

class WorkingProvider extends ChangeNotifier {
  List<Working> _working = [];
  bool _isLoading = false;
  String? _error;
  late IO.Socket _socket;

  List<Working> get working => _working;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WorkingProvider() {
    _initializeSocket();
    loadWorking();
  }

  void _initializeSocket() {
    _socket = IO.io('${dotenv.env['API_URL']?.trim()}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print('Connected to WebSocket');
    });

    _socket.on('newcheck', (data) {
      try {
        // Check if the data is a list, extract the first item
        final eventData = (data is List && data.isNotEmpty)
            ? data.first as Map<String, dynamic>
            : data as Map<String, dynamic>;

        print('New check-in received: $eventData');
        _processNewCheckIn(eventData);
      } catch (e) {
        print('Error processing new check-in: $e');
      }
    });

    _socket.onDisconnect((_) => print('Disconnected from WebSocket'));
  }

  void _processNewCheckIn(Map<String, dynamic> eventData) {
    try {
      final newEntry = Working.fromJson(eventData);

      // Print for debugging to ensure the check-out data is received
      print('Received check-out data: ${newEntry.checkOut}');

      // Update the existing entry if it matches, otherwise add a new one
      final existingIndex =
          _working.indexWhere((entry) => entry.id == newEntry.id);
      if (existingIndex != -1) {
        _working[existingIndex] = newEntry;
        print('Updated existing entry with ID: ${newEntry.id}');
      } else {
        _working.add(newEntry);
        print('Added new entry with ID: ${newEntry.id}');
      }

      notifyListeners();
    } catch (e) {
      print('Error adding new entry: $e');
    }
  }

  void loadWorking() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _working = await fetchWorking();
      print("Loaded working entries: ${_working.length}");
    } catch (e) {
      _error = e.toString();
      print("Error loading working entries: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
