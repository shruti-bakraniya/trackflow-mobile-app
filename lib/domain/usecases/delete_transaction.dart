import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

/// Removes a transaction by id.
class DeleteTransaction implements UseCase<void, String> {
  const DeleteTransaction(this._repository);
  final TransactionRepository _repository;

  @override
  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteTransaction(id);
  }
}
