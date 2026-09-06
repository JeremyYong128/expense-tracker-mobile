import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/category_form_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/dialogs/confirmation_dialog.dart';
import 'package:expense_tracker_mobile/ui/widgets/transaction_list.dart';
import 'package:expense_tracker_mobile/ui/widgets/month_selector_toggle.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailsScreen({super.key, required this.category});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _showAddEditDialog(Category category) {
    SlideUpModal.showCustom(
      context: context,
      builder: (context) => CategoryFormModal(category: category),
    );
  }

  void _confirmDelete(Category category) {
    final transactionProvider = context.read<TransactionProvider>();
    final recurringTxProvider = context.read<RecurringTransactionProvider>();

    final hasTransactions = transactionProvider.transactions.any(
      (t) => t.categoryId == category.id,
    );
    final hasRecurring = recurringTxProvider.transactions.any(
      (t) => t.categoryId == category.id,
    );

    if (hasTransactions || hasRecurring) {
      ConfirmationDialog.show(
        context: context,
        title: 'Delete Category?',
        content: 'This will not affect past transactions.',
        confirmText: 'Delete',
        isDestructive: true,
        onConfirm: () async {
          final navigator = Navigator.of(context);
          final provider = context.read<CategoryProvider>();

          await provider.deleteCategory(category.id!);

          if (mounted) {
            navigator.pop(); // Close details screen
          }
        },
      );
    } else {
      // Immediately delete if no associations exist
      final navigator = Navigator.of(context);
      final provider = context.read<CategoryProvider>();

      provider.deleteCategory(category.id!).then((_) {
        if (mounted) {
          navigator.pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final latestCategory = categoryProvider.categories.firstWhere(
      (c) => c.id == widget.category.id,
      orElse: () => widget.category,
    );

    if (transactionProvider.isLoading || categoryProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(latestCategory.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final allTransactions = transactionProvider.transactions
        .where((t) => t.categoryId == latestCategory.id)
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

    return Scaffold(
      appBar: AppBar(
        title: Text(latestCategory.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.white),
            onPressed: () => _showAddEditDialog(latestCategory),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.white),
            onPressed: () => _confirmDelete(latestCategory),
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
              _buildCategoryHeader(latestCategory),
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
                _buildMonthlySummary(totalIncome, totalExpense),
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
                    padding: const EdgeInsetsGeometry.only(top: 8.0),
                    child: TransactionList(transactions: transactionsList),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(double totalIncome, double totalExpense) {
    final balance = totalIncome - totalExpense;
    final isPositive = balance > 0;
    final isNegative = balance < 0;
    final color = AppColors.textPrimary;
    final sign = isPositive ? '+' : (isNegative ? '-' : '');

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
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(Category category) {
    final color = AppColors.getColorFromHex(category.colorHex);

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
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
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
        ],
      ),
    );
  }
}
