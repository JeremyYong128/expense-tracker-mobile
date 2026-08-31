import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/edit_transaction_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final recurringProvider = context.watch<RecurringTransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

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

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
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
        body: recurringTransactions.isEmpty
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

                  return Container(
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
                        onTap: () async {
                          await SlideUpModal.showCustom(
                            context: context,
                            builder: (context) =>
                                EditTransactionModal(recurringTransaction: tx),
                          );
                        },
                        child: Padding(
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
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
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
                                        category.name,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        'Every ${tx.interval} ${tx.period}'
                                            .cased(context),
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        'Due: ${DateFormat('d MMMM y').format(tx.nextDueDate).cased(context)}'
                                            .cased(context),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (tx.note != null &&
                                          tx.note!.trim().isNotEmpty) ...[
                                        const SizedBox(height: 2.0),
                                        Text(
                                          tx.note!,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
