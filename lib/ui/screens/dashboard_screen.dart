import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/credit_card_provider.dart';
import 'package:expense_tracker_mobile/providers/notification_provider.dart';
import 'package:expense_tracker_mobile/ui/screens/notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
  }

  void _navigateMonth(int monthOffset) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + monthOffset,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final creditCardProvider = context.watch<CreditCardProvider>();

    if (transactionProvider.isLoading ||
        categoryProvider.isLoading ||
        creditCardProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Home'.cased(context))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final stats = DataService.computeDashboardStats(
      transactionProvider.transactions,
      categoryProvider.categories,
      creditCardProvider.creditCards,
      _currentMonth,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'.cased(context)),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => NotificationsScreen.show(context),
              ),
              if (context.watch<NotificationProvider>().hasUnread)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.expense,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _navigateMonth(-1),
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: Text(
                      DateFormat(
                        'MMMM yyyy',
                      ).format(_currentMonth).cased(context),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _navigateMonth(1),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // SUMMARY CARDS
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Income',
                      stats.totalIncome,
                      AppColors.primary,
                      percentageChange: stats.incomePercentageChange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Expense',
                      stats.totalExpense,
                      AppColors.primary,
                      percentageChange: stats.expensePercentageChange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // TOP CATEGORIES
              if (stats.topCategories.isNotEmpty) ...[
                Text(
                  'Top Categories'.cased(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...stats.topCategories.entries.map((entry) {
                  final category = entry.key;
                  final amount = entry.value;
                  final color = category.color;
                  final percentage = stats.totalExpense > 0
                      ? (amount / stats.totalExpense)
                      : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(
                            category.iconData,
                            color: color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    _currencyFormat.format(amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
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
                                    color,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],

              // REWARDS SECTION
              if (stats.monthlyRewards.isNotEmpty) ...[
                Text(
                  'Rewards Earned'.cased(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...stats.monthlyRewards.entries.map((entry) {
                  final card = entry.key;
                  final reward = entry.value;
                  final isCashback = card.rewardType == 'Cashback';
                  final rewardText = isCashback
                      ? '\$${reward.toStringAsFixed(2)}'
                      : NumberFormat.decimalPattern().format(reward.toInt());

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
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
                            '+$rewardText ${card.rewardType}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.income,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
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

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.cased(context),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
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
      ),
    );
  }
}
