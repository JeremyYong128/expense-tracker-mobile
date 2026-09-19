import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/budget_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/card_provider.dart';
import 'package:expense_tracker_mobile/database/drift_database.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/budget_form.dart';
import 'package:expense_tracker_mobile/ui/widgets/month_navigator.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_app_bar.dart';
import 'package:expense_tracker_mobile/ui/widgets/layout_widgets.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_segment_toggle.dart';
import 'package:expense_tracker_mobile/providers/analytics_provider.dart';
import 'package:expense_tracker_mobile/services/snackbar_service.dart';

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
  int? _expandedBudgetId;
  String _activeTab = 'category';

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

  void _showAddBudgetForm(BuildContext context, {Budget? existingBudget}) {
    SlideUpModal.showCustom(
      context: context,
      builder: (context) => BudgetForm(
        targetMonth: _currentMonth,
        existingBudget: existingBudget,
        onSaved: () {
          Navigator.pop(context); // Close the modal
        },
      ),
    );
  }

  Widget _buildBudgetContentCard(
    BuildContext context,
    List<Budget> categoryBudgets,
    List<Budget> cardBudgets,
  ) {
    final categories = context.watch<CategoryProvider>().categories;
    final cards = context.watch<CardProvider>().cards;
    final analyticsProvider = context.watch<AnalyticsProvider>();

    final budgets = _activeTab == 'category' ? categoryBudgets : cardBudgets;
    final isCategory = _activeTab == 'category';

    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSegmentToggle<String>(
            activeValue: _activeTab,
            option1Value: 'category',
            option1Text: 'Category',
            option2Value: 'card',
            option2Text: 'Card',
            onChanged: (value) {
              setState(() {
                _activeTab = value;
                _expandedBudgetId = null;
              });
            },
          ),
          const SizedBox(height: AppStyles.sectionHeaderBottomSpacing),
          if (budgets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'No $_activeTab budgets set.'.cased(context),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...budgets.asMap().entries.expand((entry) {
              final index = entry.key;
              final budget = entry.value;

              String name;
              Color color;
              IconData iconData;
              double spent;

              if (isCategory) {
                final category = categories.firstWhere(
                  (c) => c.id == budget.categoryId,
                  orElse: () => categories.first,
                );
                name = category.name;
                color = category.color;
                iconData = category.iconData;
                final stats = analyticsProvider.getCategoryStats(
                  budget.categoryId!,
                  DateTime(budget.year, budget.month),
                );
                spent = stats.totalExpense;
              } else {
                final card = cards.firstWhere(
                  (c) => c.id == budget.cardId,
                  orElse: () => cards.first, // Fallback
                );
                name = card.name;
                color = AppColors.primary;
                iconData = Icons.credit_card;
                final stats = analyticsProvider.getCardStats(
                  budget.cardId!,
                  DateTime(budget.year, budget.month),
                );
                spent = stats.totalExpense;
              }

              final budgetAmount = budget.amount ?? 0.0;
              final percentage = budgetAmount > 0
                  ? (spent / budgetAmount)
                  : 0.0;
              final isExceeded = budgetAmount > 0 && spent > budgetAmount;

              return [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (_expandedBudgetId == budget.id) {
                          _expandedBudgetId = null;
                        } else {
                          _expandedBudgetId = budget.id;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Icon(iconData, color: color, size: 24.0),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    name,
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
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: _expandedBudgetId == budget.id
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    bottom: 4.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _showAddBudgetForm(
                                          context,
                                          existingBudget: budget,
                                        ),
                                        icon: const Icon(Icons.edit, size: 18),
                                        label: const Text('Edit'),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      TextButton.icon(
                                        onPressed: () async {
                                          try {
                                            await context
                                                .read<BudgetProvider>()
                                                .deleteBudget(budget);
                                            if (context.mounted) {
                                              SnackBarService.showSuccess(
                                                'Budget deleted successfully',
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              SnackBarService.showError(
                                                'Failed to delete budget',
                                              );
                                            }
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: AppColors.error,
                                        ),
                                        label: const Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: AppColors.error,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 8.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage.clamp(0.0, 1.0),
                            backgroundColor: AppColors.grey.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < budgets.length - 1)
                  const SizedBox(height: AppStyles.listItemSpacing),
              ];
            }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeBudgets = context.watch<BudgetProvider>().activeBudgets;
    final categoryBudgets = activeBudgets
        .where((b) => b.type == 'category')
        .toList();
    final cardBudgets = activeBudgets.where((b) => b.type == 'card').toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Budgets'.cased(context)),
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
              _buildBudgetContentCard(context, categoryBudgets, cardBudgets),
          ],
        ),
      ),
    );
  }
}
