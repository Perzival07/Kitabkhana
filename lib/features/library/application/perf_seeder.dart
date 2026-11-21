import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/text/isbn.dart';
import '../../../core/uuid.dart';
import '../../../data/db/app_database.dart';
import '../../lending/domain/loan_direction.dart';
import '../data/book_mapper.dart';
import '../domain/book.dart';
import '../domain/book_enums.dart';

/// What [PerfSeeder] wrote.
final class PerfSeedSummary {
  const PerfSeedSummary({
    required this.books,
    required this.loans,
    required this.readingLogs,
    required this.quotes,
    required this.elapsed,
  });

  final int books;
  final int loans;
  final int readingLogs;
  final int quotes;
  final Duration elapsed;

  @override
  String toString() =>
      '$books books, $loans loans, $readingLogs logs, $quotes quotes '
      'in ${elapsed.inMilliseconds} ms';
}

/// Dev-only: fills a database with a large, varied library (English, Hindi
/// and Bengali titles) so scrolling, search and statistics can be measured at
/// scale. Deterministic for a given seed, so runs are comparable. Writes
/// straight to the tables in batches, inside one transaction.
class PerfSeeder {
  PerfSeeder(this._db);

  final AppDatabase _db;

  static const List<String> _en = <String>[
    'River',
    'Garden',
    'Silent',
    'Winter',
    'Memory',
    'Shadow',
    'Empire',
    'Light',
    'Letters',
    'Journey',
    'Midnight',
    'Ocean',
    'Forest',
    'Mirror',
    'Glass',
    'Harvest',
    'Atlas',
    'Orchard',
    'Compass',
    'Lantern',
    'Salt',
    'Thread',
  ];
  static const List<String> _hi = <String>[
    'किताब',
    'सफ़र',
    'चाँद',
    'आसमान',
    'कहानी',
    'ज़िन्दगी',
    'रात',
    'दरिया',
    'मौसम',
    'ख़्वाब',
    'धरती',
    'यादें',
  ];
  static const List<String> _bn = <String>[
    'বই',
    'নদী',
    'আকাশ',
    'গল্প',
    'রাত',
    'স্বপ্ন',
    'পথ',
    'বৃষ্টি',
    'মেঘ',
    'ঘর',
  ];
  static const List<String> _first = <String>[
    'Anita',
    'Rahul',
    'Meera',
    'Arjun',
    'Isha',
    'Kabir',
    'Sara',
    'Dev',
    'Nila',
    'Omar',
    'Priya',
    'Tariq',
    'Leela',
    'Noor',
  ];
  static const List<String> _last = <String>[
    'Sharma',
    'Banerjee',
    'Khan',
    'Iyer',
    'Das',
    'Rao',
    'Mehta',
    'Sen',
    'Roy',
    'Nair',
    'Gupta',
    'Bose',
  ];
  static const List<String> _genres = <String>[
    'Fiction',
    'History',
    'Science',
    'Poetry',
    'Biography',
    'Fantasy',
    'Mystery',
    'Philosophy',
    'Travel',
    'Children',
  ];
  static const List<String> _tags = <String>[
    'Favourites',
    'Classics',
    'Gifted',
    'Reference',
    'To lend',
    'Signed',
    'Hindi',
    'Bengali',
    'Cookbooks',
    'Comics',
    'Poetry',
    'Travel',
    'Kids',
    'Rare',
    'Re-read',
  ];

