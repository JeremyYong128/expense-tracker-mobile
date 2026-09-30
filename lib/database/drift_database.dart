import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker_mobile/utils/logger.dart';

part 'drift_database.g.dart';

@DataClassName('CategoryTableData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get colorHex =>
      text().named('colorHex').withDefault(const Constant('#9E9E9E'))();
  TextColumn get iconString => text().named('iconString').nullable()();
  BoolColumn get isActive =>
      boolean().named('isActive').withDefault(const Constant(true))();
  BoolColumn get isExpense =>
      boolean().named('isExpense').withDefault(const Constant(true))();
  BoolColumn get isIncome =>
      boolean().named('isIncome').withDefault(const Constant(false))();
  IntColumn get sortOrder =>
      integer().named('sortOrder').withDefault(const Constant(0))();
}

@DataClassName('TransactionTableData')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get title => text()();
  TextColumn get date => text()();
  IntColumn get categoryId => integer()
      .named('categoryId')
      .customConstraint(
        'NOT NULL REFERENCES categories(id) ON DELETE RESTRICT',
      )();
  TextColumn get note => text().nullable()();
  BoolColumn get isIncome =>
      boolean().named('isIncome').withDefault(const Constant(false))();
  RealColumn get rewardAmount => real().nullable()();
  IntColumn get recurringId => integer()
      .named('recurringId')
      .nullable()
      .customConstraint(
        'REFERENCES recurring_transactions(id) ON DELETE SET NULL',
      )();
  IntColumn get cardId => integer()
      .named('cardId')
      .nullable()
      .customConstraint('REFERENCES cards(id) ON DELETE SET NULL')();
  TextColumn get currencyCode => text().withDefault(const Constant('SGD'))();
  RealColumn get baseCurrencyAmount =>
      real().withDefault(const Constant(0.0))();
}

@DataClassName('CardTableData')
class Cards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get rewardType => text().named('rewardType')();
  RealColumn get rewardRate => real().named('rewardRate')();
  TextColumn get colorHex =>
      text().named('colorHex').withDefault(const Constant('#9E9E9E'))();
  BoolColumn get isActive =>
      boolean().named('isActive').withDefault(const Constant(true))();
  IntColumn get sortOrder =>
      integer().named('sortOrder').withDefault(const Constant(0))();
  TextColumn get currencyCode => text().withDefault(const Constant('SGD'))();
}

