import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/data/db/app_database.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';

import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDb());
  tearDown(() => db.close());

  Future<void> insertBook([String id = 'b1', String title = 'T']) =>
      db.into(db.books).insert(bookCompanion(id: id, title: title));

  Future<void> insertLoan({
    String id = 'ln1',
    String bookId = 'b1',
    DateTime? returnedOn,
    DateTime? deletedAt,
  }) {
    return db
        .into(db.loans)
        .insert(
          LoansCompanion.insert(
            id: Value(id),
            bookId: bookId,
            direction: LoanDirection.lent,
            personName: 'Priya',
            startedOn: DateTime(2025, 1, 2),
            returnedOn: Value(returnedOn),
            deletedAt: Value(deletedAt),
            createdAt: t0,
            updatedAt: t0,
          ),
        );
  }

  Future<List<String>> ftsSearch(String match) async {
    final rows = await db
        .customSelect(
          'SELECT b.id FROM books_fts f JOIN books b ON b.rowid = f.rowid '
          'WHERE books_fts MATCH ? ORDER BY b.id',
          variables: [Variable<String>(match)],
        )
        .get();
    return rows.map((r) => r.read<String>('id')).toList();
  }

  group('open', () {
    test('creates the current schema with foreign keys on', () async {
      expect(db.schemaVersion, 2);
      final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(fk.data.values.first, 1);
    });

    test('integrity check passes', () async {
      final r = await db.customSelect('PRAGMA integrity_check').getSingle();
      expect(r.data.values.first, 'ok');
    });
  });

  group('defaults', () {
    test('a minimal book gets sensible defaults and a UUIDv7 id', () async {
      await db
          .into(db.books)
          .insert(
            BooksCompanion.insert(
              title: 'Godan',
              titleKey: 'godan',
              createdAt: t0,
              updatedAt: t0,
            ),
          );
      final b = await db.select(db.books).getSingle();
      expect(b.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
      expect(b.id[14], '7');
      expect(b.ownership, Ownership.owned);
      expect(b.status, ReadStatus.want);
      expect(b.currentPage, 0);
      expect(b.rev, 1);
      expect(b.authors, '');
      expect(b.genre, '');
      expect(b.deletedAt, isNull);
      expect(b.pages, isNull);
      expect(b.rating, isNull);
    });

    test('timestamps round-trip with millisecond precision', () async {
      final at = DateTime.utc(2025, 5, 6, 7, 8, 9, 123);
      await db
          .into(db.books)
          .insert(
            bookCompanion().copyWith(
              createdAt: Value(at),
              updatedAt: Value(at),
            ),
          );
      final b = await db.select(db.books).getSingle();
      expect(b.createdAt.toUtc(), at);
    });

    test(
      'date-only columns store yyyy-MM-dd and read back as local dates',
      () async {
        await insertBook();
        await (db.update(db.books)..where((t) => t.id.equals('b1'))).write(
          BooksCompanion(startedOn: Value(DateTime(2025, 3, 9))),
        );
        final raw = await db
            .customSelect(
              'SELECT started_on FROM books WHERE id = ?',
              variables: [const Variable<String>('b1')],
            )
            .getSingle();
        expect(raw.read<String>('started_on'), '2025-03-09');
        final b = await db.select(db.books).getSingle();
        expect(b.startedOn, DateTime(2025, 3, 9));
      },
    );
  });

  group('constraints reject bad data', () {
    test('rating 6 and 0', () async {
      for (final r in <int>[6, 0, -1]) {
        await expectLater(
          db.into(db.books).insert(bookCompanion(id: 'r$r', rating: r)),
          throwsA(anything),
          reason: 'rating $r',
        );
      }
      await db.into(db.books).insert(bookCompanion(id: 'ok1', rating: 1));
      await db.into(db.books).insert(bookCompanion(id: 'ok5', rating: 5));
    });

    test('non-positive pages and negative current page', () async {
      await expectLater(
        db.into(db.books).insert(bookCompanion(id: 'p0', pages: 0)),
        throwsA(anything),
      );
      await expectLater(
        db.into(db.books).insert(bookCompanion(id: 'pn', pages: -10)),
        throwsA(anything),
      );
      await expectLater(
        db.into(db.books).insert(bookCompanion(id: 'cp', currentPage: -1)),
        throwsA(anything),
      );
      await db.into(db.books).insert(bookCompanion(id: 'fine', pages: 1));
    });

    test('unknown enum text via raw SQL', () async {
      Future<void> raw(String sql) => db.customStatement(sql);
      const base =
          "INSERT INTO books (id, title, title_key, created_at, updated_at";
      await expectLater(
        raw(
          "$base, ownership) VALUES ('x','t','t','2025-01-01','2025-01-01','junk')",
        ),
        throwsA(anything),
      );
      await expectLater(
        raw(
          "$base, status) VALUES ('y','t','t','2025-01-01','2025-01-01','junk')",
        ),
        throwsA(anything),
      );
    });

    test(
      'reading log needs positive pages; goal needs positive target',
      () async {
        await insertBook();
        await expectLater(
          db
              .into(db.readingLogs)
              .insert(
                ReadingLogsCompanion.insert(
                  bookId: 'b1',
                  date: DateTime(2025, 1, 1),
                  pagesRead: 0,
                  fromPage: 5,
                  toPage: 5,
                  createdAt: t0,
                  updatedAt: t0,
                ),
              ),
          throwsA(anything),
        );
        await expectLater(
          db
              .into(db.goals)
              .insert(
                GoalsCompanion.insert(
                  year: 2025,
                  targetBooks: 0,
                  createdAt: t0,
                  updatedAt: t0,
                ),
              ),
          throwsA(anything),
        );
      },
    );

    test('foreign keys are enforced', () async {
      await expectLater(
        db.into(db.books).insert(bookCompanion(locationId: 'nope')),
        throwsA(anything),
      );
      await expectLater(insertLoan(bookId: 'missing'), throwsA(anything));
    });

    test('deleting a location nulls the book location', () async {
      await db.into(db.locations).insert(locationCompanion());
      await db.into(db.books).insert(bookCompanion(locationId: 'l1'));
      await (db.delete(db.locations)..where((t) => t.id.equals('l1'))).go();
      final b = await db.select(db.books).getSingle();
      expect(b.locationId, isNull);
    });
  });

  group('uniqueness', () {
    test('only one active loan per book', () async {
      await insertBook();
      await insertLoan();
      await expectLater(insertLoan(id: 'ln2'), throwsA(anything));
    });

    test('a returned loan frees the book for a new loan', () async {
      await insertBook();
      await insertLoan(returnedOn: DateTime(2025, 1, 9));
      await insertLoan(id: 'ln2');
      await expectLater(insertLoan(id: 'ln3'), throwsA(anything));
    });

    test('a soft-deleted loan does not block a new one', () async {
      await insertBook();
      await insertLoan(deletedAt: t0);
      await insertLoan(id: 'ln2');
    });

    test('one goal per year among non-deleted goals', () async {
      GoalsCompanion goal(String id, {DateTime? deletedAt}) =>
          GoalsCompanion.insert(
            id: Value(id),
            year: 2025,
            targetBooks: 24,
            createdAt: t0,
            updatedAt: t0,
            deletedAt: Value(deletedAt),
          );
      await db.into(db.goals).insert(goal('g1'));
      await expectLater(
        db.into(db.goals).insert(goal('g2')),
        throwsA(anything),
      );
      await (db.update(db.goals)..where((t) => t.id.equals('g1'))).write(
        GoalsCompanion(deletedAt: Value(t0)),
      );
      await db.into(db.goals).insert(goal('g2'));
    });

    test('tag names are unique ignoring case', () async {
      TagsCompanion tag(String id, String name) => TagsCompanion.insert(
        id: Value(id),
        name: name,
        createdAt: t0,
        updatedAt: t0,
      );
      await db.into(db.tags).insert(tag('t1', 'Fiction'));
      await expectLater(
        db.into(db.tags).insert(tag('t2', 'fiction')),
        throwsA(anything),
      );
      await db.into(db.tags).insert(tag('t3', 'History'));
    });

    test('location names are unique per parent, ignoring case', () async {
      await db.into(db.locations).insert(locationCompanion(name: 'Bedroom'));
      await expectLater(
        db
            .into(db.locations)
            .insert(locationCompanion(id: 'l2', name: 'BEDROOM')),
        throwsA(anything),
      );
      // Same name under a different parent is fine.
      await db
          .into(db.locations)
          .insert(locationCompanion(id: 'l3', name: 'Bedroom', parentId: 'l1'));
    });

    test('a tag can be attached to a book only once', () async {
      await insertBook();
      await db
          .into(db.tags)
          .insert(
            TagsCompanion.insert(
              id: const Value('t1'),
              name: 'x',
              createdAt: t0,
              updatedAt: t0,
            ),
          );
      BookTagsCompanion link(String id) => BookTagsCompanion.insert(
        id: Value(id),
        bookId: 'b1',
        tagId: 't1',
        createdAt: t0,
        updatedAt: t0,
      );
      await db.into(db.bookTags).insert(link('bt1'));
      await expectLater(
        db.into(db.bookTags).insert(link('bt2')),
        throwsA(anything),
      );
    });
  });

  group('full-text search', () {
    setUp(() async {
      await db.batch((b) {
        b.insertAll(db.books, [
          bookCompanion(
            id: 'hp',
            title: "Harry Potter and the Philosopher's Stone",
            authors: 'J. K. Rowling',
          ),
          bookCompanion(
            id: 'gm',
            title: 'Cien años de soledad',
            subtitle: 'Edición ilustrada',
            authors: 'Gabriel García Márquez',
          ),
          bookCompanion(id: 'gd', title: 'गोदान', authors: 'प्रेमचंद'),
        ]);
      });
    });

    test('finds by partial title', () async {
      expect(await ftsSearch('harr*'), ['hp']);
      expect(await ftsSearch('philos*'), ['hp']);
    });

    test('finds by author prefix', () async {
      expect(await ftsSearch('rowl*'), ['hp']);
      expect(await ftsSearch('gabriel'), ['gm']);
    });

    test('ignores diacritics', () async {
      expect(await ftsSearch('garcia'), ['gm']);
      expect(await ftsSearch('anos'), ['gm']);
      expect(await ftsSearch('edicion'), ['gm']);
    });

    test('searches Devanagari text', () async {
      expect(await ftsSearch('गोदान'), ['gd']);
    });

    test('reflects title updates', () async {
      await (db.update(db.books)..where((t) => t.id.equals('hp'))).write(
        const BooksCompanion(title: Value('Dune')),
      );
      expect(await ftsSearch('harr*'), isEmpty);
      expect(await ftsSearch('dune'), ['hp']);
    });

    test(
      'soft delete removes from the index and restore adds it back',
      () async {
        await (db.update(db.books)..where((t) => t.id.equals('hp'))).write(
          BooksCompanion(deletedAt: Value(t0)),
        );
        expect(await ftsSearch('harr*'), isEmpty);
        await (db.update(db.books)..where((t) => t.id.equals('hp'))).write(
          const BooksCompanion(deletedAt: Value(null)),
        );
        expect(await ftsSearch('harr*'), ['hp']);
      },
    );

    test('editing a soft-deleted book keeps it out of the index', () async {
      await (db.update(db.books)..where((t) => t.id.equals('hp'))).write(
        BooksCompanion(deletedAt: Value(t0)),
      );
      await (db.update(db.books)..where((t) => t.id.equals('hp'))).write(
        const BooksCompanion(notes: Value('note')),
      );
      expect(await ftsSearch('harr*'), isEmpty);
    });

    test(
      'hard delete removes from the index; index stays consistent',
      () async {
        await (db.delete(db.books)..where((t) => t.id.equals('gm'))).go();
        expect(await ftsSearch('garcia'), isEmpty);
        await db.customStatement(
          "INSERT INTO books_fts(books_fts) VALUES('integrity-check')",
        );
      },
    );

    test('books inserted already soft-deleted are not indexed', () async {
      await db
          .into(db.books)
          .insert(bookCompanion(id: 'old', title: 'Zebra', deletedAt: t0));
      expect(await ftsSearch('zebra'), isEmpty);
    });
  });

  group('default queries exclude soft-deleted rows', () {
    test('liveBooks / liveLocations / liveLoans', () async {
      await db.into(db.locations).insert(locationCompanion());
      await db
          .into(db.locations)
          .insert(locationCompanion(id: 'l2', name: 'Gone', deletedAt: t0));
      await insertBook();
      await db
          .into(db.books)
          .insert(bookCompanion(id: 'b2', title: 'Gone', deletedAt: t0));
      await insertLoan();
      await insertLoan(id: 'ln2', bookId: 'b2', deletedAt: t0);

      expect((await db.liveBooks().get()).map((b) => b.id), ['b1']);
      expect((await db.liveLocations().get()).map((l) => l.id), ['l1']);
      expect((await db.liveLoans().get()).map((l) => l.id), ['ln1']);
      // The rows still exist (soft delete).
      expect(await db.select(db.books).get(), hasLength(2));
    });
  });
}
