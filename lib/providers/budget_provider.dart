import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/database/drift_database.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:drift/drift.dart' as drift;

class BudgetProvider extends ChangeNotifier {
  List<Budget> _activeBudgets = [];

  List<Budget> get activeBudgets => _activeBudgets;

  BudgetProvider() {
    // Load for current month by default
    final now = DateTime.now();
    loadBudgetsForMonth(now.month, now.year);
  }

  Future<void> loadBudgetsForMonth(int targetMonth, int targetYear) async {
    // Fetch only the requested month's budgets directly from SQLite (ignoring tombstones)
    _activeBudgets = await DataService.getBudgetsForMonth(
      targetMonth,
      targetYear,
    );

    notifyListeners();
  }

  Future<void> setBudget({
    required int targetMonth,
    required int targetYear,
    required String type,
    int? categoryId,
    int? cardId,
    required double amount,
  }) async {
    final existing = await DataService.getBudget(
      month: targetMonth,
      year: targetYear,
      type: type,
      categoryId: categoryId,
      cardId: cardId,
    );

    final companion = BudgetsCompanion(
      id: existing != null
          ? drift.Value(existing.id)
          : const drift.Value.absent(),
      month: drift.Value(targetMonth),
      year: drift.Value(targetYear),
      type: drift.Value(type),
      categoryId: drift.Value(categoryId),
      cardId: drift.Value(cardId),
      amount: drift.Value(amount),
    );
    await DataService.upsertBudget(companion);



    // Reload active budgets for the current view
    await loadBudgetsForMonth(targetMonth, targetYear);
  }


  Future<List<Budget>> getBudgetHistoryForCategory(int categoryId) async {
    final allBudgets = await DataService.getAllBudgets();

    allBudgets.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.month.compareTo(a.month);
    });

    return allBudgets.where((b) => b.categoryId == categoryId).toList();
  }

  Future<List<Budget>> getBudgetHistoryForCard(int cardId) async {
    final allBudgets = await DataService.getAllBudgets();

    allBudgets.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.month.compareTo(a.month);
    });

    return allBudgets.where((b) => b.cardId == cardId).toList();
  }

  Future<void> deleteBudget(Budget budget) async {
    await DataService.deleteBudgetRow(budget.id);

    await loadBudgetsForMonth(budget.month, budget.year);
  }
}
