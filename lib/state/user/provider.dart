import 'package:flutter/material.dart';
import 'package:gailtrack/state/user/model.dart';
import 'package:gailtrack/state/user/service.dart';

class UserProvider extends ChangeNotifier {
  User _user = User.noUser();
  bool _isLoading = false;
  String? _error;

  User get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await fetchUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
