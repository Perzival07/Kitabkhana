/// What the reminder logic needs from the operating system: scheduling and
/// cancelling local notifications. Implemented per platform; faked in tests.
abstract interface class NotificationScheduler {
  /// Whether this platform can schedule notifications at all.
  bool get supported;

  /// Notification permission: true when granted.
  Future<bool> hasPermission();

  /// Asks the OS for permission; true when granted.
  Future<bool> requestPermission();

  /// Schedules (replacing any with the same [id]) a notification at the local
  /// time [at]. [payload] comes back when the notification is tapped.
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  });

  Future<void> cancel(int id);

  /// Ids of notifications still waiting to fire.
  Future<Set<int>> pendingIds();
}

/// For the web and anywhere notifications cannot be scheduled.
class UnsupportedNotificationScheduler implements NotificationScheduler {
  const UnsupportedNotificationScheduler();

  @override
  bool get supported => false;
  @override
  Future<bool> hasPermission() async => false;
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {}
  @override
  Future<void> cancel(int id) async {}
  @override
  Future<Set<int>> pendingIds() async => <int>{};
}
