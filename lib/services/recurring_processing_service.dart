import 'package:expense_tracker_mobile/models/transaction.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/utils/logger.dart';

class RecurringProcessingService {
  /// Fetches all recurring transactions whose nextDueDate has passed
  static Future<List<Transaction>> getPendingApprovals() async {
    final allRecurring = await DataService.getRecurringTransactions();
    final now = DateTime.now();
    List<Transaction> pendingInstances = [];

    for (var tx in allRecurring) {
      var currentDueDate = tx.nextDueDate;
      while (currentDueDate.isBefore(now) ||
          currentDueDate.isAtSameMomentAs(now)) {
        pendingInstances.add(
          Transaction(
            amount: tx.amount,
            title: tx.title,
            date: currentDueDate,
            categoryId: tx.categoryId,
            note: tx.note,
            isIncome: tx.isIncome,
            recurringId: tx.id,
            creditCardId: tx.creditCardId,
            rewardAmount: tx.rewardAmount,
          ),
        );

        currentDueDate = DataService.calculateNextDueDate(
          currentDueDate,
          tx.interval,
          tx.period,
        );
      }
    }

    // Sort by due date (oldest first)
    pendingInstances.sort((a, b) => a.date.compareTo(b.date));

    if (pendingInstances.isNotEmpty) {
      AppLogger.info(
        'Found ${pendingInstances.length} pending recurring transactions to process.',
      );
    }

    return pendingInstances;
  }

  /// Approves the transaction: Inserts it into history and advances the nextDueDate of the recurring one.
  static Future<void> approveTransaction(Transaction pendingTx) async {
    // 1. Insert into history
    await DataService.insertTransaction(pendingTx);

    // 2. Advance the next due date for the recurring template
    await _advanceNextDueDate(pendingTx);
  }

  /// Rejects the transaction: Does not insert it into history, but still advances the nextDueDate so it doesn't keep prompting.
  static Future<void> rejectTransaction(Transaction pendingTx) async {
    await _advanceNextDueDate(pendingTx);
  }

  static Future<void> _advanceNextDueDate(Transaction pendingTx) async {
    if (pendingTx.recurringId == null) return;

    final template = await DataService.getRecurringTransactionById(
      pendingTx.recurringId!,
    );
    if (template == null) return;

    final newDueDate = DataService.calculateNextDueDate(
      pendingTx.date,
      template.interval,
      template.period,
    );

    await DataService.updateRecurringTransactionNextDueDate(
      template.id!,
      newDueDate,
    );
  }
}
