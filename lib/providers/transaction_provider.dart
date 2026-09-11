import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/transaction.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  TransactionProvider() {
    fetchTransactions();
  }

  DateTime get oldestTransactionMonth {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    if (_transactions.isEmpty) return currentMonth;

    DateTime oldest = _transactions.first.date;
    for (var tx in _transactions) {
      if (tx.date.isBefore(oldest)) {
        oldest = tx.date;
      }
    }

    final oldestMonth = DateTime(oldest.year, oldest.month);
    return oldestMonth.isBefore(currentMonth) ? oldestMonth : currentMonth;
  }

  DateTime get newestTransactionMonth {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    if (_transactions.isEmpty) return currentMonth;

    DateTime newest = _transactions.first.date;
    for (var tx in _transactions) {
      if (tx.date.isAfter(newest)) {
        newest = tx.date;
      }
    }

    final newestMonth = DateTime(newest.year, newest.month);
    return newestMonth.isAfter(currentMonth) ? newestMonth : currentMonth;
  }

  Future<void> fetchTransactions() async {
    _transactions = await DataService.getTransactions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction({
    required String amountText,
    required String title,
    required DateTime date,
    required int categoryId,
    required bool isIncome,
    required bool isRecurring,
    required String recurringIntervalText,
    required String recurringPeriod,
    required String note,
    int? cardId,
    int? recurringId,
    double? rewardAmount,
  }) async {
    await DataService.addTransaction(
      amountText: amountText,
      title: title,
      date: date,
      categoryId: categoryId,
      isIncome: isIncome,
      isRecurring: isRecurring,
      recurringIntervalText: recurringIntervalText,
      recurringPeriod: recurringPeriod,
      note: note,
      cardId: cardId,
      recurringId: recurringId,
      rewardAmount: rewardAmount,
    );
    await fetchTransactions();
  }

  Future<void> updateTransaction(Transaction tx) async {
    await DataService.updateTransaction(tx);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DataService.deleteTransaction(id);
    await fetchTransactions();
  }
}
