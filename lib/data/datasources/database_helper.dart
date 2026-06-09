import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';

/// Owns the single sqflite [Database] instance: opening, schema creation and
/// first-run seeding. Datasources receive the opened DB from here so there's
/// exactly one connection for the whole app.
class DatabaseHelper {
  DatabaseHelper();

  Database? _db;
  Future<Database>? _opening;

  /// Returns the shared connection, opening it exactly once even when several
  /// blocs request it concurrently on first launch (prevents double-seeding).
  Future<Database> get database async {
    if (_db != null) return _db!;
    _opening ??= _open();
    _db = await _opening;
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, AppConstants.databaseName);
    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTransactions} (
        ${AppConstants.colId} TEXT PRIMARY KEY,
        ${AppConstants.colType} TEXT NOT NULL,
        ${AppConstants.colAmount} REAL NOT NULL,
        ${AppConstants.colCategory} TEXT NOT NULL,
        ${AppConstants.colDate} TEXT NOT NULL,
        ${AppConstants.colNote} TEXT NOT NULL DEFAULT '',
        ${AppConstants.colCreatedAt} INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableBudgets} (
        ${AppConstants.colBudgetCategory} TEXT PRIMARY KEY,
        ${AppConstants.colBudgetLimit} REAL NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_txn_date ON ${AppConstants.tableTransactions}(${AppConstants.colDate})',
    );

    await _seed(db);
  }

  /// Seeds a realistic month of demo data on first launch so the dashboard,
  /// charts and budget warnings have something to show immediately.
  Future<void> _seed(Database db) async {
    final batch = db.batch();
    var uid = 1000;

    String dayAgo(int n) {
      final now = DateTime.now();
      final base = DateTime(now.year, now.month, now.day, 12);
      final d = base.subtract(Duration(days: n));
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '${d.year}-$m-$day';
    }

    void tx(String type, String cat, double amount, int daysAgo, String note) {
      batch.insert(AppConstants.tableTransactions, {
        AppConstants.colId: 't${uid++}',
        AppConstants.colType: type,
        AppConstants.colAmount: amount,
        AppConstants.colCategory: cat,
        AppConstants.colDate: dayAgo(daysAgo),
        AppConstants.colNote: note,
        AppConstants.colCreatedAt: DateTime.now().millisecondsSinceEpoch + uid,
      });
    }

    tx('income', 'salary', 4200, 2, 'Monthly pay');
    tx('expense', 'grocery', 86.40, 0, 'Whole Foods');
    tx('expense', 'meals', 18.50, 0, 'Lunch · Sweetgreen');
    tx('expense', 'transport', 24.00, 0, 'Uber to office');
    tx('expense', 'fun', 32.00, 1, 'Cinema');
    tx('expense', 'bills', 120.00, 1, 'Electricity');
    tx('expense', 'meals', 9.75, 1, 'Coffee run');
    tx('expense', 'shopping', 64.99, 2, 'New sneakers');
    tx('income', 'freelance', 650.00, 3, 'Logo project');
    tx('expense', 'grocery', 52.10, 3, 'Trader Joes');
    tx('expense', 'health', 45.00, 4, 'Pharmacy');
    tx('expense', 'meals', 27.30, 4, 'Dinner');
    tx('expense', 'transport', 60.00, 5, 'Monthly transit');
    tx('expense', 'home', 38.00, 6, 'Plants');
    tx('expense', 'fun', 14.99, 6, 'Spotify');
    tx('income', 'invest', 120.40, 7, 'Dividend');
    tx('expense', 'shopping', 112.00, 8, 'Jacket');
    tx('expense', 'meals', 22.00, 9, 'Brunch');
    tx('expense', 'bills', 45.00, 10, 'Internet');
    tx('expense', 'grocery', 71.25, 11, 'Costco');

    const budgets = {
      'meals': 300.0,
      'transport': 180.0,
      'shopping': 220.0,
      'fun': 150.0,
      'grocery': 400.0,
      'bills': 350.0,
    };
    budgets.forEach((cat, limit) {
      batch.insert(AppConstants.tableBudgets, {
        AppConstants.colBudgetCategory: cat,
        AppConstants.colBudgetLimit: limit,
      });
    });

    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
