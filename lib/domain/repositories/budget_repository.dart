import '../../core/usecases/either.dart';
import '../../core/errors/failures.dart';
import '../entities/budget.dart';

/// Contract for persisting per-category budget limits.
abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getBudgets();

  Future<Either<Failure, Budget>> setBudget(Budget budget);

  Future<Either<Failure, void>> deleteBudget(String categoryId);
}
