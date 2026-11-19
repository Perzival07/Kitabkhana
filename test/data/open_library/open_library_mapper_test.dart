import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/data/open_library/open_library_mapper.dart';

void main() {
  final isbn = parseIsbn('9780143127550')!;
  const m = OpenLibraryMapper.edition;

  group('yearFrom', () {
    test('finds a 4-digit year in common date shapes', () {
      expect(OpenLibraryMapper.yearFrom('2015'), 2015);
      expect(OpenLibraryMapper.yearFrom('March 3, 1999'), 1999);
      expect(OpenLibraryMapper.yearFrom('20 Luglio 2026'), 2026);
      expect(OpenLibraryMapper.yearFrom('c1987'), 1987);
      expect(OpenLibraryMapper.yearFrom('1850-1860'), 1850);
    });

    test('ignores non-years', () {
      expect(OpenLibraryMapper.yearFrom(null), isNull);
      expect(OpenLibraryMapper.yearFrom(''), isNull);
      expect(OpenLibraryMapper.yearFrom('12345'), isNull);
      expect(OpenLibraryMapper.yearFrom('3000'), isNull);
      expect(OpenLibraryMapper.yearFrom(2015), isNull);
    });
  });

  group('coverUrlForId', () {
    test('builds large and medium URLs', () {
      expect(
        OpenLibraryMapper.coverUrlForId(123),
        'https://covers.openlibrary.org/b/id/123-L.jpg',
      );
      expect(
        OpenLibraryMapper.coverUrlForId('456', size: 'M'),
        'https://covers.openlibrary.org/b/id/456-M.jpg',
      );
    });

    test('treats missing and placeholder ids as no cover', () {
      for (final bad in <Object?>[null, -1, 0, 'x', '', <int>[]]) {
        expect(OpenLibraryMapper.coverUrlForId(bad), isNull, reason: '$bad');
      }
    });
  });

  group('edition', () {
    test('trims titles and tolerates odd types', () {
      final info = m({
        'title': '  Dune  ',
        'subtitle': '   ',
        'number_of_pages': '412',
        'publish_date': 1965,
        'works': [
          {'key': '/works/W1'},
        ],
      }, isbn: isbn)!;
      expect(info.title, 'Dune');
      expect(info.subtitle, isNull);
      expect(info.pages, 412);
      expect(info.year, isNull);
      expect(info.olWorkKey, '/works/W1');
      expect(info.isbn13, isbn);
    });

    test('no usable title means no result', () {
      for (final bad in <Object?>[null, '', '   ', 5, <String>[]]) {
        expect(m({'title': bad}, isbn: isbn), isNull, reason: '$bad');
      }
    });

    test('pages fall back to pagination, ignoring roman numerals', () {
      expect(
        m({'title': 'T', 'pagination': 'xii, 320 p.'}, isbn: isbn)!.pages,
        320,
      );
      expect(m({'title': 'T', 'pagination': '289'}, isbn: isbn)!.pages, 289);
      expect(
        m({'title': 'T', 'pagination': 'many'}, isbn: isbn)!.pages,
        isNull,
      );
      expect(
        m({'title': 'T', 'number_of_pages': 0}, isbn: isbn)!.pages,
        isNull,
      );
      expect(
        m({'title': 'T', 'number_of_pages': -5}, isbn: isbn)!.pages,
        isNull,
      );
      expect(m({'title': 'T', 'number_of_pages': 12.0}, isbn: isbn)!.pages, 12);
    });

    test(
      'cover prefers the edition, falls back to the work, skips bad ids',
      () {
        expect(
          m({
            'title': 'T',
            'covers': [111, 222],
          }, isbn: isbn)!.coverUrl,
          contains('111-L'),
        );
        expect(
          m(
            {
              'title': 'T',
              'covers': [-1],
            },
            isbn: isbn,
            work: {
              'covers': [-1, 333],
            },
          )!.coverUrl,
          contains('333-L'),
        );
        expect(m({'title': 'T', 'covers': 'x'}, isbn: isbn)!.coverUrl, isNull);
      },
    );

    test('year falls back to copyright_date', () {
      expect(
        m({'title': 'T', 'copyright_date': '2001'}, isbn: isbn)!.year,
        2001,
      );
    });

    test('work key tolerates missing or malformed works', () {
      expect(m({'title': 'T'}, isbn: isbn)!.olWorkKey, isNull);
      expect(m({'title': 'T', 'works': []}, isbn: isbn)!.olWorkKey, isNull);
      expect(m({'title': 'T', 'works': 'x'}, isbn: isbn)!.olWorkKey, isNull);
      expect(
        m({
          'title': 'T',
          'works': ['/works/W9'],
        }, isbn: isbn)!.olWorkKey,
        '/works/W9',
      );
    });
  });

  group('author keys and names', () {
    test('edition authors accept maps and bare strings', () {
      expect(
        OpenLibraryMapper.editionAuthorKeys({
          'authors': [
            {'key': '/authors/A1'},
            '/authors/A2',
            {'name': 'no key'},
            5,
          ],
        }),
        ['/authors/A1', '/authors/A2'],
      );
      expect(
        OpenLibraryMapper.editionAuthorKeys({
          'authors': [
            'not-a-key',
            {'key': 'also bad'},
          ],
        }),
        isEmpty,
      );
      expect(OpenLibraryMapper.editionAuthorKeys({}), isEmpty);
      expect(OpenLibraryMapper.editionAuthorKeys({'authors': 'x'}), isEmpty);
    });

    test('work authors read the nested author key', () {
      expect(
        OpenLibraryMapper.workAuthorKeys({
          'authors': [
            {
              'author': {'key': '/authors/A1'},
              'type': {'key': '/type/author_role'},
            },
            {'key': '/authors/A2'},
            {'author': 'bad'},
          ],
        }),
        ['/authors/A1', '/authors/A2'],
      );
    });

    test('authorName prefers name, falls back to personal_name', () {
      expect(
        OpenLibraryMapper.authorName({'name': ' Celeste Ng '}),
        'Celeste Ng',
      );
      expect(OpenLibraryMapper.authorName({'personal_name': 'C. Ng'}), 'C. Ng');
      expect(OpenLibraryMapper.authorName({'name': ''}), isNull);
      expect(OpenLibraryMapper.authorName('x'), isNull);
      expect(OpenLibraryMapper.authorName(null), isNull);
    });
  });

  group('searchResults', () {
    test('skips malformed docs and untitled entries', () {
      final list = OpenLibraryMapper.searchResults({
        'docs': [
          {
            'title': 'Good',
            'author_name': ['A', 7, ' '],
            'isbn': ['bad', '0306406152'],
          },
          {
            'author_name': ['No title'],
          },
          'garbage',
          {'title': '  '},
          {'title': 'Pages', 'number_of_pages_median': 0, 'cover_i': -1},
        ],
      });
      expect(list.map((b) => b.title), ['Good', 'Pages']);
      expect(list.first.authors, ['A']);
      expect(list.first.isbn13!.value, '9780306406157'); // ISBN-10 converted
      expect(list.last.pages, isNull);
      expect(list.last.coverUrl, isNull);
    });

    test('non-object and docs-less payloads give an empty list', () {
      expect(OpenLibraryMapper.searchResults(null), isEmpty);
      expect(OpenLibraryMapper.searchResults([1]), isEmpty);
      expect(OpenLibraryMapper.searchResults({'docs': 'x'}), isEmpty);
      expect(OpenLibraryMapper.searchResults({}), isEmpty);
    });
  });
}
