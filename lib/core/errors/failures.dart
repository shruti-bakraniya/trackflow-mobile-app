import 'package:equatable/equatable.dart';

/// High-level, user-facing errors surfaced by the **domain layer**.
///
/// Repositories translate raw [Exception]s into these typed [Failure]s,
/// which BLoCs then render as friendly messages. Being [Equatable] makes
/// them trivial to assert against in widget/bloc tests.
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Could not access local storage.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read cached data.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'The provided data is invalid.']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong. Please try again.']);
}
