import 'package:drift/drift.dart' as drift;
import 'package:expense_tracker_mobile/models/transaction.dart';
import 'package:expense_tracker_mobile/models/recurring_transaction.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/models/credit_card.dart';
import 'package:expense_tracker_mobile/database/drift_database.dart';
import 'package:expense_tracker_mobile/services/data_change_notifier.dart';

class DataService {
  static final AppDatabase _db = AppDatabase();
  static final DataChangeNotifier onDataChanged = DataChangeNotifier();

  // --- Mappers ---
  
  static Category _mapCategory(CategoryTableData data) {
    return Category(
      id: data.id,
      name: data.name,
      colorHex: data.colorHex,
      iconString: data.iconString,
      isActive: data.isActive,
    );
  }

  static Transaction _mapTransaction(TransactionTableData data) {
    return Transaction(
      id: data.id,
      amount: data.amount,
      title: data.title,
      date: DateTime.parse(data.date),
      categoryId: data.categoryId,
      note: data.note,
      isIncome: data.isIncome,
      recurringId: data.recurringId,
      creditCardId: data.creditCardId,
    );
  }

  static CreditCard _mapCreditCard(CreditCardTableData data) {
    return CreditCard(
      id: data.id,
      name: data.name,
      rewardType: data.rewardType,
      rewardRate: data.rewardRate,
    );
  }

  static RecurringTransaction _mapRecurringTransaction(RecurringTransactionTableData data) {
    return RecurringTransaction(
      id: data.id,
      amount: data.amount,
      title: data.title,
      categoryId: data.categoryId,
      note: data.note,
      isIncome: data.isIncome,
      interval: data.interval,
      period: data.period,
      nextDueDate: DateTime.parse(data.nextDueDate),
    );
  }

  // --- Category Methods ---

  static Future<List<Category>> getCategories() async {
    final list = await _db.select(_db.categories).get();
    return list.map(_mapCategory).toList();
  }

