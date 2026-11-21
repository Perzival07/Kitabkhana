import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';
import 'package:kitabkhana/features/quotes/domain/quote.dart';
import 'package:kitabkhana/features/reading/domain/reading_log.dart';

import 'add_flow_harness.dart';

/// A small, varied library for tests that look at whole screens: a book being
/// read (with logs and a quote), a finished and lent one, a wishlist one, a
/// goal, a tag and a place. Ids: `b1` (reading), `b2` (finished, lent),
/// `b3` (want to read); location `loc`.
Future<void> seedDemoLibrary(AddFlowHarness h) async {
  final now = DateTime(2025, 3, 10);
  await h.repos.locations.upsert(
    Location.create(id: 'loc', name: 'Living room shelf', now: now),
  );
  await h.repos.books.upsert(
    Book.create(
      id: 'b1',
      title: 'Middlemarch',
      authors: 'George Eliot',
      pages: 880,
      status: ReadStatus.reading,
      now: now,
      locationId: 'loc',
    ).copyWith(currentPage: 312, startedOn: DateTime(2025, 3, 1)),
  );
  await h.repos.books.upsert(
    Book.create(
      id: 'b2',
      title: 'Dune',
      authors: 'Frank Herbert',
      isbn13: parseIsbn('9780441013593'),
      pages: 612,
      status: ReadStatus.finished,
      now: now,
    ).copyWith(finishedOn: DateTime(2025, 2, 1), rating: 5),
  );
  await h.repos.books.upsert(
    Book.create(id: 'b3', title: 'Piranesi', now: now),
  );
  await h.repos.loans.startLoan(
    Loan.create(
      id: 'ln',
      bookId: 'b2',
      direction: LoanDirection.lent,
      personName: 'Priya',
      startedOn: DateTime(2025, 3, 1),
      dueOn: DateTime(2025, 3, 5),
      now: now,
    ),
  );
  await h.repos.readings.upsert(
    ReadingLog.create(
      id: 'l1',
      bookId: 'b1',
      date: DateTime(2025, 3, 9),
      fromPage: 0,
      toPage: 30,
      now: now,
    ),
  );
  await h.repos.quotes.upsert(
    Quote.create(
      id: 'q1',
      bookId: 'b1',
      body: 'Every limit is a beginning as well as an ending.',
      page: 9,
      isFavourite: true,
      now: now,
    ),
  );
  await h.repos.goals.setTarget(2025, 12);
  await h.repos.tags.createIfAbsent('Classic');
}
