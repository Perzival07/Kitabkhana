import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kitabkhana/core/clock.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/rate_limiter.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/data/google_books/google_books_client.dart';
import 'package:kitabkhana/features/library/application/fallback_book_info_source.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';

import '../../helpers/fake_book_info_source.dart';

final Map<String, Object?> _volume = <String, Object?>{
  'items': <Object?>[
    <String, Object?>{
      'volumeInfo': <String, Object?>{
        'title': 'Godaan',
        'subtitle': '',
        'authors': <Object?>['Premchand'],
        'pageCount': 344,
        'publishedDate': '1936-01-01',
        'industryIdentifiers': <Object?>[
          <String, Object?>{'type': 'ISBN_10', 'identifier': '8126704078'},
          <String, Object?>{'type': 'ISBN_13', 'identifier': '9788126704071'},
        ],
        'imageLinks': <String, Object?>{
          'thumbnail': 'http://books.google.com/books/content?id=x&zoom=1',
        },
      },
    },
    <String, Object?>{
      'volumeInfo': <String, Object?>{'title': ''},
    },
  ],
};

void main() {
  late List<http.Request> sent;

  GoogleBooksClient client(
    FutureOr<http.Response> Function(http.Request) answer, {
    String key = '',
    Map<String, String> headers = const <String, String>{},
  }) => GoogleBooksClient(
    client: MockClient((r) async {
      sent.add(r);
      return answer(r);
    }),
    limiter: RateLimiter(rate: 100, burst: 100, clock: const SystemClock()),
    apiKey: key,
    appHeaders: headers,
  );

  http.Response json(Object body, [int status = 200]) =>
      http.Response.bytes(utf8.encode(jsonEncode(body)), status);

  setUp(() => sent = <http.Request>[]);

  test('looks an ISBN up and maps the first volume', () async {
    final r = await client((_) => json(_volume))
        .lookupIsbn(parseIsbn('9788126704071')!);
    final info = (r as Ok<BookInfo>).value;
    expect(info.title, 'Godaan');
    expect(info.subtitle, isNull);
    expect(info.authors, <String>['Premchand']);
    expect(info.pages, 344);
    expect(info.year, 1936);
    expect(info.isbn13!.value, '9788126704071');
    expect(info.coverUrl, startsWith('https://books.google.com/'));
    final q = sent.single.url.queryParameters;
    expect(sent.single.url.host, 'www.googleapis.com');
    expect(q['q'], 'isbn:9788126704071');
    expect(q.containsKey('key'), isFalse);
  });

  test('sends only the ISBN, the key and the app headers', () async {
    await client(
      (_) => json(_volume),
      key: 'abc',
      headers: <String, String>{
        'X-Android-Package': 'com.kitabkhana.kitabkhana',
      },
    ).lookupIsbn(parseIsbn('9788126704071')!);
    final r = sent.single;
    expect(r.url.queryParameters['key'], 'abc');
    expect(r.headers['X-Android-Package'], 'com.kitabkhana.kitabkhana');
  });

  test('no items is "not found"', () async {
    final r = await client((_) => json(<String, Object?>{'totalItems': 0}))
        .lookupIsbn(parseIsbn('9788126704071')!);
    expect((r as Err<BookInfo>).failure, isA<NotFoundFailure>());
  });

  test('title search passes title and author, skips untitled items', () async {
    final r = await client((_) => json(_volume))
        .searchTitle('Godaan', author: 'Premchand');
    expect((r as Ok<List<BookInfo>>).value, hasLength(1));
    expect(
      sent.single.url.queryParameters['q'],
      'intitle:Godaan inauthor:Premchand',
    );
  });

  test('errors map to failures', () async {
    expect(
      ((await client(
        (_) => json(<String, Object?>{}, 429),
      ).searchTitle('x')) as Err).failure,
      isA<NetworkFailure>(),
    );
    expect(
      ((await client(
        (_) => throw http.ClientException('down'),
      ).searchTitle('x')) as Err).failure,
      const NetworkFailure.offline(),
    );
    expect(
      ((await client(
        (_) => http.Response('not json', 200),
      ).searchTitle('x')) as Err).failure,
      isA<NetworkFailure>(),
    );
  });

  group('FallbackBookInfoSource', () {
    late FakeSource primary;
    late FakeSource fallback;
    late FallbackBookInfoSource source;
    const found = BookInfo(title: 'Found');

    setUp(() {
      primary = FakeSource();
      fallback = FakeSource();
      source = FallbackBookInfoSource(primary: primary, fallback: fallback);
    });

    test('Open Library answers: Google is never asked', () async {
      primary.onIsbn = () => const Ok<BookInfo>(found);
      expect(
        await source.lookupIsbn(parseIsbn('9788126704071')!),
        isA<Ok<BookInfo>>(),
      );
      expect(fallback.isbnCalls, 0);
    });

    test('not on Open Library: Google answers', () async {
      fallback.onIsbn = () => const Ok<BookInfo>(found);
      final r = await source.lookupIsbn(parseIsbn('9788126704071')!);
      expect((r as Ok<BookInfo>).value.title, 'Found');
      expect(primary.isbnCalls, 1);
    });

    test('neither knows it: the primary failure stands', () async {
      fallback.onIsbn = () => const Err<BookInfo>(NetworkFailure.offline());
      final r = await source.lookupIsbn(parseIsbn('9788126704071')!);
      expect((r as Err<BookInfo>).failure, isA<NotFoundFailure>());
    });

    test('an empty search asks Google; a full one does not', () async {
      fallback.onSearch = () => const Ok<List<BookInfo>>(<BookInfo>[found]);
      expect(
        ((await source.searchTitle('x')) as Ok<List<BookInfo>>).value,
        hasLength(1),
      );
      expect(fallback.searchCalls, 1);
      primary.onSearch = () =>
          const Ok<List<BookInfo>>(<BookInfo>[found, found]);
      expect(
        ((await source.searchTitle('y')) as Ok<List<BookInfo>>).value,
        hasLength(2),
      );
      expect(fallback.searchCalls, 1);
    });
  });
}
