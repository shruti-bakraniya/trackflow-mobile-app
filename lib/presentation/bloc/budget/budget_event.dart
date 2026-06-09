part of 'budget_bloc.dart';

sealed class BudgetEvent extends Equatable {
  const BudgetEvent();
  @override
  List<Object?> get props => [];
}

class BudgetsRequested extends BudgetEvent {
  const BudgetsRequested();
}

class BudgetSet extends BudgetEvent {
  const BudgetSet(this.budget);
  final Budget budget;
  @override
  List<Object?> get props => [budget];
}

class BudgetRemoved extends BudgetEvent {
  const BudgetRemoved(this.categoryId);
  final String categoryId;
  @override
  List<Object?> get props => [categoryId];
}
