import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

/// Creates or updates a category budget limit.
class SetBudget implements UseCase<Budget, Budget> {
  const SetBudget(this._repository);
  final BudgetRepository _repository;

  @override
  Future<Either<Failure, Budget>> call(Budget params) async {
    if (params.limit <= 0) {
      return const Left(ValidationFailure('Budget limit must be greater than zero.'));
    }
    return _repository.setBudget(params);
  }
}
