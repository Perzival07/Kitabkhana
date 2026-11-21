import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/app_config.dart';
import 'package:kitabkhana/app/app_config_provider.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/application/library_query.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/library/presentation/library_screen.dart';
import 'package:kitabkhana/features/library/presentation/widgets/book_tiles.dart';
import 'package:kitabkhana/features/library/presentation/widgets/highlight_text.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/pump_router_app.dart';

/// The app's providers for a test, as a root scope. (An uncontrolled scope on
/// a container the test owns: a plain nested ProviderScope would need a
/// dependencies list under riverpod_lint.)
Widget rootScope(List<Override> overrides, Widget child) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return UncontrolledProviderScope(container: container, child: child);
}

void main() {
  late AddFlowHarness h;

  // Pure unit tests never build a harness; closing a closed database is a
  // no-op, so a stale one from an earlier test is harmless.
  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised: nothing to close.
    }
  });

  Future<void> advance(WidgetTester t) async {
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 1));
  }

  /// A widget test that unmounts the app at the end, so closing database
  /// streams can run their zero-delay timer before the test is checked.
  void libTest(String name, Future<void> Function(WidgetTester t) body) {
    testWidgets(name, (t) async {
      await body(t);
      await t.pumpWidget(const SizedBox());
      await advance(t);
    });
  }

  /// A book's title as shown in a tile (the generated cover repeats it).
  Finder titled(String text) =>
      find.byWidgetPredicate((w) => w is HighlightText && w.text == text);

  /// Taps a filter chip (use a window wide enough to show the chip row).
  Future<void> tapChip(WidgetTester t, String label) async {
    await t.tap(find.widgetWithText(FilterChip, label));
    await advance(t);
  }

  Future<void> seed(
    String id,
    String title, {
    String authors = '',
    ReadStatus status = ReadStatus.want,
    Ownership ownership = Ownership.owned,
    int? pages,
    int currentPage = 0,
  }) async {
    var b = Book.create(
      id: id,
      title: title,
      authors: authors,
      now: h.clock.now(),
      status: status,
      ownership: ownership,
      pages: pages,
    );
    if (currentPage > 0) b = b.copyWith(currentPage: currentPage);
    await h.repos.books.upsert(b);
  }

  /// The library on its own, at [size].
  Future<void> pumpLibrary(
    WidgetTester t, {
    Size size = const Size(400, 900),
  }) async {
    await pumpThemed(
      t,
      rootScope([
        ...h.overrides,
        appConfigProvider.overrideWithValue(const AppConfig.prod()),
      ], const LibraryScreen()),
      size: size,
      scaffold: false,
    );
    await advance(t);
  }

  group('libraryColumns', () {
    test('follows the width', () {
      expect(libraryColumns(320), 2);
      expect(libraryColumns(399), 2);
      expect(libraryColumns(400), 3);
      expect(libraryColumns(599), 3);
      expect(libraryColumns(700), 4);
      expect(libraryColumns(900), 5);
      expect(libraryColumns(1200), 6);
    });
  });

  group('HighlightText.split', () {
    test('marks word prefixes, ignoring case', () {
      expect(
        HighlightText.split('Harry Potter and the Chamber', 'harr pot'),
        <(String, bool)>[
          ('Harr', true),
          ('y ', false),
          ('Pot', true),
          ('ter and the Chamber', false),
        ],
      );
    });

    test('does not match inside a word', () {
      expect(HighlightText.split('Charred', 'har'), <(String, bool)>[
        ('Charred', false),
      ]);
    });

    test('returns the text untouched for an empty query', () {
      expect(HighlightText.split('Dune', '  '), <(String, bool)>[
        ('Dune', false),
      ]);
    });

    test('treats punctuation in the query as plain text', () {
      expect(HighlightText.split('C++ Primer', 'c++'), <(String, bool)>[
        ('C', true),
        ('++ Primer', false),
      ]);
    });
  });

  group('empty states', () {
    libTest('an empty library invites you to add a book', (t) async {
      h = AddFlowHarness();
      await pumpLibrary(t);
      expect(find.text('Your shelf is empty'), findsOneWidget);
      expect(find.text('Add your first book'), findsOneWidget);
      expect(find.text('Scan a barcode'), findsOneWidget);
    });

    libTest('no results offers to clear the search', (t) async {
      h = AddFlowHarness();
      await seed('1', 'Dune', authors: 'Frank Herbert');
      await pumpLibrary(t);
      await t.enterText(find.byType(TextField), 'xyz');
      await t.pump(const Duration(milliseconds: 300));
      await advance(t);
      expect(find.text('Nothing matches “xyz”'), findsOneWidget);
      await t.tap(find.text('Clear filters'));
      await advance(t);
      expect(titled('Dune'), findsOneWidget);
      expect(find.text('Nothing matches “xyz”'), findsNothing);
    });
  });

  group('browsing', () {
    libTest('shows the count and lent-out line', (t) async {
      h = AddFlowHarness();
      await seed('1', 'Dune');
      await seed('2', 'Emma');
      await h.repos.loans.create(
        Loan.create(
          id: 'loan1',
          bookId: '1',
          direction: LoanDirection.lent,
          personName: 'Asha',
          startedOn: h.clock.now(),
          now: h.clock.now(),
        ),
      );
      await pumpLibrary(t);
      expect(find.text('2 books · 1 lent out'), findsOneWidget);
      expect(find.text('Lent'), findsOneWidget);
    });

    libTest('filters combine', (t) async {
      h = AddFlowHarness();
      await seed('1', 'Dune', status: ReadStatus.reading);
      await seed(
        '2',
        'Emma',
        status: ReadStatus.reading,
        ownership: Ownership.wishlist,
      );
      await seed('3', 'Circe', ownership: Ownership.wishlist);
      await pumpLibrary(t, size: const Size(700, 900));
      expect(find.byType(BookGridTile), findsNWidgets(3));

      await tapChip(t, 'Reading');
      expect(find.byType(BookGridTile), findsNWidgets(2));

      await tapChip(t, 'Wishlist');
      expect(find.byType(BookGridTile), findsOneWidget);
      expect(titled('Emma'), findsOneWidget);

      await tapChip(t, 'All');
      expect(find.byType(BookGridTile), findsNWidgets(3));
    });

    libTest('search narrows by title prefix and highlights it', (t) async {
      h = AddFlowHarness();
      await seed('1', 'Harry Potter and the Chamber of Secrets');
      await seed('2', 'Dune');
      await pumpLibrary(t);
      await t.enterText(find.byType(TextField), 'harr');
      await t.pump(const Duration(milliseconds: 300));
      await advance(t);
      expect(find.byType(BookGridTile), findsOneWidget);
      expect(find.textContaining('Dune'), findsNothing);
      expect(find.byType(HighlightText), findsWidgets);
    });

    libTest('the list view shows progress for books being read', (t) async {
      h = AddFlowHarness();
      await seed(
        '1',
        'Dune',
        status: ReadStatus.reading,
        pages: 100,
        currentPage: 40,
      );
      await pumpLibrary(t);
      await t.tap(find.byTooltip('Show as list'));
      await advance(t);
      expect(find.byType(BookListTile), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byTooltip('Show as grid'), findsOneWidget);
    });

    libTest('sorting by title reorders the books', (t) async {
      h = AddFlowHarness();
      await seed('1', 'Anna Karenina');
      await seed('2', 'Zorba');
      await pumpLibrary(t);
      double y(String s) => t.getTopLeft(titled(s)).dx; // tiles share a row
      // Newest first: Zorba (higher id) leads until we sort by title.
      expect(y('Zorba'), lessThan(y('Anna Karenina')));
      await t.tap(find.byTooltip('Sort'));
      await advance(t);
      await t.tap(find.text('Title'));
      await advance(t);
      expect(y('Anna Karenina'), lessThan(y('Zorba')));
    });
  });

  group('grid columns', () {
    for (final (width, cols) in <(double, int)>[
      (320, 2),
      (400, 3),
      (700, 4),
      (1200, 6),
    ]) {
      libTest('$cols columns at ${width.toInt()}dp', (t) async {
        h = AddFlowHarness();
        for (var i = 0; i < 12; i++) {
          await seed('b$i', 'Book number $i');
        }
        await pumpLibrary(t, size: Size(width, 900));
        final tiles = find.byType(BookGridTile).evaluate().length;
        expect(tiles, greaterThanOrEqualTo(cols));
        final firstRowY = t.getTopLeft(find.byType(BookGridTile).first).dy;
        var inFirstRow = 0;
        for (var i = 0; i < tiles; i++) {
          if (t.getTopLeft(find.byType(BookGridTile).at(i)).dy == firstRowY) {
            inFirstRow++;
          }
        }
        expect(inFirstRow, cols);
      });
    }
  });

  group('actions', () {
    libTest('long-press, delete, then undo', (t) async {
      h = AddFlowHarness();
      await seed('1', 'Dune');
      await pumpLibrary(t);
      await t.longPress(find.byType(BookGridTile));
      await advance(t);
      await t.tap(find.text('Delete'));
      await advance(t);
      expect(find.byType(BookGridTile), findsNothing);
      expect(find.text('“Dune” deleted'), findsOneWidget);
      await t.tap(find.text('Undo'));
      await advance(t);
      expect(find.byType(BookGridTile), findsOneWidget);
    });

    libTest('long-press changes the status', (t) async {
      h = AddFlowHarness();
      await seed('1', 'Dune');
      await pumpLibrary(t);
      await t.longPress(find.byType(BookGridTile));
      await advance(t);
      await t.tap(find.text('Change status'));
      await advance(t);
      await t.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Finished'),
        ),
      );
      await advance(t);
      expect((await h.repos.allBooks()).single.status, ReadStatus.finished);
    });

    libTest('the add button opens the add flow', (t) async {
      h = AddFlowHarness();
      // With an empty shelf the empty state is the call to action instead.
      await seed('1', 'Dune');
      final c = await h.pump(t, start: '/library');
      await t.tap(find.text('Add book'));
      await advance(t);
      expect(locationOf(c), '/library/add');
    });
  });
}
