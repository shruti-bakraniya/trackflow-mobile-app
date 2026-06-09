import '../../core/usecases/either.dart';
import '../../core/errors/failures.dart';
import '../entities/transaction.dart';

/// Contract the data layer must fulfil for transaction persistence.
///
/// The domain depends only on this abstraction; the concrete sqflite-backed
/// implementation lives in `data/repositories`.
abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions();

  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction);

  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction);

  Future<Either<Failure, void>> deleteTransaction(String id);
}
