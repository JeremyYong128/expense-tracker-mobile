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
import 'package:expense_tracker_mobile/providers/analytics_provider.dart';

class BudgetScreen extends StatefulWidget {
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
    final analyticsProvider = context.watch<AnalyticsProvider>();

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

                final stats = analyticsProvider.getCategoryStats(
                  budget.categoryId!,
                  DateTime(budget.year, budget.month),
                );
                final spent = stats.totalExpense;

                final budgetAmount = budget.amount ?? 0.0;
                final percentage = budgetAmount > 0
                    ? (spent / budgetAmount).clamp(0.0, 1.0)
                    : 0.0;

                final isExceeded = budgetAmount > 0 && spent > budgetAmount;

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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      category.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        if (isExceeded)
                                          const WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: Padding(
                                              padding: EdgeInsets.only(right: 4.0),
                                              child: Icon(
                                                Icons.warning_amber_rounded,
                                                color: AppColors.error,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        TextSpan(
                                          text: '\$${spent.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: isExceeded ? AppColors.error : null,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' / \$${budgetAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentage,
                                  backgroundColor: AppColors.grey.withValues(
                                    alpha: 0.3,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    category.color,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
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
