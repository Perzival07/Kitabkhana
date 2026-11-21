import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/reading/domain/reading_log.dart';
import 'package:kitabkhana/features/reading/presentation/reading_screen.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

void main() {
  late AddFlowHarness h;
  // The harness clock: 10 March 2025, 09:00.
  final today = DateTime(2025, 3, 10);

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Future<void> book(
    String id, {
    ReadStatus status = ReadStatus.reading,
    int? pages = 300,
    int page = 0,
  }) async {
    await h.repos.books.upsert(
      Book.create(
        id: id,
        title: 'Title $id',
        authors: 'Author $id',
        now: today,
        pages: pages,
        status: status,
      ).copyWith(currentPage: page, startedOn: today),
    );
  }

  Future<void> log(String bookId, DateTime day, int pages) async {
    await h.repos.readings.upsert(
      ReadingLog.create(
        id: 'l-$bookId-${day.day}',
        bookId: bookId,
        date: day,
        fromPage: 0,
        toPage: pages,
        now: today,
      ),
    );
  }

  Future<void> open(WidgetTester t) async {
    final c = await pumpRouterApp(
      t,
      size: const Size(420, 900),
      overrides: h.overrides,
    );
    routerOf(c).go('/reading');
    await t.pumpAndSettle();
  }

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  group('dayPartOf', () {
    test('switches at noon and 17:00', () {
      expect(dayPartOf(DateTime(2025, 1, 1, 0, 0)), DayPart.morning);
      expect(dayPartOf(DateTime(2025, 1, 1, 11, 59)), DayPart.morning);
      expect(dayPartOf(DateTime(2025, 1, 1, 12)), DayPart.afternoon);
      expect(dayPartOf(DateTime(2025, 1, 1, 16, 59)), DayPart.afternoon);
      expect(dayPartOf(DateTime(2025, 1, 1, 17)), DayPart.evening);
      expect(dayPartOf(DateTime(2025, 1, 1, 23, 59)), DayPart.evening);
    });
  });

  for (final (hour, text) in <(int, String)>[
    (9, 'Good morning'),
    (14, 'Good afternoon'),
    (20, 'Good evening'),
  ]) {
    testWidgets('greeting at $hour:00 is $text', (t) async {
      h = AddFlowHarness();
      h.clock.set(DateTime(2025, 3, 10, hour));
      await open(t);
      expect(find.text(text), findsOneWidget);
      await end(t);
    });
  }

  testWidgets('streak badge counts days, alive from yesterday', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() async {
      await book('a', page: 60);
      await log('a', DateTime(2025, 3, 8), 20);
      await log('a', DateTime(2025, 3, 9), 20);
    });
    await open(t);
    // Nothing read yet today, but yesterday keeps the streak alive.
    expect(find.text('2-day streak'), findsOneWidget);
    await end(t);
  });

  testWidgets('a streak missed by a full day is not shown', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() async {
      await book('a', page: 60);
      await log('a', DateTime(2025, 3, 7), 20);
    });
    await open(t);
    expect(find.textContaining('-day streak'), findsNothing);
    await end(t);
  });

  testWidgets('a reading card shows page, progress and the update sheet', (
    t,
  ) async {
    h = AddFlowHarness();
    await t.runAsync(() => book('a', page: 100));
    await open(t);
    expect(find.text('Currently reading'), findsOneWidget);
    expect(find.text('Page 100 of 300'), findsOneWidget);
    expect(find.text('33%'), findsOneWidget);
    expect(find.text('No pages yet today'), findsOneWidget);

    await t.tap(find.text('Update page'));
    await t.pumpAndSettle();
    await t.tap(find.text('+25'));
    await t.pump();
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();

    expect(find.text('Page 125 of 300'), findsOneWidget);
    expect(find.text('25 pages today'), findsOneWidget);
    expect(find.text('1-day streak'), findsOneWidget);
    await end(t);
  });

  testWidgets('empty state: nothing to read offers Add a book', (t) async {
    h = AddFlowHarness();
    await open(t);
    expect(find.text('Pick your next read'), findsOneWidget);
    expect(find.text('Add a book'), findsOneWidget);
    await end(t);
  });

  testWidgets('empty state: want-to-read covers are offered', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() => book('w', status: ReadStatus.want));
    await open(t);
    expect(find.text('Pick your next read'), findsOneWidget);
    expect(find.text('Title w'), findsWidgets);
    await end(t);
  });

  testWidgets('up next shows only when something is being read', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() async {
      await book('a');
      await book('w', status: ReadStatus.want);
    });
    await open(t);
    expect(find.text('Up next'), findsOneWidget);
    await end(t);
  });

  testWidgets('overdue loans card appears only when something is overdue', (
    t,
  ) async {
    h = AddFlowHarness();
    await t.runAsync(() async {
      await book('a');
      await book('o', status: ReadStatus.finished);
      await h.repos.loans.startLoan(
        Loan.create(
          id: 'ln',
          bookId: 'o',
          direction: LoanDirection.lent,
          personName: 'Priya',
          startedOn: DateTime(2025, 3, 1),
          dueOn: DateTime(2025, 3, 5),
          now: today,
        ),
      );
    });
    await open(t);
    expect(find.text('1 book is out past its date'), findsOneWidget);
    await end(t);
  });

  testWidgets('no overdue card when nothing is overdue', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() => book('a'));
    await open(t);
    expect(find.textContaining('out past'), findsNothing);
    await end(t);
  });
}
