import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

void main() {
  late AddFlowHarness h;
  // The harness clock: 10 March 2025, 09:00.

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Future<void> finished(String id, DateTime on, {int pages = 300}) =>
      h.repos.books.upsert(
        // Book.create keeps the defaults; dates are set through copyWith.
        _book(id, on, pages),
      );

  Future<void> open(WidgetTester t, {Size size = const Size(420, 900)}) async {
    final c = await pumpRouterApp(t, size: size, overrides: h.overrides);
    routerOf(c).go('/stats');
    await t.pumpAndSettle();
  }

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  testWidgets('an empty library offers Add a book', (t) async {
    h = AddFlowHarness();
    await open(t);
    expect(find.text('Add a book'), findsOneWidget);
    await end(t);
  });

  testWidgets('no goal shows the call to set one, and saving shows the ring', (
    t,
  ) async {
    h = AddFlowHarness();
    await t.runAsync(() => finished('a', DateTime(2025, 2, 2)));
    await open(t);
    expect(find.text('Set a reading goal'), findsOneWidget);

    await t.tap(find.text('Set a goal'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '12');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();

    expect(find.text('1 of 12 books'), findsOneWidget);
    expect(find.text('Set a reading goal'), findsNothing);
    await end(t);
  });

  testWidgets('goal text says ahead of pace, and editing can remove it', (
    t,
  ) async {
    h = AddFlowHarness();
    await t.runAsync(() async {
      for (var i = 0; i < 4; i++) {
        await finished('b$i', DateTime(2025, 1, 5 + i));
      }
      await h.repos.goals.setTarget(2025, 12);
    });
    await open(t);
    // 10 March is day 69: 2.3 of 12 expected, 4 finished.
    expect(find.text('4 of 12 books'), findsOneWidget);
    expect(find.text('1 book ahead of pace'), findsOneWidget);

    await t.tap(find.text('Edit goal'));
    await t.pumpAndSettle();
    await t.tap(find.text('Remove goal'));
    await t.pumpAndSettle();
    expect(find.text('Set a reading goal'), findsOneWidget);
    await end(t);
  });

  testWidgets('invalid goal is refused with a message', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() => finished('a', DateTime(2025, 2, 2)));
    await open(t);
    await t.tap(find.text('Set a goal'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '0');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(find.text('Enter a number from 1 to 999'), findsOneWidget);
    await end(t);
  });

  testWidgets('the year selector moves between years with data', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() async {
      await finished('a', DateTime(2025, 2, 2));
      await finished('b', DateTime(2024, 5, 5));
      await h.repos.goals.setTarget(2024, 3);
    });
    await open(t);
    expect(find.text('2025'), findsOneWidget);
    expect(
      t
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
          )
          .onPressed,
      isNull,
      reason: 'cannot go past the latest year',
    );
    await t.tap(find.byTooltip('Previous year'));
    await t.pumpAndSettle();
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('1 of 3 books'), findsOneWidget);
    expect(find.text('2 books short'), findsOneWidget);
    await end(t);
  });

  testWidgets('partial data: library facts and empty charts still render', (
    t,
  ) async {
    h = AddFlowHarness();
    await t.runAsync(
      () =>
          h.repos.books.upsert(_book('w', null, 100, status: ReadStatus.want)),
    );
    await open(t);
    expect(
      find.text('Finish a book and its month lights up here.'),
      findsOneWidget,
    );
    await t.scrollUntilVisible(find.text('Your library'), 300);
    expect(find.text('Your library'), findsOneWidget);
    await end(t);
  });

  testWidgets('no overflow at 320dp and 200% text', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() async {
      await finished('a', DateTime(2025, 2, 2), pages: 1200);
      await h.repos.goals.setTarget(2025, 24);
    });
    final c = await pumpRouterApp(
      t,
      size: const Size(320, 640),
      textScale: 2,
      overrides: h.overrides,
    );
    routerOf(c).go('/stats');
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    await end(t);
  });
}

Book _book(
  String id,
  DateTime? on,
  int pages, {
  ReadStatus status = ReadStatus.finished,
}) => Book.create(
  id: id,
  title: 'Title $id',
  authors: 'Author $id',
  now: DateTime(2025, 1, 1),
  pages: pages,
  status: status,
).copyWith(finishedOn: on, startedOn: on);
