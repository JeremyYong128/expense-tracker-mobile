import 'package:flutter/material.dart' hide Card;
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/models/card.dart';
import 'package:provider/provider.dart';
import '../../utils/business_logic.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/card_form.dart';
import 'package:expense_tracker_mobile/ui/widgets/dialogs/confirmation_dialog.dart';
import 'package:expense_tracker_mobile/providers/card_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_list.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/month_selector_toggle.dart';
import 'package:expense_tracker_mobile/services/snackbar_service.dart';
import 'package:expense_tracker_mobile/utils/logger.dart';

class CardDetailsScreen extends StatefulWidget {
  final Card card;

  const CardDetailsScreen({super.key, required this.card});

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _showAddEditDialog(Card card) {
    SlideUpModal.showCustom(
      context: context,
      builder: (context) => CardForm(card: card),
    );
  }

  void _confirmDelete(Card card) {
    final transactionProvider = context.read<TransactionProvider>();
    final recurringProvider = context.read<RecurringTransactionProvider>();

    final hasTransactions = transactionProvider.transactions.any(
      (t) => t.cardId == card.id,
    );
    final hasRecurring = recurringProvider.transactions.any(
      (r) => r.cardId == card.id,
    );

    if (!hasTransactions && !hasRecurring) {
      ConfirmationDialog.show(
        context: context,
        title: 'Delete Card',
        content: '${card.name} will be permanently deleted. Continue?',
        confirmText: 'Delete',
        isDestructive: true,
        onConfirm: () async {
          final navigator = Navigator.of(context);
          final provider = context.read<CardProvider>();
          final txProvider = context.read<TransactionProvider>();
          final recProvider = context.read<RecurringTransactionProvider>();

          try {
            final affected = await provider.deleteCard(
              card.id!,
              forceHardDelete: true,
            );
            if (affected) {
              await txProvider.fetchTransactions();
              await recProvider.fetchRecurringTransactions();
            }
            SnackBarService.showSuccess('Card deleted successfully');
          } catch (e, stack) {
            AppLogger.error('Failed to delete card', e, stack);
            SnackBarService.showError('An unexpected error occurred.');
          }

          if (mounted) {
            navigator.pop(); // Close details screen
          }
        },
      );
      return;
    }

    ConfirmationDialog.show(
      context: context,
      title: 'Delete Card',
      content: 'You have transactions that use this card. Archive instead?',
      confirmText: 'Delete',
      isDestructive: true,
      onConfirm: () {
        ConfirmationDialog.show(
          context: context,
          title: 'Permanently Delete?',
          content:
              'Deleting this card removes the card association from these transactions.',
          confirmText: 'Delete',
          isDestructive: true,
          onConfirm: () async {
            final innerNavigator = Navigator.of(context);
            final provider = context.read<CardProvider>();
            final txProvider = context.read<TransactionProvider>();
            final recProvider = context.read<RecurringTransactionProvider>();

            try {
              final affected = await provider.deleteCard(
                card.id!,
                forceHardDelete: true,
              );
              if (affected) {
                await txProvider.fetchTransactions();
                await recProvider.fetchRecurringTransactions();
              }
              SnackBarService.showSuccess('Card deleted successfully');
            } catch (e, stack) {
              AppLogger.error('Failed to delete card', e, stack);
              SnackBarService.showError('An unexpected error occurred.');
            }

            if (mounted) {
              innerNavigator.pop(); // Close details screen
            }
          },
        );
      },
      secondaryActionText: 'Archive',
      onSecondaryAction: () async {
        final navigator = Navigator.of(context);
        final provider = context.read<CardProvider>();

        try {
          await provider.deleteCard(card.id!, forceHardDelete: false);
          SnackBarService.showSuccess('Card archived successfully');
        } catch (e, stack) {
          AppLogger.error('Failed to archive card', e, stack);
          SnackBarService.showError('An unexpected error occurred.');
        }

        if (mounted) {
          navigator.pop(); // Close details screen
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final cardProvider = context.watch<CardProvider>();

    final latestCard = cardProvider.cards.firstWhere(
      (c) => c.id == widget.card.id,
      orElse: () => widget.card,
    );

    if (transactionProvider.isLoading || categoryProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(latestCard.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final allTransactions = transactionProvider.transactions
        .where((t) => t.cardId == latestCard.id)
        .toList();
    allTransactions.sort((a, b) => b.date.compareTo(a.date));

    final transactionsList = allTransactions.where((t) {
      return t.date.year == _selectedMonth.year &&
          t.date.month == _selectedMonth.month;
    }).toList();

    // Calculate total rewards and expense
    double totalRewardsAmount = 0;
    double totalExpense = 0;
    for (var tx in transactionsList) {
      if (!tx.isIncome) {
        totalExpense += tx.amount;
        if (tx.rewardAmount != null) {
          totalRewardsAmount += tx.rewardAmount!;
        }
      }
    }

    final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    final prevTransactionsList = allTransactions.where((t) {
      return t.date.year == prevMonth.year && t.date.month == prevMonth.month;
    }).toList();

    double prevExpense = 0;
    double prevRewardsAmount = 0;
    for (var tx in prevTransactionsList) {
      if (!tx.isIncome) {
        prevExpense += tx.amount;
        if (tx.rewardAmount != null) {
          prevRewardsAmount += tx.rewardAmount!;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(latestCard.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.white),
            onPressed: () => _showAddEditDialog(latestCard),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.white),
            onPressed: () => _confirmDelete(latestCard),
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
              _buildDigitalCard(latestCard),
              if (allTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0, bottom: 32.0),
                  child: Text(
                    'No expenses tagged to this card.'.cased(context),
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 16,
                    ),
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
                _buildMonthlySummary(latestCard, totalExpense, totalRewardsAmount, prevExpense, prevRewardsAmount),
                const SizedBox(height: 24),
                if (transactionsList.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Expenses'.cased(context),
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
                      'No expenses tagged to this card for this month.'.cased(context),
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

  IconData _getIconForRewardType(String rewardType) {
    switch (rewardType.toLowerCase()) {
      case 'cashback':
        return Icons.attach_money;
      case 'miles':
        return Icons.flight_takeoff;
      case 'points':
        return Icons.stars;
      case 'none':
      default:
        return Icons.credit_card;
    }
  }

  String _getRewardSubtitle(BuildContext context, Card card) {
    final type = card.rewardType.toLowerCase();
    if (type == 'none') return 'No rewards'.cased(context);
    final rateStr = card.rewardRate == card.rewardRate.toInt()
        ? card.rewardRate.toInt().toString()
        : card.rewardRate.toStringAsFixed(1);
    if (type == 'cashback') return '$rateStr% Cashback'.cased(context);
    if (type == 'miles') return '$rateStr Miles per \$'.cased(context);
    if (type == 'points') return '$rateStr Points per \$'.cased(context);
    return '$rateStr ${card.rewardType.cased(context)}';
  }

  Widget _buildDigitalCard(Card card) {
    final color = AppColors.getColorFromHex(card.colorHex);
    final iconData = _getIconForRewardType(card.rewardType);
    final subtitle = _getRewardSubtitle(context, card);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppStyles.cardRadius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  card.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(iconData, color: AppColors.white, size: 32),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(
    Card card,
    double totalExpense,
    double totalRewardsAmount,
    double prevExpense,
    double prevRewardsAmount,
  ) {
    final isCashback = card.rewardType == 'Cashback';
    final rewardText = isCashback
        ? '\$${totalRewardsAmount.toStringAsFixed(2)}'
        : NumberFormat('#,##0.##').format(totalRewardsAmount);

    final expenseDiff = BusinessLogic.calculateAbsoluteDifference(totalExpense, prevExpense);
    final isExpenseGood = expenseDiff <= 0;
    final expenseChangeColor = isExpenseGood ? AppColors.income : AppColors.expense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppStyles.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Monthly Spending'.cased(context),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${totalExpense.abs().toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (expenseDiff != 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        expenseDiff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: expenseChangeColor,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '\$${expenseDiff.abs().toStringAsFixed(2)} vs last month',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (card.rewardType.toLowerCase() != 'none') ...[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Monthly Rewards'.cased(context),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rewardText,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
