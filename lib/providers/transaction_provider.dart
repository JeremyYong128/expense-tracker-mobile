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
    int? creditCardId,
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
      creditCardId: creditCardId,
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
