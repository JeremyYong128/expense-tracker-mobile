import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  
  bool _isLowerCaps = true;
  bool _useUsEnglish = false;

  bool get isLowerCaps => _isLowerCaps;
  bool get useUsEnglish => _useUsEnglish;

  UserPreferencesProvider(this._prefs) {
    _isLowerCaps = _prefs.getBool('isLowerCaps') ?? true;
    _useUsEnglish = _prefs.getBool('useUsEnglish') ?? false;
  }

  void toggleLowerCaps(bool value) {
    if (_isLowerCaps != value) {
      _isLowerCaps = value;
      _prefs.setBool('isLowerCaps', value);
      notifyListeners();
    }
  }
  
  void toggleUsEnglish(bool value) {
    if (_useUsEnglish != value) {
      _useUsEnglish = value;
      _prefs.setBool('useUsEnglish', value);
      notifyListeners();
    }
  }
}
