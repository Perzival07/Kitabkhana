import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../core/clock.dart';
import '../../core/failure.dart';
import '../../core/rate_limiter.dart';
import '../../core/result.dart';
import '../../core/text/isbn.dart';
import '../../features/library/domain/book_info.dart';
import '../../features/library/domain/book_info_source.dart';
import 'open_library_mapper.dart';

/// Open Library catalogue client.
///
/// ISBN lookup uses `/isbn/{isbn}.json` (the canonical edition record, which
/// carries the work key the ownership matcher needs), then `/works/{key}.json`
/// only when the edition lists no authors, then `/authors/{key}.json` for up
/// to three author names. A failure in those secondary calls still returns the
/// book, marked incomplete. `/api/books?jscmd=data` was rejected because it
/// omits the work key.
///
/// Resilience: shared [RateLimiter]; 15 s timeout per request (a phone on a
/// slow mobile connection, talking to a service on another continent, is not
/// unusual); two retries with exponential backoff and jitter for timeouts and
/// 5xx only; 429 starts a cool-down; five consecutive failures open a circuit
/// breaker for 30 seconds, during which calls answer with the last real
/// failure (so a run of timeouts says "took too long", not "offline").
class OpenLibraryClient implements BookInfoSource {
  OpenLibraryClient({
    required this._client,
    required this._limiter,
    this._clock = const SystemClock(),
    this.userAgent,
    this.baseUrl = 'https://openlibrary.org',
    this.timeout = const Duration(seconds: 15),
    this.maxRetries = 2,
    this.backoffBase = const Duration(milliseconds: 500),
    this.breakerThreshold = 5,
    this.breakerCooldown = const Duration(seconds: 30),
    this.defaultRateLimitCooldown = const Duration(seconds: 30),
    this.maxAuthors = 3,
    this._isOnline,
    Future<void> Function(Duration)? delay,
    Random? random,
  }) : _delay = delay ?? Future<void>.delayed,
       _random = random ?? Random();

  final http.Client _client;
  final RateLimiter _limiter;
  final Clock _clock;
  final Future<bool> Function()? _isOnline;
  final Future<void> Function(Duration) _delay;
  final Random _random;

  /// Sent as `User-Agent` when non-null (browsers forbid setting it).
  final String? userAgent;
  final String baseUrl;
  final Duration timeout;
  final int maxRetries;
  final Duration backoffBase;
  final int breakerThreshold;
  final Duration breakerCooldown;
  final Duration defaultRateLimitCooldown;
  final int maxAuthors;

  int _consecutiveFailures = 0;
  DateTime? _breakerOpenUntil;
  DateTime? _rateLimitedUntil;
  Failure? _lastFailure;

  /// True while the breaker is short-circuiting calls.
  bool get isBreakerOpen {
    final until = _breakerOpenUntil;
    return until != null && _clock.now().isBefore(until);
  }

  @override
  Future<Result<BookInfo>> lookupIsbn(Isbn13 isbn) async {
    final editionResult = await _getJson('/isbn/${isbn.value}.json');
    if (editionResult is Err<Object?>) {
      return Err<BookInfo>(editionResult.failure);
    }
    final edition = OpenLibraryMapper.asMap(editionResult.getOrNull());
    if (edition == null) {
      return const Err<BookInfo>(NetworkFailure.server(200));
    }

    var complete = true;
    Map<String, Object?>? work;
    var authorKeys = OpenLibraryMapper.editionAuthorKeys(edition);
    final workKey = OpenLibraryMapper.workKey(edition);
    if (authorKeys.isEmpty && workKey != null) {
      final workResult = await _getJson('$workKey.json');
      if (workResult is Ok<Object?>) {
        work = OpenLibraryMapper.asMap(workResult.value);
        if (work != null) authorKeys = OpenLibraryMapper.workAuthorKeys(work);
      } else {
        complete = false;
      }
    }

    // Authors are independent of each other: fetch them together rather than
    // one round trip after another (each trip can take seconds on a phone).
    final authorResults = await Future.wait(<Future<Result<Object?>>>[
      for (final key in authorKeys.take(maxAuthors)) _getJson('$key.json'),
    ]);
    final names = <String>[];
    for (final r in authorResults) {
      final name = r is Ok<Object?>
          ? OpenLibraryMapper.authorName(r.value)
          : null;
      if (name != null) {
        names.add(name);
      } else {
        complete = false;
      }
    }

    final info = OpenLibraryMapper.edition(
      edition,
      isbn: isbn,
      work: work,
      authors: names,
      complete: complete,
    );
    if (info == null) return const Err<BookInfo>(NotFoundFailure('book'));
    return Ok<BookInfo>(info);
  }

