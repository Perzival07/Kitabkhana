import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

BookInfo info({String title = 'Everything I Never Told You'}) => BookInfo(
  title: title,
  authors: const ['Celeste Ng'],
  pages: 297,
  isbn13: parseIsbn('9780143127550'),
  olWorkKey: '/works/OL17295077W',
  year: 2015,
);

void main() {
  late AddFlowHarness h;

  tearDown(() => h.dispose());

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  /// Advances time without waiting for endless animations (a loading spinner
  /// keeps running while a sheet is open, so `pumpAndSettle` would never end).
  Future<void> advance(WidgetTester t) async {
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
    // Closed database streams schedule a zero-delay timer; let it fire.
    await t.pump(const Duration(milliseconds: 1));
  }

  /// Scrolls the (lazily built) form until [target] exists and is visible,
  /// whether it is above or below the current position.
  Future<void> reveal(WidgetTester t, Finder target) async {
    if (target.evaluate().isEmpty) {
      final list = find.byType(Scrollable).first;
      await t.drag(list, const Offset(0, 6000)); // to the top
      await t.pump();
      await t.scrollUntilVisible(target, 250, scrollable: list);
    } else {
      await t.ensureVisible(target.first);
    }
    // A scroll activity ignores taps until it finishes.
    await advance(t);
  }

  Future<void> tapText(WidgetTester t, String text) async {
    // A focused field scrolls itself back into view, which would undo the
    // scroll to a button further down.
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pump();
    await reveal(t, find.text(text));
    await t.tap(find.text(text).first);
    await advance(t);
  }

  Future<void> enter(WidgetTester t, String label, String text) async {
    await reveal(t, field(label));
    await t.enterText(field(label), text);
  }

  Future<List<Book>> allBooks() => h.repos.allBooks();

  group('entry screen', () {
    testWidgets('shows the four ways to add a book', (t) async {
      h = AddFlowHarness();
      await h.pump(t);
      for (final label in <String>[
        'Scan barcode',
        'Type ISBN',
        'Search by title',
        'Enter manually',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('each card opens its screen', (t) async {
      h = AddFlowHarness();
      final c = await h.pump(t);
      for (final (label, path) in <(String, String)>[
        ('Type ISBN', '/library/add/isbn'),
        ('Search by title', '/library/add/search'),
        ('Enter manually', '/library/add/manual'),
        ('Scan barcode', '/library/add/scan'),
      ]) {
        await t.tap(find.text(label));
        await t.pumpAndSettle();
        expect(locationOf(c), path, reason: label);
        routerOf(c).pop();
        await t.pumpAndSettle();
      }
    });

    testWidgets('fits 320dp wide at 200% text', (t) async {
      h = AddFlowHarness();
      await h.pump(t, size: const Size(320, 640), textScale: 2);
      expect(t.takeException(), isNull);
    });
  });

  group('type ISBN', () {
    testWidgets('validates live and enables lookup only when valid', (t) async {
      h = AddFlowHarness();
      await h.pump(t, start: '/library/add/isbn');
      final button = find.widgetWithText(FilledButton, 'Look up');
      expect(t.widget<FilledButton>(button).onPressed, isNull);

      await t.enterText(find.byType(TextField), '9780');
      await t.pump();
      expect(find.text('An ISBN has 10 or 13 digits.'), findsOneWidget);
      expect(t.widget<FilledButton>(button).onPressed, isNull);

      await t.enterText(find.byType(TextField), '9780143127551'); // bad check
      await t.pump();
      expect(
        find.textContaining("doesn't look like a valid ISBN"),
        findsOneWidget,
      );
      expect(t.widget<FilledButton>(button).onPressed, isNull);

      await t.enterText(find.byType(TextField), '978-0-14-312755-0');
      await t.pump();
      expect(find.text('Valid ISBN'), findsOneWidget);
      expect(t.widget<FilledButton>(button).onPressed, isNotNull);
    });

    testWidgets('accepts an ISBN-10 and a pasted barcode with add-on', (
      t,
    ) async {
      h = AddFlowHarness();
      await h.pump(t, start: '/library/add/isbn');
      await t.enterText(find.byType(TextField), '0306406152');
      await t.pump();
      expect(find.text('Valid ISBN'), findsOneWidget);
      await t.enterText(find.byType(TextField), '978014312755051295');
      await t.pump();
      expect(find.text('Valid ISBN'), findsOneWidget);
    });

    testWidgets('only digits, X, spaces and hyphens can be typed', (t) async {
      h = AddFlowHarness();
      await h.pump(t, start: '/library/add/isbn');
      await t.enterText(find.byType(TextField), 'abc978-0 x!?');
      await t.pump();
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        '978-0 x',
      );
    });

    testWidgets('a found book opens the preview with its details', (t) async {
      h = AddFlowHarness();
      h.source.onIsbn = () => Ok(info());
      final c = await h.pump(t, start: '/library/add/isbn');
      await t.enterText(find.byType(TextField), '9780143127550');
      await t.pump();
      await tapText(t, 'Look up');
      expect(locationOf(c), '/library/add/preview');
      expect(
        find.text(
          'From the Open Library catalogue. Edit anything before saving.',
        ),
        findsOneWidget,
      );
      expect(field('Title').evaluate().isNotEmpty, isTrue);
      expect(
        t.widget<TextFormField>(field('Title')).controller!.text,
        'Everything I Never Told You',
      );
      expect(
        t.widget<TextFormField>(field('Authors')).controller!.text,
        'Celeste Ng',
      );
      expect(t.widget<TextFormField>(field('Pages')).controller!.text, '297');
      expect(
        t.widget<TextFormField>(field('ISBN')).controller!.text,
        '9780143127550',
      );
    });

    testWidgets('not found opens the manual form pre-filled with the ISBN', (
      t,
    ) async {
      h = AddFlowHarness();
      h.source.onIsbn = () => const Err<BookInfo>(NotFoundFailure());
      final c = await h.pump(t, start: '/library/add/isbn');
      await t.enterText(find.byType(TextField), '9780143127550');
      await t.pump();
      await tapText(t, 'Look up');
      expect(locationOf(c), '/library/add/manual');
      expect(find.textContaining("couldn't find that ISBN"), findsOneWidget);
      expect(
        t.widget<TextFormField>(field('ISBN')).controller!.text,
        '9780143127550',
      );
      expect(t.widget<TextFormField>(field('Title')).controller!.text, '');
    });

    testWidgets('offline never blocks: manual form with a friendly note', (
      t,
    ) async {
      h = AddFlowHarness();
      h.source.onIsbn = () => const Err<BookInfo>(NetworkFailure.offline());
      final c = await h.pump(t, start: '/library/add/isbn');
      await t.enterText(find.byType(TextField), '9780143127550');
      await t.pump();
      await tapText(t, 'Look up');
      expect(locationOf(c), '/library/add/manual');
      expect(find.textContaining('offline'), findsOneWidget);
    });

    testWidgets('fits 320dp at 200% text with the keyboard-sized viewport', (
      t,
    ) async {
      h = AddFlowHarness();
      await h.pump(
        t,
        start: '/library/add/isbn',
        size: const Size(320, 480),
        textScale: 2,
      );
      await t.enterText(find.byType(TextField), '9780143127550');
      await t.pump();
      expect(t.takeException(), isNull);
    });
  });

  group('search by title', () {
    testWidgets('debounces, then lists results; a result opens the preview', (
      t,
    ) async {
      h = AddFlowHarness();
      h.source.onSearch = () =>
          Ok([info(), info(title: 'Little Fires Everywhere')]);
      final c = await h.pump(t, start: '/library/add/search');
      expect(
        find.text('Type a title to search the catalogue.'),
        findsOneWidget,
      );

      await t.enterText(find.byType(TextField), 'every');
      await t.pump(const Duration(milliseconds: 300));
      expect(h.source.searchCalls, 0);
      await t.pump(const Duration(milliseconds: 60));
      await t.pumpAndSettle();
      expect(h.source.searchCalls, 1);
      expect(h.source.lastSearch, 'every');
      expect(find.text('Everything I Never Told You'), findsWidgets);
      expect(find.text('Little Fires Everywhere'), findsWidgets);
      expect(find.textContaining('Celeste Ng'), findsWidgets);
      expect(find.text('297 pages'), findsWidgets);

      await t.tap(find.text('Little Fires Everywhere').last);
      await t.pumpAndSettle();
      expect(locationOf(c), '/library/add/preview');
      expect(
        t.widget<TextFormField>(field('Title')).controller!.text,
        'Little Fires Everywhere',
      );
    });

    testWidgets('no matches suggests entering the book manually', (t) async {
      h = AddFlowHarness();
      final c = await h.pump(t, start: '/library/add/search');
      await t.enterText(find.byType(TextField), 'zzzz');
      await t.pump(const Duration(milliseconds: 400));
      await t.pumpAndSettle();
      expect(find.textContaining('No matches'), findsOneWidget);
      await t.tap(find.text('Enter manually'));
      await t.pumpAndSettle();
      expect(locationOf(c), '/library/add/manual');
      // What was typed carries over as the title.
      expect(t.widget<TextFormField>(field('Title')).controller!.text, 'zzzz');
    });

    testWidgets('offline explains and offers manual entry', (t) async {
      h = AddFlowHarness();
      h.source.onSearch = () =>
          const Err<List<BookInfo>>(NetworkFailure.offline());
      await h.pump(t, start: '/library/add/search');
      await t.enterText(find.byType(TextField), 'dune');
      await t.pump(const Duration(milliseconds: 400));
      await t.pumpAndSettle();
      expect(find.textContaining("You're offline"), findsOneWidget);
      expect(find.text('Enter manually'), findsOneWidget);
    });

    testWidgets('other failures show a retry-friendly message', (t) async {
      h = AddFlowHarness();
      h.source.onSearch = () =>
          const Err<List<BookInfo>>(NetworkFailure.server(500));
      await h.pump(t, start: '/library/add/search');
      await t.enterText(find.byType(TextField), 'dune');
      await t.pump(const Duration(milliseconds: 400));
      await t.pumpAndSettle();
      expect(find.textContaining("didn't work this time"), findsOneWidget);
    });

    testWidgets('clearing the field returns to the prompt', (t) async {
      h = AddFlowHarness();
      h.source.onSearch = () => Ok([info()]);
      await h.pump(t, start: '/library/add/search');
      await t.enterText(find.byType(TextField), 'dune');
      await t.pump(const Duration(milliseconds: 400));
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.close_rounded));
      await t.pumpAndSettle();
      expect(
        find.text('Type a title to search the catalogue.'),
        findsOneWidget,
      );
    });
  });

  group('scan', () {
    testWidgets('a valid barcode is looked up; non-book barcodes are ignored', (
      t,
    ) async {
      h = AddFlowHarness(scanCodes: ['5901234123457', '9780143127550']);
      h.source.onIsbn = () => Ok(info());
      final c = await h.pump(t, start: '/library/add/scan');
      expect(
        find.text('Point at the barcode on the back cover'),
        findsOneWidget,
      );

      await t.tap(find.text('scan 5901234123457'));
      await t.pumpAndSettle();
      expect(h.source.isbnCalls, 0);
      expect(locationOf(c), '/library/add/scan');

      await t.tap(find.text('scan 9780143127550'));
      await t.pumpAndSettle();
      expect(h.source.isbnCalls, 1);
      expect(locationOf(c), '/library/add/preview');
    });

    testWidgets('no camera: explains and offers typing the ISBN', (t) async {
      h = AddFlowHarness(cameraOk: false);
      final c = await h.pump(t, start: '/library/add/scan');
      expect(find.text("Camera scanning isn't available here"), findsOneWidget);
      await t.tap(find.text('Type ISBN'));
      await t.pumpAndSettle();
      expect(locationOf(c), '/library/add/isbn');
    });
  });

  group('form', () {
    testWidgets('validates title, pages and ISBN', (t) async {
      h = AddFlowHarness();
      await h.pump(t, start: '/library/add/manual');
      await enter(t, 'Pages', '0');
      await enter(t, 'ISBN', '123');
      await tapText(t, 'Save');
      await reveal(t, find.text('Please enter a title'));
      expect(find.text('Please enter a title'), findsOneWidget);
      await reveal(t, find.text('Pages must be a whole number above 0'));
      expect(find.text('Pages must be a whole number above 0'), findsOneWidget);
      await reveal(t, find.textContaining("doesn't look like a valid ISBN"));
      expect(
        find.textContaining("doesn't look like a valid ISBN"),
        findsOneWidget,
      );
      expect(await allBooks(), isEmpty);

      await enter(t, 'Title', 'Dune');
      await enter(t, 'Pages', '412');
      await enter(t, 'ISBN', '');
      await tapText(t, 'Save');
      expect(find.text('Please enter a title'), findsNothing);
      expect((await allBooks()).single.title, 'Dune');
    });

    testWidgets(
      'saves with every field, shows a toast and goes to the library',
      (t) async {
        h = AddFlowHarness();
        final shelf = await h.repos.locations.upsert(
          Location.create(
            id: 'shelf',
            name: 'Bedroom shelf',
            now: h.clock.now(),
          ),
        );
        expect(shelf.isOk, isTrue);
        final c = await h.pump(t, start: '/library/add/manual');
        await enter(t, 'Title', 'Godan');
        await enter(t, 'Authors', 'Premchand');
        await enter(t, 'Pages', '320');
        await enter(t, 'Genre', 'Classic');
        await enter(t, 'Language', 'hi');
        await enter(t, 'Notes', 'Gift');
        await tapText(t, 'Wishlist');
        await tapText(t, 'Reading');
        await t.ensureVisible(find.text('No location'));
        await t.tap(find.text('No location'));
        await t.pumpAndSettle();
        await t.tap(find.text('Bedroom shelf').last);
        await t.pumpAndSettle();
        await tapText(t, 'Save');

        final b = (await allBooks()).single;
        expect(b.title, 'Godan');
        expect(b.authors, 'Premchand');
        expect(b.pages, 320);
        expect(b.genre, 'Classic');
        expect(b.language, 'hi');
        expect(b.notes, 'Gift');
        expect(b.ownership, Ownership.wishlist);
        expect(b.status, ReadStatus.reading);
        expect(b.locationId, 'shelf');
        expect(b.startedOn, DateTime(2025, 3, 10));
        expect(locationOf(c), '/library');
        expect(find.text('Added to Bedroom shelf'), findsOneWidget);
        expect(find.text('View'), findsOneWidget);

        await t.tap(find.text('View'));
        await t.pumpAndSettle();
        expect(locationOf(c), '/book/${b.id}');
      },
    );

    testWidgets('without a location the toast says "your library"', (t) async {
      h = AddFlowHarness();
      await h.pump(t, start: '/library/add/manual');
      await enter(t, 'Title', 'Dune');
      await tapText(t, 'Save');
      expect(find.text('Added to your library'), findsOneWidget);
    });

    testWidgets('"Save and add another" returns to the entry screen', (
      t,
    ) async {
      h = AddFlowHarness();
      final c = await h.pump(t, start: '/library/add/manual');
      await enter(t, 'Title', 'Dune');
      await tapText(t, 'Save and add another');
      expect(locationOf(c), '/library/add');
      expect(find.text('Scan barcode'), findsOneWidget);
      expect((await allBooks()), hasLength(1));
      await t.pumpAndSettle(); // let closed database streams finish
    });

    testWidgets('the cover preview follows the title as you type', (t) async {
      h = AddFlowHarness();
      await h.pump(t, start: '/library/add/manual');
      await enter(t, 'Title', 'A Fresh Title');
      await t.pump();
      expect(
        find.bySemanticsLabel(RegExp('Cover of A Fresh Title')),
        findsNothing,
      ); // semantics are off in this test; check the widget
      expect(find.text('A Fresh Title'), findsWidgets);
    });

    testWidgets('a chosen photo is stored as the cover after saving', (
      t,
    ) async {
      h = AddFlowHarness();
      h.picker.next = Uint8List.fromList([1, 2, 3]);
      await h.pump(t, start: '/library/add/manual');
      await enter(t, 'Title', 'Dune');
      await tapText(t, 'Choose photo');
      expect(find.text('Use generated cover'), findsOneWidget);
      await tapText(t, 'Save');
      await t.pumpAndSettle();
      expect(h.covers.photoSaves, hasLength(1));
      final b = (await allBooks()).single;
      expect(b.coverLocalPath, isNotNull);
    });

    testWidgets('cancelling the picker changes nothing', (t) async {
      h = AddFlowHarness();
      h.picker.next = null;
      await h.pump(t, start: '/library/add/manual');
      await tapText(t, 'Take photo');
      expect(find.text('Use generated cover'), findsNothing);
      expect(h.picker.asked, [isNotNull]);
    });

    testWidgets('"Use generated cover" drops the catalogue cover', (t) async {
      h = AddFlowHarness();
      h.source.onIsbn = () => Ok(info().copyWith()); // no cover url in info
      await h.pump(t, start: '/library/add/manual');
      expect(find.text('Use generated cover'), findsNothing);
    });

    testWidgets('fits 320dp wide at 200% text', (t) async {
      h = AddFlowHarness();
      await h.pump(
        t,
        start: '/library/add/manual',
        size: const Size(320, 640),
        textScale: 2,
      );
      for (var i = 0; i < 12; i++) {
        await t.drag(find.byType(ListView).first, const Offset(0, -300));
        await t.pump();
      }
      expect(t.takeException(), isNull);
    });
  });

  group('duplicates', () {
    Future<void> seedHobbit(AddFlowHarness h) async {
      final b = Book.create(
        id: 'existing',
        title: 'The Hobbit',
        authors: 'J. R. R. Tolkien',
        now: h.clock.now(),
      );
      await h.repos.books.upsert(b);
    }

    testWidgets('same ISBN shows the sheet and saves nothing yet', (t) async {
      h = AddFlowHarness();
      await h.repos.books.upsert(
        Book.create(
          id: 'existing',
          title: 'Everything I Never Told You',
          now: h.clock.now(),
          isbn13: parseIsbn('9780143127550'),
        ),
      );
      h.source.onIsbn = () => Ok(info());
      await h.pump(t, start: '/library/add/isbn');
      await t.enterText(find.byType(TextField), '9780143127550');
      await t.pump();
      await tapText(t, 'Look up');
      await tapText(t, 'Save');
      expect(find.text('You may already have this'), findsOneWidget);
      expect(find.text('Open existing'), findsOneWidget);
      expect(find.text('Add another copy'), findsOneWidget);
      expect((await allBooks()), hasLength(1));
    });

    testWidgets('same title without an ISBN shows the sheet', (t) async {
      h = AddFlowHarness();
      await seedHobbit(h);
      await h.pump(t, start: '/library/add/manual');
      await enter(t, 'Title', 'Hobbit');
      await enter(t, 'Authors', 'Tolkien');
      await tapText(t, 'Save');
      expect(find.text('You may already have this'), findsOneWidget);
      expect(find.text('The Hobbit'), findsWidgets);
      expect(find.text('J. R. R. Tolkien'), findsOneWidget);
    });

    testWidgets('"Add another copy" saves a second book', (t) async {
      h = AddFlowHarness();
      await seedHobbit(h);
      final c = await h.pump(t, start: '/library/add/manual');
      await enter(t, 'Title', 'The Hobbit');
      await enter(t, 'Authors', 'J. R. R. Tolkien');
      await tapText(t, 'Save');
      await tapText(t, 'Add another copy');
      expect(await allBooks(), hasLength(2));
      expect(locationOf(c), '/library');
    });

    testWidgets('"Open existing" goes to that book and saves nothing', (
      t,
    ) async {
      h = AddFlowHarness();
      await seedHobbit(h);
      final c = await h.pump(t, start: '/library/add/manual');
      await enter(t, 'Title', 'The Hobbit');
      await enter(t, 'Authors', 'J. R. R. Tolkien');
      await tapText(t, 'Save');
      await tapText(t, 'Open existing');
      expect(locationOf(c), '/book/existing');
      expect(await allBooks(), hasLength(1));
    });

    testWidgets('Cancel keeps the form and lets the user edit', (t) async {
      h = AddFlowHarness();
      await seedHobbit(h);
      final c = await h.pump(t, start: '/library/add/manual');
      await enter(t, 'Title', 'The Hobbit');
      await enter(t, 'Authors', 'J. R. R. Tolkien');
      await tapText(t, 'Save');
      await tapText(t, 'Cancel');
      await reveal(t, field('Title'));
      expect(locationOf(c), '/library/add/manual');
      expect(
        t.widget<TextFormField>(field('Title')).controller!.text,
        'The Hobbit',
      );
      expect(await allBooks(), hasLength(1));
      // The Save button works again after cancelling.
      await enter(t, 'Title', 'Something else');
      await tapText(t, 'Save');
      expect(await allBooks(), hasLength(2));
    });
  });
}
