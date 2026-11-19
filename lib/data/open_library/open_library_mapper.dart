import '../../core/text/isbn.dart';
import '../../features/library/domain/book_info.dart';

/// Anti-corruption layer: turns Open Library's loosely-typed JSON into
/// [BookInfo]. Every accessor tolerates missing or oddly typed fields.
abstract final class OpenLibraryMapper {
  static const String coversBase = 'https://covers.openlibrary.org';

  static String? _string(Object? v) {
    if (v is! String) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  static int? _int(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  static Map<String, Object?>? asMap(Object? v) =>
      v is Map ? v.cast<String, Object?>() : null;

  /// `{"key": "/authors/OL1A"}` or a bare `"/authors/OL1A"` to the key.
  static String? _key(Object? v) {
    final raw = v is String ? _string(v) : _string(asMap(v)?['key']);
    // Open Library keys are absolute paths; anything else is not a key and
    // must never be turned into a request.
    return raw != null && raw.startsWith('/') ? raw : null;
  }

  /// A cover image URL for an Open Library cover id, or null for missing or
  /// placeholder ids (<= 0).
  static String? coverUrlForId(Object? id, {String size = 'L'}) {
    final n = _int(id);
    if (n == null || n <= 0) return null;
    return '$coversBase/b/id/$n-$size.jpg';
  }

  /// First plausible 4-digit year inside [text] ("15 March 2015" -> 2015).
  static int? yearFrom(Object? text) {
    final s = _string(text);
    if (s == null) return null;
    final m = RegExp(r'(?<!\d)(1[0-9]{3}|20[0-9]{2})(?!\d)').firstMatch(s);
    return m == null ? null : int.parse(m.group(1)!);
  }

  static int? _pages(Map<String, Object?> edition) {
    final direct = _int(edition['number_of_pages']);
    if (direct != null && direct > 0) return direct;
    final pagination = _string(edition['pagination']);
    if (pagination != null) {
      // "xii, 320 p." -> 320 (the largest plain number).
      final nums = RegExp(r'\d+')
          .allMatches(pagination)
          .map((m) => int.parse(m.group(0)!))
          .where((n) => n > 0);
      if (nums.isNotEmpty) return nums.reduce((a, b) => a > b ? a : b);
    }
    return null;
  }

  /// Author keys listed directly on an edition.
  static List<String> editionAuthorKeys(Map<String, Object?> edition) {
    final raw = edition['authors'];
    if (raw is! List) return const <String>[];
    return raw.map(_key).whereType<String>().toList();
  }

  /// Author keys listed on a work (`[{"author": {"key": ...}}]`).
  static List<String> workAuthorKeys(Map<String, Object?> work) {
    final raw = work['authors'];
    if (raw is! List) return const <String>[];
    return raw
        .map((e) => _key(asMap(e)?['author']) ?? _key(e))
        .whereType<String>()
        .toList();
  }

  static String? workKey(Map<String, Object?> edition) {
    final works = edition['works'];
    if (works is List && works.isNotEmpty) return _key(works.first);
    return null;
  }

  /// A person's display name from an `/authors/{key}.json` document.
  static String? authorName(Object? json) =>
      _string(asMap(json)?['name']) ?? _string(asMap(json)?['personal_name']);

  /// Maps an edition (+ optionally its work for a cover fallback) to a
  /// [BookInfo]. Returns null when there is no usable title.
  static BookInfo? edition(
    Map<String, Object?> edition, {
    required Isbn13 isbn,
    Map<String, Object?>? work,
    List<String> authors = const <String>[],
    bool complete = true,
  }) {
    final title = _string(edition['title']);
    if (title == null) return null;
    final covers = edition['covers'];
    String? cover = covers is List && covers.isNotEmpty
        ? coverUrlForId(covers.first)
        : null;
    if (cover == null && work != null) {
      final wc = work['covers'];
      if (wc is List) {
        for (final id in wc) {
          cover = coverUrlForId(id);
          if (cover != null) break;
        }
      }
    }
    return BookInfo(
      title: title,
      subtitle: _string(edition['subtitle']),
      authors: authors,
      pages: _pages(edition),
      isbn13: isbn,
      olWorkKey: workKey(edition),
      coverUrl: cover,
      year:
          yearFrom(edition['publish_date']) ??
          yearFrom(edition['copyright_date']),
      isComplete: complete,
    );
  }

  /// Maps `/search.json` to results; entries without a title are skipped.
  static List<BookInfo> searchResults(Object? json) {
    final docs = asMap(json)?['docs'];
    if (docs is! List) return const <BookInfo>[];
    final out = <BookInfo>[];
    for (final d in docs) {
      final doc = asMap(d);
      if (doc == null) continue;
      final title = _string(doc['title']);
      if (title == null) continue;
      final authorsRaw = doc['author_name'];
      final authors = authorsRaw is List
          ? authorsRaw.map(_string).whereType<String>().toList()
          : <String>[];
      Isbn13? isbn;
      final isbns = doc['isbn'];
      if (isbns is List) {
        for (final i in isbns) {
          final parsed = i is String ? parseIsbn(i) : null;
          if (parsed != null) {
            isbn = parsed;
            break;
          }
        }
      }
      final pages = _int(doc['number_of_pages_median']);
      out.add(
        BookInfo(
          title: title,
          authors: authors,
          pages: pages != null && pages > 0 ? pages : null,
          isbn13: isbn,
          olWorkKey: _string(doc['key']),
          coverUrl: coverUrlForId(doc['cover_i'], size: 'M'),
          year: _int(doc['first_publish_year']),
        ),
      );
    }
    return out;
  }
}
