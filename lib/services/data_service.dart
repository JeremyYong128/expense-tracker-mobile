import 'package:drift/drift.dart' as drift;
import 'package:expense_tracker_mobile/models/transaction.dart';
import 'package:expense_tracker_mobile/models/recurring_transaction.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/models/card.dart';
import 'package:expense_tracker_mobile/database/drift_database.dart';
import 'package:expense_tracker_mobile/core/exceptions.dart';
import '../utils/business_logic.dart';

class DataService {
  static final AppDatabase _db = AppDatabase();

  // --- Mappers ---

  static Category _mapCategory(CategoryTableData data) {
    return Category(
      id: data.id,
      name: data.name,
      colorHex: data.colorHex,
      iconString: data.iconString,
      isActive: data.isActive,
      isExpense: data.isExpense,
      isIncome: data.isIncome,
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
      cardId: data.cardId,
      rewardAmount: data.rewardAmount,
    );
  }

  static Card _mapCard(CardTableData data) {
    return Card(
      id: data.id,
      name: data.name,
      rewardType: data.rewardType,
      rewardRate: data.rewardRate,
      colorHex: data.colorHex,
      isActive: data.isActive,
    );
  }

  static RecurringTransaction _mapRecurringTransaction(
    RecurringTransactionTableData data,
  ) {
    return RecurringTransaction(
      id: data.id,
      amount: data.amount,
      title: data.title,
      categoryId: data.categoryId,
      note: data.note,
      isIncome: data.isIncome,
      interval: data.interval,
      period: data.period,
      startDate: DateTime.parse(data.startDate),
      nextDueDate: DateTime.parse(data.nextDueDate),
      cardId: data.cardId,
      rewardAmount: data.rewardAmount,
    );
  }

  // --- Category Methods ---

  // Get all categories
  static Future<List<Category>> getCategories() async {
    final list = await _db.select(_db.categories).get();
    return list.map(_mapCategory).toList();
  }

