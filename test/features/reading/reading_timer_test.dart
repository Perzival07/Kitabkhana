import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/reading/data/drift_reading_sessions.dart';
import 'package:kitabkhana/features/reading/domain/reading_timer.dart';
import 'package:kitabkhana/features/reading/presentation/reading_timer_button.dart';
import 'package:kitabkhana/l10n/app_localizations_en.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';
import '../../helpers/repo_harness.dart';

void main() {
  group('rules', () {
    test('a session counts from half a minute, in whole minutes', () {
      expect(sessionMinutes(const Duration(seconds: 29)), isNull);
      expect(sessionMinutes(const Duration(seconds: 30)), 1);
      expect(sessionMinutes(const Duration(minutes: 24, seconds: 40)), 25);
      expect(sessionMinutes(const Duration(days: 3)), 1440);
    });

    test('times read nicely', () {
      final l10n = AppLocalizationsEn();
      expect(minutesText(l10n, 35), '35 min');
      expect(minutesText(l10n, 120), '2 h');
      expect(minutesText(l10n, 125), '2 h 5 min');
      expect(clockText(const Duration(minutes: 3, seconds: 7)), '03:07');
      expect(
        clockText(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
    });
  });

  group('storage', () {
    late RepoHarness h;
    setUp(() => h = RepoHarness());
    tearDown(() => h.db.close());

    test(
      'minutes for a book and day add up; deleted books do not count',
      () async {
        final repo = DriftReadingSessionRepository(h.db, h.clock);
        await h.addBook(id: 'a', title: 'A');
        await h.addBook(id: 'b', title: 'B');
        final day = DateTime(2025, 3, 10);
        await repo.addMinutes('a', day, 20);
        await repo.addMinutes('a', day, 15);
        await repo.addMinutes('b', day, 10);
        await repo.addMinutes('a', DateTime(2025, 3, 11), 5);
        expect(await h.db.select(h.db.readingSessions).get(), hasLength(3));
        expect(await repo.watchMinutesBetween(day, day).first, 45);
        expect(await repo.watchMinutesForBook('a').first, 40);
        await h.books.softDelete('b');
        expect(await repo.watchMinutesBetween(day, day).first, 35);
        expect(
          await repo
              .watchMinutesBetween(DateTime(2025), DateTime(2025, 12, 31))
              .first,
          40,
        );
      },
    );

    test('a running timer survives a restart', () async {
      final store = DbReadingTimerStore(h.db);
      expect(await store.load(), isNull);
      final at = DateTime(2025, 3, 10, 21, 5);
      await store.save(RunningTimer('a', at));
      final back = (await DbReadingTimerStore(h.db).load())!;
      expect(back.bookId, 'a');
      expect(back.startedAt, at);
      await store.clear();
      expect(await store.load(), isNull);
    });
  });

  testWidgets('time a session on the Reading tab, then update the page', (
    t,
  ) async {
    final h = AddFlowHarness();
    addTearDown(h.dispose);
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(
          id: 'a',
          title: 'Middlemarch',
          now: DateTime(2025, 3, 10),
          pages: 880,
          status: ReadStatus.reading,
        ).copyWith(currentPage: 100),
      ),
    );
    final c = await pumpRouterApp(
      t,
      size: const Size(420, 900),
      overrides: h.overrides,
    );
    routerOf(c).go('/reading');
    await t.pumpAndSettle();

    await t.tap(find.byTooltip('Start the reading timer'));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await t.pump();
    expect(find.text('Reading for 00:00'), findsOneWidget);

    h.clock.advance(const Duration(minutes: 25));
    await t.pump(const Duration(seconds: 1));
    expect(find.text('Reading for 25:00'), findsOneWidget);

    await t.tap(find.byTooltip('Stop the timer (25:00)'));
    for (var i = 0; i < 3; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await t.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('Logged 25 min of reading'), findsOneWidget);
    // The page sheet follows.
    expect(find.text('Save'), findsOneWidget);
    await t.tap(find.text('+25'));
    await t.pump();
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(find.text('25 min with the timer'), findsOneWidget);
    expect(
      await t.runAsync(
        () => DriftReadingSessionRepository(
          h.db,
          h.clock,
        ).watchMinutesForBook('a').first,
      ),
      25,
    );
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  });
}
