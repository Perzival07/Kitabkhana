import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';

void main() {
  final info = BookInfo(
    title: 'Everything I Never Told You',
    subtitle: 'A novel',
    authors: const ['Celeste Ng'],
    pages: 297,
    isbn13: parseIsbn('9780143127550'),
    olWorkKey: '/works/OL17295077W',
    coverUrl: 'https://covers.openlibrary.org/b/id/1-L.jpg',
    year: 2015,
  );

  test('JSON round-trips', () {
    expect(BookInfo.fromJson(info.toJson()), info);
  });

  test('fromJson tolerates missing and wrong-typed fields', () {
    final b = BookInfo.fromJson({'title': 'X', 'authors': 'nope', 'isbn13': 5});
    expect(b.title, 'X');
    expect(b.authors, isEmpty);
    expect(b.isbn13, isNull);
    expect(BookInfo.fromJson({}).title, '');
  });

  test('authorsText joins with commas', () {
    expect(const BookInfo(title: 't', authors: ['A', 'B']).authorsText, 'A, B');
    expect(const BookInfo(title: 't').authorsText, '');
  });

  test('equality includes authors and completeness', () {
    expect(info, BookInfo.fromJson(info.toJson()));
    expect(info.copyWith(authors: ['Other']), isNot(info));
    expect(info.copyWith(isComplete: false), isNot(info));
    expect(info.hashCode, BookInfo.fromJson(info.toJson()).hashCode);
  });
}
