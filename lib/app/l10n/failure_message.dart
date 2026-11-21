import '../../core/failure.dart';
import '../../l10n/app_localizations.dart';

/// Resolves a [Failure]'s message key to localised user-facing text.
String failureMessage(AppLocalizations l10n, Failure failure) {
  return switch (failure.messageKey) {
    'failureOffline' => l10n.failureOffline,
    'failureTimeout' => l10n.failureTimeout,
    'failureServer' => l10n.failureServer,
    'failureRateLimited' => l10n.failureRateLimited,
    'failureNotFound' => l10n.failureNotFound,
    'failureConflict' => l10n.failureConflict,
    'failureBookAlreadyLent' => l10n.failureBookAlreadyLent,
    'failureStorage' => l10n.failureStorage,
    'failurePermissionCamera' => l10n.failurePermissionCamera,
    'failurePermissionNotifications' => l10n.failurePermissionNotifications,
    'failurePermissionFiles' => l10n.failurePermissionFiles,
    'failureUnsupported' => l10n.failureUnsupported,
    'failureBackupNotABackup' => l10n.failureBackupNotABackup,
    'failureBackupDamaged' => l10n.failureBackupDamaged,
    'failureBackupNewer' => l10n.failureBackupNewer,
    'failureUnexpected' => l10n.failureUnexpected,
    _ =>
      failure is ValidationFailure
          ? l10n.failureValidation
          : l10n.failureUnexpected,
  };
}
