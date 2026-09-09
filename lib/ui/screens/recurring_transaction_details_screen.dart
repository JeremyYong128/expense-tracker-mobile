import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/business_logic.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/models/recurring_transaction.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/providers/analytics_provider.dart';
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
import 'package:expense_tracker_mobile/utils/logger.dart';

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

  void _confirmDelete(RecurringTransaction tx) async {
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

          try {
            await provider.deleteRecurringTransaction(tx.id!);
            SnackBarService.showSuccess('Recurring transaction deleted successfully');
          } catch (e, stack) {
            AppLogger.error('Failed to delete recurring transaction', e, stack);
            SnackBarService.showError('An unexpected error occurred.');
          }

          if (mounted) {
            navigator.pop();
          }
        },
      );
    } else {
      final navigator = Navigator.of(context);
      final provider = context.read<RecurringTransactionProvider>();

      try {
        await provider.deleteRecurringTransaction(tx.id!);
        SnackBarService.showSuccess('Recurring transaction deleted successfully');
        if (mounted) {
          navigator.pop();
        }
      } catch (e, stack) {
        AppLogger.error('Failed to delete recurring transaction', e, stack);
        SnackBarService.showError('An unexpected error occurred.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final recurringProvider = context.watch<RecurringTransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final cardProvider = context.watch<CardProvider>();

    final latestTx = recurringProvider.getRecurringTransactionById(widget.recurringTransaction.id) 
        ?? widget.recurringTransaction;

    if (transactionProvider.isLoading ||
        recurringProvider.isLoading ||
        categoryProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(latestTx.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final category = categoryProvider.getCategoryById(widget.recurringTransaction.categoryId) ?? Category(
        name: 'Unknown',
        colorHex: '#9E9E9E',
        iconString: null,
        isActive: true,
      );

    final latestCard = latestTx.cardId != null
        ? cardProvider.getCardById(latestTx.cardId)
        : null;

    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    final stats = analyticsProvider.getRecurringStats(latestTx.id!, _selectedMonth);

    final allTransactions = stats.allRecurringTransactions;
    final transactionsList = stats.currentMonthTransactions;
    final totalIncome = stats.totalIncome;
    final totalExpense = stats.totalExpense;
    final prevBalance = stats.prevBalance;

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
              _buildRecurringHeader(latestTx, category, latestCard),
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
    final sign = isPositive ? '+' : (isNegative ? '-' : '');

    final diff = BusinessLogic.calculateAbsoluteDifference(balance, prevBalance);
    final isGood = diff >= 0;
    final changeColor = isGood ? AppColors.income : AppColors.expense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppStyles.cardRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Monthly Balance'.cased(context),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$sign\$${balance.abs().toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (diff != 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  diff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: changeColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '\$${diff.abs().toStringAsFixed(2)} vs last month',
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
        borderRadius: BorderRadius.circular(AppStyles.cardRadius),
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
