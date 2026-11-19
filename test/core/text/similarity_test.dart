import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/text/similarity.dart';

void main() {
  test('trigrams are padded per word', () {
    expect(trigrams('ab'), <String>{'  a', ' ab', 'ab '});
    expect(trigrams('a b'), <String>{'  a', ' a ', '  b', ' b '});
    expect(trigrams(''), isEmpty);
    expect(trigrams('!!!'), isEmpty);
  });

  test('identical text scores 1, ignoring case', () {
    expect(trigramSimilarity('The Hobbit', 'the hobbit'), 1);
    expect(trigramSimilarity('Dune', 'DUNE'), 1);
  });

  test('empty or unrelated text scores 0', () {
    expect(trigramSimilarity('', 'dune'), 0);
    expect(trigramSimilarity('dune', ''), 0);
    expect(trigramSimilarity('', ''), 0);
    expect(trigramSimilarity('abc', 'xyz'), 0);
  });

  test('is symmetric and within 0..1', () {
    const pairs = <(String, String)>[
      ('harry potter', 'harry potter and the chamber of secrets'),
      ('hobbit', 'hobbitt'),
      ('dune', 'dune messiah'),
    ];
    for (final (a, b) in pairs) {
      final s = trigramSimilarity(a, b);
      expect(s, trigramSimilarity(b, a));
      expect(s, inInclusiveRange(0, 1));
    }
  });

  test('close spellings outrank distant ones', () {
    final typo = trigramSimilarity('philosophers stone', 'philosopher stone');
    final other = trigramSimilarity('philosophers stone', 'dune messiah');
    expect(typo, greaterThan(0.6));
    expect(other, lessThan(0.1));
    expect(trigramSimilarity('hobbit', 'hobbitt'), greaterThan(0.6));
  });

  test('works for Indic scripts', () {
    expect(trigramSimilarity('गोदान', 'गोदान'), 1);
    final s = trigramSimilarity('गोदान', 'गबन');
    expect(s, inInclusiveRange(0, 0.5));
    expect(trigramSimilarity('পথের পাঁচালী', 'পথের পাঁচালী'), 1);
  });

  test('word order matters little, extra words lower the score', () {
    final full = trigramSimilarity('harry potter', 'harry potter');
    final extra = trigramSimilarity(
      'harry potter',
      'harry potter and the half blood prince',
    );
    expect(full, 1);
    expect(extra, lessThan(full));
  });
}
