import 'package:unorm_dart/unorm_dart.dart' as unorm;

/// A normalised `title|authorSurname` key used to recognise the same book
/// across spellings, punctuation, accents and editions.
final class TitleKey {
  const TitleKey(this.value);

  final String value;

  /// The normalised title part (before the `|`).
  String get titlePart {
    final i = value.indexOf('|');
    return i < 0 ? value : value.substring(0, i);
  }

  /// The normalised first-author surname (after the `|`), or empty.
  String get authorPart {
    final i = value.indexOf('|');
    return i < 0 ? '' : value.substring(i + 1);
  }

  @override
  bool operator ==(Object other) => other is TitleKey && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

// Latin combining diacritics only. Indic vowel signs (also combining marks)
// must survive, so we never strip the whole \p{M} category.
final RegExp _latinMarks = RegExp('[̀-ͯ]');
final RegExp _apostrophes = RegExp("['‘’ʼ`´]");
final RegExp _punctuation = RegExp(r'[^\p{L}\p{N}\p{M}\s]', unicode: true);
final RegExp _spaces = RegExp(r'\s+');
const Set<String> _articles = <String>{'the', 'a', 'an'};
const Set<String> _nameSuffixes = <String>{
  'jr',
  'sr',
  'ii',
  'iii',
  'iv',
  'phd',
};

/// Normalises [text]: NFKD, strip Latin accents, lowercase, `&` to `and`,
/// drop apostrophes, other punctuation to spaces, collapse whitespace.
String normalizeText(String text) {
  var s = unorm.nfkd(text);
  s = s.replaceAll(_latinMarks, '');
  s = s.toLowerCase();
  s = s.replaceAll('&', ' and ');
  s = s.replaceAll(_apostrophes, '');
  s = s.replaceAll(_punctuation, ' ');
  return s.replaceAll(_spaces, ' ').trim();
}

/// Builds the [TitleKey] for a title and (optional) author list.
///
/// The subtitle after `:` is dropped, leading articles (the/a/an) are
/// removed, and the first author's surname is appended after `|`.
TitleKey normalizeTitle(String title, [String authors = '']) {
  final colon = title.indexOf(':');
  final main = colon > 0 ? title.substring(0, colon) : title;

  var words = normalizeText(main)
      .split(' ')
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.length > 1 && _articles.contains(words.first)) {
    words = words.sublist(1);
  }
  final titlePart = words.join(' ');
  final surname = _firstAuthorSurname(authors);
  return TitleKey(surname.isEmpty ? titlePart : '$titlePart|$surname');
}

String _firstAuthorSurname(String authors) {
  final trimmed = authors.trim();
  if (trimmed.isEmpty) return '';
  // First author: up to the first ';', ' and ', ' & ' or ','.
  final first = trimmed
      .split(RegExp(r'\s*;\s*|\s+and\s+|\s+&\s+|\s*,\s*', caseSensitive: false))
      .firstWhere((p) => p.trim().isNotEmpty, orElse: () => '');
  final tokens = normalizeText(first).split(' ').where((t) => t.isNotEmpty);
  final list = tokens.toList();
  if (list.isEmpty) return '';
  if (list.length == 1) return list.first; // "Rowling, J. K." or single name

  // "J. K. Rowling": last token that is a real name (skip initials/suffixes).
  for (var i = list.length - 1; i >= 0; i--) {
    final t = list[i];
    if (t.length > 1 && !_nameSuffixes.contains(t)) return t;
  }
  return list.last;
}
