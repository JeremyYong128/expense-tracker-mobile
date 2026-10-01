import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/card_provider.dart';
import 'package:expense_tracker_mobile/providers/analytics_provider.dart';
import 'package:expense_tracker_mobile/ui/widgets/notification_button.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_app_bar.dart';
import 'package:expense_tracker_mobile/ui/widgets/layout_widgets.dart';
import 'package:expense_tracker_mobile/ui/widgets/dashboard_category_breakdown.dart';
import 'package:expense_tracker_mobile/ui/widgets/dashboard_budgets.dart';
import 'package:expense_tracker_mobile/utils/currency_utils.dart';
import 'package:expense_tracker_mobile/providers/user_preferences_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final baseCurrency = context.watch<UserPreferencesProvider>().baseCurrency;

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
                        baseCurrency: baseCurrency,
                        percentageChange: stats.expensePercentageChange,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryCard(
                        'Income',
                        stats.totalIncome,
                        AppColors.primary,
                        baseCurrency: baseCurrency,
                        percentageChange: stats.incomePercentageChange,
                        isRightAligned: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppStyles.cardSpacing),

              // EXPENSES BY CATEGORY
              const CategoryBreakdownCard(),
              const SizedBox(height: AppStyles.cardSpacing),

              // BUDGETS
              const BudgetsCard(),
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
    required String baseCurrency,
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
          alignment: isRightAligned
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label.toLowerCase() == 'expense') ...[
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.expense,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                CurrencyFormatter.format(amount, baseCurrency),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (label.toLowerCase() == 'income') ...[
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.income,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ],
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
