import 'dart:convert';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../core/text/isbn.dart';
import '../domain/book_info.dart';
import '../domain/book_info_source.dart';

/// Looks books up with a cache in front of the network: cache first, then the
/// network, then store the answer.
///
/// Successful lookups are cached for 30 days and "not found" for 7. An expired
/// success is still returned when the network is unavailable, so a book you
/// looked up once keeps working offline.
class BookLookupService {
  BookLookupService({
    required this._source,
    required this._cache,
    required this._clock,
  });

  static const Duration successTtl = Duration(days: 30);
  static const Duration notFoundTtl = Duration(days: 7);

  final BookInfoSource _source;
  final LookupCacheStore _cache;
  final Clock _clock;

  static String cacheKey(Isbn13 isbn) => 'isbn:${isbn.value}';

  bool _fresh(LookupCacheEntry e) {
    final ttl = e.isNotFound ? notFoundTtl : successTtl;
    return _clock.now().difference(e.fetchedAt) < ttl;
  }

  BookInfo? _decode(LookupCacheEntry e) {
    try {
      final json = jsonDecode(e.payloadJson);
      if (json is Map<String, Object?>) return BookInfo.fromJson(json);
    } on FormatException {
      // A corrupt entry is treated as a miss.
    }
    return null;
  }

  /// Only the local cache; never touches the network. Includes expired
  /// successes (useful for offline matching).
  Future<BookInfo?> cachedIsbn(Isbn13 isbn) async {
    final entry = await _cache.get(cacheKey(isbn));
    if (entry == null || entry.isNotFound) return null;
    return _decode(entry);
  }

  /// Looks up [isbn]. Set [forceRefresh] to skip a fresh cache entry.
  Future<Result<BookInfo>> lookupIsbn(
    Isbn13 isbn, {
    bool forceRefresh = false,
  }) async {
    final key = cacheKey(isbn);
    final entry = await _cache.get(key);

    if (entry != null && !forceRefresh && _fresh(entry)) {
      if (entry.isNotFound) return const Err<BookInfo>(NotFoundFailure('book'));
      final info = _decode(entry);
      if (info != null) return Ok<BookInfo>(info);
    }

    final result = await _source.lookupIsbn(isbn);
    switch (result) {
      case Ok<BookInfo>(:final value):
        if (value.isComplete) {
          await _store(key, jsonEncode(value.toJson()), isNotFound: false);
        }
        return result;
      case Err<BookInfo>(:final failure):
        if (failure is NotFoundFailure) {
          await _store(key, '{}', isNotFound: true);
          return result;
        }
        // Network trouble: fall back to an expired success if we have one.
        if (entry != null && !entry.isNotFound) {
          final stale = _decode(entry);
          if (stale != null) return Ok<BookInfo>(stale);
        }
        return result;
    }
  }

  /// Searches by title. Not cached: results are cheap to refetch and change.
  Future<Result<List<BookInfo>>> searchTitle(
    String title, {
    String? author,
    int limit = 10,
  }) {
    if (title.trim().isEmpty) {
      return Future<Result<List<BookInfo>>>.value(
        const Ok<List<BookInfo>>(<BookInfo>[]),
      );
    }
    return _source.searchTitle(title, author: author, limit: limit);
  }

  Future<void> _store(String key, String payload, {required bool isNotFound}) {
    return _cache.put(
      LookupCacheEntry(
        key: key,
        payloadJson: payload,
        fetchedAt: _clock.now(),
        isNotFound: isNotFound,
      ),
    );
  }
}
