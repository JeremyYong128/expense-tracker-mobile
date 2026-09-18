import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/models/card.dart';
import 'package:expense_tracker_mobile/models/transaction.dart';

class DashboardStats {
  final double totalIncome;
  final double totalExpense;
  final double? incomePercentageChange;
  final double? expensePercentageChange;
  final Map<Category, double> expenseBreakdown;
  final Map<Category, double?> categoryBudgets;
  final Map<Card, double> monthlyRewards;

  DashboardStats({
    required this.totalIncome,
    required this.totalExpense,
    this.incomePercentageChange,
    this.expensePercentageChange,
    required this.expenseBreakdown,
    required this.categoryBudgets,
    required this.monthlyRewards,
  });
}

class CardMonthlyStats {
  final double totalExpense;
  final double totalRewardsAmount;
  final double prevExpense;
  final double prevRewardsAmount;
  final List<Transaction> currentMonthTransactions;
  final List<Transaction> allCardTransactions;

  CardMonthlyStats({
    required this.totalExpense,
    required this.totalRewardsAmount,
    required this.prevExpense,
    required this.prevRewardsAmount,
    required this.currentMonthTransactions,
    required this.allCardTransactions,
  });
}

class CategoryMonthlyStats {
  final double totalIncome;
  final double totalExpense;
  final double prevBalance;
  final List<Transaction> currentMonthTransactions;
  final List<Transaction> allCategoryTransactions;

  CategoryMonthlyStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.prevBalance,
    required this.currentMonthTransactions,
    required this.allCategoryTransactions,
  });
}

class RecurringMonthlyStats {
  final double totalIncome;
  final double totalExpense;
  final double prevBalance;
  final List<Transaction> currentMonthTransactions;
  final List<Transaction> allRecurringTransactions;

  RecurringMonthlyStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.prevBalance,
    required this.currentMonthTransactions,
    required this.allRecurringTransactions,
  });
}

class HistoryStats {
  final Map<DateTime, List<Transaction>> groupedTransactions;
  final List<Category> categories;

  HistoryStats({required this.groupedTransactions, required this.categories});

  static HistoryStats fromTransactions(
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final Map<DateTime, List<Transaction>> grouped = {};
    for (var tx in sortedTransactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(tx);
    }

    return HistoryStats(groupedTransactions: grouped, categories: categories);
  }
}

class MonthlyBudgetPacing {
  final int month;
  final int year;
  final double? budgetAmount;
  final double spentAmount;

  MonthlyBudgetPacing({
    required this.month,
    required this.year,
    this.budgetAmount,
    required this.spentAmount,
  });

  bool get isOverBudget => budgetAmount != null && spentAmount > budgetAmount!;
  double get percentageUsed => budgetAmount != null && budgetAmount! > 0
      ? spentAmount / budgetAmount!
      : 0.0;
}
