/// A minimal, dependency-free `Either` type.
///
/// We deliberately hand-roll this (using Dart 3 sealed classes) instead of
/// pulling in `dartz`, to satisfy the project's "verified publisher only"
/// dependency constraint while still giving the domain layer a clean
/// `Either<Failure, T>` return type.
sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  /// Collapses both branches into a single value.
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    final self = this;
    return switch (self) {
      Left(value: final l) => onLeft(l),
      Right(value: final r) => onRight(r),
    };
  }

  /// The right value or `null` when this is a [Left].
  R? get rightOrNull => switch (this) {
        Right(value: final r) => r,
        _ => null,
      };
}

final class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;
}

final class Right<L, R> extends Either<L, R> {
  const Right(this.value);
  final R value;
}
