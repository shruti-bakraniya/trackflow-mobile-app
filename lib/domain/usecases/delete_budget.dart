import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/budget_repository.dart';

/// Removes the budget limit for a category.
class DeleteBudget implements UseCase<void, String> {
  const DeleteBudget(this._repository);
  final BudgetRepository _repository;

  @override
  Future<Either<Failure, void>> call(String categoryId) {
    return _repository.deleteBudget(categoryId);
  }
}
