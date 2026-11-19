final RegExp _word = RegExp(r'[\p{L}\p{N}\p{M}]+', unicode: true);

/// The set of trigrams of [text], padded per word like PostgreSQL's pg_trgm
/// (two leading spaces and one trailing space).
Set<String> trigrams(String text) {
  final result = <String>{};
  for (final m in _word.allMatches(text.toLowerCase())) {
    final padded = '  ${m.group(0)} ';
    final runes = padded.runes.toList();
    for (var i = 0; i + 3 <= runes.length; i++) {
      result.add(String.fromCharCodes(runes.sublist(i, i + 3)));
    }
  }
  return result;
}

/// Trigram similarity from 0 (nothing shared) to 1 (identical trigram sets):
/// the Jaccard index of the two trigram sets. Empty input scores 0.
double trigramSimilarity(String a, String b) {
  final ta = trigrams(a);
  final tb = trigrams(b);
  if (ta.isEmpty || tb.isEmpty) return 0;
  final shared = ta.intersection(tb).length;
  final union = ta.length + tb.length - shared;
  return shared / union;
}
