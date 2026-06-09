import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Persists edits to an existing transaction.
class UpdateTransaction implements UseCase<Transaction, Transaction> {
  const UpdateTransaction(this._repository);
  final TransactionRepository _repository;

  @override
  Future<Either<Failure, Transaction>> call(Transaction params) async {
    if (params.amount <= 0) {
      return const Left(ValidationFailure('Amount must be greater than zero.'));
    }
    if (params.categoryId.isEmpty) {
      return const Left(ValidationFailure('Please choose a category.'));
    }
    return _repository.updateTransaction(params);
  }
}
