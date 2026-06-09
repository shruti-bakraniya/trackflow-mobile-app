import 'package:sqflite/sqflite.dart' hide DatabaseException;

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/budget_model.dart';
import 'database_helper.dart';

/// Raw CRUD against the sqflite `budgets` table.
abstract class BudgetLocalDataSource {
  Future<List<BudgetModel>> getBudgets();
  Future<BudgetModel> upsertBudget(BudgetModel model);
  Future<void> deleteBudget(String categoryId);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  BudgetLocalDataSourceImpl(this._helper);
  final DatabaseHelper _helper;

  @override
  Future<List<BudgetModel>> getBudgets() async {
    try {
      final db = await _helper.database;
      final rows = await db.query(AppConstants.tableBudgets);
      return rows.map((r) => BudgetModel.fromMap(r)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load budgets: $e');
    }
  }

  @override
  Future<BudgetModel> upsertBudget(BudgetModel model) async {
    try {
      final db = await _helper.database;
      await db.insert(
        AppConstants.tableBudgets,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return model;
    } catch (e) {
      throw DatabaseException('Failed to save budget: $e');
    }
  }

  @override
  Future<void> deleteBudget(String categoryId) async {
    try {
      final db = await _helper.database;
      await db.delete(
        AppConstants.tableBudgets,
        where: '${AppConstants.colBudgetCategory} = ?',
        whereArgs: [categoryId],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete budget: $e');
    }
  }
}
