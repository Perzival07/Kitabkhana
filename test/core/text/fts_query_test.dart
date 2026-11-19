import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/text/fts_query.dart';

void main() {
  test('builds prefix terms joined by AND', () {
    expect(buildFtsQuery('harr'), '"harr"*');
    expect(buildFtsQuery('harry pot'), '"harry"* "pot"*');
  });

  test('strips FTS syntax and punctuation', () {
    expect(buildFtsQuery('harry OR dune'), '"harry"* "OR"* "dune"*');
    expect(buildFtsQuery('a" OR "b'), '"a"* "OR"* "b"*');
    expect(buildFtsQuery('title:harry*'), '"title"* "harry"*');
    expect(
      buildFtsQuery("'; DROP TABLE books; --"),
      '"DROP"* "TABLE"* "books"*',
    );
  });

  test('keeps Unicode letters and marks', () {
    expect(buildFtsQuery('गोदान'), '"गोदान"*');
    expect(buildFtsQuery('García'), '"García"*');
  });

  test('returns null when nothing searchable remains', () {
    expect(buildFtsQuery(''), isNull);
    expect(buildFtsQuery('   '), isNull);
    expect(buildFtsQuery('"*()'), isNull);
  });
}
