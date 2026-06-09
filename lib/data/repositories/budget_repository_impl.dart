import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/either.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._local);
  final BudgetLocalDataSource _local;

  @override
  Future<Either<Failure, List<Budget>>> getBudgets() {
    return _guard(() async => _local.getBudgets());
  }

  @override
  Future<Either<Failure, Budget>> setBudget(Budget budget) {
    return _guard(() async => _local.upsertBudget(BudgetModel.fromEntity(budget)));
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String categoryId) {
    return _guard(() async => _local.deleteBudget(categoryId));
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('$e'));
    }
  }
}
