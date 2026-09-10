import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/recurring_transaction.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';

class RecurringTransactionProvider extends ChangeNotifier {
  List<RecurringTransaction> _transactions = [];
  bool _isLoading = true;

  List<RecurringTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  RecurringTransaction? getRecurringTransactionById(int? id) {
    if (id == null) return null;
    return _transactions.where((r) => r.id == id).firstOrNull;
  }

  RecurringTransactionProvider() {
    fetchRecurringTransactions();
  }

  Future<void> fetchRecurringTransactions() async {
    _transactions = await DataService.getRecurringTransactions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateRecurringTransaction(RecurringTransaction tx) async {
    await DataService.updateRecurringTransaction(tx);
    await fetchRecurringTransactions();
  }

  Future<void> deleteRecurringTransaction(int id) async {
    await DataService.deleteRecurringTransaction(id);
    await fetchRecurringTransactions();
  }

  void reorderTransaction(int oldIndex, int newIndex) {
    final item = _transactions.removeAt(oldIndex);
    _transactions.insert(newIndex, item);

    for (int i = 0; i < _transactions.length; i++) {
      _transactions[i] = _transactions[i].copyWith(sortOrder: i);
    }
    notifyListeners();
    DataService.updateRecurringTransactionsOrder(_transactions);
  }
}
