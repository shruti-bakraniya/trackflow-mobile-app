import 'package:equatable/equatable.dart';

/// A monthly spending cap for a single expense category.
class Budget extends Equatable {
  const Budget({
    required this.categoryId,
    required this.limit,
  });

  final String categoryId;
  final double limit;

  Budget copyWith({String? categoryId, double? limit}) {
    return Budget(
      categoryId: categoryId ?? this.categoryId,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object?> get props => [categoryId, limit];
}

/// A budget combined with how much has been spent against it this month.
/// Produced by the statistics/budget use cases for the UI to render rings.
class BudgetStatus extends Equatable {
  const BudgetStatus({
    required this.categoryId,
    required this.limit,
    required this.spent,
  });

  final String categoryId;
  final double limit;
  final double spent;

  double get remaining => limit - spent;
  double get ratio => limit <= 0 ? 0 : spent / limit;
  bool get isOver => spent > limit;
  bool get isNear => !isOver && ratio >= 0.8;

  BudgetLevel get level {
    if (isOver) return BudgetLevel.over;
    if (isNear) return BudgetLevel.near;
    return BudgetLevel.ok;
  }

  @override
  List<Object?> get props => [categoryId, limit, spent];
}

enum BudgetLevel { ok, near, over }
