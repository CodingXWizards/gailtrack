import 'package:flutter/material.dart';
import 'package:gailtrack/state/attendance/model.dart';
import 'package:gailtrack/state/attendance/service.dart';

class WorkingProvider extends ChangeNotifier {
  List<Working> _working = [];
  bool _isLoading = false;
  String? _error;

  List<Working> get working => _working;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadWorking() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _working = await fetchWorking();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
