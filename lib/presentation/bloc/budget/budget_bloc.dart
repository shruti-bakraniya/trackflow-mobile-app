import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/usecases/delete_budget.dart';
import '../../../domain/usecases/get_budgets.dart';
import '../../../domain/usecases/set_budget.dart';

part 'budget_event.dart';
part 'budget_state.dart';

/// Owns the per-category budget limits.
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc({
    required GetBudgets getBudgets,
    required SetBudget setBudget,
    required DeleteBudget deleteBudget,
  })  : _getBudgets = getBudgets,
        _setBudget = setBudget,
        _deleteBudget = deleteBudget,
        super(const BudgetState()) {
    on<BudgetsRequested>(_onLoad);
    on<BudgetSet>(_onSet);
    on<BudgetRemoved>(_onRemove);
  }

  final GetBudgets _getBudgets;
  final SetBudget _setBudget;
  final DeleteBudget _deleteBudget;

  Future<void> _onLoad(BudgetsRequested event, Emitter<BudgetState> emit) async {
    emit(state.copyWith(status: BudgetStatusType.loading));
    final result = await _getBudgets(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: BudgetStatusType.failure,
        errorMessage: () => failure.message,
      )),
      (budgets) => emit(state.copyWith(
        status: BudgetStatusType.loaded,
        budgets: budgets,
        errorMessage: () => null,
      )),
    );
  }

  Future<void> _onSet(BudgetSet event, Emitter<BudgetState> emit) async {
    final result = await _setBudget(event.budget);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: () => failure.message)),
      (saved) {
        final next = [...state.budgets.where((b) => b.categoryId != saved.categoryId), saved];
        emit(state.copyWith(status: BudgetStatusType.loaded, budgets: next));
      },
    );
  }

  Future<void> _onRemove(BudgetRemoved event, Emitter<BudgetState> emit) async {
    final result = await _deleteBudget(event.categoryId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: () => failure.message)),
      (_) {
        final next = state.budgets.where((b) => b.categoryId != event.categoryId).toList();
        emit(state.copyWith(status: BudgetStatusType.loaded, budgets: next));
      },
    );
  }
}
