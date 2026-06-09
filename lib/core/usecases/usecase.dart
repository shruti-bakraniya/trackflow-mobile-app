import 'package:equatable/equatable.dart';

import '../errors/failures.dart';
import 'either.dart';

export 'either.dart';

/// Base contract every business-logic use case implements.
///
/// [Type] is the success payload, [Params] is the input. A use case is a
/// single callable object — invoke it with `useCase(params)`.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Placeholder for use cases that take no input.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
