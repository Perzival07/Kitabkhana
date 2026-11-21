import '../../../core/clock.dart';
import '../../../core/text/isbn.dart';
import '../../../core/uuid.dart';
import '../../lending/domain/loan.dart';
import '../../lending/domain/loan_direction.dart';
import '../../lending/domain/loan_repository.dart';
import '../../locations/domain/location.dart';
import '../../locations/domain/location_repository.dart';
import '../../quotes/domain/quote.dart';
import '../../quotes/domain/quote_repository.dart';
import '../../reading/domain/reading_log.dart';
import '../../reading/domain/reading_repository.dart';
import '../../stats/domain/goal_repository.dart';
import '../../tags/domain/tag_repository.dart';
import '../domain/book.dart';
import '../domain/book_enums.dart';
import '../domain/book_repository.dart';

/// Dev-only: a small, good-looking library of public-domain classics, for store
/// screenshots (on a device, or from `test/tool/generate_store_screenshots_test.dart`).
/// Everything is relative to the clock's "today", so the demo always looks
/// current: a reading streak running into today, a loan due soon and one a few
/// days overdue, a yearly goal about on pace.
class StoreDemoSeeder {
  StoreDemoSeeder({
    required this.books,
    required this.locations,
    required this.loans,
    required this.readings,
    required this.quotes,
    required this.goals,
    required this.tags,
    required this.clock,
  });

  final BookRepository books;
  final LocationRepository locations;
  final LoanRepository loans;
  final ReadingRepository readings;
  final QuoteRepository quotes;
  final GoalRepository goals;
  final TagRepository tags;
  final Clock clock;

  /// Ids the screenshots refer to.
  static const String prideId = 'demo-pride';
  static const String middlemarchId = 'demo-middlemarch';
  static const String prideIsbn = '9780141439518';

