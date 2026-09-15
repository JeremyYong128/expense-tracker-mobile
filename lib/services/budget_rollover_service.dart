import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/database/drift_database.dart';
import 'package:expense_tracker_mobile/utils/logger.dart';
import 'package:drift/drift.dart' as drift;

class BudgetRolloverService {
  /// Checks if the budget rollover has occurred for the current month.
  /// If not, it copies forward the budgets from the most recent previous month.
  static Future<void> checkAndRolloverBudgets() async {
    try {
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      final rolloverKey = 'budget_rollover_${now.year}_${now.month}';

      if (prefs.getBool(rolloverKey) == true) {
        return; // Already rolled over for this month
      }

      AppLogger.info('Running budget rollover for ${now.month}/${now.year}');

      final allBudgets = await DataService.getAllBudgets();

      // Separate budgets into "current month" and "past months"
      final currentMonthBudgets = <Budget>[];
      final pastBudgets = <Budget>[];

      for (var budget in allBudgets) {
        if (budget.year == now.year && budget.month == now.month) {
          currentMonthBudgets.add(budget);
        } else if (budget.year < now.year ||
            (budget.year == now.year && budget.month < now.month)) {
          pastBudgets.add(budget);
        }
      }

      // If we have past budgets, find the most recent past month
      if (pastBudgets.isNotEmpty) {
        // Sort past budgets descending by date
        pastBudgets.sort((a, b) {
          if (a.year != b.year) return b.year.compareTo(a.year);
          return b.month.compareTo(a.month);
        });

        final mostRecentYear = pastBudgets.first.year;
        final mostRecentMonth = pastBudgets.first.month;

        // Get all budgets from that specific most recent month
        final budgetsToRollover = pastBudgets
            .where(
              (b) => b.year == mostRecentYear && b.month == mostRecentMonth,
            )
            .toList();

        int rolloverCount = 0;

        for (var pastBudget in budgetsToRollover) {
          // Check if it already exists in the current month to avoid overwriting
          final existsInCurrent = currentMonthBudgets.any(
            (b) =>
                b.type == pastBudget.type &&
                b.categoryId == pastBudget.categoryId &&
                b.cardId == pastBudget.cardId,
          );

          if (!existsInCurrent && pastBudget.amount != null) {
            final companion = BudgetsCompanion(
              month: drift.Value(now.month),
              year: drift.Value(now.year),
              type: drift.Value(pastBudget.type),
              categoryId: drift.Value(pastBudget.categoryId),
              cardId: drift.Value(pastBudget.cardId),
              amount: drift.Value(pastBudget.amount),
              enableRollover: drift.Value(pastBudget.enableRollover),
            );
            await DataService.upsertBudget(companion);
            rolloverCount++;
          }
        }

        AppLogger.info(
          'Successfully rolled over $rolloverCount budgets from $mostRecentMonth/$mostRecentYear.',
        );
      } else {
        AppLogger.info('No past budgets found to rollover.');
      }

      // Mark rollover as complete for this month
      await prefs.setBool(rolloverKey, true);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to run budget rollover service', e, stackTrace);
    }
  }
}
