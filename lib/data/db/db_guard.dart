import 'package:drift/drift.dart';

import '../../core/failure.dart';
import '../../core/result.dart';

/// Thrown inside a transaction to roll it back and surface [failure].
final class FailureException implements Exception {
  const FailureException(this.failure);

  final Failure failure;

  @override
  String toString() => 'FailureException($failure)';
}

/// Maps a database error to a [Failure]. Business rules are checked
/// explicitly before writing; this is the backstop for constraint errors.
Failure mapDbError(Object error) {
  if (error is FailureException) return error.failure;
  final text = error.toString();
  if (text.contains('UNIQUE constraint failed')) {
    return const ConflictFailure();
  }
  if (text.contains('CHECK constraint failed') ||
      text.contains('NOT NULL constraint failed') ||
      text.contains('FOREIGN KEY constraint failed') ||
      error is InvalidDataException) {
    return const ValidationFailure(field: '', messageKey: 'failureValidation');
  }
  return StorageFailure(error);
}

/// Runs [body], converting every error into an [Err]; never throws.
Future<Result<T>> dbGuard<T>(Future<T> Function() body) async {
  try {
    return Ok<T>(await body());
  } on Object catch (error) {
    return Err<T>(mapDbError(error));
  }
}
