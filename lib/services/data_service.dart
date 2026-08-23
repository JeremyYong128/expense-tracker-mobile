import 'package:drift/drift.dart' as drift;
import '../models/transaction.dart';
import '../models/recurring_transaction.dart';
import '../models/category.dart';
import '../models/credit_card.dart';
import '../database/drift_database.dart';

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
      return existing.id;
    }

    return await _db.into(_db.categories).insert(
      CategoriesCompanion.insert(
        name: category.name,
        colorHex: drift.Value(category.colorHex),
        iconString: drift.Value(category.iconString),
        isActive: drift.Value(category.isActive),
      ),
    );
  }

  static Future<int> updateCategory(Category category) async {
    await (_db.update(_db.categories)..where((c) => c.id.equals(category.id!))).write(
      CategoriesCompanion(
        name: drift.Value(category.name),
        colorHex: drift.Value(category.colorHex),
        iconString: drift.Value(category.iconString),
        isActive: drift.Value(category.isActive),
      ),
    );
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
  }

  // --- Credit Card Methods ---

  static Future<List<CreditCard>> getCreditCards() async {
    final list = await _db.select(_db.creditCards).get();
    return list.map(_mapCreditCard).toList();
  }

  static Future<int> addCreditCard(CreditCard card) async {
    return await _db.into(_db.creditCards).insert(
      CreditCardsCompanion.insert(
        name: card.name,
        rewardType: card.rewardType,
        rewardRate: card.rewardRate,
      ),
    );
  }

  static Future<void> updateCreditCard(CreditCard card) async {
    await (_db.update(_db.creditCards)..where((c) => c.id.equals(card.id!))).write(
      CreditCardsCompanion(
        name: drift.Value(card.name),
        rewardType: drift.Value(card.rewardType),
        rewardRate: drift.Value(card.rewardRate),
      ),
    );
  }

  static Future<void> deleteCreditCard(int id) async {
    await (_db.delete(_db.creditCards)..where((c) => c.id.equals(id))).go();
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
  }
  static Future<void> deleteTransaction(int id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  static Future<void> deleteRecurringTransaction(int id) async {
    await (_db.delete(_db.recurringTransactions)..where((t) => t.id.equals(id))).go();
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
}
