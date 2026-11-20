import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

void main() {
  late AddFlowHarness h;

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Future<void> seed() => h.repos.books.upsert(
    Book.create(
      id: 'b1',
      title: 'Dune',
      authors: 'Frank Herbert',
      now: h.clock.now(),
      pages: 300,
    ),
  );

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  testWidgets('/book/:id shows the detail page', (t) async {
    h = AddFlowHarness();
    await seed();
    final c = await h.pump(t, start: '/book/b1');
    expect(locationOf(c), '/book/b1');
    expect(find.text('Frank Herbert'), findsOneWidget);
    await end(t);
  });

  testWidgets('edit changes the title and returns', (t) async {
    h = AddFlowHarness();
    await seed();
    final c = await h.pump(t, start: '/book/b1', size: const Size(400, 2400));
    await t.tap(find.text('Edit'));
    await t.pumpAndSettle();
    expect(locationOf(c), '/book/b1/edit');
    expect(find.text('Edit book'), findsOneWidget);
    await t.enterText(find.widgetWithText(TextFormField, 'Title'), 'Dune II');
    await t.ensureVisible(find.text('Save'));
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(locationOf(c), '/book/b1');
    final b = (await t.runAsync(() => h.repos.books.getById('b1')))!
        .getOrNull()!;
    expect(b.title, 'Dune II');
    expect(b.status, ReadStatus.want);
    await end(t);
  });

  testWidgets('wide screens show the detail beside the library', (t) async {
    h = AddFlowHarness();
    await seed();
    final c = await h.pump(t, start: '/library', size: const Size(1200, 900));
    await t.tap(find.text('Dune').first);
    await t.pumpAndSettle();
    expect(locationOf(c), '/library', reason: 'no route change');
    expect(find.widgetWithText(ChoiceChip, 'Reading'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
    await end(t);
  });
}
