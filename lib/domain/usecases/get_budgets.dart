import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

/// Returns all configured category budgets.
class GetBudgets implements UseCase<List<Budget>, NoParams> {
  const GetBudgets(this._repository);
  final BudgetRepository _repository;

  @override
  Future<Either<Failure, List<Budget>>> call(NoParams params) {
    return _repository.getBudgets();
  }
}