  static Future<int> addCategory(Category category) async {
    final existing = await (_db.select(_db.categories)
          ..where((c) => c.name.lower().equals(category.name.toLowerCase())))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.categories)..where((c) => c.id.equals(existing.id))).write(
        CategoriesCompanion(
          isActive: const drift.Value(true),
          colorHex: drift.Value(category.colorHex),
          iconString: drift.Value(category.iconString),
        ),
      );
      onDataChanged.notify();
      return existing.id;
    }

    final newId = await _db.into(_db.categories).insert(
      CategoriesCompanion.insert(
        name: category.name,
        colorHex: drift.Value(category.colorHex),
        iconString: drift.Value(category.iconString),
        isActive: drift.Value(category.isActive),
      ),
    );
    onDataChanged.notify();
    return newId;
  }

  static Future<int> updateCategory(Category category) async {
    // Check for a collision with an existing (likely soft-deleted) category
    final existing = await (_db.select(_db.categories)
          ..where((c) => c.name.lower().equals(category.name.toLowerCase()))
          ..where((c) => c.id.equals(category.id!).not()))
        .getSingleOrNull();

    if (existing != null) {
      // Merge: Update the existing soft-deleted category
      await (_db.update(_db.categories)..where((c) => c.id.equals(existing.id))).write(
        CategoriesCompanion(
          name: drift.Value(category.name),
          colorHex: drift.Value(category.colorHex),
          iconString: drift.Value(category.iconString),
          isActive: const drift.Value(true), // Reactivate
        ),
      );

      // Migrate transactions to the existing category
      await (_db.update(_db.transactions)..where((t) => t.categoryId.equals(category.id!))).write(
        TransactionsCompanion(
          categoryId: drift.Value(existing.id),
        ),
      );

      // Migrate recurring transactions
      await (_db.update(_db.recurringTransactions)..where((r) => r.categoryId.equals(category.id!))).write(
        RecurringTransactionsCompanion(
          categoryId: drift.Value(existing.id),
        ),
      );

      // Delete the old category
      await (_db.delete(_db.categories)..where((c) => c.id.equals(category.id!))).go();

      onDataChanged.notify();
      return existing.id;
    }

    // Normal update
    await (_db.update(_db.categories)..where((c) => c.id.equals(category.id!))).write(
      CategoriesCompanion(
        name: drift.Value(category.name),
        colorHex: drift.Value(category.colorHex),
        iconString: drift.Value(category.iconString),
        isActive: drift.Value(category.isActive),
      ),
    );
    onDataChanged.notify();
    return category.id!;
  }

  static Future<void> deleteCategory(int id) async {
    final txCount = await (_db.select(_db.transactions)..where((t) => t.categoryId.equals(id))).get();
    final recCount = await (_db.select(_db.recurringTransactions)..where((r) => r.categoryId.equals(id))).get();

    if (txCount.isNotEmpty || recCount.isNotEmpty) {
      await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
        const CategoriesCompanion(isActive: drift.Value(false)),
      );
    } else {
      await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
    }
    onDataChanged.notify();
  }

  // --- Credit Card Methods ---

  static Future<List<CreditCard>> getCreditCards() async {
    final list = await _db.select(_db.creditCards).get();
    return list.map(_mapCreditCard).toList();
  }

  static Future<int> addCreditCard(CreditCard card) async {
    final id = await _db.into(_db.creditCards).insert(
      CreditCardsCompanion.insert(
        name: card.name,
        rewardType: card.rewardType,
        rewardRate: card.rewardRate,
      ),
    );
    onDataChanged.notify();
    return id;
  }

  static Future<void> updateCreditCard(CreditCard card) async {
    await (_db.update(_db.creditCards)..where((c) => c.id.equals(card.id!))).write(
      CreditCardsCompanion(
        name: drift.Value(card.name),
        rewardType: drift.Value(card.rewardType),
        rewardRate: drift.Value(card.rewardRate),
      ),
    );
    onDataChanged.notify();
  }

  static Future<void> deleteCreditCard(int id) async {
    await (_db.delete(_db.creditCards)..where((c) => c.id.equals(id))).go();
    onDataChanged.notify();
  }

  // --- Transaction Methods ---

  static Future<void> addTransaction({
    required String amountText,
    required String title,
    required DateTime date,
    required int categoryId,
    required bool isIncome,
    required bool isRecurring,
    required String recurringIntervalText,
    required String recurringPeriod,
    required String note,
    int? creditCardId,
  }) async {
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      throw Exception('Please enter a valid amount greater than 0.');
    }

    if (title.trim().isEmpty) {
      throw Exception('Please enter a title.');
    }

    if (isRecurring) {
      final recurringInterval = int.tryParse(recurringIntervalText);
      if (recurringInterval == null || recurringInterval <= 0) {
        throw Exception('Please enter a valid recurring interval.');
      }

      final nextDueDate = calculateNextDueDate(date, recurringInterval, recurringPeriod);

      await _db.into(_db.recurringTransactions).insert(
        RecurringTransactionsCompanion.insert(
          amount: amount,
          title: title.trim(),
          categoryId: categoryId,
          isIncome: drift.Value(isIncome),
          interval: recurringInterval,
          period: recurringPeriod,
          nextDueDate: nextDueDate.toIso8601String(),
          note: drift.Value(note.trim().isEmpty ? null : note.trim()),
          creditCardId: drift.Value(creditCardId),
        ),
      );
    } else {
      await _db.into(_db.transactions).insert(
        TransactionsCompanion.insert(
          amount: amount,
          title: title.trim(),
          date: date.toIso8601String(),
          categoryId: categoryId,
          isIncome: drift.Value(isIncome),
          note: drift.Value(note.trim().isEmpty ? null : note.trim()),
          creditCardId: drift.Value(creditCardId),
        ),
      );
    }
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    await (_db.update(_db.transactions)..where((t) => t.id.equals(transaction.id!))).write(
      TransactionsCompanion(
        amount: drift.Value(transaction.amount),
        title: drift.Value(transaction.title),
        date: drift.Value(transaction.date.toIso8601String()),
        categoryId: drift.Value(transaction.categoryId),
        isIncome: drift.Value(transaction.isIncome),
        note: drift.Value(transaction.note),
        creditCardId: drift.Value(transaction.creditCardId),
      ),
    );
    onDataChanged.notify();
  }

  static Future<List<Transaction>> getTransactions() async {
    final list = await _db.select(_db.transactions).get();
    return list.map(_mapTransaction).toList();
  }

  static Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final list = await _db.select(_db.recurringTransactions).get();
    return list.map(_mapRecurringTransaction).toList();
  }
  
  static Future<RecurringTransaction?> getRecurringTransactionById(int id) async {
    final data = await (_db.select(_db.recurringTransactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (data == null) return null;
    return _mapRecurringTransaction(data);
  }
  
  static Future<void> updateRecurringTransaction(RecurringTransaction transaction) async {
    await (_db.update(_db.recurringTransactions)..where((t) => t.id.equals(transaction.id!))).write(
      RecurringTransactionsCompanion(
        amount: drift.Value(transaction.amount),
        title: drift.Value(transaction.title),
        categoryId: drift.Value(transaction.categoryId),
        isIncome: drift.Value(transaction.isIncome),
        interval: drift.Value(transaction.interval),
        period: drift.Value(transaction.period),
        nextDueDate: drift.Value(transaction.nextDueDate.toIso8601String()),
        note: drift.Value(transaction.note),
        creditCardId: drift.Value(transaction.creditCardId),
      ),
    );
    onDataChanged.notify();
  }
  static Future<void> deleteTransaction(int id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
    onDataChanged.notify();
  }

  static Future<void> deleteRecurringTransaction(int id) async {
    await (_db.delete(_db.recurringTransactions)..where((t) => t.id.equals(id))).go();
    onDataChanged.notify();
  }
  
  static Future<void> insertTransaction(Transaction transaction) async {
    await _db.into(_db.transactions).insert(
      TransactionsCompanion.insert(
        amount: transaction.amount,
        title: transaction.title,
        date: transaction.date.toIso8601String(),
        categoryId: transaction.categoryId,
        isIncome: drift.Value(transaction.isIncome),
        note: drift.Value(transaction.note),
        recurringId: drift.Value(transaction.recurringId),
        creditCardId: drift.Value(transaction.creditCardId),
      ),
    );
  }

  static Future<List<Transaction>> getTransactionsForCard(int creditCardId) async {
    final list = await (_db.select(_db.transactions)..where((t) => t.creditCardId.equals(creditCardId))).get();
    return list.map(_mapTransaction).toList();
  }

  static DateTime calculateNextDueDate(
    DateTime date,
    int interval,
    String period,
  ) {
    switch (period.toLowerCase()) {
      case 'day(s)':
        return date.add(Duration(days: interval));
      case 'week(s)':
        return date.add(Duration(days: interval * 7));
      case 'month(s)':
        int nextMonth = date.month + interval;
        int nextYear = date.year;
        while (nextMonth > 12) {
          nextMonth -= 12;
          nextYear++;
        }
        int nextDay = date.day;
        final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        if (nextDay > daysInNextMonth) {
          nextDay = daysInNextMonth;
        }
        return DateTime(nextYear, nextMonth, nextDay, date.hour, date.minute);
      case 'year(s)':
        int nextYear = date.year + interval;
        int nextDay = date.day;
        final daysInNextMonth = DateTime(nextYear, date.month + 1, 0).day;
        if (nextDay > daysInNextMonth) {
          nextDay = daysInNextMonth;
        }
        return DateTime(nextYear, date.month, nextDay, date.hour, date.minute);
      default:
        return date.add(Duration(days: interval));
    }
  }

  static Future<DashboardStats> getDashboardStats(DateTime currentMonth) async {
    final allTransactions = await getTransactions();
    final categories = await getCategories();

    // Filter to current month
    final currentMonthTransactions = allTransactions
        .where(
          (t) =>
              t.date.year == currentMonth.year &&
              t.date.month == currentMonth.month,
        )
        .toList();

    // Filter to past month
    final pastMonth = DateTime(currentMonth.year, currentMonth.month - 1);
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
      final category = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => Category(id: -1, name: 'Unknown', isActive: false),
      );
      topCatMap[category] = entry.value;
    }

    final creditCards = await getCreditCards();
    Map<CreditCard, double> rewardsMap = {};

    // Group spending by credit card ID for current month
    Map<int, double> cardSpending = {};
    for (var tx in currentMonthTransactions) {
      if (!tx.isIncome && tx.creditCardId != null) {
        cardSpending[tx.creditCardId!] =
            (cardSpending[tx.creditCardId!] ?? 0) + tx.amount;
      }
    }

    for (var card in creditCards) {
      if (cardSpending.containsKey(card.id)) {
        double spent = cardSpending[card.id]!;
        if (card.rewardType == 'Cashback') {
          rewardsMap[card] =
              ((spent * (card.rewardRate / 100)) * 100).floorToDouble() / 100;
        } else {
          rewardsMap[card] =
              ((spent * card.rewardRate) * 100).floorToDouble() / 100;
        }
      }
    }

    return DashboardStats(
      totalIncome: income,
      totalExpense: expense,
      incomePercentageChange: incomePercentageChange,
      expensePercentageChange: expensePercentageChange,
      topCategories: topCatMap,
      monthlyRewards: rewardsMap,
    );
  }

  static Future<HistoryStats> getHistoryStats() async {
    final transactions = await getTransactions();
    final categories = await getCategories();

    transactions.sort((a, b) => b.date.compareTo(a.date));

    final Map<DateTime, List<Transaction>> grouped = {};
    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(tx);
    }

    return HistoryStats(
      groupedTransactions: grouped,
      categories: categories,
    );
  }
}

class DashboardStats {
  final double totalIncome;
  final double totalExpense;
  final double? incomePercentageChange;
  final double? expensePercentageChange;
  final Map<Category, double> topCategories;
  final Map<CreditCard, double> monthlyRewards;

  DashboardStats({
    required this.totalIncome,
    required this.totalExpense,
    this.incomePercentageChange,
    this.expensePercentageChange,
    required this.topCategories,
    required this.monthlyRewards,
  });
}

class HistoryStats {
  final Map<DateTime, List<Transaction>> groupedTransactions;
  final List<Category> categories;

  HistoryStats({
    required this.groupedTransactions,
    required this.categories,
  });
}
