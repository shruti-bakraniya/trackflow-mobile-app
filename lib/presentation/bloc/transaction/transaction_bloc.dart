import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/constants/categories.dart';
import '../../../core/usecases/usecase.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/add_transaction.dart';
import '../../../domain/usecases/delete_transaction.dart';
import '../../../domain/usecases/get_budgets.dart';
import '../../../domain/usecases/get_transactions.dart';
import '../../../domain/usecases/update_transaction.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

/// Owns the transaction list, search/filter criteria and all CRUD flows.
/// On a successful expense mutation it cross-references the category budget
/// to surface a non-disruptive over/near-limit warning (see [_feedbackFor]).
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required GetTransactions getTransactions,
    required AddTransaction addTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
    required GetBudgets getBudgets,
  })  : _getTransactions = getTransactions,
        _addTransaction = addTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        _getBudgets = getBudgets,
        super(const TransactionState()) {
    on<TransactionsRequested>(_onLoad);
    on<TransactionAdded>(_onAdd);
    on<TransactionUpdated>(_onUpdate);
    on<TransactionDeleted>(_onDelete);
    on<SearchQueryChanged>((e, emit) => emit(state.copyWith(query: e.query)));
    on<TypeFilterChanged>((e, emit) => emit(state.copyWith(typeFilter: () => e.type)));
    on<CategoryFilterToggled>(_onToggleCategory);
    on<DateRangeFilterChanged>((e, emit) => emit(state.copyWith(range: e.range)));
    on<FiltersCleared>((e, emit) => emit(state.copyWith(
          typeFilter: () => null,
          categoryFilter: const {},
          range: DateRangeFilter.all,
          query: '',
        )));
  }

  final GetTransactions _getTransactions;
  final AddTransaction _addTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final GetBudgets _getBudgets;

  int _feedbackSeq = 0;
  int get _nextFeedbackId => ++_feedbackSeq;

  Future<void> _onLoad(TransactionsRequested event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(status: TransactionStatus.loading));
    final result = await _getTransactions(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: () => failure.message,
      )),
      (txns) => emit(state.copyWith(
        status: TransactionStatus.loaded,
        transactions: txns,
        errorMessage: () => null,
      )),
    );
  }

  Future<void> _onAdd(TransactionAdded event, Emitter<TransactionState> emit) async {
    final result = await _addTransaction(event.transaction);
    await result.fold(
      (failure) async => emit(_withFeedback(failure.message, tone: FeedbackTone.danger)),
      (saved) async => _refreshThen(emit, saved, isCreate: true),
    );
  }

  Future<void> _onUpdate(TransactionUpdated event, Emitter<TransactionState> emit) async {
    final result = await _updateTransaction(event.transaction);
    await result.fold(
      (failure) async => emit(_withFeedback(failure.message, tone: FeedbackTone.danger)),
      (saved) async => _refreshThen(emit, saved, isCreate: false),
    );
  }

  Future<void> _onDelete(TransactionDeleted event, Emitter<TransactionState> emit) async {
    final result = await _deleteTransaction(event.id);
    await result.fold(
      (failure) async => emit(_withFeedback(failure.message, tone: FeedbackTone.danger)),
      (_) async {
        final reloaded = await _reload();
        emit(state.copyWith(
          status: TransactionStatus.loaded,
          transactions: reloaded ?? state.transactions,
          feedback: () => TransactionFeedback(id: _nextFeedbackId, title: 'Transaction deleted'),
        ));
      },
    );
  }

  void _onToggleCategory(CategoryFilterToggled event, Emitter<TransactionState> emit) {
    final next = Set<String>.from(state.categoryFilter);
    if (!next.add(event.categoryId)) next.remove(event.categoryId);
    emit(state.copyWith(categoryFilter: next));
  }

  /// Re-reads the list, then emits it together with budget-aware feedback.
  Future<void> _refreshThen(
    Emitter<TransactionState> emit,
    Transaction saved, {
    required bool isCreate,
  }) async {
    final reloaded = await _reload() ?? state.transactions;
    final feedback = await _feedbackFor(saved, reloaded, isCreate: isCreate);
    emit(state.copyWith(
      status: TransactionStatus.loaded,
      transactions: reloaded,
      feedback: () => feedback,
    ));
  }

  Future<List<Transaction>?> _reload() async {
    final result = await _getTransactions(const NoParams());
    return result.fold<List<Transaction>?>((_) => null, (txns) => txns);
  }

  /// Builds the toast for a save, escalating tone when an expense pushes a
  /// category near or over its monthly budget.
  Future<TransactionFeedback> _feedbackFor(
    Transaction saved,
    List<Transaction> txns, {
    required bool isCreate,
  }) async {
    final label = Categories.byId(saved.categoryId).label;

    if (saved.type.isExpense && _isThisMonth(saved.date)) {
      final budgets = await _budgetMap();
      final limit = budgets[saved.categoryId];
      if (limit != null) {
        final spent = _monthSpend(txns, saved.categoryId);
        final status = BudgetStatus(categoryId: saved.categoryId, limit: limit, spent: spent);
        if (status.isOver) {
          return TransactionFeedback(
            id: _nextFeedbackId,
            tone: FeedbackTone.danger,
            title: '$label budget exceeded',
            subtitle:
                '${Formatters.money(spent, cents: false)} of ${Formatters.money(limit, cents: false)} '
                '— ${Formatters.money(spent - limit, cents: false)} over',
          );
        }
        if (status.isNear) {
          return TransactionFeedback(
            id: _nextFeedbackId,
            tone: FeedbackTone.warning,
            title: 'Heads up — $label at ${(status.ratio * 100).round()}%',
            subtitle: '${Formatters.money(limit - spent, cents: false)} left this month',
          );
        }
      }
    }

    return TransactionFeedback(
      id: _nextFeedbackId,
      title: isCreate ? 'Transaction saved' : 'Changes saved',
      subtitle: '${Formatters.money(saved.amount, cents: false)} · $label',
    );
  }

  Future<Map<String, double>> _budgetMap() async {
    final result = await _getBudgets(const NoParams());
    return result.fold<Map<String, double>>(
      (_) => <String, double>{},
      (budgets) => {for (final b in budgets) b.categoryId: b.limit},
    );
  }

  double _monthSpend(List<Transaction> txns, String categoryId) {
    final now = DateTime.now();
    return txns
        .where((t) =>
            t.type.isExpense &&
            t.categoryId == categoryId &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (a, t) => a + t.amount);
  }

  bool _isThisMonth(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month;
  }

  TransactionState _withFeedback(String title, {required FeedbackTone tone}) {
    return state.copyWith(
      feedback: () => TransactionFeedback(id: _nextFeedbackId, title: title, tone: tone),
    );
  }
}
