final RegExp _tokenPattern = RegExp(r'[\p{L}\p{N}\p{M}]+', unicode: true);

/// Turns free text into a safe FTS5 prefix query: `harr pot` becomes
/// `"harr"* "pot"*` (every word must match as a prefix). Only letters, digits
/// and marks survive, so user input can never inject FTS syntax. Returns null
/// when nothing searchable remains.
String? buildFtsQuery(String raw) {
  final tokens = _tokenPattern.allMatches(raw).map((m) => m.group(0)!).toList();
  if (tokens.isEmpty) return null;
  return tokens.map((t) => '"$t"*').join(' ');
}
