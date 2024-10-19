import 'package:mymoney/core/constants.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/budgeting_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'money_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      balance REAL,
      iconNumber INTEGER
    )
    ''');

    await db
        .insert('accounts', {'name': 'Cash', 'balance': 0.00, 'iconNumber': 0});
    await db
        .insert('accounts', {'name': 'Card', 'balance': 0.00, 'iconNumber': 1});
    await db.insert(
        'accounts', {'name': 'Savings', 'balance': 0.00, 'iconNumber': 2});

    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      accountId INTEGER,
      categoryId INTEGER,
      title TEXT,
      amount REAL,
      date TEXT,
      type TEXT,
      FOREIGN KEY(accountId) REFERENCES accounts(id) ON DELETE CASCADE,
      FOREIGN KEY(categoryId) REFERENCES categories(id) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE budgeting (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category TEXT,
      budgetAmount REAL,
      spentAmount REAL
    )
    ''');

    await db.execute('''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      assetPath TEXT,
      type TEXT
    )
    ''');

    await _insertExpenseCategories(db);
    await _insertIncomeCategories(db);
  }

  Future<void> _insertExpenseCategories(Database db) async {
    for (var category in expenseCategories) {
      await db.insert('categories', category);
    }
  }

  Future<void> _insertIncomeCategories(Database db) async {
    for (var category in incomeCategories) {
      await db.insert('categories', category);
    }
  }

  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('accounts');
    return List.generate(maps.length, (i) {
      return Account.fromMap(maps[i]);
    });
  }

  Future<void> updateAccountBalance(int accountId, double newBalance) async {
    final db = await database;
    await db.update(
      'accounts',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getTransactionsByAccount(int accountId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<int> insertBudget(Budgeting budget) async {
    final db = await database;
    return await db.insert('budgeting', budget.toMap());
  }

  Future<void> updateBudgetSpent(String category, double spentAmount) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE budgeting 
      SET spentAmount = spentAmount + ?
      WHERE category = ?
    ''', [spentAmount, category]);
  }
}