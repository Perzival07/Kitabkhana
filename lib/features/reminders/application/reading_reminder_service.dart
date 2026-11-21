import '../../../core/clock.dart';
import '../../../l10n/app_localizations.dart';
import '../../reading/domain/reading_repository.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/notification_scheduler.dart';
import '../domain/reminder_plan.dart';

/// An optional daily nudge to read, at the time chosen in Settings.
///
/// Local notifications cannot repeat with a condition, so the next
/// [kReadingReminderDays] days are scheduled one by one and rebuilt on every
/// app start, when the setting changes and after reading is logged (today's
/// nudge is dropped once you have read today).
class ReadingReminderService {
  ReadingReminderService({
    required this.scheduler,
    required this.readings,
    required this.clock,
    required this.settings,
    required this.l10n,
  });

  final NotificationScheduler scheduler;
  final ReadingRepository readings;
  final Clock clock;
  final Future<AppSettings> Function() settings;
  final AppLocalizations Function() l10n;

  /// Makes the pending reading reminders match the settings. Safe to run
  /// any time; never throws.
  Future<void> reconcile() async {
    try {
      if (!scheduler.supported) return;
      for (final id in await scheduler.pendingIds()) {
        if (isReadingReminderId(id)) await scheduler.cancel(id);
      }
      final s = await settings();
      if (!s.readingReminderEnabled) return;

      final now = clock.now();
      final today = clock.today();
      final readToday =
          (await readings.watchBetween(today, today).first).isNotEmpty;
      final text = l10n();
      for (var i = 0; i < kReadingReminderDays; i++) {
        final at = DateTime(
          today.year,
          today.month,
          today.day + i,
          s.readingReminderTime.hour,
          s.readingReminderTime.minute,
        );
        if (!at.isAfter(now) || (i == 0 && readToday)) continue;
        await scheduler.schedule(
          id: kReadingReminderIdBase + i,
          at: at,
          title: text.readingReminderTitle,
          body: text.readingReminderBody,
          payload: '',
        );
      }
    } on Object {
      // Reminders are optional: never let them get in the way.
    }
  }
}