  Future<int> seed() async {
    final today = clock.today();
    final now = clock.now();
    DateTime ago(int days) =>
        DateTime(today.year, today.month, today.day - days);

    var order = 0;
    Future<void> place(String id, String name, String icon) async {
      await locations.upsert(
        Location.create(
          id: id,
          name: name,
          now: now,
          sortOrder: order++,
          icon: icon,
        ),
      );
    }

    await place('demo-living', 'Living room shelf', 'shelf');
    await place('demo-study', 'Study desk', 'shelf');
    await place('demo-bedroom', 'Bedroom shelf', 'shelf');
    await place('demo-box', 'Storage box', 'box');

    var n = 0;
    Future<void> add(
      String id,
      String title,
      String author, {
      required ReadStatus status,
      required int pages,
      String? place,
      int page = 0,
      int? rating,
      int? startedAgo,
      int? finishedAgo,
      String genre = 'Classics',
      String? isbn,
      Ownership ownership = Ownership.owned,
    }) async {
      var b = Book.create(
        id: id,
        title: title,
        authors: author,
        pages: pages,
        genre: genre,
        status: status,
        ownership: ownership,
        locationId: place,
        isbn13: isbn == null ? null : parseIsbn(isbn),
        // Newest first in the library, in the order listed here.
        now: now.subtract(Duration(minutes: ++n)),
      );
      if (startedAgo != null) b = b.copyWith(startedOn: ago(startedAgo));
      if (finishedAgo != null) {
        b = b.copyWith(finishedOn: ago(finishedAgo), currentPage: pages);
      } else if (status == ReadStatus.reading) {
        b = b.copyWith(currentPage: page);
      }
      if (rating != null) b = b.copyWith(rating: rating);
      await books.upsert(b);
    }

    await add(
      middlemarchId,
      'Middlemarch',
      'George Eliot',
      status: ReadStatus.reading,
      pages: 880,
      place: 'demo-study',
      page: 312,
      startedAgo: 16,
    );
    await add(
      prideId,
      'Pride and Prejudice',
      'Jane Austen',
      status: ReadStatus.finished,
      pages: 432,
      place: 'demo-study',
      rating: 5,
      startedAgo: 70,
      finishedAgo: 58,
      isbn: prideIsbn,
    );
    await add(
      'demo-jane-eyre',
      'Jane Eyre',
      'Charlotte Brontë',
      status: ReadStatus.reading,
      pages: 532,
      place: 'demo-bedroom',
      page: 121,
      startedAgo: 9,
    );
    await add(
      'demo-frankenstein',
      'Frankenstein',
      'Mary Shelley',
      status: ReadStatus.finished,
      pages: 280,
      place: 'demo-living',
      rating: 4,
      startedAgo: 120,
      finishedAgo: 105,
      genre: 'Gothic',
    );
    await add(
      'demo-moby',
      'Moby-Dick',
      'Herman Melville',
      status: ReadStatus.finished,
      pages: 635,
      place: 'demo-living',
      rating: 4,
      startedAgo: 200,
      finishedAgo: 160,
      genre: 'Adventure',
    );
    await add(
      'demo-wuthering',
      'Wuthering Heights',
      'Emily Brontë',
      status: ReadStatus.finished,
      pages: 416,
      place: 'demo-bedroom',
      rating: 5,
      startedAgo: 240,
      finishedAgo: 225,
    );
    await add(
      'demo-great',
      'Great Expectations',
      'Charles Dickens',
      status: ReadStatus.finished,
      pages: 544,
      place: 'demo-living',
      rating: 4,
      startedAgo: 300,
      finishedAgo: 270,
    );
    await add(
      'demo-dorian',
      'The Picture of Dorian Gray',
      'Oscar Wilde',
      status: ReadStatus.want,
      pages: 254,
      place: 'demo-box',
      genre: 'Gothic',
    );
    await add(
      'demo-alice',
      'Alice’s Adventures in Wonderland',
      'Lewis Carroll',
      status: ReadStatus.want,
      pages: 200,
      place: 'demo-box',
      genre: 'Fantasy',
    );
    await add(
      'demo-dracula',
      'Dracula',
      'Bram Stoker',
      status: ReadStatus.finished,
      pages: 418,
      rating: 4,
      startedAgo: 330,
      finishedAgo: 310,
      genre: 'Gothic',
    );
    await add(
      'demo-emma',
      'Emma',
      'Jane Austen',
      status: ReadStatus.want,
      pages: 474,
      place: 'demo-study',
    );
    await add(
      'demo-little-women',
      'Little Women',
      'Louisa May Alcott',
      status: ReadStatus.want,
      pages: 759,
      ownership: Ownership.wishlist,
    );
    await add(
      'demo-monte-cristo',
      'The Count of Monte Cristo',
      'Alexandre Dumas',
      status: ReadStatus.want,
      pages: 1276,
      ownership: Ownership.wishlist,
      genre: 'Adventure',
    );

    // Loans: Frankenstein is out, due soon; Dracula is a few days overdue.
    Future<void> lend(
      String book,
      String who,
      int startedAgo,
      int dueIn,
    ) async {
      await loans.startLoan(
        Loan.create(
          id: uuidV7(),
          bookId: book,
          direction: LoanDirection.lent,
          personName: who,
          startedOn: ago(startedAgo),
          dueOn: DateTime(today.year, today.month, today.day + dueIn),
          now: now,
        ),
      );
    }

    await lend('demo-frankenstein', 'Priya Sharma', 12, 2);
    await lend('demo-dracula', 'Rahul Verma', 24, -4);

    // A reading streak running into today.
    var logId = 0;
    for (var d = 0; d < 12; d++) {
      final from = 300 - d * 22;
      await readings.upsert(
        ReadingLog.create(
          id: 'demo-log-${logId++}',
          bookId: middlemarchId,
          date: ago(d),
          fromPage: from - 22,
          toPage: from,
          now: now,
        ),
      );
    }
    for (var d = 0; d < 5; d++) {
      await readings.upsert(
        ReadingLog.create(
          id: 'demo-log-${logId++}',
          bookId: 'demo-jane-eyre',
          date: ago(d),
          fromPage: 120 - d * 20 - 20,
          toPage: 120 - d * 20,
          now: now,
        ),
      );
    }

    // Quotes: all in the public domain.
    var q = 0;
    Future<void> quote(
      String book,
      String body,
      int page, {
      bool fav = false,
    }) => quotes.upsert(
      Quote.create(
        id: 'demo-quote-${q++}',
        bookId: book,
        body: body,
        page: page,
        isFavourite: fav,
        now: now.subtract(Duration(minutes: q)),
      ),
    );
    await quote(
      prideId,
      'It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife.',
      3,
      fav: true,
    );
    await quote(
      'demo-jane-eyre',
      'I am no bird; and no net ensnares me: I am a free human being with an independent will.',
      253,
      fav: true,
    );
    await quote(
      'demo-moby',
      'It is not down in any map; true places never are.',
      98,
    );
    await quote(
      'demo-wuthering',
      'Whatever our souls are made of, his and mine are the same.',
      73,
    );
    await quote(
      middlemarchId,
      'Every limit is a beginning as well as an ending.',
      822,
    );

    // A goal about on pace, and a few tags.
    await goals.setTarget(today.year, 24);
    for (final (book, name) in <(String, String)>[
      (prideId, 'Favourites'),
      ('demo-jane-eyre', 'Favourites'),
      ('demo-frankenstein', 'To lend'),
      ('demo-wuthering', 'Favourites'),
    ]) {
      final tag = (await tags.createIfAbsent(name)).getOrNull();
      if (tag != null) await tags.attach(book, tag.id);
    }
    return n;
  }
}
