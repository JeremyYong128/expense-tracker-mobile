import 'package:flutter/material.dart' hide Card;
import 'package:expense_tracker_mobile/models/analytics_stats.dart';
import 'package:expense_tracker_mobile/models/transaction.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/models/card.dart';
import 'package:expense_tracker_mobile/providers/transaction_provider.dart';
import 'package:expense_tracker_mobile/providers/category_provider.dart';
import 'package:expense_tracker_mobile/providers/card_provider.dart';
import 'package:expense_tracker_mobile/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker_mobile/utils/business_logic.dart';
class AnalyticsProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  List<Card> _cards = [];
  
  // Memoization caches
  final Map<String, DashboardStats> _dashboardStatsCache = {};
  final Map<String, CardMonthlyStats> _cardStatsCache = {};
  final Map<String, CategoryMonthlyStats> _categoryStatsCache = {};
  final Map<String, RecurringMonthlyStats> _recurringStatsCache = {};

  void update(
    TransactionProvider txProvider,
    CategoryProvider catProvider,
    CardProvider cardProvider,
    RecurringTransactionProvider recProvider,
  ) {
    _transactions = txProvider.transactions;
    _categories = catProvider.categories;
    _cards = cardProvider.cards;
    
    // Invalidate caches when data updates
    _dashboardStatsCache.clear();
    _cardStatsCache.clear();
    _categoryStatsCache.clear();
    _recurringStatsCache.clear();
    
    notifyListeners();
  }

  String _formatMonthKey(DateTime month) {
    return '${month.year}-${month.month.toString().padLeft(2, '0')}';
  }

  List<Transaction> getTransactionsForMonth(DateTime month) {
    return _transactions.where((t) {
      return t.date.year == month.year && t.date.month == month.month;
    }).toList();
  }

  DashboardStats getDashboardStats(DateTime month) {
    final key = _formatMonthKey(month);
    if (!_dashboardStatsCache.containsKey(key)) {
      // Filter to current month
      final currentMonthTransactions = _transactions
          .where(
            (t) =>
                t.date.year == month.year &&
                t.date.month == month.month,
          )
          .toList();

      // Filter to past month
      final pastMonth = DateTime(month.year, month.month - 1);
      final pastMonthTransactions = _transactions
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

      final incomePercentageChange = BusinessLogic.calculatePercentageChange(income, pastIncome);
      final expensePercentageChange = BusinessLogic.calculatePercentageChange(expense, pastExpense);

      // Sort category spending to get top ones
      final sortedCategories = categorySpending.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Map to Category objects
      Map<Category, double> expenseBreakdownMap = {};
      for (var entry in sortedCategories) {
        final category = _categories.firstWhere(
          (c) => c.id == entry.key,
          orElse: () => Category(id: -1, name: 'Unknown', colorHex: '#9E9E9E', isActive: false),
        );
        expenseBreakdownMap[category] = entry.value;
      }

      Map<Card, double> rewardsMap = {};

      // Group rewards by card ID for current month
      Map<int, double> cardRewards = {};
      for (var tx in currentMonthTransactions) {
        if (!tx.isIncome && tx.cardId != null && tx.rewardAmount != null) {
          cardRewards[tx.cardId!] =
              (cardRewards[tx.cardId!] ?? 0) + tx.rewardAmount!;
        }
      }

      for (var card in _cards) {
        if (cardRewards.containsKey(card.id)) {
          rewardsMap[card] = cardRewards[card.id]!;
        }
      }

      _dashboardStatsCache[key] = DashboardStats(
        totalIncome: income,
        totalExpense: expense,
        incomePercentageChange: incomePercentageChange,
        expensePercentageChange: expensePercentageChange,
        expenseBreakdown: expenseBreakdownMap,
        monthlyRewards: rewardsMap,
      );
    }
    return _dashboardStatsCache[key]!;
  }

  CardMonthlyStats getCardStats(int cardId, DateTime month) {
    final key = '${cardId}_${_formatMonthKey(month)}';
    if (!_cardStatsCache.containsKey(key)) {
      final allCardTransactions = _transactions.where((t) => t.cardId == cardId).toList();
      allCardTransactions.sort((a, b) => b.date.compareTo(a.date));

      final currentMonthTransactions = allCardTransactions.where((t) {
        return t.date.year == month.year && t.date.month == month.month;
      }).toList();

      double totalExpense = 0;
      double totalRewardsAmount = 0;
      for (var tx in currentMonthTransactions) {
        if (!tx.isIncome) {
          totalExpense += tx.amount;
          if (tx.rewardAmount != null) {
            totalRewardsAmount += tx.rewardAmount!;
          }
        }
      }

      final prevMonth = DateTime(month.year, month.month - 1);
      final prevTransactionsList = allCardTransactions.where((t) {
        return t.date.year == prevMonth.year && t.date.month == prevMonth.month;
      }).toList();

      double prevExpense = 0;
      double prevRewardsAmount = 0;
      for (var tx in prevTransactionsList) {
        if (!tx.isIncome) {
          prevExpense += tx.amount;
          if (tx.rewardAmount != null) {
            prevRewardsAmount += tx.rewardAmount!;
          }
        }
      }

      _cardStatsCache[key] = CardMonthlyStats(
        totalExpense: totalExpense,
        totalRewardsAmount: totalRewardsAmount,
        prevExpense: prevExpense,
        prevRewardsAmount: prevRewardsAmount,
        currentMonthTransactions: currentMonthTransactions,
        allCardTransactions: allCardTransactions,
      );
    }
    return _cardStatsCache[key]!;
  }

  CategoryMonthlyStats getCategoryStats(int categoryId, DateTime month) {
    final key = '${categoryId}_${_formatMonthKey(month)}';
    if (!_categoryStatsCache.containsKey(key)) {
      final allCategoryTransactions = _transactions.where((t) => t.categoryId == categoryId).toList();
      allCategoryTransactions.sort((a, b) => b.date.compareTo(a.date));

      final currentMonthTransactions = allCategoryTransactions.where((t) {
        return t.date.year == month.year && t.date.month == month.month;
      }).toList();

      double totalIncome = 0;
      double totalExpense = 0;
      for (var tx in currentMonthTransactions) {
        if (tx.isIncome) {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
      }

      final prevMonth = DateTime(month.year, month.month - 1);
      final prevTransactionsList = allCategoryTransactions.where((t) {
        return t.date.year == prevMonth.year && t.date.month == prevMonth.month;
      }).toList();

      double prevIncome = 0;
      double prevExpense = 0;
      for (var tx in prevTransactionsList) {
        if (tx.isIncome) {
          prevIncome += tx.amount;
        } else {
          prevExpense += tx.amount;
        }
      }

      _categoryStatsCache[key] = CategoryMonthlyStats(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        prevBalance: prevIncome - prevExpense,
        currentMonthTransactions: currentMonthTransactions,
        allCategoryTransactions: allCategoryTransactions,
      );
    }
    return _categoryStatsCache[key]!;
  }

  RecurringMonthlyStats getRecurringStats(int recurringId, DateTime month) {
    final key = '${recurringId}_${_formatMonthKey(month)}';
    if (!_recurringStatsCache.containsKey(key)) {
      final allRecurringTransactions = _transactions.where((t) => t.recurringId == recurringId).toList();
      allRecurringTransactions.sort((a, b) => b.date.compareTo(a.date));

      final currentMonthTransactions = allRecurringTransactions.where((t) {
        return t.date.year == month.year && t.date.month == month.month;
      }).toList();

      double totalIncome = 0;
      double totalExpense = 0;
      for (var tx in currentMonthTransactions) {
        if (tx.isIncome) {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
      }

      final prevMonth = DateTime(month.year, month.month - 1);
      final prevTransactionsList = allRecurringTransactions.where((t) {
        return t.date.year == prevMonth.year && t.date.month == prevMonth.month;
      }).toList();

      double prevIncome = 0;
      double prevExpense = 0;
      for (var tx in prevTransactionsList) {
        if (tx.isIncome) {
          prevIncome += tx.amount;
        } else {
          prevExpense += tx.amount;
        }
      }

      _recurringStatsCache[key] = RecurringMonthlyStats(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        prevBalance: prevIncome - prevExpense,
        currentMonthTransactions: currentMonthTransactions,
        allRecurringTransactions: allRecurringTransactions,
      );
    }
    return _recurringStatsCache[key]!;
  }
}
