import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kitabkhana/platform/notifications/mobile_notification_scheduler.dart';

/// The platform code the journeys replace with fakes, run for real on a device
/// or emulator: Android's notification plugin, its time zone lookup and its
/// stored schedule. Run with
///   flutter test integration_test/platform_test.dart --flavor dev -d <device>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a reminder can be scheduled, found and cancelled', (t) async {
    final s = MobileNotificationScheduler(
      channelName: 'Loan reminders',
      channelDescription: 'Reminders about lent books',
    );
    expect(s.supported, isTrue);

    const id = 424242;
    final at = DateTime.now().add(const Duration(days: 2));
    await s.schedule(
      id: id,
      at: at,
      title: 'Return due',
      body: 'Godan is due back',
      payload: 'book-1',
    );
    expect(await s.pendingIds(), contains(id));

    // Scheduling the same id again replaces it rather than adding another.
    await s.schedule(
      id: id,
      at: at.add(const Duration(hours: 1)),
      title: 'Return due',
      body: 'Godan is due back',
      payload: 'book-1',
    );
    final pending = await s.pendingIds();
    expect(pending.where((p) => p == id), hasLength(1));

    await s.cancel(id);
    expect(await s.pendingIds(), isNot(contains(id)));
  });

  testWidgets('asking for permission answers without throwing', (t) async {
    final s = MobileNotificationScheduler(
      channelName: 'Loan reminders',
      channelDescription: 'Reminders about lent books',
    );
    // The answer depends on the device (Android 13+ asks, older grants).
    expect(await s.hasPermission(), isA<bool>());
  });
}
