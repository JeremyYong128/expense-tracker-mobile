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
    final allBudgets = await DataService.getAllBudgets();

    // With the copy-forward pattern, we strictly load only the requested month's budgets
    _activeBudgets = allBudgets
        .where(
          (b) =>
              b.year == targetYear &&
              b.month == targetMonth &&
              b.amount != null,
        )
        .toList();

    notifyListeners();
  }

  Future<void> setBudget({
    required int targetMonth,
    required int targetYear,
    required String type,
    int? categoryId,
    int? cardId,
    required double? amount,
  }) async {
    // In SQLite, NULL != NULL, so the unique constraint on (month, year, type, categoryId, cardId)
    // doesn't prevent multiple rows if categoryId or cardId is null.
    // We must manually check for an existing row and supply its ID if it exists.
    final existing = await DataService.getBudget(
      month: targetMonth,
      year: targetYear,
      type: type,
      categoryId: categoryId,
      cardId: cardId,
    );

    // Upsert the primary budget row
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
    final now = DateTime.now();
    await loadBudgetsForMonth(now.month, now.year);
  }

  Future<List<Budget>> getBudgetHistoryForCategory(int categoryId) async {
    final allBudgets = await DataService.getAllBudgets();

    allBudgets.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.month.compareTo(a.month);
    });

    return allBudgets.where((b) => b.categoryId == categoryId).toList();
  }
}
