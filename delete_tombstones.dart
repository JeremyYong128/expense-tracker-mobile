import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker_mobile/database/drift_database.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase(NativeDatabase.memory()); // We need the actual DB path
}
