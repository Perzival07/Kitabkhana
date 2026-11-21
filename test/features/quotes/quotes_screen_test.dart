import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/quotes/domain/quote.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

void main() {
  late AddFlowHarness h;
  final now = DateTime(2025, 3, 10);

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Future<void> seed() async {
    await h.repos.books.upsert(
      Book.create(
        id: 'b1',
        title: 'Middlemarch',
        authors: 'George Eliot',
        pages: 880,
        now: now,
      ),
    );
    await h.repos.books.upsert(
      Book.create(id: 'b2', title: 'Dune', authors: 'Frank Herbert', now: now),
    );
    var i = 0;
    Future<void> q(
      String id,
      String bookId,
      String body, {
      int? page,
      bool fav = false,
    }) => h.repos.quotes.upsert(
      Quote.create(
        id: id,
        bookId: bookId,
        body: body,
        page: page,
        isFavourite: fav,
        now: now.add(Duration(minutes: ++i)),
      ),
    );
    await q('q1', 'b1', 'It is a truth universally acknowledged.', page: 42);
    await q(
      'q2',
      'b1',
      'Nothing is so good as it seems beforehand.',
      fav: true,
    );
    await q('q3', 'b2', 'Fear is the mind-killer.', page: 7);
  }

  Future<void> open(WidgetTester t) async {
    final c = await pumpRouterApp(
      t,
      size: const Size(420, 900),
      overrides: h.overrides,
    );
    routerOf(c).go('/quotes');
    await t.pumpAndSettle();
  }

  /// The "More" menu of the card showing [text].
  Finder menuOf(String text) => find.descendant(
    of: find.ancestor(of: find.text(text), matching: find.byType(Card)),
    matching: find.byTooltip('More'),
  );

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  Future<List<QuoteRowLite>> rows() async => (await h.db.liveQuotes().get())
      .map((r) => QuoteRowLite(r.id, r.body, r.page, r.isFavourite))
      .toList();

  testWidgets('an empty list is a warm empty state', (t) async {
    h = AddFlowHarness();
    await open(t);
    expect(find.text('No quotes yet'), findsOneWidget);
    expect(find.text('Snap a quote'), findsOneWidget);
    await end(t);
  });

  testWidgets('quotes show their text and "— Title, p. 42"', (t) async {
    h = AddFlowHarness();
    await t.runAsync(seed);
    await open(t);
    expect(
      find.text('It is a truth universally acknowledged.'),
      findsOneWidget,
    );
    expect(find.text('— Middlemarch, p. 42'), findsOneWidget);
    expect(find.text('— Middlemarch'), findsOneWidget, reason: 'no page');
    expect(find.text('— Dune, p. 7'), findsOneWidget);
    await end(t);
  });

  testWidgets('search matches text, title and author', (t) async {
    h = AddFlowHarness();
    await t.runAsync(seed);
    await open(t);
    await t.enterText(find.byType(TextField).first, 'mind-killer');
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Fear is the mind-killer.'), findsOneWidget);
    expect(find.textContaining('truth universally'), findsNothing);

    await t.enterText(find.byType(TextField).first, 'ELIOT');
    await t.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('truth universally'), findsOneWidget);
    expect(find.text('Fear is the mind-killer.'), findsNothing);

    await t.enterText(find.byType(TextField).first, 'zzz');
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('No quotes match.'), findsOneWidget);
    await end(t);
  });

  testWidgets('the favourites filter and the favourite star', (t) async {
    h = AddFlowHarness();
    await t.runAsync(seed);
    await open(t);
    await t.tap(find.widgetWithText(FilterChip, 'Favourites'));
    await t.pumpAndSettle();
    expect(
      find.text('Nothing is so good as it seems beforehand.'),
      findsOneWidget,
    );
    expect(find.text('Fear is the mind-killer.'), findsNothing);

    // Un-favouriting it empties the filtered list.
    await t.tap(find.byTooltip('Remove from favourites'));
    await t.pumpAndSettle();
    expect(find.text('No quotes match.'), findsOneWidget);
    final saved = await t.runAsync(rows);
    expect(saved!.where((r) => r.fav), isEmpty);
    await end(t);
  });

  testWidgets('delete offers undo that brings it back', (t) async {
    h = AddFlowHarness();
    await t.runAsync(seed);
    await open(t);
    await t.tap(menuOf('Fear is the mind-killer.'));
    await t.pumpAndSettle();
    await t.tap(find.text('Delete'));
    await t.pumpAndSettle();
    expect(find.text('Quote deleted'), findsOneWidget);
    expect((await t.runAsync(rows))!, hasLength(2));

    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect((await t.runAsync(rows))!, hasLength(3));
    await end(t);
  });

  testWidgets('edit changes the text and page', (t) async {
    h = AddFlowHarness();
    await t.runAsync(seed);
    await open(t);
    await t.tap(menuOf('Fear is the mind-killer.'));
    await t.pumpAndSettle();
    await t.tap(find.text('Edit'));
    await t.pumpAndSettle();
    await t.enterText(
      find.widgetWithText(TextField, 'Quote'),
      'Fear is the little-death.',
    );
    await t.enterText(find.widgetWithText(TextField, 'Page (optional)'), '9');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(find.text('Fear is the little-death.'), findsOneWidget);
    expect(find.text('— Dune, p. 9'), findsOneWidget);
    await end(t);
  });

  testWidgets('a page past the end of the book is refused with a message', (
    t,
  ) async {
    h = AddFlowHarness();
    await t.runAsync(seed);
    await open(t);
    await t.tap(menuOf('It is a truth universally acknowledged.'));
    await t.pumpAndSettle();
    await t.tap(find.text('Edit'));
    await t.pumpAndSettle();
    await t.enterText(
      find.widgetWithText(TextField, 'Page (optional)'),
      '9999',
    );
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(find.text('Something went wrong. Please try again.'), findsNothing);
    final saved = await t.runAsync(rows);
    expect(saved!.where((r) => r.page == 9999), isEmpty);
    await end(t);
  });

  testWidgets('share as text hands over quote and source', (t) async {
    h = AddFlowHarness();
    await t.runAsync(seed);
    await open(t);
    await t.tap(menuOf('Fear is the mind-killer.'));
    await t.pumpAndSettle();
    await t.tap(find.text('Share as text'));
    await t.pumpAndSettle();
    expect(h.share.texts, ['“Fear is the mind-killer.”\n— Dune, p. 7']);
    await end(t);
  });

  testWidgets('share as image hands over a PNG', (t) async {
    h = AddFlowHarness();
    await t.runAsync(seed);
    await open(t);
    await t.tap(menuOf('Fear is the mind-killer.'));
    await t.pumpAndSettle();
    await t.tap(find.text('Share as image'));
    await t.pump();
    await t.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
    await t.pump();
    expect(h.share.images, hasLength(1));
    final png = h.share.images.single.png;
    expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    expect(h.share.images.single.name, endsWith('.png'));
    await end(t);
  });
}

class QuoteRowLite {
  const QuoteRowLite(this.id, this.body, this.page, this.fav);
  final String id;
  final String body;
  final int? page;
  final bool fav;
}
