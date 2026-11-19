import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/l10n/failure_message.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('every failure resolves to a specific, non-generic message', () {
    final specific = <Failure, String>{
      const NetworkFailure.offline(): l10n.failureOffline,
      const NetworkFailure.timeout(): l10n.failureTimeout,
      const NetworkFailure.server(500): l10n.failureServer,
      const NetworkFailure.rateLimited(): l10n.failureRateLimited,
      const NotFoundFailure(): l10n.failureNotFound,
      const ConflictFailure(): l10n.failureConflict,
      const ConflictFailure('failureBookAlreadyLent'):
          l10n.failureBookAlreadyLent,
      const StorageFailure(): l10n.failureStorage,
      const PermissionFailure(PermissionKind.camera):
          l10n.failurePermissionCamera,
      const PermissionFailure(PermissionKind.notifications):
          l10n.failurePermissionNotifications,
      const PermissionFailure(PermissionKind.files):
          l10n.failurePermissionFiles,
      const UnsupportedOnPlatformFailure(): l10n.failureUnsupported,
    };
    specific.forEach((failure, text) {
      expect(failureMessage(l10n, failure), text, reason: '$failure');
      expect(text.trim(), isNotEmpty);
    });
  });

  test('validation and unexpected failures fall back sensibly', () {
    expect(
      failureMessage(
        l10n,
        const ValidationFailure(field: 'isbn', messageKey: 'unknownKey'),
      ),
      l10n.failureValidation,
    );
    expect(
      failureMessage(l10n, UnexpectedFailure(StateError('x'))),
      l10n.failureUnexpected,
    );
  });

  test('messages never leak debug details', () {
    final m = failureMessage(l10n, const NetworkFailure.server(503));
    expect(m, isNot(contains('503')));
  });
}
