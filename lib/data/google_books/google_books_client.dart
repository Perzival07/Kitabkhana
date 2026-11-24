import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/failure.dart';
import '../../core/rate_limiter.dart';
import '../../core/result.dart';
import '../../core/text/isbn.dart';
import '../../features/library/domain/book_info.dart';
import '../../features/library/domain/book_info_source.dart';

/// Google Books, asked only when Open Library has no answer (see
/// `FallbackBookInfoSource`). Sends nothing but the ISBN or the title/author
/// typed, plus the app's API key when one was built in.
///
/// The key is optional: without one Google answers at a lower, shared rate.
/// When the key is restricted to the Android or iOS app in the Google Cloud
/// console, Google checks the package/bundle headers sent here.
class GoogleBooksClient implements BookInfoSource {
  GoogleBooksClient({
    required this._client,
    required this._limiter,
    this.apiKey = '',
    this.appHeaders = const <String, String>{},
    this.baseUrl = 'https://www.googleapis.com',
    this.timeout = const Duration(seconds: 15),
  });

  final http.Client _client;
  final RateLimiter _limiter;
  final String apiKey;

  /// `X-Android-Package` / `X-Android-Cert` or `X-Ios-Bundle-Identifier`,
  /// for keys restricted to the app.
  final Map<String, String> appHeaders;
  final String baseUrl;
  final Duration timeout;

  @override
  Future<Result<BookInfo>> lookupIsbn(Isbn13 isbn) async {
    final r = await _volumes('isbn:${isbn.value}', limit: 1);
    return switch (r) {
      Ok(value: final list) when list.isNotEmpty => Ok<BookInfo>(list.first),
      Ok() => const Err<BookInfo>(NotFoundFailure('book')),
      Err(:final failure) => Err<BookInfo>(failure),
    };
  }

  @override
  Future<Result<List<BookInfo>>> searchTitle(
    String title, {
    String? author,
    int limit = 10,
  }) {
    final t = title.trim();
    final a = author?.trim() ?? '';
    return _volumes(
      'intitle:$t${a.isEmpty ? '' : ' inauthor:$a'}',
      limit: limit,
    );
  }

  Future<Result<List<BookInfo>>> _volumes(
    String q, {
    required int limit,
  }) async {
    final uri = Uri.parse('$baseUrl/books/v1/volumes').replace(
      queryParameters: <String, String>{
        'q': q,
        'maxResults': '${limit.clamp(1, 40)}',
        'printType': 'books',
        'fields':
            'items(volumeInfo(title,subtitle,authors,pageCount,'
            'publishedDate,industryIdentifiers,imageLinks/thumbnail))',
        if (apiKey.isNotEmpty) 'key': apiKey,
      },
    );
    await _limiter.acquire();
    try {
      final response = await _client
          .get(
            uri,
            headers: <String, String>{
              'Accept': 'application/json',
              ...appHeaders,
            },
          )
          .timeout(timeout);
      final status = response.statusCode;
      if (status == 429) {
        return const Err<List<BookInfo>>(NetworkFailure.rateLimited());
      }
      if (status != 200) {
        return Err<List<BookInfo>>(NetworkFailure.server(status));
      }
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return Ok<List<BookInfo>>(parseGoogleVolumes(json));
    } on TimeoutException {
      return const Err<List<BookInfo>>(NetworkFailure.timeout());
    } on http.ClientException {
      return const Err<List<BookInfo>>(NetworkFailure.offline());
    } on FormatException {
      return const Err<List<BookInfo>>(NetworkFailure.server(200));
    }
  }
}

/// The books in a `/volumes` answer; items without a title are skipped.
List<BookInfo> parseGoogleVolumes(Object? json) {
  if (json is! Map<String, Object?>) return const <BookInfo>[];
  final items = json['items'];
  if (items is! List<Object?>) return const <BookInfo>[];
  final out = <BookInfo>[];
  for (final item in items) {
    if (item is! Map<String, Object?>) continue;
    final v = item['volumeInfo'];
    if (v is! Map<String, Object?>) continue;
    final title = (v['title'] as String?)?.trim() ?? '';
    if (title.isEmpty) continue;
    Isbn13? isbn;
    final ids = v['industryIdentifiers'];
    if (ids is List<Object?>) {
      for (final type in <String>['ISBN_13', 'ISBN_10']) {
        for (final id in ids.whereType<Map<String, Object?>>()) {
          if (isbn == null && id['type'] == type) {
            isbn = parseIsbn('${id['identifier'] ?? ''}');
          }
        }
      }
    }
    final pages = v['pageCount'];
    final year = int.tryParse(
      RegExp(r'^\d{4}').stringMatch('${v['publishedDate'] ?? ''}') ?? '',
    );
    final links = v['imageLinks'];
    var cover = links is Map<String, Object?>
        ? links['thumbnail'] as String?
        : null;
    // Google lists covers over plain HTTP; the same address works over HTTPS.
    if (cover != null && cover.startsWith('http://')) {
      cover = 'https://${cover.substring(7)}';
    }
    final subtitle = (v['subtitle'] as String?)?.trim();
    out.add(
      BookInfo(
        title: title,
        subtitle: subtitle == null || subtitle.isEmpty ? null : subtitle,
        authors: switch (v['authors']) {
          final List<Object?> a =>
            a.whereType<String>().map((s) => s.trim()).toList(),
          _ => const <String>[],
        },
        pages: pages is int && pages > 0 ? pages : null,
        isbn13: isbn,
        coverUrl: cover,
        year: year,
      ),
    );
  }
  return out;
}
