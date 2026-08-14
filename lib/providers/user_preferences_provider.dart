import 'package:flutter/material.dart';

class UserPreferencesProvider extends ChangeNotifier {
  bool _isLowerCaps = true;

  bool get isLowerCaps => _isLowerCaps;

  void toggleLowerCaps(bool value) {
    if (_isLowerCaps != value) {
      _isLowerCaps = value;
      notifyListeners();
    }
  }
}
