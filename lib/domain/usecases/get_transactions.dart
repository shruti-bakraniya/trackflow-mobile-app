import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Returns every stored transaction, newest first.
class GetTransactions implements UseCase<List<Transaction>, NoParams> {
  const GetTransactions(this._repository);
  final TransactionRepository _repository;

  @override
  Future<Either<Failure, List<Transaction>>> call(NoParams params) async {
    final result = await _repository.getTransactions();
    return result.fold<Either<Failure, List<Transaction>>>(
      (failure) => Left(failure),
      (txns) {
        final sorted = [...txns]..sort((a, b) {
            final byDate = b.date.compareTo(a.date);
            return byDate != 0 ? byDate : b.id.compareTo(a.id);
          });
        return Right(sorted);
      },
    );
  }
}
