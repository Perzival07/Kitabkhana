import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

const String dune = '9780441013593';
const String owned = '9780143127550';
const String missing = '9780306406157';

void main() {
  late AddFlowHarness h;

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 4; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await t.pumpAndSettle();
    }
  }

  Future<void> scan(WidgetTester t, String code) async {
    await t.tap(find.text('scan $code'));
    await settle(t);
  }

  setUp(() {
    h = AddFlowHarness(
      scanCodes: <String>[dune, owned, missing, '5901234123457'],
    );
    // Answers in the order the codes are scanned.
    final answers = <Result<BookInfo>>[
      Ok(
        BookInfo(
          title: 'Dune',
          authors: const ['Frank Herbert'],
          isbn13: parseIsbn(dune),
        ),
      ),
      Ok(
        BookInfo(
          title: 'Everything I Never Told You',
          authors: const ['Celeste Ng'],
          isbn13: parseIsbn(owned),
        ),
      ),
      const Err(NotFoundFailure()),
    ];
    h.source.onIsbn = () => answers[h.source.isbnCalls - 1];
  });
  tearDown(() => h.dispose());

  testWidgets(
    'scans queue up, owned ones are unticked, chosen ones are added',
    (t) async {
      await t.runAsync(
        () => h.repos.books.upsert(
          Book.create(
            id: 'mine',
            title: 'Everything I Never Told You',
            authors: 'Celeste Ng',
            isbn13: parseIsbn(owned),
            now: DateTime(2025),
          ),
        ),
      );
      final c = await h.pump(t, start: '/library/add/batch');
      expect(find.text('Scan a shelf'), findsOneWidget);
      expect(find.text('Add books'), findsOneWidget);

      await scan(t, dune);
      await scan(t, owned);
      await scan(t, missing);
      await scan(t, dune); // a second scan of the same book is ignored
      await scan(t, '5901234123457'); // not a book
      expect(h.source.isbnCalls, 3);

      expect(find.text('Dune'), findsOneWidget);
      expect(find.text('Already in your library'), findsOneWidget);
      expect(find.text('Not found; add it by hand later'), findsOneWidget);
      expect(find.text('Add 1 book'), findsOneWidget);

      await t.tap(find.text('Add 1 book'));
      await settle(t);
      expect(locationOf(c), '/library');
      expect(find.text('Added 1 book'), findsOneWidget);
      final books = await t.runAsync(h.repos.allBooks);
      expect(books!.map((b) => b.title), containsAll(<String>['Dune']));
      expect(books, hasLength(2));
    },
  );

  testWidgets('an owned book can be ticked to add another copy', (t) async {
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(
          id: 'mine',
          title: 'Everything I Never Told You',
          authors: 'Celeste Ng',
          isbn13: parseIsbn(owned),
          now: DateTime(2025),
        ),
      ),
    );
    await h.pump(t, start: '/library/add/batch');
    await scan(t, dune);
    await scan(t, owned);
    await t.tap(find.byType(Checkbox).first); // newest first: the owned one
    await t.pump();
    expect(find.text('Add 2 books'), findsOneWidget);
  });

  testWidgets('the add screen offers it', (t) async {
    final c = await h.pump(t, start: '/library/add');
    await t.tap(find.text('Scan a shelf'));
    await t.pumpAndSettle();
    expect(locationOf(c), '/library/add/batch');
  });
}
