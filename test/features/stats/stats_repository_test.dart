import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/reading/domain/reading_log.dart';
import 'package:kitabkhana/features/stats/domain/stats.dart';

import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;

  setUp(() => h = RepoHarness());
  tearDown(() => h.db.close());

  Future<String> finished(
    String title,
    DateTime on, {
    String authors = '',
    String genre = '',
    int? pages,
    int? rating,
  }) async {
    final b = await h.addBook(
      title: title,
      authors: authors,
      pages: pages,
      rating: rating,
      status: ReadStatus.finished,
      tweak: (b) => b.copyWith(genre: genre, finishedOn: on),
    );
    return b.id;
  }

  group('finished counts', () {
    test('count by finish year, ignoring other statuses and deleted', () async {
      await finished('A', DateTime(2025, 1, 5));
      await finished('B', DateTime(2025, 12, 31));
      await finished('C', DateTime(2024, 12, 31));
      final gone = await finished('D', DateTime(2025, 6, 1));
      await h.books.softDelete(gone);
      await h.addBook(title: 'Reading', status: ReadStatus.reading);
      expect(await h.stats.watchFinishedCount(2025).first, 2);
      expect(await h.stats.watchFinishedCount(2024).first, 1);
      expect(await h.stats.watchFinishedCount(2023).first, 0);
    });

    test('per month has 12 slots, January first', () async {
      await finished('A', DateTime(2025, 1, 31));
      await finished('B', DateTime(2025, 3, 1));
      await finished('C', DateTime(2025, 3, 20));
      await finished('D', DateTime(2025, 12, 31));
      await finished('E', DateTime(2024, 3, 3));
      expect(await h.stats.watchFinishedPerMonth(2025).first, [
        1,
        0,
        2,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        1,
      ]);
      expect(await h.stats.watchFinishedPerMonth(2022).first, everyElement(0));
    });

    test('books of a month, newest finish first', () async {
      await finished('Early', DateTime(2025, 3, 2));
      await finished('Late', DateTime(2025, 3, 28));
      await finished('Other month', DateTime(2025, 4, 1));
      final r = (await h.stats.finishedInMonth(2025, 3)).getOrNull()!;
      expect(r.map((b) => b.title), ['Late', 'Early']);
    });

    test('years with finished books, newest first', () async {
      await finished('A', DateTime(2023, 5, 1));
      await finished('B', DateTime(2025, 5, 1));
      await finished('C', DateTime(2025, 6, 1));
      expect(await h.stats.watchFinishedYears().first, [2025, 2023]);
    });
  });

  group('pages per week', () {
    Future<void> log(String bookId, DateTime day, int pages) =>
        h.readings.upsert(
          ReadingLog.create(
            id: '${bookId}_${day.toIso8601String()}',
            bookId: bookId,
            date: day,
            fromPage: 0,
            toPage: pages,
            now: day,
          ),
        );

    test('buckets the last 12 weeks ending on the given day', () async {
      final id = (await h.addBook(title: 'B')).id;
      final end = DateTime(2025, 3, 10);
      await log(id, DateTime(2025, 3, 10), 10); // week 0 (Mar 4-10)
      await log(id, DateTime(2025, 3, 4), 5); // week 0, first day
      await log(id, DateTime(2025, 3, 3), 7); // week 1 (Feb 25-Mar 3)
      await log(id, DateTime(2024, 12, 17), 3); // week 11, first day
      await log(id, DateTime(2024, 12, 16), 99); // too old
      await log(id, DateTime(2025, 3, 11), 99); // after the end
      final weeks = await h.stats.watchPagesPerWeek(end).first;
      expect(weeks, hasLength(12));
      expect(weeks.last, WeekPages(DateTime(2025, 3, 4), 15));
      expect(weeks[10], WeekPages(DateTime(2025, 2, 25), 7));
      expect(weeks.first, WeekPages(DateTime(2024, 12, 17), 3));
      expect(weeks.fold<int>(0, (a, w) => a + w.pages), 25);
    });

    test('logs of deleted books are left out', () async {
      final id = (await h.addBook(title: 'B')).id;
      await log(id, DateTime(2025, 3, 10), 10);
      await h.books.softDelete(id);
      final weeks = await h.stats
          .watchPagesPerWeek(DateTime(2025, 3, 10))
          .first;
      expect(weeks.every((w) => w.pages == 0), isTrue);
    });
  });

  group('genres and authors', () {
    test('top genres rank by count, case-insensitively, skip blanks', () async {
      await finished('A', DateTime(2025, 1, 1), genre: 'Fantasy');
      await finished('B', DateTime(2025, 1, 2), genre: 'fantasy');
      await finished('C', DateTime(2025, 1, 3), genre: 'History');
      await finished('D', DateTime(2025, 1, 4));
      await finished('E', DateTime(2024, 1, 4), genre: 'History');
      final top = await h.stats.watchTopGenres(2025).first;
      expect(top.map((g) => g.count), [2, 1]);
      expect(top.first.label.toLowerCase(), 'fantasy');
      expect(top.last, const LabelCount('History', 1));
    });

    test('top authors split comma lists and honour the limit', () async {
      await finished('A', DateTime(2025, 1, 1), authors: 'Ursula Le Guin');
      await finished(
        'B',
        DateTime(2025, 1, 2),
        authors: 'Ursula Le Guin, Terry Pratchett',
      );
      await finished('C', DateTime(2025, 1, 3), authors: 'Terry Pratchett');
      await finished('D', DateTime(2025, 1, 4), authors: 'Iain Banks');
      await finished('E', DateTime(2025, 1, 5));
      final top = await h.stats.watchTopAuthors(2025).first;
      expect(top.map((a) => a.count), [2, 2, 1]);
      expect(top.map((a) => a.label).toSet(), {
        'Ursula Le Guin',
        'Terry Pratchett',
        'Iain Banks',
      });
      expect(await h.stats.watchTopAuthors(2025, limit: 1).first, hasLength(1));
    });
  });

  group('library facts', () {
    test('an empty library is all zeros', () async {
      expect(await h.stats.watchFacts(2025).first, LibraryFacts.empty);
    });

    test('totals, loans, rating and the longest finished book', () async {
      await finished('Short', DateTime(2025, 2, 1), pages: 120, rating: 4);
      await finished('Long', DateTime(2025, 3, 1), pages: 900, rating: 5);
      await finished('Last year', DateTime(2024, 3, 1), pages: 1500);
      final lent = await h.addBook(title: 'Lent');
      await h.addBook(title: 'Wish', ownership: Ownership.wishlist);
      final gone = await h.addBook(title: 'Gone', rating: 1);
      await h.books.softDelete(gone.id);
      await h.loans.startLoan(
        Loan.create(
          id: 'ln',
          bookId: lent.id,
          direction: LoanDirection.lent,
          personName: 'Priya',
          startedOn: DateTime(2025, 3, 1),
          now: DateTime(2025, 3, 1),
        ),
      );
      final f = await h.stats.watchFacts(2025).first;
      expect(f.totalBooks, 5);
      expect(f.owned, 4);
      expect(f.wishlist, 1);
      expect(f.lentOut, 1);
      expect(f.averageRating, 4.5);
      expect(f.longest, const LongestBook('Long', 900));
      expect((await h.stats.watchFacts(2024).first).longest!.pages, 1500);
      expect((await h.stats.watchFacts(2020).first).longest, isNull);
    });
  });
}
