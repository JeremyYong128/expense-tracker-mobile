import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:expense_tracker_mobile/models/transaction.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// A centralized logging facade.
/// This prevents tight coupling with any specific logging framework (like Firebase Crashlytics).
class AppLogger {
  /// Logs an informational message.
  static void info(String message) {
    if (kDebugMode) {
      developer.log('ℹ️ INFO: $message', name: 'AppLogger');
    } else {
      FirebaseCrashlytics.instance.log('INFO: $message');
    }
  }

  /// Logs an error and optional stack trace.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        '❌ ERROR: $message',
        name: 'AppLogger',
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      FirebaseCrashlytics.instance.recordError(
        error ?? Exception(message),
        stackTrace,
        reason: message,
      );
    }
  }

  /// Scrubs sensitive data from a transaction before logging
  static Map<String, dynamic> scrubTransaction(Transaction tx) {
    return {
      'id': tx.id,
      'amount': '[REDACTED]',
      'title': '[REDACTED]',
      'date': tx.date.toIso8601String(),
      'categoryId': tx.categoryId,
      'isIncome': tx.isIncome,
      'recurringId': tx.recurringId,
      'creditCardId': tx.creditCardId,
    };
  }
}
