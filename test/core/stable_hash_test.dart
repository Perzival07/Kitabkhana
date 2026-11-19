import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/stable_hash.dart';

void main() {
  test('matches known FNV-1a 32-bit vectors', () {
    expect(stableHash(''), 0x811c9dc5);
    expect(stableHash('a'), 0xe40c292c);
    expect(stableHash('foobar'), 0xbf9cf968);
  });

  test('is deterministic and within 32 bits', () {
    final h = stableHash('The God of Small Things');
    expect(stableHash('The God of Small Things'), h);
    expect(h, inInclusiveRange(0, 0xFFFFFFFF));
  });

  test('handles non-Latin text', () {
    expect(stableHash('गोदान'), isNot(stableHash('গীতাঞ্জলি')));
  });
}
