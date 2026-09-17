import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/budget_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/budget_form.dart';
import 'package:expense_tracker_mobile/ui/widgets/month_navigator.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_app_bar.dart';
import 'package:expense_tracker_mobile/ui/widgets/layout_widgets.dart';
import 'package:expense_tracker_mobile/providers/analytics_provider.dart';

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
    final analyticsProvider = context.watch<AnalyticsProvider>();

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Budget'.cased(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetForm(context),
          ),
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
              ContentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget by Category'.cased(context),
                      style: AppStyles.sectionHeader,
                    ),
                    const SizedBox(height: AppStyles.sectionHeaderSpacing),
                    ...activeBudgets.asMap().entries.expand((entry) {
                    final index = entry.key;
                    final budget = entry.value;

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
                        ? (spent / budgetAmount)
                        : 0.0;

                    final isExceeded = budgetAmount > 0 && spent > budgetAmount;

                    return [
                      Column(
                        children: [
                          Row(
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
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      category.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '\$${spent.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isExceeded
                                                  ? AppColors.error
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                ' / \$${budgetAmount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
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
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        if (isExceeded)
                                          const WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: 4.0,
                                              ),
                                              child: Icon(
                                                Icons.warning_amber_rounded,
                                                color: AppColors.error,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        TextSpan(
                                          text: '${(percentage * 100).round()}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: isExceeded
                                                ? AppColors.error
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage.clamp(0.0, 1.0),
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                category.color,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                      if (index < activeBudgets.length - 1)
                        const SizedBox(height: AppStyles.listItemSpacing),
                    ];
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
