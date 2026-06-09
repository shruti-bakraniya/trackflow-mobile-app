/// App-wide constant values: database identifiers, table & column names.
///
/// Keeping these here (rather than scattered as magic strings inside the
/// data layer) means the sqflite schema has a single source of truth that
/// the datasource and any migration logic can share.
class AppConstants {
  AppConstants._();

  // ── Database ──────────────────────────────────────────────
  static const String databaseName = 'trackflow.db';
  static const int databaseVersion = 1;

  // ── transactions table ────────────────────────────────────
  static const String tableTransactions = 'transactions';
  static const String colId = 'id';
  static const String colType = 'type'; // 'expense' | 'income'
  static const String colAmount = 'amount';
  static const String colCategory = 'category_id';
  static const String colDate = 'date'; // ISO-8601 yyyy-MM-dd
  static const String colNote = 'note';
  static const String colCreatedAt = 'created_at';

  // ── budgets table ─────────────────────────────────────────
  static const String tableBudgets = 'budgets';
  static const String colBudgetCategory = 'category_id';
  static const String colBudgetLimit = 'limit_amount';
}
