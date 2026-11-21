import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/fake_ocr_service.dart';
import '../../helpers/pump_router_app.dart';
import '../../helpers/test_images.dart';

void main() {
  late AddFlowHarness h;

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Future<void> addBook({int page = 0}) => h.repos.books.upsert(
    Book.create(
      id: 'bk',
      title: 'Middlemarch',
      now: DateTime(2025, 3, 10),
      pages: 880,
      status: ReadStatus.reading,
    ).copyWith(currentPage: page),
  );

  Future<void> open(WidgetTester t) async {
    final c = await pumpRouterApp(
      t,
      size: const Size(420, 900),
      overrides: h.overrides,
    );
    routerOf(c).go('/book/bk/quote');
    await t.pumpAndSettle();
  }

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  Future<List<String>> savedBodies() async =>
      (await h.db.liveQuotes().get()).map((q) => q.body).toList();

  testWidgets('where text reading is unsupported it opens on the text field', (
    t,
  ) async {
    h = AddFlowHarness();
    h.ocr = FakeOcrService(supported: false);
    await t.runAsync(addBook);
    await open(t);
    expect(find.text('Take a photo'), findsNothing);
    expect(find.text('Quote'), findsOneWidget);

    await t.enterText(find.byType(TextField).first, '  Be the change.  ');
    await t.tap(find.text('Save quote'));
    await t.pumpAndSettle();
    expect(await t.runAsync(savedBodies), ['Be the change.']);
    await end(t);
  });

  testWidgets('an empty quote is refused', (t) async {
    h = AddFlowHarness();
    h.ocr = FakeOcrService(supported: false);
    await t.runAsync(addBook);
    await open(t);
    await t.tap(find.text('Save quote'));
    await t.pumpAndSettle();
    expect(find.text('Add the quote first'), findsOneWidget);
    expect(await t.runAsync(savedBodies), isEmpty);
    await end(t);
  });

  testWidgets('the page is prefilled and must be inside the book', (t) async {
    h = AddFlowHarness();
    h.ocr = FakeOcrService(supported: false);
    await t.runAsync(() => addBook(page: 120));
    await open(t);
    expect(find.text('120'), findsOneWidget);

    await t.enterText(find.byType(TextField).first, 'A line.');
    await t.enterText(find.byType(TextField).last, '999');
    await t.tap(find.text('Save quote'));
    await t.pumpAndSettle();
    expect(find.text('Enter a page within the book'), findsOneWidget);
    expect(await t.runAsync(savedBodies), isEmpty);

    await t.enterText(find.byType(TextField).last, '42');
    await t.tap(find.text('Save quote'));
    await t.pumpAndSettle();
    final rows = await t.runAsync(() => h.db.liveQuotes().get());
    expect(rows!.single.page, 42);
    await end(t);
  });

  testWidgets('photo to saved quote: pick lines, cleanup, save', (t) async {
    h = AddFlowHarness();
    h.ocr = FakeOcrService(
      lines: <String>[
        'It is a truth univer-',
        'sally acknowledged,',
        'Chapter 3',
        'that a "single" man',
      ],
    );
    h.picker.next = jpegBytes(60, 80);
    await t.runAsync(addBook);
    await open(t);

    await t.tap(find.text('Choose a photo'));
    await t.pump(const Duration(milliseconds: 100));
    // The crop step measures the image for real.
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Read the text'));
    await t.pumpAndSettle();

    expect(h.ocr.seen, hasLength(1));
    expect(find.text('Tap the lines you want to keep.'), findsOneWidget);
    expect(
      t
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Use selected lines'),
          )
          .onPressed,
      isNull,
    );
    await t.tap(find.text('It is a truth univer-'));
    await t.tap(find.text('sally acknowledged,'));
    await t.tap(find.text('that a "single" man'));
    await t.pump();
    await t.tap(find.text('Use selected lines'));
    await t.pumpAndSettle();

    expect(
      find.text('It is a truth universally acknowledged, that a “single” man'),
      findsOneWidget,
    );
    await t.tap(find.text('Save quote'));
    await t.pumpAndSettle();
    expect(await t.runAsync(savedBodies), [
      'It is a truth universally acknowledged, that a “single” man',
    ]);
    await end(t);
  });

  testWidgets('a photo with no text falls back to typing', (t) async {
    h = AddFlowHarness();
    h.picker.next = jpegBytes(60, 80);
    await t.runAsync(addBook);
    await open(t);
    await t.tap(find.text('Choose a photo'));
    await t.pump(const Duration(milliseconds: 100));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Read the text'));
    await t.pumpAndSettle();
    expect(
      find.text('No text found. You can type the quote instead.'),
      findsOneWidget,
    );
    expect(find.text('Quote'), findsOneWidget);
    await end(t);
  });

  testWidgets('a reading failure returns to the start with a message', (
    t,
  ) async {
    h = AddFlowHarness();
    h.ocr = FakeOcrService()..fail = true;
    h.picker.next = jpegBytes(60, 80);
    await t.runAsync(addBook);
    await open(t);
    await t.tap(find.text('Take a photo'));
    await t.pump(const Duration(milliseconds: 100));
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Read the text'));
    await t.pumpAndSettle();
    expect(
      find.text('That photo could not be read. Try another, or type it.'),
      findsOneWidget,
    );
    expect(find.text('Take a photo'), findsOneWidget);
    await end(t);
  });

  testWidgets('cancelling the picker stays on the first step', (t) async {
    h = AddFlowHarness();
    await t.runAsync(addBook);
    await open(t);
    await t.tap(find.text('Take a photo'));
    await t.pumpAndSettle();
    expect(find.text('Take a photo'), findsOneWidget);
    await end(t);
  });

  testWidgets('"Type it instead" skips the photo', (t) async {
    h = AddFlowHarness();
    await t.runAsync(addBook);
    await open(t);
    await t.tap(find.text('Type it instead'));
    await t.pumpAndSettle();
    expect(find.text('Quote'), findsOneWidget);
    expect(find.text('Pick lines again'), findsNothing);
    await end(t);
  });
}
