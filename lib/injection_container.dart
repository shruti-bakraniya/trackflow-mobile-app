import 'data/datasources/budget_local_datasource.dart';
import 'data/datasources/database_helper.dart';
import 'data/datasources/transaction_local_datasource.dart';
import 'data/repositories/budget_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/repositories/budget_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/usecases/add_transaction.dart';
import 'domain/usecases/delete_budget.dart';
import 'domain/usecases/delete_transaction.dart';
import 'domain/usecases/get_budgets.dart';
import 'domain/usecases/get_statistics.dart';
import 'domain/usecases/get_transactions.dart';
import 'domain/usecases/set_budget.dart';
import 'domain/usecases/update_transaction.dart';
import 'presentation/bloc/budget/budget_bloc.dart';
import 'presentation/bloc/statistics/statistics_cubit.dart';
import 'presentation/bloc/transaction/transaction_bloc.dart';

/// Manual dependency-injection container.
///
/// We wire the object graph by hand (rather than pulling in a service-locator
/// package) to honour the project's "verified-publisher-only" dependency
/// constraint. Construct it once in `main`, then read blocs/use cases from it.
/// Lower layers never know about the layers above them — the container is the
/// single place where concrete implementations are bound to abstractions.
class InjectionContainer {
  InjectionContainer() {
    // ── Core / data sources ──
    databaseHelper = DatabaseHelper();
    _transactionDataSource = TransactionLocalDataSourceImpl(databaseHelper);
    _budgetDataSource = BudgetLocalDataSourceImpl(databaseHelper);

    // ── Repositories (abstractions ← implementations) ──
    transactionRepository = TransactionRepositoryImpl(_transactionDataSource);
    budgetRepository = BudgetRepositoryImpl(_budgetDataSource);

    // ── Use cases ──
    getTransactions = GetTransactions(transactionRepository);
    addTransaction = AddTransaction(transactionRepository);
    updateTransaction = UpdateTransaction(transactionRepository);
    deleteTransaction = DeleteTransaction(transactionRepository);
    getStatistics = GetStatistics(transactionRepository);
    getBudgets = GetBudgets(budgetRepository);
    setBudget = SetBudget(budgetRepository);
    deleteBudget = DeleteBudget(budgetRepository);
  }

  late final DatabaseHelper databaseHelper;
  late final TransactionLocalDataSource _transactionDataSource;
  late final BudgetLocalDataSource _budgetDataSource;

  late final TransactionRepository transactionRepository;
  late final BudgetRepository budgetRepository;

  late final GetTransactions getTransactions;
  late final AddTransaction addTransaction;
  late final UpdateTransaction updateTransaction;
  late final DeleteTransaction deleteTransaction;
  late final GetStatistics getStatistics;
  late final GetBudgets getBudgets;
  late final SetBudget setBudget;
  late final DeleteBudget deleteBudget;

  // ── Bloc factories ──
  TransactionBloc createTransactionBloc() => TransactionBloc(
        getTransactions: getTransactions,
        addTransaction: addTransaction,
        updateTransaction: updateTransaction,
        deleteTransaction: deleteTransaction,
        getBudgets: getBudgets,
      )..add(const TransactionsRequested());

  BudgetBloc createBudgetBloc() => BudgetBloc(
        getBudgets: getBudgets,
        setBudget: setBudget,
        deleteBudget: deleteBudget,
      )..add(const BudgetsRequested());

  StatisticsCubit createStatisticsCubit() => StatisticsCubit(getStatistics: getStatistics);
}
