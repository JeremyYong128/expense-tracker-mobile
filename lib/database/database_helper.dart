import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/recurring_transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    // Development only: Delete existing database on every app launch
    await deleteDatabase(path);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        colorHex TEXT,
        iconString TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        note TEXT,
        isIncome INTEGER NOT NULL DEFAULT 0,
        recurringId INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE RESTRICT,
        FOREIGN KEY (recurringId) REFERENCES recurring_transactions (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recurring_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        title TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        note TEXT,
        isIncome INTEGER NOT NULL DEFAULT 0,
        interval INTEGER NOT NULL,
        period TEXT NOT NULL,
        nextDueDate TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE RESTRICT
      )
    ''');

    // Insert some default categories
    await db.execute('''
      INSERT INTO categories (name, colorHex) VALUES 
      ('Groceries', '#4CAF50'),
      ('Dining', '#FF9800'),
      ('Bills', '#F44336'),
      ('Entertainment', '#9C27B0'),
      ('Transport', '#2196F3')
    ''');

    // Insert some mock transactions
    final now = DateTime.now();
    await db.execute('''
      INSERT INTO transactions (amount, title, date, categoryId, note, isIncome) VALUES 
      (45.99, 'Trader Joe''s', '${now.subtract(const Duration(days: 2)).toIso8601String()}', 1, '', 0),
      (1500.00, 'Paycheck', '${now.subtract(const Duration(days: 3)).toIso8601String()}', 4, '', 1),
      (15.00, 'Starbucks', '${now.subtract(const Duration(days: 1)).toIso8601String()}', 2, 'morning coffee', 0),
      (120.50, 'Electric Bill', '${now.subtract(const Duration(days: 4)).toIso8601String()}', 3, '', 0)
    ''');

    // Insert some mock recurring transactions
    await db.execute('''
      INSERT INTO recurring_transactions (amount, title, categoryId, note, isIncome, interval, period, nextDueDate) VALUES 
      (15.99, 'Netflix Subscription', 4, '', 0, 1, 'month(s)', '${now.subtract(const Duration(days: 70)).toIso8601String()}'),
      (49.99, 'Gym Membership', 5, '', 0, 1, 'month(s)', '${now.subtract(const Duration(days: 5)).toIso8601String()}')
    ''');
  }

  Future<List<Category>> getCategories() async {
    final db = await instance.database;
    final maps = await db.query('categories');
    
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<int> insertCategory(Category category) async {
    final db = await instance.database;
    
    // Check if a category with the same name already exists (case-insensitive)
    final maps = await db.query(
      'categories',
      where: 'LOWER(name) = ?',
      whereArgs: [category.name.toLowerCase()],
    );

    if (maps.isNotEmpty) {
      // Revive and merge with existing category
      final existingId = maps.first['id'] as int;
      await db.update(
        'categories',
        {
          'name': category.name, // Keep the new exact casing
          'colorHex': category.colorHex,
          'iconString': category.iconString,
          'isActive': 1,
        },
        where: 'id = ?',
        whereArgs: [existingId],
      );
      return existingId;
    }

    // Insert as a brand new category
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await instance.database;
    
    // Check if another category with the same name exists
    final maps = await db.query(
      'categories',
      where: 'LOWER(name) = ? AND id != ?',
      whereArgs: [category.name.toLowerCase(), category.id],
    );

    if (maps.isNotEmpty) {
      final existingId = maps.first['id'] as int;
      
      // Move all transactions to the existingId
      await db.update(
        'transactions',
        {'categoryId': existingId},
        where: 'categoryId = ?',
        whereArgs: [category.id],
      );
      
      await db.update(
        'recurring_transactions',
        {'categoryId': existingId},
        where: 'categoryId = ?',
        whereArgs: [category.id],
      );
      
      // Hard delete the old category
      await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [category.id],
      );
      
      // Update the revived category
      await db.update(
        'categories',
        {
          'name': category.name,
          'colorHex': category.colorHex,
          'iconString': category.iconString,
          'isActive': 1,
        },
        where: 'id = ?',
        whereArgs: [existingId],
      );
      
      return existingId;
    }

    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    return category.id!;
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.update(
      'categories',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final db = await instance.database;
    final maps = await db.query(
      'recurring_transactions',
      orderBy: 'nextDueDate ASC',
    );

    return List.generate(maps.length, (i) {
      return RecurringTransaction.fromMap(maps[i]);
    });
  }

  Future<RecurringTransaction?> getRecurringTransactionById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return RecurringTransaction.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertTransaction(Transaction transaction) async {
    final db = await instance.database;
    return await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> insertRecurringTransaction(RecurringTransaction transaction) async {
    final db = await instance.database;
    return await db.insert(
      'recurring_transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateRecurringTransaction(RecurringTransaction transaction) async {
    final db = await instance.database;
    return await db.update(
      'recurring_transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
