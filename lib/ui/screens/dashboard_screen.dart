import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/card_provider.dart';
import 'package:expense_tracker_mobile/providers/analytics_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/notification_button.dart';
import 'package:expense_tracker_mobile/ui/screens/category_details_screen.dart';
import 'package:expense_tracker_mobile/ui/screens/card_details_screen.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_app_bar.dart';
import 'package:expense_tracker_mobile/ui/widgets/layout_widgets.dart';
import 'package:expense_tracker_mobile/ui/widgets/text_widgets.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/models/card.dart' as model_card;
import 'package:expense_tracker_mobile/ui/widgets/custom_segment_toggle.dart';
import 'package:expense_tracker_mobile/ui/widgets/breakdown_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isRewardsExpanded = false;
  String _categoryBreakdownType = 'expense';
  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final cardProvider = context.watch<CardProvider>();

    if (transactionProvider.isLoading ||
        categoryProvider.isLoading ||
        cardProvider.isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: Text('Home'.cased(context))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    final stats = analyticsProvider.getDashboardStats();

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Home'.cased(context)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: AppStyles.screenPadding.right),
            child: const NotificationButton(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: AppStyles.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SUMMARY CARDS
              ContentCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Expense',
                        stats.totalExpense,
                        AppColors.primary,
                        percentageChange: stats.expensePercentageChange,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryCard(
                        'Income',
                        stats.totalIncome,
                        AppColors.primary,
                        percentageChange: stats.incomePercentageChange,
                        isRightAligned: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppStyles.cardSpacing),

              // EXPENSES BY CATEGORY
              if (stats.expenseBreakdown.isNotEmpty ||
                  stats.incomeBreakdown.isNotEmpty) ...[
                BreakdownCard<Category>(
                  title: 'Category Breakdown',
                  infoText: _categoryBreakdownType == 'expense'
                      ? 'Calculated as total expenses minus income. Only categories with a net outflow are shown.'
                      : 'Total income grouped by category.',
                  entries: _categoryBreakdownType == 'expense'
                      ? stats.expenseBreakdown.entries.toList()
                      : stats.incomeBreakdown.entries.toList(),
                  budgets: stats.categoryBudgets,
                  totalAmount: _categoryBreakdownType == 'expense'
                      ? stats.totalExpense
                      : stats.totalIncome,
                  isCategory: true,
                  activeToggleValue: _categoryBreakdownType,
                  toggleOptions: [
                    CustomSegmentOption(
                      value: 'expense',
                      label: 'Expense',
                      activeColor: AppColors.expense,
                    ),
                    CustomSegmentOption(
                      value: 'income',
                      label: 'Income',
                      activeColor: AppColors.income,
                    ),
                  ],
                  onToggleChanged: (val) {
                    setState(() {
                      _categoryBreakdownType = val;
                    });
                  },
                  onItemTap: (category) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => CategoryDetailsScreen(
                          category: category,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppStyles.cardSpacing),
              ],

              // EXPENSES BY CARD
              if (stats.cardExpenseBreakdown.isNotEmpty) ...[
                BreakdownCard<model_card.Card>(
                  title: 'Card Expenses',
                  entries: stats.cardExpenseBreakdown.entries.toList(),
                  budgets: stats.cardBudgets,
                  totalAmount: stats.totalExpense,
                  isCategory: false,
                  onItemTap: (card) {
                    if (card.id != -1) {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => CardDetailsScreen(
                            card: card,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: AppStyles.cardSpacing),
              ],

              // REWARDS SECTION
              if (stats.monthlyRewards.isNotEmpty) ...[
                ContentCard(
                  child: Column(
                    children: [
                      SectionHeader(
                        title: 'Rewards Earned',
                        action: stats.monthlyRewards.length > 3
                            ? TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isRewardsExpanded = !_isRewardsExpanded;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  _isRewardsExpanded
                                      ? 'Less'.cased(context)
                                      : 'More'.cased(context),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: () {
                            final visibleEntries =
                                (_isRewardsExpanded
                                        ? stats.monthlyRewards.entries
                                        : stats.monthlyRewards.entries.take(3))
                                    .toList();
                            final List<Widget> children = [];

                            for (int i = 0; i < visibleEntries.length; i++) {
                              final entry = visibleEntries[i];
                              final card = entry.key;
                              final reward = entry.value;
                              final isCashback = card.rewardType == 'Cashback';
                              final rewardText = isCashback
                                  ? '\$${reward.toStringAsFixed(2)}'
                                  : NumberFormat.decimalPattern().format(
                                      reward.toInt(),
                                    );

                              children.add(
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              CardDetailsScreen(card: card),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.stars,
                                                  color: AppColors.primary,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                card.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '+$rewardText ${card.rewardType.cased(context)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.income,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );

                              if (i < visibleEntries.length - 1) {
                                children.add(const SizedBox(height: 12));
                              }
                            }
                            return children;
                          }(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    double amount,
    Color color, {
    double? percentageChange,
    bool isRightAligned = false,
  }) {
    bool isGood = false;
    if (percentageChange != null) {
      if (label.toLowerCase() == 'income') {
        isGood = percentageChange >= 0;
      } else {
        isGood = percentageChange <= 0;
      }
    }
    Color changeColor = isGood ? AppColors.income : AppColors.expense;

    return Column(
      crossAxisAlignment: isRightAligned
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label.toLowerCase() == 'income') ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.income.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.north_east,
                  color: AppColors.income,
                  size: 16,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label.cased(context),
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (label.toLowerCase() == 'expense') ...[
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.expense.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.south_east,
                  color: AppColors.expense,
                  size: 16,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: isRightAligned
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Text(
            _currencyFormat.format(amount),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: isRightAligned
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Icon(
              (percentageChange == null || percentageChange == 0)
                  ? Icons.horizontal_rule
                  : (percentageChange > 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward),
              size: 16,
              color: (percentageChange == null || percentageChange == 0)
                  ? AppColors.textSecondary
                  : changeColor,
            ),
            const SizedBox(width: 4),
            Text(
              percentageChange == null
                  ? ''
                  : '${percentageChange.abs().toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
