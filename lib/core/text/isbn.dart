/// A validated ISBN-13 (978/979 prefix, correct check digit).
final class Isbn13 {
  const Isbn13._(this.value);

  /// The 13 digits, no separators.
  final String value;

  /// The ISBN-10 form, or null for 979 ISBNs (which have none).
  String? get isbn10 {
    if (!value.startsWith('978')) return null;
    final body = value.substring(3, 12);
    return '$body${_isbn10CheckDigit(body)}';
  }

  @override
  bool operator ==(Object other) => other is Isbn13 && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

final RegExp _prefix = RegExp(
  r'^isbn(?:[-\s]?1[03])?\s*:?',
  caseSensitive: false,
);
final RegExp _separators = RegExp('[\\s\\-‐-―−]');

/// Parses user- or scanner-supplied text into an [Isbn13].
///
/// Accepts ISBN-10 (including an `X` check digit) and ISBN-13, with spaces,
/// hyphens or an `ISBN` prefix. Check digits are validated. ISBN-10 is
/// converted to ISBN-13. Only 978/979 prefixes are accepted. A trailing
/// 5-digit price add-on (an 18-digit EAN-13+5 barcode) is ignored. Returns
/// null for anything invalid, including non-book EANs.
Isbn13? parseIsbn(String raw) {
  var s = raw.trim().replaceFirst(_prefix, '').replaceAll(_separators, '');
  s = s.toUpperCase();
  if (s.isEmpty) return null;

  if (s.length == 18 && _allDigits(s)) {
    s = s.substring(0, 13); // EAN-13 + 5-digit supplement
  }

  if (s.length == 10) return _fromIsbn10(s);
  if (s.length == 13 && _allDigits(s)) return _fromIsbn13(s);
  return null;
}

/// Formats for display in groups: `978-014-312-755-0`.
///
/// Real ISBN hyphenation depends on publisher range tables, so this uses a
/// uniform grouping that is easy to read and verify.
String formatIsbn13(Isbn13 isbn) {
  final v = isbn.value;
  return '${v.substring(0, 3)}-${v.substring(3, 6)}-${v.substring(6, 9)}-'
      '${v.substring(9, 12)}-${v.substring(12)}';
}

bool _allDigits(String s) {
  for (final c in s.codeUnits) {
    if (c < 0x30 || c > 0x39) return false;
  }
  return true;
}

Isbn13? _fromIsbn13(String s) {
  if (!s.startsWith('978') && !s.startsWith('979')) return null;
  return _isbn13CheckDigit(s.substring(0, 12)) == s[12] ? Isbn13._(s) : null;
}

Isbn13? _fromIsbn10(String s) {
  final body = s.substring(0, 9);
  if (!_allDigits(body)) return null;
  if (_isbn10CheckDigit(body) != s[9]) return null;
  final core = '978$body';
  return Isbn13._('$core${_isbn13CheckDigit(core)}');
}

String _isbn13CheckDigit(String first12) {
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    sum += (first12.codeUnitAt(i) - 0x30) * (i.isEven ? 1 : 3);
  }
  return '${(10 - sum % 10) % 10}';
}

String _isbn10CheckDigit(String first9) {
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    sum += (first9.codeUnitAt(i) - 0x30) * (10 - i);
  }
  final check = (11 - sum % 11) % 11;
  return check == 10 ? 'X' : '$check';
}