  /// An ISBN-13 with a correct check digit built from [n].
  static String isbnFor(int n) {
    // 978 + 9 digits = 12, then the check digit makes 13.
    final nine = (100000000 + (n * 7919) % 800000000).toString();
    final body = '978$nine';
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(body[i]) * (i.isEven ? 1 : 3);
    }
    return '$body${(10 - sum % 10) % 10}';
  }

  Future<PerfSeedSummary> seed({
    int books = 5000,
    int loans = 300,
    int readingLogs = 20000,
    int quotes = 500,
    DateTime? today,
    int randomSeed = 42,
  }) async {
    final watch = Stopwatch()..start();
    final rng = Random(randomSeed);
    final day = today ?? DateTime.now();
    final end = DateTime(day.year, day.month, day.day);
    final now = DateTime(day.year, day.month, day.day, 12);

    T pick<T>(List<T> l) => l[rng.nextInt(l.length)];
    String word() => switch (rng.nextInt(10)) {
      < 6 => pick(_en),
      < 8 => pick(_hi),
      _ => pick(_bn),
    };
    String title() {
      final n = 1 + rng.nextInt(3);
      return List<String>.generate(n, (_) => word()).join(' ');
    }

    String person() => '${pick(_first)} ${pick(_last)}';

    final locationIds = <String>[];
    final tagIds = <String>[];

    await _db.transaction(() async {
      // Places.
      final locCompanions = <LocationsCompanion>[];
      for (var i = 0; i < 25; i++) {
        final id = uuidV7();
        locationIds.add(id);
        locCompanions.add(
          LocationsCompanion.insert(
            id: Value(id),
            name: 'Shelf ${i + 1}',
            createdAt: now,
            updatedAt: now,
            sortOrder: Value(i),
          ),
        );
      }
      await _db.batch((b) => b.insertAll(_db.locations, locCompanions));

      // Tags.
      final tagCompanions = <TagsCompanion>[];
      for (final t in _tags) {
        final id = uuidV7();
        tagIds.add(id);
        tagCompanions.add(
          TagsCompanion.insert(
            id: Value(id),
            name: t,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      await _db.batch((b) => b.insertAll(_db.tags, tagCompanions));

      // Books.
      final bookIds = <String>[];
      final readable = <(String, int)>[]; // (id, pages) for reading logs
      final bookCompanions = <BooksCompanion>[];
      for (var i = 0; i < books; i++) {
        final id = uuidV7();
        bookIds.add(id);
        final status = switch (rng.nextInt(10)) {
          < 4 => ReadStatus.finished,
          < 6 => ReadStatus.reading,
          < 9 => ReadStatus.want,
          _ => ReadStatus.dropped,
        };
        final pages = 80 + rng.nextInt(700);
        final titleText = title();
        final authors = rng.nextInt(8) == 0
            ? '${person()}, ${person()}'
            : person();
        final started = end.subtract(Duration(days: 30 + rng.nextInt(700)));
        var book = Book.create(
          id: id,
          title: titleText,
          authors: authors,
          now: now.subtract(Duration(minutes: books - i)),
          isbn13: rng.nextInt(5) == 0 ? null : parseIsbn(isbnFor(i)),
          pages: pages,
          genre: pick(_genres),
          ownership: rng.nextInt(12) == 0
              ? Ownership.wishlist
              : Ownership.owned,
          status: status,
          locationId: rng.nextInt(10) == 0 ? null : pick(locationIds),
        );
        if (status != ReadStatus.want) {
          book = book.copyWith(startedOn: started);
        }
        if (status == ReadStatus.finished) {
          book = book.copyWith(
            finishedOn: started.add(Duration(days: 3 + rng.nextInt(40))),
            currentPage: pages,
            rating: rng.nextBool() ? 1 + rng.nextInt(5) : null,
          );
        } else if (status == ReadStatus.reading) {
          book = book.copyWith(currentPage: rng.nextInt(pages));
        }
        if (status == ReadStatus.reading || status == ReadStatus.finished) {
          readable.add((id, pages));
        }
        bookCompanions.add(
          bookToCompanion(
            book,
            updatedAt: book.updatedAt,
            rev: 1,
            createdAt: book.createdAt,
          ),
        );
      }
      for (var i = 0; i < bookCompanions.length; i += 1000) {
        final chunk = bookCompanions.sublist(
          i,
          min(i + 1000, bookCompanions.length),
        );
        await _db.batch((b) => b.insertAll(_db.books, chunk));
      }

      // Tags on books (each pair once).
      final pairs = <String>{};
      final linkCompanions = <BookTagsCompanion>[];
      for (var i = 0; i < books * 6 ~/ 5; i++) {
        final bookId = pick(bookIds);
        final tagId = pick(tagIds);
        if (!pairs.add('$bookId|$tagId')) continue;
        linkCompanions.add(
          BookTagsCompanion.insert(
            id: Value(uuidV7()),
            bookId: bookId,
            tagId: tagId,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      for (var i = 0; i < linkCompanions.length; i += 1000) {
        final chunk = linkCompanions.sublist(
          i,
          min(i + 1000, linkCompanions.length),
        );
        await _db.batch((b) => b.insertAll(_db.bookTags, chunk));
      }

      // Loans: each on a different book; a few still out.
      final loanBooks = (List<String>.of(
        bookIds,
      )..shuffle(rng)).take(min(loans, bookIds.length)).toList();
      final loanCompanions = <LoansCompanion>[];
      for (var i = 0; i < loanBooks.length; i++) {
        final active = i < loanBooks.length ~/ 8;
        final started = end.subtract(Duration(days: 5 + rng.nextInt(400)));
        final due = started.add(Duration(days: 14 + rng.nextInt(30)));
        loanCompanions.add(
          LoansCompanion.insert(
            id: Value(uuidV7()),
            bookId: loanBooks[i],
            direction: rng.nextInt(5) == 0
                ? LoanDirection.borrowed
                : LoanDirection.lent,
            personName: person(),
            startedOn: started,
            dueOn: Value(due),
            returnedOn: Value(
              active ? null : due.add(Duration(days: rng.nextInt(10))),
            ),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      await _db.batch((b) => b.insertAll(_db.loans, loanCompanions));

      // Reading logs: a distinct day for each, per book.
      final logCompanions = <ReadingLogsCompanion>[];
      final usedDays = <String>{};
      var guard = 0;
      while (logCompanions.length < readingLogs &&
          readable.isNotEmpty &&
          guard++ < readingLogs * 4) {
        final (id, pages) = pick(readable);
        final d = end.subtract(Duration(days: rng.nextInt(540)));
        if (!usedDays.add('$id|${d.millisecondsSinceEpoch}')) continue;
        final from = rng.nextInt(max(1, pages - 60));
        final read = 1 + rng.nextInt(60);
        logCompanions.add(
          ReadingLogsCompanion.insert(
            id: Value(uuidV7()),
            bookId: id,
            date: d,
            pagesRead: read,
            fromPage: from,
            toPage: from + read,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      for (var i = 0; i < logCompanions.length; i += 1000) {
        final chunk = logCompanions.sublist(
          i,
          min(i + 1000, logCompanions.length),
        );
        await _db.batch((b) => b.insertAll(_db.readingLogs, chunk));
      }

      // Quotes.
      final quoteCompanions = <QuotesCompanion>[];
      for (var i = 0; i < quotes; i++) {
        quoteCompanions.add(
          QuotesCompanion.insert(
            id: Value(uuidV7()),
            bookId: pick(bookIds),
            body:
                'A passage worth keeping: ${title()}, ${word()} and ${word()}.',
            page: Value(1 + rng.nextInt(400)),
            isFavourite: Value(rng.nextInt(6) == 0),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      await _db.batch((b) => b.insertAll(_db.quotes, quoteCompanions));

      // Remember the totals actually written, for the summary below.
      _written = (loanCompanions.length, logCompanions.length);
    });

    watch.stop();
    return PerfSeedSummary(
      books: books,
      loans: _written.$1,
      readingLogs: _written.$2,
      quotes: quotes,
      elapsed: watch.elapsed,
    );
  }

  (int, int) _written = (0, 0);
}
