import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/models/transaction.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/credit_card_provider.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';

class TransactionList extends StatefulWidget {
  final List<Transaction> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  final Set<int> _expandedTransactionIds = {};

  Category _getCategory(List<Category> categories, int id) {
    return categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => categories.isNotEmpty
          ? categories[0]
          : Category(
              id: 0,
              name: 'unknown',
              colorHex: '#9E9E9E',
              iconString: 'help_outline',
            ),
    );
  }

  Widget _buildExpandedSection(
    BuildContext context,
    Transaction transaction,
    CreditCardProvider creditCardProvider,
    RecurringTransactionProvider recurringProvider,
  ) {
    final creditCard = transaction.creditCardId != null
        ? creditCardProvider.creditCards
            .where((c) => c.id == transaction.creditCardId)
            .firstOrNull
        : null;
    final recurring = transaction.recurringId != null
        ? recurringProvider.transactions
            .where((r) => r.id == transaction.recurringId)
            .firstOrNull
        : null;

    final hasInfo = creditCard != null ||
        recurring != null ||
        (transaction.rewardAmount != null && transaction.rewardAmount! > 0) ||
        (transaction.note != null && transaction.note!.trim().isNotEmpty);

    String rewardText = '';
    if (transaction.rewardAmount != null && transaction.rewardAmount! > 0) {
      if (creditCard != null) {
        if (creditCard.rewardType == 'Cashback') {
          rewardText = '\$${transaction.rewardAmount!.toStringAsFixed(2)} cashback';
        } else if (creditCard.rewardType == 'Miles') {
          rewardText = '${transaction.rewardAmount!.toStringAsFixed(0)} miles';
        } else if (creditCard.rewardType == 'Points') {
          rewardText = '${transaction.rewardAmount!.toStringAsFixed(0)} points';
        } else {
          rewardText = '\$${transaction.rewardAmount!.toStringAsFixed(2)}';
        }
      } else {
        rewardText = '\$${transaction.rewardAmount!.toStringAsFixed(2)}';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
      ),
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (recurring != null) ...[
            Row(
              children: [
                const SizedBox(width: 60.0),
                const Icon(Icons.repeat,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    recurring.title,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
          ],
          if (creditCard != null) ...[
            Row(
              children: [
                const SizedBox(width: 60.0),
                const Icon(Icons.credit_card,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    creditCard.name,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
          ],
          if (transaction.rewardAmount != null &&
              transaction.rewardAmount! > 0) ...[
            Row(
              children: [
                const SizedBox(width: 60.0),
                const Icon(Icons.stars,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    rewardText,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
          ],
          if (transaction.note != null && transaction.note!.trim().isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 60.0),
                const Icon(Icons.sticky_note_2, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    transaction.note!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
                        TransactionModal(transaction: transaction),
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 16.0),
              TextButton.icon(
                onPressed: () async {
                  if (transaction.id != null) {
                    await context
                        .read<TransactionProvider>()
                        .deleteTransaction(transaction.id!);
                  }
                },
                icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                label: const Text('Delete',
                    style: TextStyle(color: AppColors.error)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    final categoryProvider = context.watch<CategoryProvider>();
    final creditCardProvider = context.watch<CreditCardProvider>();
    final recurringProvider = context.watch<RecurringTransactionProvider>();
    final categories = categoryProvider.categories;

    Widget emptyWidget = Center(
      child: Text(
        'No transactions yet.'.cased(context),
        style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
      ),
    );

    if (widget.transactions.isEmpty) {
      return emptyWidget;
    }

    final stats =
        DataService.computeHistoryStats(widget.transactions, categories);
    final grouped = stats.groupedTransactions;

    final listContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: grouped.entries.map((entry) {
        final date = entry.key;
        final dayTransactions = entry.value;
        final index = grouped.keys.toList().indexOf(date);
        final isLastGroup = index == grouped.length - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: index == 0 ? 0.0 : 8.0,
                bottom: 12.0,
                left: 4.0,
              ),
              child: Text(
                DateFormat('EEEE, d MMMM yyyy').format(date).cased(context),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ...dayTransactions.asMap().entries.map((txEntry) {
              final txIndex = txEntry.key;
              final transaction = txEntry.value;

              final category = _getCategory(
                stats.categories,
                transaction.categoryId,
              );
              final color = category.color;
              final isLastItem =
                  isLastGroup && txIndex == dayTransactions.length - 1;
              final isExpanded = transaction.id != null &&
                  _expandedTransactionIds.contains(transaction.id);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(bottom: isLastItem ? 0.0 : 12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.04),
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
                      if (transaction.id == null) return;
                      setState(() {
                        if (_expandedTransactionIds.contains(transaction.id)) {
                          _expandedTransactionIds.remove(transaction.id);
                        } else {
                          _expandedTransactionIds.add(transaction.id!);
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
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
                                        transaction.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        '${DateFormat.jm().format(transaction.date).cased(context)} • ${category.name}',
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
                                const SizedBox(width: 16.0),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      transaction.isIncome
                                          ? '+\$${transaction.amount.toStringAsFixed(2)}'
                                          : '-\$${transaction.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: transaction.isIncome
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
                          _buildExpandedSection(context, transaction,
                              creditCardProvider, recurringProvider),
                      ],
                    ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );

    return listContent;
  }
}
