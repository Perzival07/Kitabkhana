/// Why a network call failed.
enum NetworkFailureKind { offline, timeout, server, rateLimited }

/// Which permission was denied.
enum PermissionKind { camera, notifications, files }

/// A recoverable, user-presentable error. Never thrown to the UI; carried in
/// [Err] results. Each failure has an l10n [messageKey].
sealed class Failure {
  const Failure();

  /// Key of the user-facing message (see `failureMessage` in the app layer).
  String get messageKey;

  /// Developer-facing detail; never shown to users, never logged at info+.
  String? get debugMessage => null;

  @override
  String toString() => '$runtimeType($messageKey)';
}

final class NetworkFailure extends Failure {
  const NetworkFailure(this.kind, {this.statusCode});

  const NetworkFailure.offline() : this(NetworkFailureKind.offline);
  const NetworkFailure.timeout() : this(NetworkFailureKind.timeout);
  const NetworkFailure.rateLimited() : this(NetworkFailureKind.rateLimited);
  const NetworkFailure.server([int? statusCode])
    : this(NetworkFailureKind.server, statusCode: statusCode);

  final NetworkFailureKind kind;
  final int? statusCode;

  @override
  String get messageKey => switch (kind) {
    NetworkFailureKind.offline => 'failureOffline',
    NetworkFailureKind.timeout => 'failureTimeout',
    NetworkFailureKind.server => 'failureServer',
    NetworkFailureKind.rateLimited => 'failureRateLimited',
  };

  @override
  String? get debugMessage => statusCode == null ? null : 'HTTP $statusCode';

  @override
  bool operator ==(Object other) =>
      other is NetworkFailure &&
      other.kind == kind &&
      other.statusCode == statusCode;

  @override
  int get hashCode => Object.hash(kind, statusCode);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([this.entity]);

  /// What was not found, e.g. `book`. Developer-facing only.
  final String? entity;

  @override
  String get messageKey => 'failureNotFound';

  @override
  String? get debugMessage => entity;
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required this.field, required this.messageKey});

  /// The form field at fault, e.g. `isbn`.
  final String field;

  @override
  final String messageKey;

  @override
  String? get debugMessage => field;
}

final class ConflictFailure extends Failure {
  const ConflictFailure([this.messageKey = 'failureConflict']);

  /// e.g. `failureBookAlreadyLent`.
  @override
  final String messageKey;
}

final class StorageFailure extends Failure {
  const StorageFailure([this.cause]);

  final Object? cause;

  @override
  String get messageKey => 'failureStorage';

  @override
  String? get debugMessage => cause?.toString();
}

final class PermissionFailure extends Failure {
  const PermissionFailure(this.kind, {this.permanentlyDenied = false});

  final PermissionKind kind;

  /// True when the user must enable it in system settings.
  final bool permanentlyDenied;

  @override
  String get messageKey => switch (kind) {
    PermissionKind.camera => 'failurePermissionCamera',
    PermissionKind.notifications => 'failurePermissionNotifications',
    PermissionKind.files => 'failurePermissionFiles',
  };
}

final class UnsupportedOnPlatformFailure extends Failure {
  const UnsupportedOnPlatformFailure([this.feature]);

  final String? feature;

  @override
  String get messageKey => 'failureUnsupported';

  @override
  String? get debugMessage => feature;
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(this.error, [this.stack]);

  final Object error;
  final StackTrace? stack;

  @override
  String get messageKey => 'failureUnexpected';

  @override
  String? get debugMessage => error.toString();
}

/// Why a backup file could not be read.
enum BackupProblem {
  /// Not a zip, or no valid manifest.
  notABackup,

  /// Missing files, bad checksums or unreadable data.
  damaged,

  /// Made by a newer app version than this one understands.
  newerVersion,
}

final class BackupFailure extends Failure {
  const BackupFailure(this.problem, [this.detail]);

  final BackupProblem problem;

  /// Developer-facing detail (which file failed).
  final String? detail;

  @override
  String get messageKey => switch (problem) {
    BackupProblem.notABackup => 'failureBackupNotABackup',
    BackupProblem.damaged => 'failureBackupDamaged',
    BackupProblem.newerVersion => 'failureBackupNewer',
  };

  @override
  String? get debugMessage => detail;
}
