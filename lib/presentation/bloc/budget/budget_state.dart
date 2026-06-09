part of 'budget_bloc.dart';

enum BudgetStatusType { initial, loading, loaded, failure }

class BudgetState extends Equatable {
  const BudgetState({
    this.status = BudgetStatusType.initial,
    this.budgets = const [],
    this.errorMessage,
  });

  final BudgetStatusType status;
  final List<Budget> budgets;
  final String? errorMessage;

  /// Category-id → limit, for quick lookups in the UI.
  Map<String, double> get limitByCategory => {for (final b in budgets) b.categoryId: b.limit};

  BudgetState copyWith({
    BudgetStatusType? status,
    List<Budget>? budgets,
    String? Function()? errorMessage,
  }) {
    return BudgetState(
      status: status ?? this.status,
      budgets: budgets ?? this.budgets,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, budgets, errorMessage];
}
