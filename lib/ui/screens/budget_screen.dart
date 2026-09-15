import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/budget_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/notification_button.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/budget_form.dart';
import 'package:expense_tracker_mobile/ui/widgets/month_navigator.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_app_bar.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  DateTime _currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgetsForMonth(
        _currentMonth.month,
        _currentMonth.year,
      );
    });
  }

  void _navigateMonth(int monthsToAdd) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + monthsToAdd,
        1,
      );
    });
    context.read<BudgetProvider>().loadBudgetsForMonth(
      _currentMonth.month,
      _currentMonth.year,
    );
  }

  void _showAddBudgetForm(BuildContext context) {
    SlideUpModal.showCustom(
      context: context,
      builder: (context) => BudgetForm(
        targetMonth: _currentMonth,
        onSaved: () {
          Navigator.pop(context); // Close the modal
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeBudgets = context.watch<BudgetProvider>().activeBudgets;
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Budget'.cased(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetForm(context),
          ),
          const NotificationButton(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppStyles.screenPadding,
          children: [
            MonthNavigator(
              currentMonth: _currentMonth,
              canGoBack: true,
              canGoForward: true,
              onPrevious: () => _navigateMonth(-1),
              onNext: () => _navigateMonth(1),
            ),
            const SizedBox(height: 24.0),
            if (activeBudgets.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Center(
                  child: Text(
                    'No budgets set for this month.'.cased(context),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...activeBudgets.map((budget) {
                // Find corresponding category
                final category = categories.firstWhere(
                  (c) => c.id == budget.categoryId,
                  orElse: () => categories.first, // Fallback
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppStyles.cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(
                            category.iconData,
                            color: category.color,
                            size: 24.0,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Text(
                            category.name.cased(context),
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          '\$${budget.amount!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
