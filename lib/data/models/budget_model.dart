import '../../core/constants/app_constants.dart';
import '../../domain/entities/budget.dart';

/// Data-layer representation of a [Budget] with sqflite (de)serialization.
class BudgetModel extends Budget {
  const BudgetModel({
    required super.categoryId,
    required super.limit,
  });

  factory BudgetModel.fromEntity(Budget b) =>
      BudgetModel(categoryId: b.categoryId, limit: b.limit);

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      categoryId: map[AppConstants.colBudgetCategory] as String,
      limit: (map[AppConstants.colBudgetLimit] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppConstants.colBudgetCategory: categoryId,
      AppConstants.colBudgetLimit: limit,
    };
  }
}
