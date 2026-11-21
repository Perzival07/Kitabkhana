import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';

void main() {
  test('every failure has a message key', () {
    final failures = <Failure>[
      const NetworkFailure.offline(),
      const NetworkFailure.timeout(),
      const NetworkFailure.server(503),
      const NetworkFailure.rateLimited(),
      const NotFoundFailure('book'),
      const ValidationFailure(field: 'isbn', messageKey: 'failureValidation'),
      const ConflictFailure(),
      const ConflictFailure('failureBookAlreadyLent'),
      const StorageFailure('disk full'),
      const PermissionFailure(PermissionKind.camera),
      const PermissionFailure(PermissionKind.notifications),
      const PermissionFailure(PermissionKind.files, permanentlyDenied: true),
      const UnsupportedOnPlatformFailure('ocr'),
      UnexpectedFailure(StateError('x')),
    ];
    for (final f in failures) {
      expect(f.messageKey, startsWith('failure'), reason: '$f');
    }
    expect(failures.map((f) => f.messageKey).toSet().length, greaterThan(8));
  });

  test('network kinds map to distinct keys', () {
    expect(const NetworkFailure.offline().messageKey, 'failureOffline');
    expect(const NetworkFailure.timeout().messageKey, 'failureTimeout');
    expect(const NetworkFailure.server().messageKey, 'failureServer');
    expect(const NetworkFailure.rateLimited().messageKey, 'failureRateLimited');
  });

  test('network failures compare by value and carry a status code', () {
    expect(const NetworkFailure.server(500), const NetworkFailure.server(500));
    expect(
      const NetworkFailure.server(500),
      isNot(const NetworkFailure.server(502)),
    );
    expect(const NetworkFailure.server(500).debugMessage, 'HTTP 500');
    expect(const NetworkFailure.offline().debugMessage, isNull);
  });

  test('permission failures expose kind and permanence', () {
    const f = PermissionFailure(PermissionKind.camera, permanentlyDenied: true);
    expect(f.permanentlyDenied, isTrue);
    expect(f.kind, PermissionKind.camera);
    expect(f.messageKey, 'failurePermissionCamera');
  });

  test('exhaustive switch over Failure compiles', () {
    String name(Failure f) => switch (f) {
      NetworkFailure() => 'network',
      NotFoundFailure() => 'notFound',
      ValidationFailure() => 'validation',
      ConflictFailure() => 'conflict',
      StorageFailure() => 'storage',
      PermissionFailure() => 'permission',
      UnsupportedOnPlatformFailure() => 'unsupported',
      BackupFailure() => 'backup',
      UnexpectedFailure() => 'unexpected',
    };
    expect(name(const ConflictFailure()), 'conflict');
    expect(
      const BackupFailure(BackupProblem.damaged).messageKey,
      'failureBackupDamaged',
    );
  });
}
