import 'package:kitabkhana/features/reminders/domain/notification_scheduler.dart';

/// Records scheduled notifications instead of talking to the OS.
class FakeNotificationScheduler implements NotificationScheduler {
  FakeNotificationScheduler({this.supported = true, this.granted = true});

  @override
  final bool supported;
  bool granted;
  int permissionRequests = 0;

  /// id -> (when, title, body, payload).
  final Map<int, ({DateTime at, String title, String body, String payload})>
  pending = <int, ({DateTime at, String title, String body, String payload})>{};

  @override
  Future<bool> hasPermission() async => granted;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    granted = true;
    return true;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {
    pending[id] = (at: at, title: title, body: body, payload: payload);
  }

  @override
  Future<void> cancel(int id) async => pending.remove(id);

  @override
  Future<Set<int>> pendingIds() async => pending.keys.toSet();
}
