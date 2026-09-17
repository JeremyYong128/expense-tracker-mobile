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
    final list =
        await (_db.select(_db.categories)..orderBy([
              (t) => drift.OrderingTerm(
                expression: t.sortOrder,
                mode: drift.OrderingMode.asc,
              ),
            ]))
            .get();
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

    final minSortOrderCat =
        await (_db.select(_db.categories)
              ..orderBy([
                (t) => drift.OrderingTerm(
                  expression: t.sortOrder,
                  mode: drift.OrderingMode.asc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    final newSortOrder = (minSortOrderCat?.sortOrder ?? 0) - 1;

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
            sortOrder: drift.Value(newSortOrder),
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

      // Merge budgets using point-by-point summation to preserve accurate budget capacity
      await _mergeBudgets(category.id!, existing.id);

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
    final budgetCount = await (_db.select(
      _db.budgets,
    )..where((b) => b.categoryId.equals(id))).get();

    if (txCount.isNotEmpty || recCount.isNotEmpty || budgetCount.isNotEmpty) {
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
    final list =
        await (_db.select(_db.cards)..orderBy([
              (t) => drift.OrderingTerm(
                expression: t.sortOrder,
                mode: drift.OrderingMode.asc,
              ),
            ]))
            .get();
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
      throw ValidationException('A card with this name already exists.');
    }

    final minSortOrderCard =
        await (_db.select(_db.cards)
              ..orderBy([
                (t) => drift.OrderingTerm(
                  expression: t.sortOrder,
                  mode: drift.OrderingMode.asc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    final newSortOrder = (minSortOrderCard?.sortOrder ?? 0) - 1;

    final id = await _db
        .into(_db.cards)
        .insert(
          CardsCompanion.insert(
            name: card.name,
            rewardType: card.rewardType,
            rewardRate: card.rewardRate,
            colorHex: drift.Value(card.colorHex),
            isActive: drift.Value(card.isActive),
            sortOrder: drift.Value(newSortOrder),
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
      throw ValidationException('A card with this name already exists.');
    }

    await (_db.update(_db.cards)..where((c) => c.id.equals(card.id!))).write(
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
    final budgetCount = await (_db.select(
      _db.budgets,
    )..where((b) => b.cardId.equals(id))).get();

    final hasTransactions =
        txCount.isNotEmpty || recCount.isNotEmpty || budgetCount.isNotEmpty;

    if (forceHardDelete) {
      // Delete budgets tied to this card
      await (_db.delete(_db.budgets)..where((b) => b.cardId.equals(id))).go();

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
      final minSortOrderTx =
          await (_db.select(_db.recurringTransactions)
                ..orderBy([
                  (t) => drift.OrderingTerm(
                    expression: t.sortOrder,
                    mode: drift.OrderingMode.asc,
                  ),
                ])
                ..limit(1))
              .getSingleOrNull();
      final newSortOrder = (minSortOrderTx?.sortOrder ?? 0) - 1;

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
              sortOrder: drift.Value(newSortOrder),
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
    final list =
        await (_db.select(_db.recurringTransactions)..orderBy([
              (t) => drift.OrderingTerm(
                expression: t.sortOrder,
                mode: drift.OrderingMode.asc,
              ),
            ]))
            .get();
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
        newNextDueDate = BusinessLogic.calculateNextDueDate(
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

  static Future<void> updateRecurringTransactionNextDueDate(
    int id,
    DateTime nextDueDate,
  ) async {
    await (_db.update(
      _db.recurringTransactions,
    )..where((t) => t.id.equals(id))).write(
      RecurringTransactionsCompanion(
        nextDueDate: drift.Value(nextDueDate.toIso8601String()),
      ),
    );
  }

  static Future<void> deleteTransaction(int id) async {
    final tx = await (_db.select(
      _db.transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();

    if (tx != null) {
      final category = await (_db.select(
        _db.categories,
      )..where((c) => c.id.equals(tx.categoryId))).getSingleOrNull();
      if (category != null && !category.isActive) {
        await deleteCategory(category.id);
      }
    }
  }

  static Future<void> deleteRecurringTransaction(int id) async {
    final tx = await (_db.select(
      _db.recurringTransactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    await (_db.delete(
      _db.recurringTransactions,
    )..where((t) => t.id.equals(id))).go();

    if (tx != null) {
      final category = await (_db.select(
        _db.categories,
      )..where((c) => c.id.equals(tx.categoryId))).getSingleOrNull();
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

  static Future<List<Transaction>> getTransactionsForCard(int cardId) async {
    final list = await (_db.select(
      _db.transactions,
    )..where((t) => t.cardId.equals(cardId))).get();
    return list.map(_mapTransaction).toList();
  }

  static Future<void> updateCategoriesOrder(List<Category> categories) async {
    await _db.batch((batch) {
      for (final category in categories) {
        batch.update(
          _db.categories,
          CategoriesCompanion(sortOrder: drift.Value(category.sortOrder)),
          where: (c) => c.id.equals(category.id!),
        );
      }
    });
  }

  static Future<void> updateCardsOrder(List<Card> cards) async {
    await _db.batch((batch) {
      for (final card in cards) {
        batch.update(
          _db.cards,
          CardsCompanion(sortOrder: drift.Value(card.sortOrder)),
          where: (c) => c.id.equals(card.id!),
        );
      }
    });
  }

  static Future<void> updateRecurringTransactionsOrder(
    List<RecurringTransaction> transactions,
  ) async {
    await _db.batch((batch) {
      for (final tx in transactions) {
        batch.update(
          _db.recurringTransactions,
          RecurringTransactionsCompanion(sortOrder: drift.Value(tx.sortOrder)),
          where: (t) => t.id.equals(tx.id!),
        );
      }
    });
  }

  // --- Budget Methods ---
  static Future<List<Budget>> getAllBudgets() async {
    return await _db.select(_db.budgets).get();
  }

  static Future<List<Budget>> getBudgetsForMonth(int month, int year) async {
    return await (_db.select(_db.budgets)
          ..where((b) => b.month.equals(month) & b.year.equals(year) & b.amount.isNotNull()))
        .get();
  }

  static Future<Budget?> getBudget({
    required int month,
    required int year,
    required String type,
    int? categoryId,
    int? cardId,
  }) async {
    final query = _db.select(_db.budgets)
      ..where((b) => b.month.equals(month))
      ..where((b) => b.year.equals(year))
      ..where((b) => b.type.equals(type));

    if (categoryId != null) {
      query.where((b) => b.categoryId.equals(categoryId));
    } else {
      query.where((b) => b.categoryId.isNull());
    }

    if (cardId != null) {
      query.where((b) => b.cardId.equals(cardId));
    } else {
      query.where((b) => b.cardId.isNull());
    }

    query.limit(1);
    final results = await query.get();
    return results.isEmpty ? null : results.first;
  }

  static Future<void> upsertBudget(BudgetsCompanion budget) async {
    await _db.into(_db.budgets).insertOnConflictUpdate(budget);
  }

  static Future<void> _mergeBudgets(int sourceId, int targetId) async {
    // 1. Fetch budgets for both categories
    final sourceBudgets =
        await (_db.select(_db.budgets)
              ..where((b) => b.categoryId.equals(sourceId))
              ..where((b) => b.type.equals('category')))
            .get();
    final targetBudgets =
        await (_db.select(_db.budgets)
              ..where((b) => b.categoryId.equals(targetId))
              ..where((b) => b.type.equals('category')))
            .get();

    if (sourceBudgets.isEmpty && targetBudgets.isEmpty) return;

    // If source has budgets but target has none, we can just move them (fast path)
    if (targetBudgets.isEmpty) {
      await (_db.update(_db.budgets)
            ..where((b) => b.categoryId.equals(sourceId)))
          .write(BudgetsCompanion(categoryId: drift.Value(targetId)));
      return;
    }

    // If target has budgets but source has none, we do nothing (fast path)
    if (sourceBudgets.isEmpty) return;

    // Both have budgets. Perform point-by-point summation.
    final sourceMap = {
      for (final b in sourceBudgets)
        '${b.year}-${b.month.toString().padLeft(2, '0')}': b,
    };
    final targetMap = {
      for (final b in targetBudgets)
        '${b.year}-${b.month.toString().padLeft(2, '0')}': b,
    };

    // Sort keys chronologically
    final allKeys = {...sourceMap.keys, ...targetMap.keys}.toList()..sort();

    final newBudgets = <BudgetsCompanion>[];
    bool wasLastTombstone = false;

    for (final key in allKeys) {
      final s = sourceMap[key];
      final t = targetMap[key];

      final sAmt = s?.amount;
      final tAmt = t?.amount;

      final sNoValue = s == null || sAmt == null;
      final tNoValue = t == null || tAmt == null;

      double? summedAmount;
      if (sNoValue && tNoValue) {
        summedAmount = null; // Either missing or tombstone for both
      } else {
        summedAmount = (sAmt ?? 0.0) + (tAmt ?? 0.0);
      }

      // Prevent multiple consecutive tombstones
      if (summedAmount == null) {
        if (wasLastTombstone) {
          continue;
        }
        wasLastTombstone = true;
      } else {
        wasLastTombstone = false;
      }

      final year = s?.year ?? t!.year;
      final month = s?.month ?? t!.month;

      newBudgets.add(
        BudgetsCompanion.insert(
          month: month,
          year: year,
          type: 'category',
          categoryId: drift.Value(targetId),
          amount: drift.Value(summedAmount),
        ),
      );
    }

    // Delete old budgets for both
    await (_db.delete(_db.budgets)
          ..where((b) => b.categoryId.isIn([sourceId, targetId]))
          ..where((b) => b.type.equals('category')))
        .go();

    // Insert new combined budgets
    await _db.batch((batch) {
      batch.insertAll(_db.budgets, newBudgets);
    });
  }
}
