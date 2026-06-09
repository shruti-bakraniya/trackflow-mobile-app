import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/either.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

/// Bridges the domain [TransactionRepository] contract to the sqflite
/// datasource, translating low-level [Exception]s into typed [Failure]s.
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._local);
  final TransactionLocalDataSource _local;

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    return _guard(() async => _local.getTransactions());
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction) async {
    return _guard(() async {
      // Assign a stable id here so the domain can stay id-agnostic on create.
      final id = transaction.id.isEmpty
          ? 't${DateTime.now().microsecondsSinceEpoch}'
          : transaction.id;
      final model = TransactionModel.fromEntity(transaction.copyWith(id: id));
      return _local.insertTransaction(model);
    });
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction) async {
    return _guard(() async {
      final model = TransactionModel.fromEntity(transaction);
      return _local.updateTransaction(model);
    });
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    return _guard(() async {
      await _local.deleteTransaction(id);
    });
  }

  /// Centralised exception→Failure mapping so every method stays tidy.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on NotFoundException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('$e'));
    }
  }
}
