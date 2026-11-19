import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/data/db/db_guard.dart';

void main() {
  test('FailureException surfaces its failure', () async {
    final r = await dbGuard<int>(
      () async => throw const FailureException(NotFoundFailure('x')),
    );
    expect(r.failureOrNull(), isA<NotFoundFailure>());
  });

  test('constraint messages map to Conflict and Validation', () {
    expect(
      mapDbError(Exception('UNIQUE constraint failed: x.y')),
      isA<ConflictFailure>(),
    );
    for (final m in <String>[
      'CHECK constraint failed: rating',
      'NOT NULL constraint failed: t.c',
      'FOREIGN KEY constraint failed',
    ]) {
      expect(mapDbError(Exception(m)), isA<ValidationFailure>(), reason: m);
    }
    expect(mapDbError(InvalidDataException('bad')), isA<ValidationFailure>());
  });

  test('anything else becomes a StorageFailure and never throws', () async {
    final r = await dbGuard<int>(() async => throw StateError('disk'));
    expect(r.failureOrNull(), isA<StorageFailure>());
    expect(await dbGuard(() async => 3), isNotNull);
  });
}
