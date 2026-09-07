import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';

class SnackBarService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {
    _showCustomSnackBar(message, AppColors.primary, Icons.check_circle);
  }

  static void showError(String message) {
    _showCustomSnackBar(message, AppColors.error, Icons.error_outline);
  }

  static void showInfo(String message) {
    _showCustomSnackBar(message, AppColors.primary, Icons.info_outline);
  }

  static String _getCasedMessage(String message) {
    final ctx = scaffoldMessengerKey.currentContext;
    final msg = ctx != null ? message.cased(ctx) : message;
    return msg;
  }

  static void _showCustomSnackBar(String message, Color color, IconData icon) {
    final msg = _getCasedMessage(message);

    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(msg, style: TextStyle(color: color)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(bottom: 90.0, left: 16.0, right: 16.0),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
