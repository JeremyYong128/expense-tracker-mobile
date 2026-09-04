import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/models/credit_card.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/credit_card_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/dialogs/confirmation_dialog.dart';
import 'package:expense_tracker_mobile/providers/credit_card_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_list.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/month_selector_toggle.dart';

class CreditCardDetailsScreen extends StatefulWidget {
  final CreditCard creditCard;

  const CreditCardDetailsScreen({super.key, required this.creditCard});

  @override
  State<CreditCardDetailsScreen> createState() =>
      _CreditCardDetailsScreenState();
}

class _CreditCardDetailsScreenState extends State<CreditCardDetailsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _showAddEditDialog(CreditCard card) {
    SlideUpModal.showCustom(
      context: context,
      builder: (context) => CreditCardModal(card: card),
    );
  }

  void _confirmDelete(CreditCard card) {
    final transactionProvider = context.read<TransactionProvider>();
    final recurringProvider = context.read<RecurringTransactionProvider>();

    final hasTransactions = transactionProvider.transactions.any(
      (t) => t.creditCardId == card.id,
    );
    final hasRecurring = recurringProvider.transactions.any(
      (r) => r.creditCardId == card.id,
    );

    if (!hasTransactions && !hasRecurring) {
      ConfirmationDialog.show(
        context: context,
        title: 'Delete Credit Card',
        content: '${card.name} will be permanently deleted. Continue?',
        confirmText: 'Delete',
        isDestructive: true,
        onConfirm: () async {
          final navigator = Navigator.of(context);
          final provider = context.read<CreditCardProvider>();
          final txProvider = context.read<TransactionProvider>();
          final recProvider = context.read<RecurringTransactionProvider>();

          final affected = await provider.deleteCreditCard(
            card.id!,
            forceHardDelete: true,
          );
          if (affected) {
            await txProvider.fetchTransactions();
            await recProvider.fetchRecurringTransactions();
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
      title: 'Delete Credit Card',
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
            final provider = context.read<CreditCardProvider>();
            final txProvider = context.read<TransactionProvider>();
            final recProvider = context.read<RecurringTransactionProvider>();

            final affected = await provider.deleteCreditCard(
              card.id!,
              forceHardDelete: true,
            );
            if (affected) {
              await txProvider.fetchTransactions();
              await recProvider.fetchRecurringTransactions();
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
        final provider = context.read<CreditCardProvider>();

        await provider.deleteCreditCard(card.id!, forceHardDelete: false);

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
    final creditCardProvider = context.watch<CreditCardProvider>();

    final latestCard = creditCardProvider.creditCards.firstWhere(
      (c) => c.id == widget.creditCard.id,
      orElse: () => widget.creditCard,
    );

    if (transactionProvider.isLoading || categoryProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(latestCard.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final allTransactions = transactionProvider.transactions
        .where((t) => t.creditCardId == latestCard.id)
        .toList();
    allTransactions.sort((a, b) => b.date.compareTo(a.date));

    final transactionsList = allTransactions.where((t) {
      return t.date.year == _selectedMonth.year &&
             t.date.month == _selectedMonth.month;
    }).toList();

    // Calculate total rewards
    double totalRewardsAmount = 0;
    for (var tx in transactionsList) {
      if (!tx.isIncome && tx.rewardAmount != null) {
        totalRewardsAmount += tx.rewardAmount!;
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: AppStyles.screenPadding.left,
                right: AppStyles.screenPadding.right,
                top: AppStyles.screenPadding.top,
                bottom: 8.0,
              ),
              child: MonthSelectorToggle(
                selectedMonth: _selectedMonth,
                transactions: allTransactions,
                onMonthChanged: (newMonth) {
                  setState(() {
                    _selectedMonth = newMonth;
                  });
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: AppStyles.screenPadding.left,
                  right: AppStyles.screenPadding.right,
                  bottom: AppStyles.screenPadding.bottom,
                ),
                child: Column(
                  children: [
                    _buildDigitalCard(latestCard, totalRewardsAmount),
                    const SizedBox(height: 16),
                    if (transactionsList.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Monthly Expenses'.cased(context),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (transactionsList.isEmpty)
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
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TransactionList(transactions: transactionsList),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradientForCard(CreditCard card) {
    final Color color1 = AppColors.getColorFromHex(card.colorHex);

    // Convert to HSL to get a slightly shifted secondary color for the gradient
    final HSLColor hsl1 = HSLColor.fromColor(color1);
    final Color color2 = hsl1
        .withHue((hsl1.hue + 40) % 360)
        .withLightness((hsl1.lightness + 0.1).clamp(0.0, 1.0))
        .toColor();

    return LinearGradient(
      colors: [color1, color2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
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

  String _getRewardSubtitle(BuildContext context, CreditCard card) {
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

  Widget _buildDigitalCard(CreditCard card, double totalRewardsAmount) {
    final isCashback = card.rewardType == 'Cashback';
    final rewardText = isCashback
        ? '\$${totalRewardsAmount.toStringAsFixed(2)}'
        : NumberFormat.decimalPattern().format(totalRewardsAmount.toInt());

    final gradient = _getGradientForCard(card);
    final iconData = _getIconForRewardType(card.rewardType);
    final subtitle = _getRewardSubtitle(context, card);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
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
          const SizedBox(height: 32),
          Text(
            'Monthly Rewards'.cased(context).toUpperCase(),
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rewardText,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
