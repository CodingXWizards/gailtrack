import 'package:flutter/material.dart';
import 'package:gailtrack/state/tasks/model.dart';
import 'package:gailtrack/state/tasks/service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _taskList = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get taskList => _taskList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadtasks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _taskList = await fetchTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
