import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/dialogs/confirmation_dialog.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/credit_card_provider.dart';
import 'package:expense_tracker_mobile/main.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  final bool showAppBar;

  const RecurringTransactionsScreen({super.key, this.showAppBar = false});

  @override
  State<RecurringTransactionsScreen> createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends State<RecurringTransactionsScreen> {
  final Set<int> _expandedTransactionIds = {};

  @override
  void initState() {
    super.initState();
  }

  Widget _buildExpandedSection(
    BuildContext context,
    dynamic tx,
    Category category,
    CreditCardProvider creditCardProvider,
  ) {
    final creditCard = tx.creditCardId != null
        ? creditCardProvider.creditCards
              .where((c) => c.id == tx.creditCardId)
              .firstOrNull
        : null;

    String rewardText = '';
    if (tx.rewardAmount != null && tx.rewardAmount! > 0) {
      if (creditCard != null) {
        if (creditCard.rewardType == 'Cashback') {
          rewardText = '\$${tx.rewardAmount!.toStringAsFixed(2)} cashback';
        } else if (creditCard.rewardType == 'Miles') {
          rewardText = '${tx.rewardAmount!.toStringAsFixed(0)} miles';
        } else if (creditCard.rewardType == 'Points') {
          rewardText = '${tx.rewardAmount!.toStringAsFixed(0)} points';
        } else {
          rewardText = '\$${tx.rewardAmount!.toStringAsFixed(2)}';
        }
      } else {
        rewardText = '\$${tx.rewardAmount!.toStringAsFixed(2)}';
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
      ),
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SizedBox(width: 60.0),
              const Icon(
                Icons.category,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              const SizedBox(width: 60.0),
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Every ${tx.interval} ${tx.period.toLowerCase().replaceAll('(s)', tx.interval == 1 ? '' : 's')}'
                      .cased(context),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          if (creditCard != null) ...[
            Row(
              children: [
                const SizedBox(width: 60.0),
                const Icon(
                  Icons.credit_card,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    creditCard.name,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
          ],
          if (tx.rewardAmount != null && tx.rewardAmount! > 0) ...[
            Row(
              children: [
                const SizedBox(width: 60.0),
                const Icon(
                  Icons.stars,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    rewardText,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
          ],
          if (tx.note != null && tx.note!.trim().isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 60.0),
                const Icon(
                  Icons.sticky_note_2,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    tx.note!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  SlideUpModal.showCustom(
                    context: context,
                    builder: (context) =>
                        TransactionModal(recurringTransaction: tx),
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 16.0),
              TextButton.icon(
                onPressed: () {
                  ConfirmationDialog.show(
                    context: context,
                    title: 'Delete Recurring Transaction?',
                    content:
                        'Existing transactions linked to this recurring transaction will not be affected.',
                    confirmText: 'Delete',
                    isDestructive: true,
                    onConfirm: () async {
                      await context
                          .read<RecurringTransactionProvider>()
                          .deleteRecurringTransaction(tx.id!);
                    },
                  );
                },
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: AppColors.error,
                ),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recurringProvider = context.watch<RecurringTransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final creditCardProvider = context.watch<CreditCardProvider>();

    if (recurringProvider.isLoading || categoryProvider.isLoading) {
      return widget.showAppBar
          ? Scaffold(
              appBar: AppBar(
                title: Text('Recurring Transactions'.cased(context)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      HomeScreen.navigateToAddTransaction(
                        context,
                        isRecurring: true,
                      );
                    },
                  ),
                ],
              ),
              body: const Center(child: CircularProgressIndicator()),
            )
          : const Center(child: CircularProgressIndicator());
    }

    final recurringTransactions = recurringProvider.transactions;
    final categories = categoryProvider.categories;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text('Recurring Transactions'.cased(context)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    HomeScreen.navigateToAddTransaction(
                      context,
                      isRecurring: true,
                    );
                  },
                ),
              ],
            )
          : null,
      body: SafeArea(
        top: false,
        bottom: true,
        child: recurringTransactions.isEmpty
            ? Center(
                child: Text(
                  'No recurring transactions found.'.cased(context),
                  style: const TextStyle(color: AppColors.grey, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: AppStyles.screenPadding,
                itemCount: recurringTransactions.length,
                itemBuilder: (context, index) {
                  final tx = recurringTransactions[index];
                  final category = categories.firstWhere(
                    (c) => c.id == tx.categoryId,
                    orElse: () => Category(
                      name: 'Unknown',
                      colorHex: '#9E9E9E',
                      iconString: null,
                      isActive: true,
                    ),
                  );
                  final color = category.color;

                  final isExpanded =
                      tx.id != null && _expandedTransactionIds.contains(tx.id);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: 0.04,
                          ), // soft shadow using primary color
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24.0),
                        onTap: () {
                          if (tx.id == null) return;
                          setState(() {
                            if (_expandedTransactionIds.contains(tx.id)) {
                              _expandedTransactionIds.remove(tx.id);
                            } else {
                              _expandedTransactionIds.add(tx.id!);
                            }
                          });
                        },
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: color.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Icon(
                                              category.iconData,
                                              color: color,
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 2.0),
                                            Text(
                                              'Due ${DateFormat('d MMMM y').format(tx.nextDueDate).cased(context)}',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            tx.isIncome
                                                ? '+\$${tx.amount.toStringAsFixed(2)}'
                                                : '-\$${tx.amount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: tx.isIncome
                                                  ? AppColors.income
                                                  : AppColors.expense,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isExpanded)
                                _buildExpandedSection(
                                  context,
                                  tx,
                                  category,
                                  creditCardProvider,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
