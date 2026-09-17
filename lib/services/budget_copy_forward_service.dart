import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/database/drift_database.dart';
import 'package:expense_tracker_mobile/utils/logger.dart';
import 'package:drift/drift.dart' as drift;

class BudgetCopyForwardService {
  /// Checks if budgets have been copied forward up to the current month.
  /// Iterates through any un-copied months sequentially, respecting tombstone rows
  /// (budgets with null amounts).
  static Future<void> checkAndCopyBudgets() async {
    try {
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();

      int? lastYear = prefs.getInt('last_budget_copy_year');
      int? lastMonth = prefs.getInt('last_budget_copy_month');

      final allBudgets = await DataService.getAllBudgets();

      if (lastYear == null || lastMonth == null) {
        if (allBudgets.isEmpty) {
          // If no budgets exist at all, just mark the current month as processed and exit.
          await prefs.setInt('last_budget_copy_year', now.year);
          await prefs.setInt('last_budget_copy_month', now.month);
          return;
        }

        // Find the earliest budget entry to start from
        allBudgets.sort((a, b) {
          if (a.year != b.year) return a.year.compareTo(b.year);
          return a.month.compareTo(b.month);
        });

        lastYear = allBudgets.first.year;
        lastMonth = allBudgets.first.month;
      }

      DateTime currentIter = DateTime(lastYear, lastMonth);
      final targetEnd = DateTime(now.year, now.month);

      if (!currentIter.isBefore(targetEnd)) {
        return; // Already up to date
      }

      AppLogger.info(
        'Starting budget copy forward from ${currentIter.month}/${currentIter.year} up to ${now.month}/${now.year}',
      );

      int totalCopied = 0;

      // Iterate month by month up to the current month
      while (currentIter.isBefore(targetEnd)) {
        final prevYear = currentIter.year;
        final prevMonth = currentIter.month;
        
        // Next month
        currentIter = DateTime(currentIter.year, currentIter.month + 1);
        final targetYear = currentIter.year;
        final targetMonth = currentIter.month;

        // Fetch current snapshot in each loop to ensure we aren't copying old data if it got updated
        final dbBudgets = await DataService.getAllBudgets();

        final sourceBudgets = dbBudgets
            .where((b) => b.year == prevYear && b.month == prevMonth)
            .toList();
            
        final destBudgets = dbBudgets
            .where((b) => b.year == targetYear && b.month == targetMonth)
            .toList();

        for (var sourceBudget in sourceBudgets) {
          // Only copy forward if it is NOT a tombstone (amount != null)
          if (sourceBudget.amount != null) {
            final existsInDest = destBudgets.any((b) =>
                b.type == sourceBudget.type &&
                b.categoryId == sourceBudget.categoryId &&
                b.cardId == sourceBudget.cardId);

            if (!existsInDest) {
              final companion = BudgetsCompanion(
                month: drift.Value(targetMonth),
                year: drift.Value(targetYear),
                type: drift.Value(sourceBudget.type),
                categoryId: drift.Value(sourceBudget.categoryId),
                cardId: drift.Value(sourceBudget.cardId),
                amount: drift.Value(sourceBudget.amount),
              );
              await DataService.upsertBudget(companion);
              totalCopied++;
            }
          }
        }

        // Mark this month as completed
        await prefs.setInt('last_budget_copy_year', currentIter.year);
        await prefs.setInt('last_budget_copy_month', currentIter.month);
      }

      if (totalCopied > 0) {
        AppLogger.info('Successfully copied forward $totalCopied budgets.');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to run budget copy forward service', e, stackTrace);
    }
  }
}
