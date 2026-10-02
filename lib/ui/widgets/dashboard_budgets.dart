import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/analytics_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/layout_widgets.dart';
import 'package:expense_tracker_mobile/ui/widgets/text_widgets.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_segment_toggle.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/models/card.dart' as model_card;
import 'package:expense_tracker_mobile/utils/string_extensions.dart';

class BudgetsCard extends StatefulWidget {
  const BudgetsCard({super.key});

  @override
  State<BudgetsCard> createState() => _BudgetsCardState();
}

class _BudgetsCardState extends State<BudgetsCard> {
  String _budgetType = 'category';
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<AnalyticsProvider>().getDashboardStats();

    final hasCategoryBudgets = stats.categoryBudgets.values.any(
      (b) => b != null && b > 0,
    );
    final hasCardBudgets = stats.cardBudgets.values.any(
      (b) => b != null && b > 0,
    );

    final hasAnyBudgets = hasCategoryBudgets || hasCardBudgets;

    final budgets = _budgetType == 'category'
        ? stats.categoryBudgets
        : stats.cardBudgets;

    final expenses = _budgetType == 'category'
        ? stats.expenseBreakdown
        : stats.cardExpenseBreakdown;

    final budgetedItems = budgets.entries
        .where((e) => e.value != null && e.value! > 0)
        .toList();

    final displayCount = _isExpanded
        ? budgetedItems.length
        : (budgetedItems.length > 3 ? 3 : budgetedItems.length);

    return ContentCard(
      child: Column(
        children: [
          SectionHeader(
            title: 'Budgets',
            action: budgetedItems.length > 3
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _isExpanded ? 'Less' : 'More',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                : null,
          ),
          if (!hasAnyBudgets)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'No budgets this month.'.cased(context),
                  style: AppStyles.emptyStateText,
                ),
              ),
            )
          else ...[
            CustomSegmentToggle<String>(
              options: [
                CustomSegmentOption(
                  value: 'category',
                  label: 'Category',
                  activeColor: AppColors.primary,
                ),
                CustomSegmentOption(
                  value: 'card',
                  label: 'Card',
                  activeColor: AppColors.primary,
                ),
              ],
              activeValue: _budgetType,
              onChanged: (val) {
                setState(() {
                  _budgetType = val;
                });
              },
            ),
            const SizedBox(height: AppStyles.listItemSpacing),
            if (budgetedItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    'No budgets this month.'.cased(context),
                    style: AppStyles.emptyStateText,
                  ),
                ),
              )
            else
              for (int i = 0; i < displayCount; i++)
                Builder(
                  builder: (context) {
                    final entry = budgetedItems[i];
                    final item = entry.key; // either Category or Card
                    final budget = entry.value!;

                    double spent = 0.0;
                    if (_budgetType == 'category') {
                      spent = (expenses as Map<Category, double>)[item] ?? 0.0;
                    } else {
                      spent =
                          (expenses as Map<model_card.Card, double>)[item] ??
                          0.0;
                    }

                    final percent = budget > 0 ? (spent / budget) : 0.0;
                    final isOverBudget = percent > 1.0;
                    final isLast = i == displayCount - 1;

                    String name = '';
                    Color color = Colors.grey;
                    IconData iconData = Icons.help;

                    if (item is Category) {
                      name = item.name;
                      color = item.color;
                      iconData = item.iconData;
                    } else if (item is model_card.Card) {
                      name = item.name == 'No card' ? 'No card' : item.name;
                      color = Color(
                        int.parse(item.colorHex.replaceAll('#', '0xFF')),
                      );
                      iconData = Icons.credit_card;
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: isLast ? 0.0 : AppStyles.listItemSpacing,
                      ),
                      child: Row(
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
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Row(
                                      children: [
                                        if (isOverBudget)
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              right: 4.0,
                                            ),
                                            child: Icon(
                                              Icons.warning_amber_rounded,
                                              color: AppColors.error,
                                              size: 16.0,
                                            ),
                                          ),
                                        Text(
                                          '${(percent * 100).toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            color: isOverBudget
                                                ? AppColors.error
                                                : AppColors.textSecondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                LinearProgressIndicator(
                                  value: percent.clamp(0.0, 1.0),
                                  minHeight: 6.0,
                                  backgroundColor: color.withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    color,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ],
        ],
      ),
    );
  }
}
