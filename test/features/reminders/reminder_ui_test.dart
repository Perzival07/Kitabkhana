import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/reminder_providers.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/reminders/application/loan_nudge.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/fake_notification_scheduler.dart';
import '../../helpers/pump_router_app.dart';

class _Launcher implements NudgeLauncher {
  final List<Uri> opened = <Uri>[];
  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return true;
  }

  @override
  Future<void> share(String text) async {}
}

void main() {
  late AddFlowHarness h;

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Future<void> seedLoan({String? phone}) async {
    await h.repos.books.upsert(
      Book.create(id: 'b1', title: 'Dune', now: h.clock.now()),
    );
    await h.repos.loans.startLoan(
      Loan.create(
        id: 'l1',
        bookId: 'b1',
        direction: LoanDirection.lent,
        personName: 'Priya',
        personPhone: phone,
        startedOn: DateTime(2025, 2, 20),
        dueOn: DateTime(2025, 3, 1),
        now: h.clock.now(),
      ),
    );
  }

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  testWidgets('web: an overdue banner shows in the library', (t) async {
    h = AddFlowHarness();
    await t.runAsync(seedLoan);
    final web = FakeNotificationScheduler(supported: false);
    await pumpRouterApp(
      t,
      overrides: <Override>[
        ...h.overrides.where((o) => o.origin != notificationSchedulerProvider),
        notificationSchedulerProvider.overrideWithValue(web),
      ],
    );
    expect(find.text('1 book is overdue'), findsOneWidget);
    await end(t);
  });

  testWidgets('phones: no overdue banner (notifications do the job)', (
    t,
  ) async {
    h = AddFlowHarness();
    await t.runAsync(seedLoan);
    await pumpRouterApp(t, overrides: h.overrides);
    expect(find.text('1 book is overdue'), findsNothing);
    await end(t);
  });

  testWidgets('Remind on WhatsApp opens a pre-filled wa.me link', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() => seedLoan(phone: '98765 43210'));
    final launcher = _Launcher();
    final c = await pumpRouterApp(
      t,
      size: const Size(400, 1400),
      overrides: <Override>[
        ...h.overrides,
        loanNudgeProvider.overrideWithValue(LoanNudge(launcher)),
      ],
    );
    routerOf(c).go('/book/b1');
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Remind'));
    await t.pumpAndSettle();
    await t.tap(find.text('Remind on WhatsApp'));
    await t.pumpAndSettle();
    expect(launcher.opened.single.host, 'wa.me');
    expect(launcher.opened.single.path, '/919876543210');
    await end(t);
  });

  testWidgets('Remind without a phone number explains itself', (t) async {
    h = AddFlowHarness();
    await t.runAsync(seedLoan);
    final launcher = _Launcher();
    final c = await pumpRouterApp(
      t,
      size: const Size(400, 1400),
      overrides: <Override>[
        ...h.overrides,
        loanNudgeProvider.overrideWithValue(LoanNudge(launcher)),
      ],
    );
    routerOf(c).go('/book/b1');
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Remind'));
    await t.pumpAndSettle();
    await t.tap(find.text('Send SMS'));
    await t.pumpAndSettle();
    expect(find.text('Add a phone number to send a reminder.'), findsOneWidget);
    expect(launcher.opened, isEmpty);
    await end(t);
  });
}