  // Add a category
  // Handles duplicate category names by merging them
  static Future<int> addCategory(Category category) async {
    final existing =
        await (_db.select(
              _db.categories,
            )..where((c) => c.name.lower().equals(category.name.toLowerCase())))
            .getSingleOrNull();

    if (existing != null) {
      await (_db.update(
        _db.categories,
      )..where((c) => c.id.equals(existing.id))).write(
        CategoriesCompanion(
          isActive: drift.Value(category.isActive),
          colorHex: drift.Value(category.colorHex),
          iconString: drift.Value(category.iconString),
          isExpense: drift.Value(category.isExpense),
          isIncome: drift.Value(category.isIncome),
        ),
      );
      return existing.id;
    }

    final newId = await _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: category.name,
            colorHex: drift.Value(category.colorHex),
            iconString: drift.Value(category.iconString),
            isActive: drift.Value(category.isActive),
            isExpense: drift.Value(category.isExpense),
            isIncome: drift.Value(category.isIncome),
          ),
        );
    return newId;
  }

  // Update a category
  // Handles collisions with existing categories by merging and using the existing category's id
  static Future<int> updateCategory(Category category) async {
    final existing =
        await (_db.select(_db.categories)
              ..where((c) => c.name.lower().equals(category.name.toLowerCase()))
              ..where((c) => c.id.equals(category.id!).not()))
            .getSingleOrNull();

    if (existing != null) {
      await (_db.update(
        _db.categories,
      )..where((c) => c.id.equals(existing.id))).write(
        CategoriesCompanion(
          name: drift.Value(category.name),
          colorHex: drift.Value(category.colorHex),
          iconString: drift.Value(category.iconString),
          isActive: drift.Value(category.isActive),
          isExpense: drift.Value(category.isExpense),
          isIncome: drift.Value(category.isIncome),
        ),
      );

      await (_db.update(_db.transactions)
            ..where((t) => t.categoryId.equals(category.id!)))
          .write(TransactionsCompanion(categoryId: drift.Value(existing.id)));
      await (_db.update(
        _db.recurringTransactions,
      )..where((r) => r.categoryId.equals(category.id!))).write(
        RecurringTransactionsCompanion(categoryId: drift.Value(existing.id)),
      );

      await (_db.delete(
        _db.categories,
      )..where((c) => c.id.equals(category.id!))).go();

      return existing.id;
    }

    await (_db.update(
      _db.categories,
    )..where((c) => c.id.equals(category.id!))).write(
      CategoriesCompanion(
        name: drift.Value(category.name),
        colorHex: drift.Value(category.colorHex),
        iconString: drift.Value(category.iconString),
        isActive: drift.Value(category.isActive),
        isExpense: drift.Value(category.isExpense),
        isIncome: drift.Value(category.isIncome),
      ),
    );
    return category.id!;
  }

  // Delete a category
  // If the category has associated transactions or recurring transactions, it will be deactivated instead of deleted
  static Future<void> deleteCategory(int id) async {
    final txCount = await (_db.select(
      _db.transactions,
    )..where((t) => t.categoryId.equals(id))).get();
    final recCount = await (_db.select(
      _db.recurringTransactions,
    )..where((r) => r.categoryId.equals(id))).get();

    if (txCount.isNotEmpty || recCount.isNotEmpty) {
      await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
        const CategoriesCompanion(isActive: drift.Value(false)),
      );
    } else {
      await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
    }
  }

  // --- Card Methods ---

  // Get all cards
  static Future<List<Card>> getCards() async {
    final list = await _db.select(_db.cards).get();
    return list.map(_mapCard).toList();
  }

  // Add card
  // Throws an exception if a card with the same name already exists
  static Future<int> addCard(Card card) async {
    final existing =
        await (_db.select(_db.cards)
              ..where((c) => c.name.lower().equals(card.name.toLowerCase()))
              ..where((c) => c.isActive.equals(true)))
            .getSingleOrNull();

    if (existing != null) {
      throw ValidationException(
        'A card with this name already exists.',
      );
    }

    final id = await _db
        .into(_db.cards)
        .insert(
          CardsCompanion.insert(
            name: card.name,
            rewardType: card.rewardType,
            rewardRate: card.rewardRate,
            colorHex: drift.Value(card.colorHex),
            isActive: drift.Value(card.isActive),
          ),
        );
    return id;
  }

  // Update card
  // Throws an exception if a card with the same name already exists
  static Future<void> updateCard(Card card) async {
    final existing =
        await (_db.select(_db.cards)
              ..where((c) => c.name.lower().equals(card.name.toLowerCase()))
              ..where((c) => c.isActive.equals(true))
              ..where((c) => c.id.equals(card.id!).not()))
            .getSingleOrNull();

    if (existing != null) {
      throw ValidationException(
        'A card with this name already exists.',
      );
    }

    await (_db.update(
      _db.cards,
    )..where((c) => c.id.equals(card.id!))).write(
      CardsCompanion(
        name: drift.Value(card.name),
        rewardType: drift.Value(card.rewardType),
        rewardRate: drift.Value(card.rewardRate),
        colorHex: drift.Value(card.colorHex),
        isActive: drift.Value(card.isActive),
      ),
    );
  }

  // Delete card
  // Soft delete if there are transactions associated with it, unless forceHardDelete is true
  static Future<bool> deleteCard(int id, {bool forceHardDelete = false}) async {
    final txCount = await (_db.select(
      _db.transactions,
    )..where((t) => t.cardId.equals(id))).get();
    final recCount = await (_db.select(
      _db.recurringTransactions,
    )..where((r) => r.cardId.equals(id))).get();
    
    final hasTransactions = txCount.isNotEmpty || recCount.isNotEmpty;

    if (forceHardDelete) {
      await (_db.delete(_db.cards)..where((c) => c.id.equals(id))).go();
      return hasTransactions;
    }

    if (hasTransactions) {
      await (_db.update(_db.cards)..where((c) => c.id.equals(id))).write(
        const CardsCompanion(isActive: drift.Value(false)),
      );
      return false;
    } else {
      await (_db.delete(_db.cards)..where((c) => c.id.equals(id))).go();
      return false;
    }
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
    int? cardId,
    int? recurringId,
    double? rewardAmount,
  }) async {
    final amount = double.parse(amountText);
    final recurringInterval = int.tryParse(recurringIntervalText) ?? 1;

    if (isRecurring) {
      await _db
          .into(_db.recurringTransactions)
          .insert(
            RecurringTransactionsCompanion.insert(
              amount: amount,
              title: title.trim(),
              categoryId: categoryId,
              isIncome: drift.Value(isIncome),
              interval: recurringInterval,
              period: recurringPeriod,
              startDate: drift.Value(date.toIso8601String()),
              nextDueDate: date.toIso8601String(),
              note: drift.Value(note.trim().isEmpty ? null : note.trim()),
              cardId: drift.Value(cardId),
              rewardAmount: drift.Value(rewardAmount),
            ),
          );
    } else {
      await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              amount: amount,
              title: title.trim(),
              date: date.toIso8601String(),
              categoryId: categoryId,
              isIncome: drift.Value(isIncome),
              note: drift.Value(note.trim().isEmpty ? null : note.trim()),
              cardId: drift.Value(cardId),
              recurringId: drift.Value(recurringId),
              rewardAmount: drift.Value(rewardAmount),
            ),
          );
    }
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    await (_db.update(
      _db.transactions,
    )..where((t) => t.id.equals(transaction.id!))).write(
      TransactionsCompanion(
        amount: drift.Value(transaction.amount),
        title: drift.Value(transaction.title),
        date: drift.Value(transaction.date.toIso8601String()),
        categoryId: drift.Value(transaction.categoryId),
        isIncome: drift.Value(transaction.isIncome),
        note: drift.Value(transaction.note),
        cardId: drift.Value(transaction.cardId),
        recurringId: drift.Value(transaction.recurringId),
        rewardAmount: drift.Value(transaction.rewardAmount),
      ),
    );
  }

  static Future<List<Transaction>> getTransactions() async {
    final list = await _db.select(_db.transactions).get();
    return list.map(_mapTransaction).toList();
  }

  static Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final list = await _db.select(_db.recurringTransactions).get();
    return list.map(_mapRecurringTransaction).toList();
  }

  static Future<RecurringTransaction?> getRecurringTransactionById(
    int id,
  ) async {
    final data = await (_db.select(
      _db.recurringTransactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (data == null) return null;
    return _mapRecurringTransaction(data);
  }

  static Future<void> updateRecurringTransaction(
    RecurringTransaction transaction,
  ) async {
    // Shift and Keep History
    DateTime newNextDueDate = transaction.startDate;

    // Fetch all existing child transactions
    final children = await (_db.select(
      _db.transactions,
    )..where((t) => t.recurringId.equals(transaction.id!))).get();

    if (children.isNotEmpty) {
      children.sort(
        (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)),
      );
      final latestChildDate = DateTime.parse(children.last.date);

      while (newNextDueDate.isBefore(latestChildDate) ||
          newNextDueDate.isAtSameMomentAs(latestChildDate)) {
        newNextDueDate = calculateNextDueDate(
          newNextDueDate,
          transaction.interval,
          transaction.period,
        );
      }
    }

    await (_db.update(
      _db.recurringTransactions,
    )..where((t) => t.id.equals(transaction.id!))).write(
      RecurringTransactionsCompanion(
        amount: drift.Value(transaction.amount),
        title: drift.Value(transaction.title),
        categoryId: drift.Value(transaction.categoryId),
        isIncome: drift.Value(transaction.isIncome),
        interval: drift.Value(transaction.interval),
        period: drift.Value(transaction.period),
        startDate: drift.Value(transaction.startDate.toIso8601String()),
        nextDueDate: drift.Value(newNextDueDate.toIso8601String()),
        note: drift.Value(transaction.note),
        cardId: drift.Value(transaction.cardId),
        rewardAmount: drift.Value(transaction.rewardAmount),
      ),
    );
  }

  static Future<void> updateRecurringTransactionNextDueDate(int id, DateTime nextDueDate) async {
    await (_db.update(
      _db.recurringTransactions,
    )..where((t) => t.id.equals(id))).write(
      RecurringTransactionsCompanion(
        nextDueDate: drift.Value(nextDueDate.toIso8601String()),
      ),
    );
  }

  static Future<void> deleteTransaction(int id) async {
    final tx = await (_db.select(_db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();

    if (tx != null) {
      final category = await (_db.select(_db.categories)..where((c) => c.id.equals(tx.categoryId))).getSingleOrNull();
      if (category != null && !category.isActive) {
        await deleteCategory(category.id);
      }
    }
  }

  static Future<void> deleteRecurringTransaction(int id) async {
    final tx = await (_db.select(_db.recurringTransactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    await (_db.delete(
      _db.recurringTransactions,
    )..where((t) => t.id.equals(id))).go();

    if (tx != null) {
      final category = await (_db.select(_db.categories)..where((c) => c.id.equals(tx.categoryId))).getSingleOrNull();
      if (category != null && !category.isActive) {
        await deleteCategory(category.id);
      }
    }
  }

  static Future<void> insertTransaction(Transaction transaction) async {
    await _db
        .into(_db.transactions)
        .insert(
          TransactionsCompanion.insert(
            amount: transaction.amount,
            title: transaction.title,
            date: transaction.date.toIso8601String(),
            categoryId: transaction.categoryId,
            isIncome: drift.Value(transaction.isIncome),
            note: drift.Value(transaction.note),
            recurringId: drift.Value(transaction.recurringId),
            cardId: drift.Value(transaction.cardId),
            rewardAmount: drift.Value(transaction.rewardAmount),
          ),
        );
  }

  static Future<List<Transaction>> getTransactionsForCard(
    int cardId,
  ) async {
    final list = await (_db.select(
      _db.transactions,
    )..where((t) => t.cardId.equals(cardId))).get();
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

  static DashboardStats computeDashboardStats(
    List<Transaction> allTransactions,
    List<Category> categories,
    List<Card> cards,
    DateTime currentMonth,
  ) {
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

    final incomePercentageChange = BusinessLogic.calculatePercentageChange(income, pastIncome);
    final expensePercentageChange = BusinessLogic.calculatePercentageChange(expense, pastExpense);

    // Sort category spending to get top ones
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Map to Category objects (take top 4)
    Map<Category, double> topCatMap = {};
    for (var entry in sortedCategories.take(4)) {
      final category = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => Category(id: -1, name: 'Unknown', colorHex: '#9E9E9E', isActive: false),
      );
      topCatMap[category] = entry.value;
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

    for (var card in cards) {
      if (cardRewards.containsKey(card.id)) {
        rewardsMap[card] = cardRewards[card.id]!;
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

  static HistoryStats computeHistoryStats(
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    // create a copy to sort
    final sortedTransactions = List<Transaction>.from(transactions);
    sortedTransactions.sort((a, b) => b.date.compareTo(a.date));

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

class DashboardStats {
  final double totalIncome;
  final double totalExpense;
  final double? incomePercentageChange;
  final double? expensePercentageChange;
  final Map<Category, double> topCategories;
  final Map<Card, double> monthlyRewards;

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

  HistoryStats({required this.groupedTransactions, required this.categories});
}
