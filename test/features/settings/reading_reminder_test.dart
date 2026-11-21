import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/reminders/application/loan_reminder_service.dart';
import 'package:kitabkhana/features/reminders/application/reading_reminder_service.dart';
import 'package:kitabkhana/features/reminders/domain/reminder_plan.dart';
import 'package:kitabkhana/features/settings/domain/app_settings.dart';
import 'package:kitabkhana/l10n/app_localizations_en.dart';

import '../../helpers/fake_notification_scheduler.dart';
import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;
  late FakeNotificationScheduler sched;
  late AppSettings settings;

  ReadingReminderService make() => ReadingReminderService(
    scheduler: sched,
    readings: h.readings,
    clock: h.clock,
    settings: () async => settings,
    l10n: AppLocalizationsEn.new,
  );

  setUp(() {
    h = RepoHarness(); // 10 March 2025, 09:00 plus a minute per tick
    sched = FakeNotificationScheduler();
    settings = const AppSettings(
      readingReminderEnabled: true,
      readingReminderTime: DayTime(20, 30),
    );
  });
  tearDown(() => h.db.close());

  test('schedules the next 14 days at the chosen time', () async {
    await make().reconcile();
    expect(sched.pending, hasLength(kReadingReminderDays));
    final first = sched.pending[kReadingReminderIdBase]!;
    expect(first.at, DateTime(2025, 3, 10, 20, 30));
    expect(
      sched.pending[kReadingReminderIdBase + 13]!.at,
      DateTime(2025, 3, 23, 20, 30),
    );
    expect(first.title, 'Time for a few pages?');
    expect(first.payload, isEmpty, reason: 'tapping just opens the app');
  });

  test('a time already gone today starts tomorrow', () async {
    h.clock.set(DateTime(2025, 3, 10, 21));
    await make().reconcile();
    expect(sched.pending, hasLength(13));
    expect(sched.pending.containsKey(kReadingReminderIdBase), isFalse);
    expect(
      sched.pending[kReadingReminderIdBase + 1]!.at,
      DateTime(2025, 3, 11, 20, 30),
    );
  });

  test('having read today drops today\'s nudge', () async {
    final b = await h.addBook(title: 'Dune');
    await h.addLog(bookId: b.id, date: h.clock.today(), to: 10);
    await make().reconcile();
    expect(sched.pending.containsKey(kReadingReminderIdBase), isFalse);
    expect(sched.pending, hasLength(13));
  });

  test('switching it off cancels them, and others are left alone', () async {
    sched.pending[42] = (
      at: DateTime(2025, 4),
      title: 'loan',
      body: '',
      payload: 'b',
    );
    await make().reconcile();
    expect(sched.pending, hasLength(15));
    settings = settings.copyWith(readingReminderEnabled: false);
    await make().reconcile();
    expect(sched.pending.keys, [42]);
  });

  test('a changed time replaces the old ones', () async {
    await make().reconcile();
    settings = settings.copyWith(readingReminderTime: const DayTime(22, 0));
    await make().reconcile();
    expect(sched.pending, hasLength(14));
    expect(sched.pending[kReadingReminderIdBase]!.at.hour, 22);
    expect(sched.pending[kReadingReminderIdBase + 1]!.at.hour, 22);
  });

  test('does nothing where notifications are unsupported', () async {
    sched = FakeNotificationScheduler(supported: false);
    await make().reconcile();
    expect(sched.pending, isEmpty);
  });

  group('loan reminders', () {
    test('ids stay clear of the reading range', () {
      for (var i = 0; i < 2000; i++) {
        for (final k in ReminderKind.values) {
          final id = reminderId('loan-$i', k);
          expect(id, lessThan(kReadingReminderIdBase));
          expect(isReadingReminderId(id), isFalse);
        }
      }
    });

    test('the due time is configurable', () async {
      final b = await h.addBook(title: 'Emma');
      final loan = (await h.loans.create(
        h.newLoan(bookId: b.id, dueOn: DateTime(2025, 3, 20)),
      )).getOrNull()!;
      final at10 = planFor(loan, h.clock.now()).first.fireAt;
      expect(at10, DateTime(2025, 3, 20, 10));
      final custom = planFor(loan, h.clock.now(), hour: 8, minute: 15);
      expect(custom.first.fireAt, DateTime(2025, 3, 20, 8, 15));
      expect(custom.last.fireAt, DateTime(2025, 3, 23, 8, 15));
    });

    test('rebuilding loan reminders leaves reading reminders alone', () async {
      await make().reconcile();
      final b = await h.addBook(title: 'Emma');
      await h.loans.create(
        h.newLoan(
          bookId: b.id,
          direction: LoanDirection.lent,
          dueOn: DateTime(2025, 3, 20),
        ),
      );
      final loans = LoanReminderService(
        scheduler: sched,
        loans: h.loans,
        books: h.books,
        clock: h.clock,
        l10n: AppLocalizationsEn.new,
        reminderTime: () async => (hour: 18, minute: 0),
      );
      await loans.reconcile();
      expect(
        sched.pending.keys.where(isReadingReminderId),
        hasLength(kReadingReminderDays),
      );
      final due = sched.pending.entries
          .where((e) => !isReadingReminderId(e.key))
          .map((e) => e.value.at)
          .toList();
      expect(due, hasLength(2));
      expect(due.every((d) => d.hour == 18), isTrue);
    });
  });
}
