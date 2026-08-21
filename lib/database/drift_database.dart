import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';


part 'drift_database.g.dart';

@DataClassName('CategoryTableData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get colorHex => text().named('colorHex').nullable()();
  TextColumn get iconString => text().named('iconString').nullable()();
  BoolColumn get isActive => boolean().named('isActive').withDefault(const Constant(true))();
}

@DataClassName('TransactionTableData')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get title => text()();
  TextColumn get date => text()();
  IntColumn get categoryId => integer().named('categoryId').customConstraint('NOT NULL REFERENCES categories(id) ON DELETE RESTRICT')();
  TextColumn get note => text().nullable()();
  BoolColumn get isIncome => boolean().named('isIncome').withDefault(const Constant(false))();
  IntColumn get recurringId => integer().named('recurringId').nullable().customConstraint('REFERENCES recurring_transactions(id) ON DELETE SET NULL')();
}

@DataClassName('RecurringTransactionTableData')
class RecurringTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get title => text()();
  IntColumn get categoryId => integer().named('categoryId').customConstraint('NOT NULL REFERENCES categories(id) ON DELETE RESTRICT')();
  TextColumn get note => text().nullable()();
  BoolColumn get isIncome => boolean().named('isIncome').withDefault(const Constant(false))();
  IntColumn get interval => integer()();
  TextColumn get period => text()();
  TextColumn get nextDueDate => text().named('nextDueDate')();
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

@DriftDatabase(tables: [Categories, Transactions, RecurringTransactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // Insert some default categories
        await into(categories).insert(CategoriesCompanion.insert(name: 'Groceries', colorHex: const Value('#4CAF50')));
        await into(categories).insert(CategoriesCompanion.insert(name: 'Dining', colorHex: const Value('#FF9800')));
        await into(categories).insert(CategoriesCompanion.insert(name: 'Bills', colorHex: const Value('#F44336')));
        await into(categories).insert(CategoriesCompanion.insert(name: 'Entertainment', colorHex: const Value('#9C27B0')));
        await into(categories).insert(CategoriesCompanion.insert(name: 'Transport', colorHex: const Value('#2196F3')));
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
