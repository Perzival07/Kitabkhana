import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/reminders/application/loan_nudge.dart';
import 'package:kitabkhana/features/reminders/application/loan_reminder_service.dart';
import 'package:kitabkhana/features/reminders/domain/reminder_plan.dart';
import 'package:kitabkhana/l10n/app_localizations_en.dart';

import '../../helpers/fake_notification_scheduler.dart';
import '../../helpers/repo_harness.dart';

void main() {
  final en = AppLocalizationsEn();
  final now = DateTime(2025, 3, 10, 9);

  Loan loan(
    String id, {
    DateTime? due,
    LoanDirection direction = LoanDirection.lent,
    String? phone,
    String person = 'Priya',
    DateTime? returned,
  }) {
    final l = Loan.create(
      id: id,
      bookId: 'b-$id',
      direction: direction,
      personName: person,
      personPhone: phone,
      startedOn: DateTime(2025, 3, 1),
      dueOn: due,
      now: now,
    );
    return returned == null ? l : l.copyWith(returnedOn: returned);
  }

  group('planFor', () {
    test('10:00 on the due date, and +3 days', () {
      final p = planFor(loan('a', due: DateTime(2025, 3, 20)), now);
      expect(p.map((e) => e.kind), <ReminderKind>[
        ReminderKind.due,
        ReminderKind.overdue,
      ]);
      expect(p[0].fireAt, DateTime(2025, 3, 20, 10));
      expect(p[1].fireAt, DateTime(2025, 3, 23, 10));
    });

    test('no due date, returned, or past times give nothing', () {
      expect(planFor(loan('a'), now), isEmpty);
      expect(
        planFor(loan('a', due: DateTime(2025, 3, 20), returned: now), now),
        isEmpty,
      );
      expect(planFor(loan('a', due: DateTime(2025, 3, 1)), now), isEmpty);
    });

    test('due today after 10:00 keeps only the overdue follow-up', () {
      final p = planFor(
        loan('a', due: DateTime(2025, 3, 10)),
        DateTime(2025, 3, 10, 11),
      );
      expect(p.single.kind, ReminderKind.overdue);
      expect(p.single.fireAt, DateTime(2025, 3, 13, 10));
    });

    test('due today before 10:00 fires today', () {
      final p = planFor(loan('a', due: DateTime(2025, 3, 10)), now);
      expect(p.first.fireAt, DateTime(2025, 3, 10, 10));
    });

    test('the +3 days rolls over month ends', () {
      final p = planFor(loan('a', due: DateTime(2025, 3, 30)), now);
      expect(p[1].fireAt, DateTime(2025, 4, 2, 10));
    });

    test('ids are stable, positive and differ by kind and loan', () {
      final a = reminderId('loan-1', ReminderKind.due);
      expect(a, reminderId('loan-1', ReminderKind.due));
      expect(a, isNot(reminderId('loan-1', ReminderKind.overdue)));
      expect(a, isNot(reminderId('loan-2', ReminderKind.due)));
      expect(a, greaterThan(0));
      expect(a, lessThan(0x7fffffff));
    });
  });

  test('planAll keeps the nearest 64', () {
    final loans = <Loan>[
      for (var i = 0; i < 50; i++)
        loan('l$i', due: DateTime(2025, 4, 1).add(Duration(days: i))),
    ];
    final p = planAll(loans, now);
    expect(p.length, 64);
    for (var i = 1; i < p.length; i++) {
      expect(p[i].fireAt.isBefore(p[i - 1].fireAt), isFalse);
    }
    // 100 reminders were possible; the latest ones were dropped.
    final all = planAll(loans, now, limit: 1000);
    expect(all.length, 100);
    expect(p.last.fireAt, all[63].fireAt);
  });

  group('LoanReminderService', () {
    late RepoHarness h;
    late FakeNotificationScheduler sched;
    late LoanReminderService svc;

    setUp(() {
      h = RepoHarness();
      sched = FakeNotificationScheduler();
      svc = LoanReminderService(
        scheduler: sched,
        loans: h.loans,
        books: h.books,
        clock: h.clock,
        l10n: () => en,
      );
    });
    tearDown(() => h.db.close());

    Future<Loan> start(
      String id,
      DateTime? due, {
      LoanDirection d = LoanDirection.lent,
    }) async {
      await h.books.upsert(
        Book.create(id: 'b-$id', title: 'Book $id', now: h.clock.now()),
      );
      return (await h.loans.startLoan(
        Loan.create(
          id: id,
          bookId: 'b-$id',
          direction: d,
          personName: 'Priya',
          startedOn: DateTime(2025, 3, 3),
          dueOn: due,
          now: h.clock.now(),
        ),
      )).getOrNull()!;
    }

    test('scheduling a loan creates the due and overdue reminders', () async {
      final l = await start('a', DateTime(2025, 3, 20));
      await svc.schedule(l, 'Book a');
      expect(sched.pending.length, 2);
      final due = sched.pending[reminderId('a', ReminderKind.due)]!;
      expect(due.at, DateTime(2025, 3, 20, 10));
      expect(due.title, '“Book a” is due today');
      expect(due.body, 'Priya has it. A friendly nudge?');
      expect(due.payload, 'b-a');
    });

    test('a loan without a due date schedules nothing', () async {
      final l = await start('a', null);
      await svc.schedule(l, 'Book a');
      expect(sched.pending, isEmpty);
    });

    test('borrowed loans word it as returning', () async {
      final l = await start(
        'a',
        DateTime(2025, 3, 20),
        d: LoanDirection.borrowed,
      );
      await svc.schedule(l, 'Book a');
      final due = sched.pending[reminderId('a', ReminderKind.due)]!;
      expect(due.body, 'Time to return it to Priya.');
    });

    test('cancel removes both reminders', () async {
      final l = await start('a', DateTime(2025, 3, 20));
      await svc.schedule(l, 'Book a');
      await svc.cancel('a');
      expect(sched.pending, isEmpty);
    });

    test('returning a loan and reconciling leaves nothing', () async {
      final l = await start('a', DateTime(2025, 3, 20));
      await svc.schedule(l, 'Book a');
      await h.loans.finishLoan('a', DateTime(2025, 3, 11));
      await svc.reconcile();
      expect(sched.pending, isEmpty);
    });

    test('reconcile removes stale ids and adds missing ones', () async {
      await start('a', DateTime(2025, 3, 20));
      sched.pending[999] = (
        at: DateTime(2025, 3, 21),
        title: 'old',
        body: '',
        payload: '',
      );
      await svc.reconcile();
      expect(sched.pending.containsKey(999), isFalse);
      expect(sched.pending.length, 2);
    });

    test('reconcile keeps only the nearest 64 of many loans', () async {
      for (var i = 0; i < 40; i++) {
        await start('l$i', DateTime(2025, 4, 1).add(Duration(days: i)));
      }
      await svc.reconcile();
      expect(sched.pending.length, 64);
      final latest = sched.pending.values
          .map((e) => e.at)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      // 80 reminders were possible; the furthest-out ones were dropped.
      expect(latest.isBefore(DateTime(2025, 5, 14)), isTrue);
    });

    test('an unsupported platform schedules nothing', () async {
      final web = FakeNotificationScheduler(supported: false);
      final s = LoanReminderService(
        scheduler: web,
        loans: h.loans,
        books: h.books,
        clock: h.clock,
        l10n: () => en,
      );
      final l = await start('a', DateTime(2025, 3, 20));
      await s.schedule(l, 'x');
      await s.reconcile();
      expect(web.pending, isEmpty);
    });
  });

  group('LoanNudge', () {
    test('message keeps emoji, quotes and Hindi intact', () {
      final l = loan('a', person: 'प्रिया');
      final m = LoanNudge.message(en, l, 'The "Big" किताब');
      expect(m, contains('प्रिया'));
      expect(m, contains('The "Big" किताब'));
      expect(m, contains('📚'));
    });

    test('WhatsApp link is pre-filled and encoded', () async {
      final launcher = _Launcher();
      final r = await LoanNudge(launcher).whatsApp(
        en,
        loan('a', phone: '98765 43210'),
        'Dune',
        defaultCountryCode: '91',
      );
      expect(r, NudgeResult.whatsApp);
      final uri = launcher.opened.single;
      expect(uri.host, 'wa.me');
      expect(uri.path, '/919876543210');
      expect(uri.queryParameters['text'], contains('Dune'));
      expect(uri.toString().contains(' '), isFalse);
    });

    test('falls back to SMS, then to the share sheet', () async {
      final noWhatsApp = _Launcher(accept: (u) => u.scheme == 'sms');
      final r1 = await LoanNudge(noWhatsApp).whatsApp(
        en,
        loan('a', phone: '9876543210'),
        'Dune',
        defaultCountryCode: '91',
      );
      expect(r1, NudgeResult.sms);
      expect(noWhatsApp.opened.last.scheme, 'sms');
      expect(noWhatsApp.opened.last.toString(), contains('body=Hi%20Priya'));

      final nothing = _Launcher(accept: (_) => false);
      final r2 = await LoanNudge(nothing).whatsApp(
        en,
        loan('a', phone: '9876543210'),
        'Dune',
        defaultCountryCode: '91',
      );
      expect(r2, NudgeResult.shared);
      expect(nothing.shared, hasLength(1));
    });

    test('no phone number means no nudge', () async {
      final launcher = _Launcher();
      final r = await LoanNudge(launcher)
          .sms(en, loan('a'), 'Dune', defaultCountryCode: '91');
      expect(r, NudgeResult.noPhone);
      expect(launcher.opened, isEmpty);
    });
  });
}

class _Launcher implements NudgeLauncher {
  _Launcher({this.accept});

  final bool Function(Uri)? accept;
  final List<Uri> opened = <Uri>[];
  final List<String> shared = <String>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return accept?.call(uri) ?? true;
  }

  @override
  Future<void> share(String text) async => shared.add(text);
}
