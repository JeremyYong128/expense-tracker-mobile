import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_preferences_provider.dart';

extension StringCasing on String {
  String cased(BuildContext context) {
    try {
      final isLower = Provider.of<UserPreferencesProvider>(context).isLowerCaps;
      return isLower ? toLowerCase() : this;
    } catch (e) {
      // Fallback in case provider is not found
      return toLowerCase();
    }
  }
}
