import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kitabkhana/core/clock.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/rate_limiter.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/data/open_library/open_library_client.dart';

import '../../helpers/fixtures.dart';

typedef Handler = FutureOr<http.Response> Function(http.Request request);

void main() {
  late FakeClock clock;
  late List<Uri> requests;
  late List<Map<String, String>> headersSeen;
  late List<Duration> delays;
  late Handler handler;

  final isbn = parseIsbn('9780143127550')!;

  http.Response json(String body, [int status = 200]) => http.Response(
    body,
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  /// A handler routing by path; unknown paths are 404.
  Handler routes(Map<String, http.Response Function()> table) => (req) {
    final make = table[req.url.path];
    return make == null ? json('{"error":"notfound"}', 404) : make();
  };

  OpenLibraryClient makeClient({
    String? userAgent = 'Kitabkhana/1.0.0',
    RateLimiter? limiter,
    int maxAuthors = 3,
    Future<bool> Function()? isOnline,
  }) {
    return OpenLibraryClient(
      client: MockClient((req) async {
        requests.add(req.url);
        headersSeen.add(req.headers);
        return handler(req);
      }),
      limiter:
          limiter ??
          RateLimiter(
            rate: 1000,
            burst: 1000,
            clock: clock,
            delay: (d) async => clock.advance(d),
          ),
      clock: clock,
      userAgent: userAgent,
      maxAuthors: maxAuthors,
      isOnline: isOnline,
      delay: (d) async {
        delays.add(d);
        clock.advance(d);
      },
      random: _FixedRandom(),
    );
  }

  setUp(() {
    clock = FakeClock(DateTime(2025, 3, 10, 9));
    requests = <Uri>[];
    headersSeen = <Map<String, String>>[];
    delays = <Duration>[];
    handler = routes({
      '/isbn/9780143127550.json': () =>
          json(fixtureText('edition_9780143127550.json')),
      '/works/OL17295077W.json': () =>
          json(fixtureText('work_OL17295077W.json')),
      '/authors/OL3429067A.json': () => json(fixtureText('author_sample.json')),
    });
  });

  group('lookupIsbn', () {
    test('edition -> work -> author, with real recorded data', () async {
      final r = await makeClient().lookupIsbn(isbn);
      final info = r.getOrNull()!;
      expect(info.title, 'Everything I Never Told You');
      expect(info.authors, ['Celeste Ng']);
      expect(info.pages, 297);
      expect(info.isbn13, isbn);
      expect(info.olWorkKey, '/works/OL17295077W');
      expect(
        info.coverUrl,
        'https://covers.openlibrary.org/b/id/12178284-L.jpg',
      );
      expect(info.year, 2015);
      expect(info.isComplete, isTrue);
      expect(requests.map((u) => u.path), [
        '/isbn/9780143127550.json',
        '/works/OL17295077W.json',
        '/authors/OL3429067A.json',
      ]);
    });

    test(
      'sends Accept and User-Agent; omits User-Agent when null (web)',
      () async {
        await makeClient().lookupIsbn(isbn);
        expect(headersSeen.first['Accept'], 'application/json');
        expect(headersSeen.first['User-Agent'], 'Kitabkhana/1.0.0');

        headersSeen.clear();
        await makeClient(userAgent: null).lookupIsbn(isbn);
        expect(headersSeen.first.containsKey('User-Agent'), isFalse);
      },
    );

    test('skips the work call when the edition lists authors', () async {
      final edition = fixtureJson('edition_9780143127550.json')
        ..['authors'] = [
          {'key': '/authors/OL3429067A'},
        ];
      handler = routes({
        '/isbn/9780143127550.json': () => json(jsonEncode(edition)),
        '/authors/OL3429067A.json': () =>
            json(fixtureText('author_sample.json')),
      });
      final info = (await makeClient().lookupIsbn(isbn)).getOrNull()!;
      expect(info.authors, ['Celeste Ng']);
      expect(requests.map((u) => u.path), [
        '/isbn/9780143127550.json',
        '/authors/OL3429067A.json',
      ]);
    });

    test('a sparse edition still maps (subtitle, pages, year)', () async {
      handler = routes({
        '/isbn/9780143127550.json': () =>
            json(fixtureText('edition_sparse.json')),
        '/works/OL46176385W.json': () => json('{"title":"ASTRAL"}'),
      });
      final info = (await makeClient().lookupIsbn(isbn)).getOrNull()!;
      expect(info.title, 'ASTRAL');
      expect(info.subtitle, "L'arte di uscire fuori dal corpo");
      expect(info.pages, 289);
      expect(info.year, 2026);
      expect(info.coverUrl, isNull);
      expect(info.authors, isEmpty);
      expect(info.isComplete, isTrue);
    });

    test('at most three authors are resolved', () async {
      final edition = fixtureJson('edition_9780143127550.json')
        ..['authors'] = [
          for (var i = 1; i <= 5; i++) {'key': '/authors/OL${i}A'},
        ];
      handler = (req) => req.url.path.startsWith('/isbn/')
          ? json(jsonEncode(edition))
          : json('{"name":"Author ${req.url.path}"}');
      final info = (await makeClient().lookupIsbn(isbn)).getOrNull()!;
      expect(info.authors, hasLength(3));
      expect(
        requests.where((u) => u.path.startsWith('/authors/')),
        hasLength(3),
      );
    });

    test('404 is NotFound and does not trip the breaker', () async {
      handler = (_) => json('{"error":"notfound"}', 404);
      final client = makeClient();
      for (var i = 0; i < 8; i++) {
        expect(
          (await client.lookupIsbn(isbn)).failureOrNull(),
          isA<NotFoundFailure>(),
        );
      }
      expect(client.isBreakerOpen, isFalse);
      expect(requests, hasLength(8));
    });

    test('an edition without a title is NotFound', () async {
      handler = (_) => json('{"works":[{"key":"/works/X"}]}');
      expect(
        (await makeClient().lookupIsbn(isbn)).failureOrNull(),
        isA<NotFoundFailure>(),
      );
    });

    test('secondary failures return the book marked incomplete', () async {
      handler = routes({
        '/isbn/9780143127550.json': () =>
            json(fixtureText('edition_9780143127550.json')),
        '/works/OL17295077W.json': () => json('oops', 500),
      });
      final info = (await makeClient().lookupIsbn(isbn)).getOrNull()!;
      expect(info.title, 'Everything I Never Told You');
      expect(info.authors, isEmpty);
      expect(info.isComplete, isFalse);

      handler = routes({
        '/isbn/9780143127550.json': () =>
            json(fixtureText('edition_9780143127550.json')),
        '/works/OL17295077W.json': () =>
            json(fixtureText('work_OL17295077W.json')),
      });
      final partial = (await makeClient().lookupIsbn(isbn)).getOrNull()!;
      expect(partial.isComplete, isFalse); // author 404
      expect(partial.authors, isEmpty);
    });
  });

  group('retries and backoff', () {
    test('500 then success retries once with ~500ms backoff', () async {
      var n = 0;
      handler = (req) {
        if (req.url.path.startsWith('/isbn/')) {
          return ++n == 1
              ? json('boom', 500)
              : json(fixtureText('edition_9780143127550.json'));
        }
        return routes({
          '/works/OL17295077W.json': () =>
              json(fixtureText('work_OL17295077W.json')),
          '/authors/OL3429067A.json': () =>
              json(fixtureText('author_sample.json')),
        })(req);
      };
      final r = await makeClient().lookupIsbn(isbn);
      expect(r.isOk, isTrue);
      expect(requests.where((u) => u.path.startsWith('/isbn/')), hasLength(2));
      expect(delays, hasLength(1));
      expect(delays.single.inMilliseconds, inInclusiveRange(500, 750));
    });

    test(
      'persistent 5xx gives up after 3 attempts with exponential backoff',
      () async {
        handler = (_) => json('boom', 503);
        final r = await makeClient().lookupIsbn(isbn);
        expect(r.failureOrNull(), const NetworkFailure.server(503));
        expect(requests, hasLength(3));
        expect(delays, hasLength(2));
        expect(delays[0].inMilliseconds, inInclusiveRange(500, 750));
        expect(delays[1].inMilliseconds, inInclusiveRange(1000, 1250));
      },
    );

    test('timeouts are retried and reported as timeout', () async {
      handler = (_) => throw TimeoutException('slow');
      final r = await makeClient().lookupIsbn(isbn);
      expect(r.failureOrNull(), const NetworkFailure.timeout());
      expect(requests, hasLength(3));
    });

    test('a timeout followed by success recovers', () async {
      var n = 0;
      handler = (req) {
        if (req.url.path.startsWith('/isbn/') && ++n == 1) {
          throw TimeoutException('slow');
        }
        return routes({
          '/isbn/9780143127550.json': () =>
              json(fixtureText('edition_9780143127550.json')),
          '/works/OL17295077W.json': () =>
              json(fixtureText('work_OL17295077W.json')),
          '/authors/OL3429067A.json': () =>
              json(fixtureText('author_sample.json')),
        })(req);
      };
      expect((await makeClient().lookupIsbn(isbn)).isOk, isTrue);
    });

    test('4xx is never retried', () async {
      for (final status in <int>[400, 401, 403, 410]) {
        requests.clear();
        handler = (_) => json('no', status);
        final r = await makeClient().lookupIsbn(isbn);
        expect(r.failureOrNull(), NetworkFailure.server(status));
        expect(requests, hasLength(1), reason: '$status');
      }
      expect(delays, isEmpty);
    });
  });

  group('rate limiting (429)', () {
    test('returns rateLimited, does not retry, then cools down', () async {
      var hits = 0;
      handler = (_) {
        hits++;
        return http.Response('slow down', 429, headers: {'retry-after': '20'});
      };
      final client = makeClient();
      expect(
        (await client.lookupIsbn(isbn)).failureOrNull(),
        const NetworkFailure.rateLimited(),
      );
      expect(hits, 1);

      // Within the cool-down nothing is sent.
      clock.advance(const Duration(seconds: 10));
      expect(
        (await client.lookupIsbn(isbn)).failureOrNull(),
        const NetworkFailure.rateLimited(),
      );
      expect(hits, 1);

      // After Retry-After it tries again.
      clock.advance(const Duration(seconds: 11));
      await client.lookupIsbn(isbn);
      expect(hits, 2);
    });

    test('defaults to a 30s cool-down without Retry-After', () async {
      var hits = 0;
      handler = (_) {
        hits++;
        return json('x', 429);
      };
      final client = makeClient();
      await client.lookupIsbn(isbn);
      clock.advance(const Duration(seconds: 29));
      await client.lookupIsbn(isbn);
      expect(hits, 1);
      clock.advance(const Duration(seconds: 2));
      await client.lookupIsbn(isbn);
      expect(hits, 2);
    });

    test('429 does not count towards the circuit breaker', () async {
      handler = (_) => http.Response('x', 429, headers: {'retry-after': '1'});
      final client = makeClient();
      for (var i = 0; i < 10; i++) {
        await client.lookupIsbn(isbn);
        clock.advance(const Duration(seconds: 2));
      }
      expect(client.isBreakerOpen, isFalse);
    });
  });

  group('offline', () {
    test('a connection error is offline immediately, no retries', () async {
      handler = (_) => throw http.ClientException('Failed host lookup');
      final r = await makeClient().lookupIsbn(isbn);
      expect(r.failureOrNull(), const NetworkFailure.offline());
      expect(requests, hasLength(1));
      expect(delays, isEmpty);
    });

    test('a known-offline device never sends a request', () async {
      final r = await makeClient(isOnline: () async => false).lookupIsbn(isbn);
      expect(r.failureOrNull(), const NetworkFailure.offline());
      expect(requests, isEmpty);
    });
  });

  group('circuit breaker', () {
    test(
      'opens after 5 consecutive failures and short-circuits for 30 seconds',
      () async {
        handler = (_) => throw http.ClientException('down');
        final client = makeClient();
        for (var i = 0; i < 5; i++) {
          await client.lookupIsbn(isbn);
        }
        expect(client.isBreakerOpen, isTrue);
        expect(requests, hasLength(5));

        final r = await client.lookupIsbn(isbn);
        expect(r.failureOrNull(), const NetworkFailure.offline());
        expect(requests, hasLength(5)); // no call made

        clock.advance(const Duration(seconds: 29));
        await client.lookupIsbn(isbn);
        expect(requests, hasLength(5));
      },
    );

    test(
      'while open it reports the last real failure, not "offline"',
      () async {
        // A slow network is not an offline one: a run of timeouts must not turn
        // into "you appear to be offline" once the breaker opens.
        handler = (_) => throw TimeoutException('slow');
        final client = makeClient();
        for (var i = 0; i < 5; i++) {
          await client.lookupIsbn(isbn);
        }
        expect(client.isBreakerOpen, isTrue);
        final before = requests.length;
        final r = await client.lookupIsbn(isbn);
        expect(r.failureOrNull(), const NetworkFailure.timeout());
        expect(requests, hasLength(before)); // short-circuited
      },
    );

    test('half-opens after the cool-down; success closes it', () async {
      var up = false;
      handler = (req) {
        if (!up) throw http.ClientException('down');
        return routes({
          '/isbn/9780143127550.json': () =>
              json(fixtureText('edition_9780143127550.json')),
          '/works/OL17295077W.json': () =>
              json(fixtureText('work_OL17295077W.json')),
          '/authors/OL3429067A.json': () =>
              json(fixtureText('author_sample.json')),
        })(req);
      };
      final client = makeClient();
      for (var i = 0; i < 5; i++) {
        await client.lookupIsbn(isbn);
      }
      expect(client.isBreakerOpen, isTrue);

      up = true;
      clock.advance(const Duration(seconds: 31));
      expect(client.isBreakerOpen, isFalse);
      expect((await client.lookupIsbn(isbn)).isOk, isTrue);
      expect(client.isBreakerOpen, isFalse);
      // Failures start counting from zero again.
      up = false;
      for (var i = 0; i < 4; i++) {
        await client.lookupIsbn(isbn);
      }
      expect(client.isBreakerOpen, isFalse);
    });

    test('a failed trial call reopens it straight away', () async {
      handler = (_) => throw http.ClientException('down');
      final client = makeClient();
      for (var i = 0; i < 5; i++) {
        await client.lookupIsbn(isbn);
      }
      clock.advance(const Duration(seconds: 31));
      await client.lookupIsbn(isbn); // trial
      expect(client.isBreakerOpen, isTrue);
    });

    test('a success in between resets the count', () async {
      var fail = true;
      handler = (req) {
        if (fail) throw http.ClientException('down');
        return json('{"title":"X"}');
      };
      final client = makeClient();
      for (var i = 0; i < 4; i++) {
        await client.lookupIsbn(isbn);
      }
      fail = false;
      await client.lookupIsbn(isbn);
      fail = true;
      for (var i = 0; i < 4; i++) {
        await client.lookupIsbn(isbn);
      }
      expect(client.isBreakerOpen, isFalse);
    });
  });

  group('malformed responses', () {
    test('invalid JSON is a server failure, not retried', () async {
      handler = (_) => json('<html>oops');
      final r = await makeClient().lookupIsbn(isbn);
      expect(r.failureOrNull(), const NetworkFailure.server(200));
      expect(requests, hasLength(1));
    });

    test('unexpected shape (array) is a server failure', () async {
      handler = (_) => json('[1,2,3]');
      expect(
        (await makeClient().lookupIsbn(isbn)).failureOrNull(),
        const NetworkFailure.server(200),
      );
    });

    test('repeated garbage trips the breaker', () async {
      handler = (_) => json('nope');
      final client = makeClient();
      for (var i = 0; i < 5; i++) {
        await client.lookupIsbn(isbn);
      }
      expect(client.isBreakerOpen, isTrue);
    });
  });

  group('searchTitle', () {
    test('maps recorded results and builds the query', () async {
      handler = routes({
        '/search.json': () =>
            json(fixtureText('search_god_of_small_things.json')),
      });
      final r = await makeClient().searchTitle(
        'god of small things',
        author: 'Roy',
        limit: 3,
      );
      final list = r.getOrNull()!;
      expect(list, hasLength(3));
      final first = list.first;
      expect(first.title, 'The God of Small Things');
      expect(first.authors, ['Arundhati Roy']);
      expect(first.pages, 357);
      expect(first.year, 1997);
      expect(first.olWorkKey, '/works/OL1052133W');
      expect(
        first.coverUrl,
        'https://covers.openlibrary.org/b/id/10513792-M.jpg',
      );
      expect(first.isbn13, isNotNull);

      final q = requests.single.queryParameters;
      expect(q['title'], 'god of small things');
      expect(q['author'], 'Roy');
      expect(q['limit'], '3');
      expect(q['fields'], contains('number_of_pages_median'));
    });

    test('omits a blank author', () async {
      handler = routes({'/search.json': () => json('{"docs":[]}')});
      final r = await makeClient().searchTitle('x', author: '  ');
      expect(r.getOrNull(), isEmpty);
      expect(requests.single.queryParameters.containsKey('author'), isFalse);
    });

    test('failures propagate', () async {
      handler = (_) => throw http.ClientException('down');
      expect(
        (await makeClient().searchTitle('x')).failureOrNull(),
        const NetworkFailure.offline(),
      );
    });
  });

  group('shared rate limiter', () {
    test('spaces requests at 1/s after a burst of 3', () async {
      final waits = <Duration>[];
      final limiter = RateLimiter(
        rate: 1,
        burst: 3,
        clock: clock,
        delay: (d) async {
          waits.add(d);
          clock.advance(d);
        },
      );
      handler = routes({'/search.json': () => json('{"docs":[]}')});
      final client = makeClient(limiter: limiter);
      for (var i = 0; i < 5; i++) {
        await client.searchTitle('x');
      }
      expect(waits, hasLength(2));
      expect(waits.every((w) => w == const Duration(seconds: 1)), isTrue);
    });
  });
}

class _FixedRandom implements Random {
  @override
  int nextInt(int max) => max ~/ 2;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0.5;
}
