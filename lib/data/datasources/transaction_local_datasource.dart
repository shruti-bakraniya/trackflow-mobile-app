import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/transaction_model.dart';
import 'database_helper.dart';

/// Raw CRUD against the sqflite `transactions` table. Throws
/// [DatabaseException] on any failure; the repository maps these to Failures.
abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel> insertTransaction(TransactionModel model);
  Future<TransactionModel> updateTransaction(TransactionModel model);
  Future<void> deleteTransaction(String id);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  TransactionLocalDataSourceImpl(this._helper);
  final DatabaseHelper _helper;

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final db = await _helper.database;
      final rows = await db.query(
        AppConstants.tableTransactions,
        orderBy: '${AppConstants.colDate} DESC, ${AppConstants.colCreatedAt} DESC',
      );
      return rows.map((r) => TransactionModel.fromMap(r)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load transactions: $e');
    }
  }

  @override
  Future<TransactionModel> insertTransaction(TransactionModel model) async {
    try {
      final db = await _helper.database;
      await db.insert(AppConstants.tableTransactions, model.toMap());
      return model;
    } catch (e) {
      throw DatabaseException('Failed to add transaction: $e');
    }
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel model) async {
    try {
      final db = await _helper.database;
      final count = await db.update(
        AppConstants.tableTransactions,
        model.toMap(),
        where: '${AppConstants.colId} = ?',
        whereArgs: [model.id],
      );
      if (count == 0) {
        throw const NotFoundException('Transaction no longer exists.');
      }
      return model;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      final db = await _helper.database;
      await db.delete(
        AppConstants.tableTransactions,
        where: '${AppConstants.colId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete transaction: $e');
    }
  }
}