@DataClassName('RecurringTransactionTableData')
class RecurringTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get title => text()();
  IntColumn get categoryId => integer()
      .named('categoryId')
      .customConstraint(
        'NOT NULL REFERENCES categories(id) ON DELETE RESTRICT',
      )();
  TextColumn get note => text().nullable()();
  BoolColumn get isIncome =>
      boolean().named('isIncome').withDefault(const Constant(false))();
  RealColumn get rewardAmount => real().nullable()();
  IntColumn get interval => integer()();
  TextColumn get period => text()();
  TextColumn get startDate =>
      text().named('startDate').withDefault(const Constant(''))();
  TextColumn get nextDueDate => text().named('nextDueDate')();
  IntColumn get cardId => integer()
      .named('cardId')
      .nullable()
      .customConstraint('REFERENCES cards(id) ON DELETE SET NULL')();
  IntColumn get sortOrder =>
      integer().named('sortOrder').withDefault(const Constant(0))();
  TextColumn get currencyCode => text().withDefault(const Constant('SGD'))();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get month => integer()();
  IntColumn get year => integer()();
  TextColumn get type => text()();

  IntColumn get categoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get cardId => integer().nullable().references(
    Cards,
    #id,
    onDelete: KeyAction.cascade,
  )();

  RealColumn get amount => real().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {month, year, type, categoryId, cardId},
  ];
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'expense_tracker.db'));

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [Categories, Transactions, RecurringTransactions, Cards, Budgets],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 19;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        // Insert default expense categories
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Food & Dining',
            colorHex: const Value('#FF9800'),
            iconString: const Value('restaurant'),
            isExpense: const Value(true),
            isIncome: const Value(false),
          ),
        );
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Groceries',
            colorHex: const Value('#4CAF50'),
            iconString: const Value('shopping_cart'),
            isExpense: const Value(true),
            isIncome: const Value(false),
          ),
        );
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Transport',
            colorHex: const Value('#2196F3'),
            iconString: const Value('directions_car'),
            isExpense: const Value(true),
            isIncome: const Value(false),
          ),
        );
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Bills & Utilities',
            colorHex: const Value('#F44336'),
            iconString: const Value('receipt'),
            isExpense: const Value(true),
            isIncome: const Value(false),
          ),
        );
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Entertainment',
            colorHex: const Value('#9C27B0'),
            iconString: const Value('movie'),
            isExpense: const Value(true),
            isIncome: const Value(false),
          ),
        );
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Shopping',
            colorHex: const Value('#E91E63'),
            iconString: const Value('shopping_bag'),
            isExpense: const Value(true),
            isIncome: const Value(false),
          ),
        );

        // Insert default income categories
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Salary',
            colorHex: const Value('#009688'),
            iconString: const Value('work'),
            isExpense: const Value(false),
            isIncome: const Value(true),
          ),
        );
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Investment',
            colorHex: const Value('#3F51B5'),
            iconString: const Value('trending_up'),
            isExpense: const Value(false),
            isIncome: const Value(true),
          ),
        );
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Gift',
            colorHex: const Value('#FFC107'),
            iconString: const Value('card_giftcard'),
            isExpense: const Value(false),
            isIncome: const Value(true),
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 11) {
          try {
            await customStatement('ALTER TABLE credit_cards RENAME TO cards;');
            await customStatement(
              'ALTER TABLE transactions RENAME COLUMN creditCardId TO cardId;',
            );
            await customStatement(
              'ALTER TABLE recurring_transactions RENAME COLUMN creditCardId TO cardId;',
            );
          } catch (e, stack) {
            AppLogger.error(
              'Failed to rename credit_cards table and columns',
              e,
              stack,
            );
            rethrow;
          }
        }

        // --- Robust Migration Fallback ---
        // Ensure ALL tables and columns exist to prevent crashes from
        // messy or skipped database migrations in older app versions.
        final db = this;
        for (final table in db.allTables) {
          // 1. Check if the table exists
          final tableResult = await customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='${table.actualTableName}'",
          ).get();

          if (tableResult.isEmpty) {
            // Table doesn't exist, create it
            await m.createTable(table);
          } else {
            // 2. Table exists, check for missing columns
            final columnResult = await customSelect(
              'PRAGMA table_info(${table.actualTableName})',
            ).get();
            final existingColumns = columnResult
                .map((row) => row.read<String>('name'))
                .toSet();

            for (final column in table.$columns) {
              if (!existingColumns.contains(column.name)) {
                await m.addColumn(table, column);
              }
            }
          }
        }

        // Run specific data migrations AFTER schema is guaranteed to be correct
        if (from < 4) {
          try {
            await customStatement(
              'UPDATE recurring_transactions SET startDate = nextDueDate',
            );
          } catch (e, stack) {
            AppLogger.error(
              'Data migration failed during schema upgrade to v4',
              e,
              stack,
            );
            rethrow;
          }
        }

        if (from < 10) {
          try {
            await customStatement('''
              UPDATE transactions 
              SET rewardAmount = (
                SELECT CASE 
                  WHEN cards.rewardType = 'Cashback' THEN transactions.amount * (cards.rewardRate / 100.0)
                  ELSE transactions.amount * cards.rewardRate
                END
                FROM cards 
                WHERE cards.id = transactions.cardId
              )
              WHERE cardId IS NOT NULL AND isIncome = 0;
            ''');

            await customStatement('''
              UPDATE recurring_transactions 
              SET rewardAmount = (
                SELECT CASE 
                  WHEN cards.rewardType = 'Cashback' THEN recurring_transactions.amount * (cards.rewardRate / 100.0)
                  ELSE recurring_transactions.amount * cards.rewardRate
                END
                FROM cards 
                WHERE cards.id = recurring_transactions.cardId
              )
              WHERE cardId IS NOT NULL AND isIncome = 0;
            ''');
          } catch (e, stack) {
            AppLogger.error(
              'Data migration failed during schema upgrade to v10',
              e,
              stack,
            );
            rethrow;
          }
        }
        if (from < 12) {
          try {
            await m.addColumn(categories, categories.sortOrder);
            await customStatement('''
              UPDATE categories SET sortOrder = id;
            ''');

            await m.addColumn(cards, cards.sortOrder);
            await customStatement('''
              UPDATE cards SET sortOrder = id;
            ''');

            await m.addColumn(
              recurringTransactions,
              recurringTransactions.sortOrder,
            );
            await customStatement('''
              UPDATE recurring_transactions SET sortOrder = id;
            ''');
          } catch (e, stack) {
            AppLogger.error(
              'Data migration failed during schema upgrade to v12',
              e,
              stack,
            );
            rethrow;
          }
        }
        if (from < 14) {
          try {
            await m.alterTable(TableMigration(budgets));
          } catch (e, stack) {
            AppLogger.error(
              'Data migration failed during schema upgrade to v14',
              e,
              stack,
            );
            rethrow;
          }
        }
        if (from < 17) {
          try {
            await customStatement(
              "UPDATE transactions SET currency_code = 'SGD' WHERE currency_code IS NULL;",
            );
            await customStatement(
              "UPDATE transactions SET base_currency_amount = amount WHERE base_currency_amount IS NULL OR base_currency_amount = 0.0;",
            );
            await customStatement(
              "UPDATE recurring_transactions SET currency_code = 'SGD' WHERE currency_code IS NULL;",
            );
          } catch (e, stack) {
            AppLogger.error('Failed to migrate baseCurrencyAmount', e, stack);
            rethrow;
          }
        }
        if (from < 18) {
          try {
            await customStatement(
              "UPDATE cards SET currency_code = 'SGD' WHERE currency_code IS NULL;",
            );
          } catch (e, stack) {
            AppLogger.error('Failed to migrate cards currencyCode', e, stack);
            rethrow;
          }
        }
        if (from < 19) {
          try {
            await customStatement(
              "DELETE FROM budgets WHERE amount IS NULL;",
            );
            
            // Rewind the copy service by 1 month so it re-evaluates the current month
            final prefs = await SharedPreferences.getInstance();
            final lastMonth = prefs.getInt('last_budget_copy_month');
            final lastYear = prefs.getInt('last_budget_copy_year');
            if (lastMonth != null && lastYear != null) {
              int newMonth = lastMonth - 1;
              int newYear = lastYear;
              if (newMonth == 0) {
                newMonth = 12;
                newYear--;
              }
              await prefs.setInt('last_budget_copy_month', newMonth);
              await prefs.setInt('last_budget_copy_year', newYear);
            }
          } catch (e, stack) {
            AppLogger.error('Failed to clean up tombstones', e, stack);
            rethrow;
          }
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
