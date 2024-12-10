import 'package:flutter/material.dart';
import 'package:gailtrack/state/request/model.dart';
import 'package:gailtrack/state/request/service.dart';

class RequestProvider extends ChangeNotifier {
  List<Request> _requestList = [];
  bool _isLoading = false;
  String? _error;

  List<Request> get requestList => _requestList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadRequests() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _requestList = await fetchRequests();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
