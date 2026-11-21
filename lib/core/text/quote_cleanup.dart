/// Cleans text read from a photographed page so it reads like prose.
///
/// * Spaces are collapsed and trimmed; no space is left before punctuation.
/// * A word broken across lines with a hyphen ("exam-" / "ple") is joined
///   when the next line carries on in lower case. A real hyphen before a
///   capital or digit ("Anglo-" / "Saxon") is kept.
/// * Lines are joined into paragraphs with single spaces; blank lines start
///   a new paragraph (separated by one empty line).
/// * Quotation marks become typographic ones, and `...` becomes `…`.
String cleanQuoteText(Iterable<String> lines) {
  final paragraphs = <String>[];
  var current = '';

  void flush() {
    if (current.isNotEmpty) paragraphs.add(current);
    current = '';
  }

  for (final raw in lines) {
    final line = _tidySpaces(raw);
    if (line.isEmpty) {
      flush();
      continue;
    }
    if (current.isEmpty) {
      current = line;
    } else if (_continuesHyphenatedWord(current, line)) {
      current = current.substring(0, current.length - 1) + line;
    } else if (current.endsWith('­')) {
      current = current.substring(0, current.length - 1) + line;
    } else {
      current = '$current $line';
    }
  }
  flush();

  return paragraphs.map(_smartQuotes).join('\n\n');
}

final RegExp _spaces = RegExp(r'[ \t  -  ]+');
final RegExp _spaceBeforePunct = RegExp(r' +([,.;:!?%)\]])');

String _tidySpaces(String s) => s
    .replaceAll('​', '')
    .replaceAll(_spaces, ' ')
    .trim()
    .replaceAllMapped(_spaceBeforePunct, (m) => m[1]!);

bool _continuesHyphenatedWord(String before, String next) {
  if (before.length < 2 || !before.endsWith('-')) return false;
  final letter = before[before.length - 2];
  if (!_isLetter(letter)) return false;
  return _isLowerLetter(next[0]);
}

bool _isLetter(String c) => c.toLowerCase() != c.toUpperCase();
bool _isLowerLetter(String c) => _isLetter(c) && c == c.toLowerCase();

String _smartQuotes(String text) {
  final s = text
      .replaceAll('...', '…')
      .replaceAll('``', '“')
      .replaceAll("''", '”')
      .replaceAll('„', '“')
      .replaceAll('«', '“')
      .replaceAll('»', '”')
      .replaceAll('‚', '‘')
      .replaceAll('‹', '‘')
      .replaceAll('›', '’');

  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    final prev = i == 0 ? '' : s[i - 1];
    final opening = prev.isEmpty || _opensAfter(prev);
    switch (c) {
      case '"':
        out.write(opening ? '“' : '”');
      case "'":
        // An apostrophe inside a word is always the closing form.
        out.write(opening ? '‘' : '’');
      default:
        out.write(c);
    }
  }
  return out.toString();
}

/// Whether a quote after [c] opens a quotation.
bool _opensAfter(String c) =>
    c == ' ' ||
    c == '\n' ||
    c == '(' ||
    c == '[' ||
    c == '{' ||
    c == '—' ||
    c == '–' ||
    c == '“' ||
    c == '‘';
