import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  String _title = "Login Screen";

  String get title => _title;

  void updateTitle(String newTitle) {
    _title = newTitle;
    notifyListeners(); //* Notify UI about changes
  }
}
