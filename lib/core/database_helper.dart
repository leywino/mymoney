import 'package:mymoney/core/constants.dart';
import 'package:mymoney/models/category_model.dart';
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
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
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
      toAccountId INTEGER,
      categoryId INTEGER,
      amount REAL,
      date TEXT,
      type TEXT,
      notes TEXT,
      FOREIGN KEY(accountId) REFERENCES accounts(id) ON DELETE CASCADE,
      FOREIGN KEY(toAccountId) REFERENCES accounts(id) ON DELETE CASCADE,
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
      iconNumber INTEGER,
      type TEXT
    )
    ''');

    await _insertTransactionCategory(db);
    await _insertExpenseCategories(db);
    await _insertIncomeCategories(db);
  }

  Future<void> _insertTransactionCategory(Database db) async {
    await db.insert('categories', {
      'name': 'Transfer',
      'iconNumber': '34',
      'type': 'transfer'
    });
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

  Future<void> transferMoney(Transaction transaction) async {
    int fromAccountId = transaction.accountId;
    int toAccountId = transaction.toAccountId!;
    double amountToTransfer = transaction.amount;
    final db = await database;

    await db.transaction((txn) async {
      final List<Map<String, dynamic>> fromAccountResult = await txn.query(
        'accounts',
        columns: ['balance'],
        where: 'id = ?',
        whereArgs: [fromAccountId],
        limit: 1,
      );

      final List<Map<String, dynamic>> toAccountResult = await txn.query(
        'accounts',
        columns: ['balance'],
        where: 'id = ?',
        whereArgs: [toAccountId],
        limit: 1,
      );

      if (fromAccountResult.isEmpty) {
        throw Exception('From Account with ID $fromAccountId not found');
      }

      if (toAccountResult.isEmpty) {
        throw Exception('To Account with ID $toAccountId not found');
      }

      final double fromAccountBalance =
          fromAccountResult.first['balance'] as double;
      if (fromAccountBalance < amountToTransfer) {
        throw Exception('Insufficient balance in the From Account');
      }

      final double updatedFromAccountBalance =
          fromAccountBalance - amountToTransfer;
      await txn.update(
        'accounts',
        {'balance': updatedFromAccountBalance},
        where: 'id = ?',
        whereArgs: [fromAccountId],
      );

      final double toAccountBalance =
          toAccountResult.first['balance'] as double;
      final double updatedToAccountBalance =
          toAccountBalance + amountToTransfer;
      await txn.update(
        'accounts',
        {'balance': updatedToAccountBalance},
        where: 'id = ?',
        whereArgs: [toAccountId],
      );

      await txn.insert('transactions', {
        'accountId': fromAccountId,
        'toAccountId': toAccountId,
        'categoryId': 1,
        'amount': amountToTransfer,
        'date': DateTime.now().toIso8601String(),
        'type': 'TRANSFER',
      });
    });
  }

  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    final db = await database;
    return await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
  }

  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<int> deleteAccount(int accountId) async {
    final db = await database;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  Future<Category?> getCategoryWithId(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [categoryId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Account?> getAccountWithId(int accountId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [accountId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('accounts');
    return List.generate(maps.length, (i) {
      return Account.fromMap(maps[i]);
    });
  }

  Future<double> getAccountBalance(int accountId) async {
    final db = await database;

    // Query the account by its ID
    final List<Map<String, dynamic>> result = await db.query(
      'accounts',
      columns: ['balance'],
      where: 'id = ?',
      whereArgs: [accountId],
    );

    if (result.isNotEmpty) {
      return result.first['balance'] as double;
    } else {
      throw Exception('Account not found');
    }
  }

  Future<void> updateAccountBalance(int accountId, double amount) async {
    final db = await database;
    await db.transaction((txn) async {
      final List<Map<String, dynamic>> result = await txn.query(
        'accounts',
        columns: ['balance'],
        where: 'id = ?',
        whereArgs: [accountId],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final currentBalance = result.first['balance'] as double;
        final newBalance = currentBalance + amount;
        await txn.update(
          'accounts',
          {'balance': newBalance},
          where: 'id = ?',
          whereArgs: [accountId],
        );
      } else {
        throw Exception('Account with ID $accountId not found');
      }
    });
  }

  Future<void> replaceAccountBalance(int accountId, double newBalance) async {
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

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;

    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(int transactionId) async {
    final db = await database;
    await db.transaction((txn) async {
      final List<Map<String, dynamic>> transactionResult = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
        limit: 1,
      );

      if (transactionResult.isEmpty) {
        throw Exception('Transaction with ID $transactionId not found');
      }

      final transaction = Transaction.fromMap(transactionResult.first);
      final List<Map<String, dynamic>> fromAccountResult = await txn.query(
        'accounts',
        columns: ['balance'],
        where: 'id = ?',
        whereArgs: [transaction.accountId],
        limit: 1,
      );

      if (fromAccountResult.isEmpty) {
        throw Exception('Account with ID ${transaction.accountId} not found');
      }

      final double fromAccountBalance =
          fromAccountResult.first['balance'] as double;
      final double updatedFromAccountBalance =
          fromAccountBalance - transaction.amount;

      await txn.update(
        'accounts',
        {'balance': updatedFromAccountBalance},
        where: 'id = ?',
        whereArgs: [transaction.accountId],
      );

      if (transaction.type == 'TRANSFER' && transaction.toAccountId != null) {
        final List<Map<String, dynamic>> toAccountResult = await txn.query(
          'accounts',
          columns: ['balance'],
          where: 'id = ?',
          whereArgs: [transaction.toAccountId],
          limit: 1,
        );

        if (toAccountResult.isEmpty) {
          throw Exception(
              'Account with ID ${transaction.toAccountId} not found');
        }

        final double toAccountBalance =
            toAccountResult.first['balance'] as double;
        final double updatedToAccountBalance =
            toAccountBalance + transaction.amount;

        await txn.update(
          'accounts',
          {'balance': updatedToAccountBalance},
          where: 'id = ?',
          whereArgs: [transaction.toAccountId],
        );
      }

      await txn.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    });
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

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
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
