import '../models/transaction.dart';
import '../models/recurring_transaction.dart';
import '../models/category.dart';
import '../database/database_helper.dart';

class DataService {
  // --- Category Methods ---

  static Future<List<Category>> getCategories() async {
    return await DatabaseHelper.instance.getCategories();
  }

  static Future<int> addCategory(Category category) async {
    return await DatabaseHelper.instance.insertCategory(category);
  }

  static Future<int> updateCategory(Category category) async {
    return await DatabaseHelper.instance.updateCategory(category);
  }

  static Future<void> deleteCategory(int id) async {
    await DatabaseHelper.instance.deleteCategory(id);
  }

  // --- Transaction Methods ---

  static Future<void> addTransaction({
    required String amountText,
    required String title,
    required DateTime date,
    required Category? category,
    required bool isIncome,
    required bool isRecurring,
    required String recurringIntervalText,
    required String recurringPeriod,
    required String note,
  }) async {
    // 1. Validation
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      throw Exception('Please enter a valid amount greater than 0.');
    }

    if (title.trim().isEmpty) {
      throw Exception('Please enter a title.');
    }

    if (category == null || category.id == null) {
      throw Exception('Please select a valid category.');
    }

    if (isRecurring) {
      final recurringInterval = int.tryParse(recurringIntervalText);
      if (recurringInterval == null || recurringInterval <= 0) {
        throw Exception('Please enter a valid recurring interval.');
      }

      // Calculate next due date based on current selected date
      final nextDueDate = calculateNextDueDate(
        date,
        recurringInterval,
        recurringPeriod,
      );

      final transaction = RecurringTransaction(
        amount: amount,
        title: title.trim(),
        categoryId: category.id!,
        isIncome: isIncome,
        interval: recurringInterval,
        period: recurringPeriod,
        nextDueDate: nextDueDate,
        note: note.trim().isEmpty ? null : note.trim(),
      );

      await DatabaseHelper.instance.insertRecurringTransaction(transaction);
    } else {
      final transaction = Transaction(
        amount: amount,
        title: title.trim(),
        date: date,
        categoryId: category.id!,
        isIncome: isIncome,
        note: note.trim().isEmpty ? null : note.trim(),
      );

      await DatabaseHelper.instance.insertTransaction(transaction);
    }
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.updateTransaction(transaction);
  }

  static Future<List<Transaction>> getTransactions() async {
    return await DatabaseHelper.instance.getTransactions();
  }

  static Future<List<RecurringTransaction>> getRecurringTransactions() async {
    return await DatabaseHelper.instance.getRecurringTransactions();
  }

  static DateTime calculateNextDueDate(
    DateTime date,
    int interval,
    String period,
  ) {
    switch (period.toLowerCase()) {
      case 'day(s)':
        return date.add(Duration(days: interval));
      case 'week(s)':
        return date.add(Duration(days: interval * 7));
      case 'month(s)':
        int nextMonth = date.month + interval;
        int nextYear = date.year;
        while (nextMonth > 12) {
          nextMonth -= 12;
          nextYear++;
        }
        // Ensure day is valid for next month
        int nextDay = date.day;
        final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        if (nextDay > daysInNextMonth) {
          nextDay = daysInNextMonth;
        }
        return DateTime(nextYear, nextMonth, nextDay, date.hour, date.minute);
      case 'year(s)':
        // Ensure day is valid for next year (e.g. leap years)
        int nextYear = date.year + interval;
        int nextDay = date.day;
        final daysInNextMonth = DateTime(nextYear, date.month + 1, 0).day;
        if (nextDay > daysInNextMonth) {
          nextDay = daysInNextMonth;
        }
        return DateTime(nextYear, date.month, nextDay, date.hour, date.minute);
      default:
        return date.add(Duration(days: interval));
    }
  }
}
