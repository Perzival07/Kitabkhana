import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/reading/application/read_again.dart';
import 'package:kitabkhana/features/reading/data/drift_read_throughs.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';
import '../../helpers/repo_harness.dart';

void main() {
  group('ReadAgain', () {
    late RepoHarness h;
    late DriftReadThroughRepository reads;
    late ReadAgain use;

    setUp(() {
      h = RepoHarness();
      reads = DriftReadThroughRepository(h.db, h.clock);
      use = ReadAgain(books: h.books, reads: reads, clock: h.clock);
    });
    tearDown(() => h.db.close());

    Future<void> finished(String id, {required int year}) => h.addBook(
      id: id,
      title: 'Book $id',
      pages: 300,
      status: ReadStatus.finished,
      tweak: (b) => b.copyWith(
        startedOn: DateTime(year, 1, 2),
        finishedOn: DateTime(year, 2, 3),
        currentPage: 300,
        genre: 'Fantasy',
        authors: 'Ursula K. Le Guin',
      ),
    );

    test('keeps the finished read and starts a new one today', () async {
      await finished('a', year: 2024);
      final r = await use('a');
      final book = (r as Ok<Book>).value;
      expect(book.status, ReadStatus.reading);
      expect(book.startedOn, h.clock.today());
      expect(book.finishedOn, isNull);
      expect(book.currentPage, 0);
      final earlier = await reads.watchForBook('a').first;
      expect(earlier.single.startedOn, DateTime(2024, 1, 2));
      expect(earlier.single.finishedOn, DateTime(2024, 2, 3));
    });

    test('a book not finished is just started again, nothing kept', () async {
      await h.addBook(id: 'b', title: 'B', status: ReadStatus.dropped);
      await use('b');
      expect(await reads.watchForBook('b').first, isEmpty);
    });

    test('stats count every finished read', () async {
      await finished('a', year: 2024);
      await use('a');
      // Finished again in 2025.
      await h.books.update(
        'a',
        (b) => b.copyWith(
          status: ReadStatus.finished,
          finishedOn: DateTime(2025, 3, 1),
        ),
      );
      expect(await h.stats.watchFinishedCount(2024).first, 1);
      expect(await h.stats.watchFinishedCount(2025).first, 1);
      expect(await h.stats.watchFinishedYears().first, <int>[2025, 2024]);
      expect((await h.stats.watchFinishedPerMonth(2024).first)[1], 1);
      expect(
        (await h.stats.finishedInMonth(2024, 2)).getOrNull()!.single.title,
        'Book a',
      );
      expect(
        (await h.stats.watchTopGenres(2024).first).single.label,
        'Fantasy',
      );
      expect(
        (await h.stats.watchTopAuthors(2024).first).single.label,
        'Ursula K. Le Guin',
      );
    });
  });

  testWidgets('"Read again" on a finished book', (t) async {
    final h = AddFlowHarness();
    addTearDown(h.dispose);
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(
          id: 'a',
          title: 'Earthsea',
          now: DateTime(2025, 1, 1),
          pages: 200,
          status: ReadStatus.finished,
        ).copyWith(
          startedOn: DateTime(2024, 5, 1),
          finishedOn: DateTime(2024, 5, 20),
          currentPage: 200,
        ),
      ),
    );
    final c = await pumpRouterApp(
      t,
      size: const Size(420, 1400),
      overrides: h.overrides,
    );
    routerOf(c).go('/book/a');
    await t.pumpAndSettle();
    expect(find.text('Earlier reads'), findsNothing);
    await t.tap(find.text('Read again'));
    for (var i = 0; i < 3; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await t.pumpAndSettle();
    }
    expect(
      find.text('A new read starts today. The last one is kept.'),
      findsOneWidget,
    );
    expect(find.text('Earlier reads'), findsOneWidget);
    expect(find.text('May 1, 2024 – May 20, 2024'), findsOneWidget);
    expect(find.text('Read again'), findsNothing, reason: 'now reading');
  });
}
