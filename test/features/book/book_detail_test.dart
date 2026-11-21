import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/app_theme.dart';
import 'package:kitabkhana/features/book/presentation/book_detail_screen.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';
import 'package:kitabkhana/l10n/app_localizations.dart';

import '../../helpers/add_flow_harness.dart';

void main() {
  late AddFlowHarness h;

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Future<void> advance(WidgetTester t) async {
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 1));
  }

  void bookTest(String name, Future<void> Function(WidgetTester t) body) {
    testWidgets(name, (t) async {
      h = AddFlowHarness();
      await body(t);
      await t.pumpWidget(const SizedBox());
      await advance(t);
    });
  }

  Future<void> seed({
    int? pages = 300,
    ReadStatus status = ReadStatus.want,
    String? locationId,
    String? notes,
  }) async {
    await h.repos.books.upsert(
      Book.create(
        id: 'b1',
        title: 'Dune',
        authors: 'Frank Herbert',
        now: h.clock.now(),
        pages: pages,
        status: status,
        locationId: locationId,
        notes: notes,
      ),
    );
  }

  Future<Book> stored(WidgetTester t) async =>
      (await t.runAsync(() => h.repos.books.getById('b1')))!.getOrNull()!;

  Future<void> pumpDetail(
    WidgetTester t, {
    bool embedded = false,
    Size size = const Size(400, 1200),
  }) async {
    t.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: h.overrides,
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: embedded
              ? const BookDetailScreen(bookId: 'b1', embedded: true)
              : const Scaffold(body: Text('home')),
        ),
      ),
    );
    await advance(t);
    if (!embedded) {
      Navigator.of(t.element(find.text('home'))).push(
        MaterialPageRoute<void>(
          builder: (_) => const BookDetailScreen(bookId: 'b1'),
        ),
      );
      await advance(t);
    }
  }

  Future<void> chip(WidgetTester t, String label) async {
    final f = find.widgetWithText(ChoiceChip, label);
    await t.ensureVisible(f);
    await t.tap(f);
    await advance(t);
  }

  bookTest('shows title, author and pages', (t) async {
    await seed();
    await pumpDetail(t);
    expect(find.text('Dune'), findsWidgets);
    expect(find.text('Frank Herbert'), findsOneWidget);
    expect(find.text('300 pages'), findsOneWidget);
  });

  bookTest('Reading sets startedOn and shows the progress card', (t) async {
    await seed();
    await pumpDetail(t);
    await chip(t, 'Reading');
    final b = await stored(t);
    expect(b.status, ReadStatus.reading);
    expect(b.startedOn, DateTime(2025, 3, 10));
    expect(find.text('Page 0 of 300'), findsOneWidget);
    expect(find.text('Update page'), findsOneWidget);
  });

  bookTest('Finished sets finishedOn and currentPage = pages, offers rating', (
    t,
  ) async {
    await seed(status: ReadStatus.reading);
    await pumpDetail(t);
    await chip(t, 'Finished');
    final b = await stored(t);
    expect(b.finishedOn, DateTime(2025, 3, 10));
    expect(b.currentPage, 300);
    expect(find.text('Rate it?'), findsOneWidget);
    await t.tap(find.byTooltip('Rate 4 stars'));
    await advance(t);
    expect((await stored(t)).rating, 4);
    // Tapping the same star again clears the rating.
    await t.tap(find.byTooltip('Rate 4 stars'));
    await advance(t);
    expect((await stored(t)).rating, isNull);
  });

  bookTest('update page saves and clamps to the page count', (t) async {
    await seed(status: ReadStatus.reading);
    await pumpDetail(t);
    await t.tap(find.text('Update page'));
    await advance(t);
    await t.enterText(find.byType(TextField).last, '120');
    await t.tap(find.text('Save'));
    await advance(t);
    expect((await stored(t)).currentPage, 120);
    expect(find.text('Page 120 of 300'), findsOneWidget);

    await t.tap(find.text('Update page'));
    await advance(t);
    await t.enterText(find.byType(TextField).last, '999');
    await t.tap(find.text('Save'));
    await advance(t);
    expect(find.text('Enter a number from 0 to 300'), findsOneWidget);
  });

  bookTest('location card shows the path and Change opens the picker', (
    t,
  ) async {
    await h.repos.locations.upsert(
      Location.create(id: 'p', name: 'Bedroom', now: h.clock.now()),
    );
    await h.repos.locations.upsert(
      Location.create(
        id: 'c',
        name: 'Shelf 2',
        now: h.clock.now(),
        parentId: 'p',
        sortOrder: 1,
      ),
    );
    await seed(locationId: 'c');
    await pumpDetail(t);
    expect(find.text('Bedroom › Shelf 2'), findsOneWidget);
    await t.tap(find.text('Change'));
    await advance(t);
    expect(find.text('Choose a location'), findsOneWidget);
    await t.tap(find.text('No location').last);
    await advance(t);
    expect((await stored(t)).locationId, isNull);
  });

  bookTest('a lent book shows the loan with a Return button', (t) async {
    await seed();
    await t.runAsync(
      () => h.repos.loans.create(
        Loan.create(
          id: 'l1',
          direction: LoanDirection.lent,
          bookId: 'b1',
          personName: 'Priya',
          startedOn: DateTime(2025, 3, 3),
          dueOn: DateTime(2025, 3, 20),
          now: h.clock.now(),
        ),
      ),
    );
    await pumpDetail(t);
    expect(find.textContaining('Lent to Priya since'), findsOneWidget);
    expect(find.textContaining('due'), findsOneWidget);
    await t.tap(find.text('Return'));
    await advance(t);
    expect(find.textContaining('Lent to Priya'), findsNothing);
  });

  bookTest('notes are saved inline when the field loses focus', (t) async {
    await seed();
    await pumpDetail(t);
    final field = find.widgetWithText(TextField, '');
    await t.ensureVisible(find.text('Notes'));
    await t.enterText(find.byType(TextField).last, 'Spice must flow');
    FocusManager.instance.primaryFocus?.unfocus();
    await advance(t);
    expect((await stored(t)).notes, 'Spice must flow');
    expect(field, isNotNull);
  });

  bookTest('tags can be added and removed', (t) async {
    await seed();
    await pumpDetail(t);
    await t.scrollUntilVisible(
      find.text('Add tag'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await advance(t);
    await t.tap(find.text('Add tag'));
    await advance(t);
    await t.enterText(find.byType(TextField).last, 'Sci-fi');
    await t.tap(find.text('Save'));
    await advance(t);
    expect(find.widgetWithText(InputChip, 'Sci-fi'), findsOneWidget);
    await t.tap(find.byTooltip('Remove tag Sci-fi'));
    await advance(t);
    expect(find.widgetWithText(InputChip, 'Sci-fi'), findsNothing);
  });

  bookTest('delete asks to confirm, then undo restores the book', (t) async {
    await seed();
    await pumpDetail(t);
    await t.tap(find.byTooltip('More'));
    await advance(t);
    await t.tap(find.text('Delete'));
    await advance(t);
    expect(find.text('Delete this book?'), findsOneWidget);
    await t.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await advance(t);
    final gone = await t.runAsync(() => h.repos.books.getById('b1'));
    expect(gone!.getOrNull(), isNull);
    await t.tap(find.text('Undo'));
    await advance(t);
    expect((await stored(t)).title, 'Dune');
  });

  bookTest('embedded mode has no back button', (t) async {
    await seed();
    await pumpDetail(t, embedded: true);
    expect(find.byTooltip('Back'), findsNothing);
  });

  bookTest('standalone has a back button', (t) async {
    await seed();
    await pumpDetail(t);
    expect(find.byTooltip('Back'), findsOneWidget);
  });

  bookTest('a missing book shows a friendly message', (t) async {
    await pumpDetail(t);
    expect(
      find.text('This book is no longer in your library.'),
      findsOneWidget,
    );
  });

  bookTest('very long titles and missing covers do not overflow', (t) async {
    await h.repos.books.upsert(
      Book.create(
        id: 'b1',
        title:
            'The Extraordinarily Long and Winding Tale of a Small Book '
            'That Never Seems to End Despite Everyone Asking It To',
        authors: 'A. Very-Long-Named Author Of Many Words',
        now: h.clock.now(),
      ),
    );
    await pumpDetail(t, size: const Size(320, 800));
    expect(t.takeException(), isNull);
  });
}
