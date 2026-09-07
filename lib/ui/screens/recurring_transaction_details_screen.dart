import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/models/recurring_transaction.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/card_provider.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/dialogs/confirmation_dialog.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_list.dart';
import 'package:expense_tracker_mobile/ui/widgets/month_selector_toggle.dart';
import 'package:expense_tracker_mobile/services/snackbar_service.dart';

class RecurringTransactionDetailsScreen extends StatefulWidget {
  final RecurringTransaction recurringTransaction;

  const RecurringTransactionDetailsScreen({
    super.key,
    required this.recurringTransaction,
  });

  @override
  State<RecurringTransactionDetailsScreen> createState() =>
      _RecurringTransactionDetailsScreenState();
}

class _RecurringTransactionDetailsScreenState
    extends State<RecurringTransactionDetailsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _showAddEditDialog(RecurringTransaction tx) {
    SlideUpModal.showCustom(
      context: context,
      builder: (context) => TransactionModal(recurringTransaction: tx),
    );
  }

  void _confirmDelete(RecurringTransaction tx) {
    final transactionProvider = context.read<TransactionProvider>();
    final hasTransactions = transactionProvider.transactions.any(
      (t) => t.recurringId == tx.id,
    );

    if (hasTransactions) {
      ConfirmationDialog.show(
        context: context,
        title: 'Delete Recurring Transaction?',
        content:
            'Existing transactions linked to this recurring transaction will not be affected.',
        confirmText: 'Delete',
        isDestructive: true,
        onConfirm: () async {
          final navigator = Navigator.of(context);
          final provider = context.read<RecurringTransactionProvider>();

          await provider.deleteRecurringTransaction(tx.id!);
          SnackBarService.showSuccess('Recurring transaction deleted successfully');

          if (mounted) {
            navigator.pop();
          }
        },
      );
    } else {
      final navigator = Navigator.of(context);
      final provider = context.read<RecurringTransactionProvider>();

      provider.deleteRecurringTransaction(tx.id!).then((_) {
        SnackBarService.showSuccess('Recurring transaction deleted successfully');
        if (mounted) {
          navigator.pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final recurringProvider = context.watch<RecurringTransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final cardProvider = context.watch<CardProvider>();

    final latestTx = recurringProvider.transactions.firstWhere(
      (c) => c.id == widget.recurringTransaction.id,
      orElse: () => widget.recurringTransaction,
    );

    if (transactionProvider.isLoading ||
        recurringProvider.isLoading ||
        categoryProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(latestTx.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final category = categoryProvider.categories.firstWhere(
      (c) => c.id == latestTx.categoryId,
      orElse: () => Category(
        name: 'Unknown',
        colorHex: '#9E9E9E',
        iconString: null,
        isActive: true,
      ),
    );

    final card = latestTx.cardId != null
        ? cardProvider.cards.where((c) => c.id == latestTx.cardId).firstOrNull
        : null;

    final allTransactions = transactionProvider.transactions
        .where((t) => t.recurringId == latestTx.id)
        .toList();
    allTransactions.sort((a, b) => b.date.compareTo(a.date));

    final transactionsList = allTransactions.where((t) {
      return t.date.year == _selectedMonth.year &&
          t.date.month == _selectedMonth.month;
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    for (var tx in transactionsList) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    final prevTransactionsList = allTransactions.where((t) {
      return t.date.year == prevMonth.year && t.date.month == prevMonth.month;
    }).toList();

    double prevIncome = 0;
    double prevExpense = 0;
    for (var tx in prevTransactionsList) {
      if (tx.isIncome) {
        prevIncome += tx.amount;
      } else {
        prevExpense += tx.amount;
      }
    }
    double prevBalance = prevIncome - prevExpense;

    return Scaffold(
      appBar: AppBar(
        title: Text(latestTx.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.white),
            onPressed: () => _showAddEditDialog(latestTx),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.white),
            onPressed: () => _confirmDelete(latestTx),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: SingleChildScrollView(
          padding: AppStyles.screenPadding,
          child: Column(
            children: [
              _buildRecurringHeader(latestTx, category, card),
              if (allTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0, bottom: 32.0),
                  child: Text(
                    'No transactions yet.'.cased(context),
                    style: const TextStyle(color: AppColors.grey, fontSize: 16),
                  ),
                )
              else ...[
                const SizedBox(height: 16),
                MonthSelectorToggle(
                  selectedMonth: _selectedMonth,
                  transactions: allTransactions,
                  onMonthChanged: (newMonth) {
                    setState(() {
                      _selectedMonth = newMonth;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildMonthlySummary(totalIncome, totalExpense, prevBalance),
                const SizedBox(height: 24),
                if (transactionsList.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Transactions'.cased(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                if (transactionsList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 32.0),
                    child: Text(
                      'No transactions for this month.'.cased(context),
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TransactionList(transactions: transactionsList),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(
    double totalIncome,
    double totalExpense,
    double prevBalance,
  ) {
    final balance = totalIncome - totalExpense;
    final isPositive = balance > 0;
    final isNegative = balance < 0;
    final color = AppColors.textPrimary;
    final sign = isPositive ? '+' : (isNegative ? '-' : '');

    double? percentageChange;
    if (prevBalance != 0) {
      percentageChange = ((balance - prevBalance) / prevBalance.abs()) * 100;
    } else if (balance != 0) {
      percentageChange = 100.0;
    }

    bool isGood = false;
    if (percentageChange != null) {
      isGood = percentageChange >= 0;
    }
    Color changeColor = isGood ? AppColors.income : AppColors.expense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Monthly Balance'.cased(context).toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$sign\$${balance.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (percentageChange != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  percentageChange == 0
                      ? Icons.horizontal_rule
                      : (percentageChange > 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward),
                  size: 16,
                  color: percentageChange == 0
                      ? AppColors.textSecondary
                      : changeColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${percentageChange.abs().toStringAsFixed(1)}% from previous month',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecurringHeader(
    RecurringTransaction tx,
    Category category,
    dynamic card,
  ) {
    final color = AppColors.getColorFromHex(category.colorHex);

    String rewardText = '';
    if (tx.rewardAmount != null && tx.rewardAmount! > 0) {
      if (card != null) {
        if (card.rewardType == 'Cashback') {
          rewardText = '\$${tx.rewardAmount!.toStringAsFixed(2)} cashback';
        } else if (card.rewardType == 'Miles') {
          rewardText = '${tx.rewardAmount!.toStringAsFixed(0)} miles';
        } else if (card.rewardType == 'Points') {
          rewardText = '${tx.rewardAmount!.toStringAsFixed(0)} points';
        } else {
          rewardText = '\$${tx.rewardAmount!.toStringAsFixed(2)}';
        }
      } else {
        rewardText = '\$${tx.rewardAmount!.toStringAsFixed(2)}';
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(category.iconData, color: color, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Amount'.cased(context).toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${tx.isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Due'.cased(context).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(tx.nextDueDate),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Repeats'.cased(context).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Every ${tx.interval} ${tx.period.toLowerCase().replaceAll('(s)', tx.interval == 1 ? '' : 's')}'
                          .cased(context),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (card != null || rewardText.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (card != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card'.cased(context).toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                const SizedBox(width: 16),
                if (rewardText.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rewards'.cased(context).toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rewardText,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ],
          if (tx.note != null && tx.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note'.cased(context).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tx.note!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
