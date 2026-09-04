import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
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
    ConfirmationDialog.show(
      context: context,
      title: 'Delete Category',
      content:
          'Are you sure you want to delete this category? If there are transactions associated with it, it will be archived instead.',
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
                    _buildCategoryHeader(latestCategory, totalIncome, totalExpense),
                    const SizedBox(height: 16),
                    if (transactionsList.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Monthly Transactions'.cased(context),
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
                          'No transactions tagged to this category.'.cased(
                            context,
                          ),
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

  Widget _buildCategoryHeader(Category category, double totalIncome, double totalExpense) {
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
          const SizedBox(height: 32),
          if (category.isIncome) ...[
            Text(
              'Monthly Income'.cased(context).toUpperCase(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${totalIncome.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (category.isIncome && category.isExpense)
            const SizedBox(height: 24),
          if (category.isExpense) ...[
            Text(
              'Monthly Expenses'.cased(context).toUpperCase(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${totalExpense.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
