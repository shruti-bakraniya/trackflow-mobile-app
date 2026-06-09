/// Low-level errors thrown by the **data layer** (datasources).
///
/// These are caught by repository implementations and converted into
/// [Failure]s so the rest of the app never deals with raw exceptions.
library;

class DatabaseException implements Exception {
  const DatabaseException([this.message = 'A database error occurred.']);
  final String message;

  @override
  String toString() => 'DatabaseException: $message';
}

class CacheException implements Exception {
  const CacheException([this.message = 'A cache error occurred.']);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class NotFoundException implements Exception {
  const NotFoundException([this.message = 'The requested record was not found.']);
  final String message;

  @override
  String toString() => 'NotFoundException: $message';
}
