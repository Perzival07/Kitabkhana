import 'package:kitabkhana/core/clock.dart';
import 'package:kitabkhana/data/db/app_database.dart';
import 'package:kitabkhana/features/lending/data/drift_loan_repository.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/data/book_mapper.dart';
import 'package:kitabkhana/features/library/data/drift_book_repository.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/locations/data/drift_location_repository.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';
import 'package:kitabkhana/features/quotes/data/drift_quote_repository.dart';
import 'package:kitabkhana/features/reading/data/drift_reading_repository.dart';
import 'package:kitabkhana/features/reading/domain/reading_log.dart';
import 'package:kitabkhana/features/stats/data/drift_goal_repository.dart';
import 'package:kitabkhana/features/stats/data/drift_stats_repository.dart';
import 'package:kitabkhana/features/tags/data/drift_tag_repository.dart';

import 'test_db.dart';

/// The repositories over an existing database (used by widget-test harnesses).
class RepoHarnessForDb {
  RepoHarnessForDb(AppDatabase db, FakeClock clock)
    : _db = db,
      books = DriftBookRepository(db, clock),
      locations = DriftLocationRepository(db, clock),
      loans = DriftLoanRepository(db, clock),
      readings = DriftReadingRepository(db, clock),
      goals = DriftGoalRepository(db, clock),
      quotes = DriftQuoteRepository(db, clock),
      tags = DriftTagRepository(db, clock);

  final AppDatabase _db;
  final DriftBookRepository books;
  final DriftLocationRepository locations;
  final DriftLoanRepository loans;
  final DriftReadingRepository readings;
  final DriftGoalRepository goals;
  final DriftQuoteRepository quotes;
  final DriftTagRepository tags;

  /// All live books via a one-shot query (a stream would leave a pending
  /// timer behind when cancelled inside a widget test).
  Future<List<Book>> allBooks() async =>
      (await _db.liveBooks().get()).map((r) => r.toDomain()).toList();
}

/// An in-memory database, a controllable clock and every repository.
class RepoHarness {
  RepoHarness() : clock = FakeClock(DateTime(2025, 3, 10, 9)) {
    db = createTestDb();
    books = DriftBookRepository(db, clock);
    locations = DriftLocationRepository(db, clock);
    loans = DriftLoanRepository(db, clock);
    readings = DriftReadingRepository(db, clock);
    quotes = DriftQuoteRepository(db, clock);
    goals = DriftGoalRepository(db, clock);
    stats = DriftStatsRepository(db);
    tags = DriftTagRepository(db, clock);
  }

  final FakeClock clock;
  late final AppDatabase db;
  late final DriftBookRepository books;
  late final DriftLocationRepository locations;
  late final DriftLoanRepository loans;
  late final DriftReadingRepository readings;
  late final DriftQuoteRepository quotes;
  late final DriftGoalRepository goals;
  late final DriftStatsRepository stats;
  late final DriftTagRepository tags;

  int _seq = 0;

  String nextId(String prefix) => '$prefix${++_seq}';

  /// Moves the clock forward one minute so created-at ordering is stable.
  void tick([Duration by = const Duration(minutes: 1)]) => clock.advance(by);

  /// Saves a book and returns the stored copy.
  Future<Book> addBook({
    String? id,
    String title = 'Untitled',
    String authors = '',
    Ownership ownership = Ownership.owned,
    ReadStatus status = ReadStatus.want,
    String? locationId,
    String? olWorkKey,
    int? pages,
    int? rating,
    String? subtitle,
    Book Function(Book)? tweak,
  }) async {
    tick();
    var book = Book.create(
      id: id ?? nextId('b'),
      title: title,
      authors: authors,
      now: clock.now(),
      ownership: ownership,
      status: status,
      locationId: locationId,
      olWorkKey: olWorkKey,
      pages: pages,
      subtitle: subtitle,
    ).copyWith(rating: rating);
    if (tweak != null) book = tweak(book);
    return (await books.upsert(book)).getOrNull()!;
  }

  Future<Location> addLocation({
    String? id,
    String name = 'Shelf',
    String? parentId,
    int sortOrder = 0,
  }) async {
    tick();
    final l = Location.create(
      id: id ?? nextId('l'),
      name: name,
      now: clock.now(),
      parentId: parentId,
      sortOrder: sortOrder,
    );
    return (await locations.upsert(l)).getOrNull()!;
  }

  Loan newLoan({
    String? id,
    required String bookId,
    LoanDirection direction = LoanDirection.lent,
    String person = 'Priya',
    DateTime? startedOn,
    DateTime? dueOn,
    String? previousLocationId,
  }) {
    return Loan.create(
      id: id ?? nextId('ln'),
      bookId: bookId,
      direction: direction,
      personName: person,
      startedOn: startedOn ?? clock.today(),
      dueOn: dueOn,
      previousLocationId: previousLocationId,
      now: clock.now(),
    );
  }

  Future<Loan> addLoan({
    required String bookId,
    LoanDirection direction = LoanDirection.lent,
    DateTime? dueOn,
    String? id,
  }) async {
    tick();
    final r = await loans.create(
      newLoan(id: id, bookId: bookId, direction: direction, dueOn: dueOn),
    );
    return r.getOrNull()!;
  }

  Future<ReadingLog> addLog({
    required String bookId,
    required DateTime date,
    int from = 0,
    int to = 10,
  }) async {
    tick();
    final r = await readings.upsert(
      ReadingLog.create(
        id: nextId('r'),
        bookId: bookId,
        date: date,
        fromPage: from,
        toPage: to,
        now: clock.now(),
      ),
    );
    return r.getOrNull()!;
  }

  Future<void> dispose() => db.close();
}
