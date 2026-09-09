import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/ui/screens/recurring_transaction_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
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
                  final category = categoryProvider.getCategoryById(tx.categoryId);
                  final color = category?.color ?? AppColors.grey;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
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
                          if (tx.id == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecurringTransactionDetailsScreen(
                                    recurringTransaction: tx,
                                  ),
                            ),
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
                                        category?.iconData ?? Icons.help_outline,
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
