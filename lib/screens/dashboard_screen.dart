import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../services/data_service.dart';
import '../utils/category_appearance.dart';
import '../utils/string_extensions.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  double _totalIncome = 0;
  double _totalExpense = 0;
  double? _incomePercentageChange;
  double? _expensePercentageChange;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  Map<Category, double> _topCategories = {};
  List<Category> _categories = [];

  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final allTransactions = await DataService.getTransactions();
    _categories = await DataService.getCategories();

    // Filter to current month
    final currentMonthTransactions = allTransactions
        .where(
          (t) =>
              t.date.year == _currentMonth.year &&
              t.date.month == _currentMonth.month,
        )
        .toList();

    // Filter to past month
    final pastMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    final pastMonthTransactions = allTransactions
        .where(
          (t) =>
              t.date.year == pastMonth.year && t.date.month == pastMonth.month,
        )
        .toList();

    double income = 0;
    double expense = 0;
    Map<int, double> categorySpending = {};

    for (var tx in currentMonthTransactions) {
      if (tx.isIncome) {
        income += tx.amount;
      } else {
        expense += tx.amount;
        categorySpending[tx.categoryId] =
            (categorySpending[tx.categoryId] ?? 0) + tx.amount;
      }
    }

    double pastIncome = 0;
    double pastExpense = 0;
    for (var tx in pastMonthTransactions) {
      if (tx.isIncome) {
        pastIncome += tx.amount;
      } else {
        pastExpense += tx.amount;
      }
    }

    double? incomePercentageChange;
    if (pastIncome == 0) {
      if (income > 0) incomePercentageChange = 100.0;
    } else {
      incomePercentageChange = ((income - pastIncome) / pastIncome) * 100;
    }

    double? expensePercentageChange;
    if (pastExpense == 0) {
      if (expense > 0) expensePercentageChange = 100.0;
    } else {
      expensePercentageChange = ((expense - pastExpense) / pastExpense) * 100;
    }

    // Sort category spending to get top ones
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Map to Category objects (take top 4)
    Map<Category, double> topCatMap = {};
    for (var entry in sortedCategories.take(4)) {
      final category = _categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => Category(id: -1, name: 'Unknown', isActive: false),
      );
      topCatMap[category] = entry.value;
    }

    if (mounted) {
      setState(() {
        _totalIncome = income;
        _totalExpense = expense;
        _incomePercentageChange = incomePercentageChange;
        _expensePercentageChange = expensePercentageChange;
        _topCategories = topCatMap;
        _isLoading = false;
      });
    }
  }

  void _navigateMonth(int monthOffset) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + monthOffset,
      );
    });
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
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
                  DateFormat('MMMM yyyy').format(_currentMonth).cased(context),
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
                  _totalIncome,
                  AppColors.primary,
                  percentageChange: _incomePercentageChange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Expense',
                  _totalExpense,
                  AppColors.primary,
                  percentageChange: _expensePercentageChange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // TOP CATEGORIES
          if (_topCategories.isNotEmpty) ...[
            Text(
              'Top Categories'.cased(context),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ..._topCategories.entries.map((entry) {
              final category = entry.key;
              final amount = entry.value;
              final color = category.color;
              final percentage = _totalExpense > 0
                  ? (amount / _totalExpense)
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
                      child: Icon(category.iconData, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              valueColor: AlwaysStoppedAnimation<Color>(color),
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
        ],
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
                style: TextStyle(
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
