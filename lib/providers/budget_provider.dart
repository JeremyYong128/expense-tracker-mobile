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

    await _maintainTombstones(type, categoryId, cardId);

    // Reload active budgets for the current view
    await loadBudgetsForMonth(targetMonth, targetYear);
  }

  Future<void> _maintainTombstones(
    String type,
    int? categoryId,
    int? cardId,
  ) async {
    final allRows = await DataService.getBudgetsForEntity(
      type: type,
      categoryId: categoryId,
      cardId: cardId,
    );

    final validBudgets = allRows.where((b) => b.amount != null).toList();
    final existingTombstones = allRows.where((b) => b.amount == null).toList();

    // Determine required tombstones (months immediately following a valid budget that don't have a valid budget themselves)
    final requiredTombstones = <String>{};
    for (final vb in validBudgets) {
      final nextMonth = vb.month == 12 ? 1 : vb.month + 1;
      final nextYear = vb.month == 12 ? vb.year + 1 : vb.year;

      final hasValidNext = validBudgets.any(
        (b) => b.year == nextYear && b.month == nextMonth,
      );
      if (!hasValidNext) {
        requiredTombstones.add('${nextYear}_$nextMonth');
      }
    }

    // Delete existing tombstones that are no longer required
    for (final tb in existingTombstones) {
      final key = '${tb.year}_${tb.month}';
      if (!requiredTombstones.contains(key)) {
        await DataService.deleteBudgetRow(tb.id);
      }
    }

    // Insert required tombstones that don't exist yet
    for (final key in requiredTombstones) {
      final exists = existingTombstones.any(
        (tb) => '${tb.year}_${tb.month}' == key,
      );
      if (!exists) {
        final parts = key.split('_');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);

        final companion = BudgetsCompanion(
          month: drift.Value(month),
          year: drift.Value(year),
          type: drift.Value(type),
          categoryId: drift.Value(categoryId),
          cardId: drift.Value(cardId),
          amount: const drift.Value(null),
        );
        await DataService.upsertBudget(companion);
      }
    }
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
    await _maintainTombstones(budget.type, budget.categoryId, budget.cardId);
    await loadBudgetsForMonth(budget.month, budget.year);
  }
}