  @override
  Future<Result<List<BookInfo>>> searchTitle(
    String title, {
    String? author,
    int limit = 10,
  }) async {
    final query = <String, String>{
      'title': title.trim(),
      if (author != null && author.trim().isNotEmpty) 'author': author.trim(),
      'limit': '$limit',
      'fields':
          'key,title,author_name,isbn,cover_i,'
          'number_of_pages_median,first_publish_year',
    };
    final r = await _getJson('/search.json', query: query);
    return r.map(OpenLibraryMapper.searchResults);
  }

  /// GETs [path] and decodes JSON, applying the resilience policy.
  Future<Result<Object?>> _getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final now = _clock.now();
    final open = _breakerOpenUntil;
    if (open != null && now.isBefore(open)) {
      return Err<Object?>(_lastFailure ?? const NetworkFailure.offline());
    }
    final cooldown = _rateLimitedUntil;
    if (cooldown != null && now.isBefore(cooldown)) {
      return const Err<Object?>(NetworkFailure.rateLimited());
    }
    final online = _isOnline;
    if (online != null && !await online()) {
      return const Err<Object?>(NetworkFailure.offline());
    }

    final uri = Uri.parse(baseUrl).replace(path: path, queryParameters: query);
    final headers = <String, String>{
      'Accept': 'application/json',
      'User-Agent': ?userAgent,
    };

    Failure? last;
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      await _limiter.acquire();
      try {
        final response = await _client
            .get(uri, headers: headers)
            .timeout(timeout);
        final status = response.statusCode;
        if (status == 200) {
          try {
            final json = jsonDecode(utf8.decode(response.bodyBytes));
            _recordSuccess();
            return Ok<Object?>(json);
          } on FormatException {
            return _recordFailure(const NetworkFailure.server(200));
          }
        }
        if (status == 404) {
          _recordSuccess(); // the service is up; the book just is not there
          return const Err<Object?>(NotFoundFailure('book'));
        }
        if (status == 429) {
          final wait = _retryAfter(response) ?? defaultRateLimitCooldown;
          _rateLimitedUntil = _clock.now().add(wait);
          return const Err<Object?>(NetworkFailure.rateLimited());
        }
        if (status >= 500) {
          last = NetworkFailure.server(status);
          if (attempt < maxRetries) await _backoff(attempt);
          continue;
        }
        // Other 4xx: our request is wrong; retrying cannot help.
        return Err<Object?>(NetworkFailure.server(status));
      } on TimeoutException {
        last = const NetworkFailure.timeout();
        if (attempt < maxRetries) await _backoff(attempt);
      } on http.ClientException {
        // DNS failure, unreachable network, browser XHR error: offline.
        return _recordFailure(const NetworkFailure.offline());
      }
    }
    return _recordFailure(last ?? const NetworkFailure.timeout());
  }

  Duration? _retryAfter(http.Response r) {
    final header = r.headers['retry-after'];
    final seconds = header == null ? null : int.tryParse(header.trim());
    if (seconds == null || seconds <= 0) return null;
    return Duration(seconds: seconds.clamp(1, 300));
  }

  Future<void> _backoff(int attempt) {
    final exp = backoffBase * (1 << attempt);
    final jitter = Duration(
      milliseconds: _random.nextInt(backoffBase.inMilliseconds ~/ 2 + 1),
    );
    return _delay(exp + jitter);
  }

  void _recordSuccess() {
    _consecutiveFailures = 0;
    _breakerOpenUntil = null;
  }

  Err<Object?> _recordFailure(Failure failure) {
    _lastFailure = failure;
    _consecutiveFailures++;
    if (_consecutiveFailures >= breakerThreshold) {
      _breakerOpenUntil = _clock.now().add(breakerCooldown);
    }
    return Err<Object?>(failure);
  }
}
