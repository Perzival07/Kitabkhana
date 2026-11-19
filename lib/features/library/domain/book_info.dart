import '../../../core/text/isbn.dart';

/// Book metadata from an external catalogue (Open Library), independent of
/// the user's own `Book` record.
final class BookInfo {
  const BookInfo({
    required this.title,
    this.subtitle,
    this.authors = const <String>[],
    this.pages,
    this.isbn13,
    this.olWorkKey,
    this.coverUrl,
    this.year,
    this.isComplete = true,
  });

  factory BookInfo.fromJson(Map<String, Object?> json) {
    final isbn = json['isbn13'];
    final authors = json['authors'];
    return BookInfo(
      title: (json['title'] as String?) ?? '',
      subtitle: json['subtitle'] as String?,
      authors: authors is List
          ? authors.whereType<String>().toList()
          : const <String>[],
      pages: json['pages'] as int?,
      isbn13: isbn is String ? parseIsbn(isbn) : null,
      olWorkKey: json['olWorkKey'] as String?,
      coverUrl: json['coverUrl'] as String?,
      year: json['year'] as int?,
    );
  }

  final String title;
  final String? subtitle;
  final List<String> authors;
  final int? pages;
  final Isbn13? isbn13;

  /// e.g. `/works/OL17295077W`; identifies all editions of the same work.
  final String? olWorkKey;
  final String? coverUrl;

  /// First publication / publication year, if known.
  final int? year;

  /// False when a secondary lookup (work, authors) failed, so the data may be
  /// missing authors. Incomplete results are not cached.
  final bool isComplete;

  /// Authors joined for display and for `Book.authors`.
  String get authorsText => authors.join(', ');

  BookInfo copyWith({List<String>? authors, Isbn13? isbn13, bool? isComplete}) {
    return BookInfo(
      title: title,
      subtitle: subtitle,
      authors: authors ?? this.authors,
      pages: pages,
      isbn13: isbn13 ?? this.isbn13,
      olWorkKey: olWorkKey,
      coverUrl: coverUrl,
      year: year,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'title': title,
    'subtitle': subtitle,
    'authors': authors,
    'pages': pages,
    'isbn13': isbn13?.value,
    'olWorkKey': olWorkKey,
    'coverUrl': coverUrl,
    'year': year,
  };

  @override
  bool operator ==(Object other) =>
      other is BookInfo &&
      other.title == title &&
      other.subtitle == subtitle &&
      _listEq(other.authors, authors) &&
      other.pages == pages &&
      other.isbn13 == isbn13 &&
      other.olWorkKey == olWorkKey &&
      other.coverUrl == coverUrl &&
      other.year == year &&
      other.isComplete == isComplete;

  @override
  int get hashCode => Object.hash(
    title,
    subtitle,
    Object.hashAll(authors),
    pages,
    isbn13,
    olWorkKey,
    coverUrl,
    year,
    isComplete,
  );

  @override
  String toString() => 'BookInfo($title, $authors)';
}

bool _listEq(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
