/// Deterministic 32-bit FNV-1a hash, identical on native and web.
///
/// Used for stable colours (generated covers, avatars); never use
/// `String.hashCode`, which differs between runs and platforms.
int stableHash(String input) {
  const prime = 0x01000193;
  var hash = 0x811c9dc5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    // 32-bit multiply without exceeding 2^53 (safe on web).
    final low = (hash & 0xFFFF) * prime;
    final high = ((hash >>> 16) * prime) & 0xFFFF;
    hash = (low + (high << 16)) & 0xFFFFFFFF;
  }
  return hash;
}
