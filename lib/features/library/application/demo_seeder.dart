import '../../../core/clock.dart';
import '../../../core/text/isbn.dart';
import '../../../core/uuid.dart';
import '../../locations/domain/location.dart';
import '../../locations/domain/location_repository.dart';
import '../domain/book.dart';
import '../domain/book_enums.dart';
import '../domain/book_repository.dart';

/// Dev-only: fills the library with plausible books to test scrolling and
/// search. Deterministic, so runs are comparable.
class DemoSeeder {
  DemoSeeder({
    required this.books,
    required this.locations,
    required this.clock,
  });

  final BookRepository books;
  final LocationRepository locations;
  final Clock clock;

  static const List<String> _first = <String>[
    'Harry Potter and the Philosopher’s Stone',
    'Harry Potter and the Chamber of Secrets',
    'Harry Potter and the Prisoner of Azkaban',
    'The Hobbit',
    'Dune',
    'Pride and Prejudice',
    'The Name of the Wind',
    'Circe',
    'Piranesi',
    'A Gentleman in Moscow',
  ];
  static const List<String> _adj = <String>[
    'Silent',
    'Golden',
    'Hidden',
    'Last',
    'Broken',
    'Distant',
    'Winter',
    'Paper',
    'Crimson',
    'Quiet',
    'Endless',
    'Forgotten',
    'Salt',
    'Glass',
  ];
  static const List<String> _noun = <String>[
    'River',
    'Garden',
    'Library',
    'Harbour',
    'Archive',
    'Orchard',
    'Lantern',
    'Station',
    'Mirror',
    'Compass',
    'Kingdom',
    'Letters',
    'Atlas',
    'Season',
  ];
  static const List<String> _authors = <String>[
    'J. K. Rowling',
    'Ursula K. Le Guin',
    'Haruki Murakami',
    'Zadie Smith',
    'Amor Towles',
    'Madeline Miller',
    'Susanna Clarke',
    'Kazuo Ishiguro',
    'Chimamanda Ngozi Adichie',
    'Arundhati Roy',
    'Italo Calvino',
    'Toni Morrison',
    'Neil Gaiman',
    'Elena Ferrante',
    'Jhumpa Lahiri',
  ];

  /// Adds [count] books (and three shelves to put them on). Returns how many
  /// books were saved.
  Future<int> seed({int count = 300}) async {
    final now = clock.now();
    final shelfIds = <String>[];
    for (final name in const <String>['Living room', 'Bedroom', 'Storage']) {
      final shelf = Location.create(
        id: uuidV7(),
        name: 'Demo · $name',
        now: now,
      );
      final saved = await locations.upsert(shelf);
      if (saved.isOk) shelfIds.add(shelf.id);
    }
    var added = 0;
    for (var i = 0; i < count; i++) {
      final title = i < _first.length
          ? _first[i]
          : 'The ${_adj[i % _adj.length]} ${_noun[(i * 7) % _noun.length]} '
                '${i ~/ (_adj.length * _noun.length) + 1}';
      final status = ReadStatus.values[i % ReadStatus.values.length];
      final pages = 180 + (i * 37) % 520;
      var book = Book.create(
        id: uuidV7(),
        title: title,
        authors: _authors[i % _authors.length],
        now: now.subtract(Duration(minutes: count - i)),
        isbn13: parseIsbn(_isbnFor(i)),
        pages: pages,
        status: status,
        ownership: i % 11 == 0 ? Ownership.wishlist : Ownership.owned,
        locationId: shelfIds.isEmpty ? null : shelfIds[i % shelfIds.length],
      );
      if (status == ReadStatus.reading) {
        book = book.copyWith(currentPage: pages ~/ 3);
      }
      if (status == ReadStatus.finished) {
        book = book.copyWith(currentPage: pages, rating: 3 + i % 3);
      }
      final result = await books.upsert(book);
      if (result.isOk) added++;
    }
    return added;
  }

  /// A valid ISBN-13 derived from [i].
  static String _isbnFor(int i) {
    final body = '978${(1000000000 + i * 7919).toString().substring(0, 9)}';
    var sum = 0;
    for (var d = 0; d < 12; d++) {
      sum += int.parse(body[d]) * (d.isEven ? 1 : 3);
    }
    return '$body${(10 - sum % 10) % 10}';
  }
}
