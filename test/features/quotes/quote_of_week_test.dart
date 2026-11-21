import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/quotes/domain/quote.dart';
import 'package:kitabkhana/features/quotes/domain/quote_of_week.dart';

Quote q(String id, {bool fav = false, bool deleted = false}) {
  final base = Quote.create(
    id: id,
    bookId: 'b',
    body: 'Body $id',
    now: DateTime(2025),
    isFavourite: fav,
  );
  return deleted ? base.copyWith(deletedAt: DateTime(2025, 2)) : base;
}

void main() {
  // Mondays: 2025-03-03, 03-10, 03-17 ...
  final mon = DateTime(2025, 3, 10);

  test('no quotes, no pick; deleted ones do not count', () {
    expect(quoteOfTheWeek(const <Quote>[], mon), isNull);
    expect(quoteOfTheWeek([q('a', deleted: true)], mon), isNull);
  });

  test('the week runs Monday to Sunday', () {
    final quotes = [for (final i in 'abcdef'.split('')) q(i)];
    final week = quoteOfTheWeek(quotes, mon)!.id;
    for (var d = 0; d < 7; d++) {
      expect(
        quoteOfTheWeek(quotes, DateTime(2025, 3, 10 + d, 23, 59))!.id,
        week,
        reason: 'day $d',
      );
    }
    expect(quoteOfTheWeek(quotes, DateTime(2025, 3, 17))!.id, isNot(week));
    // Sunday night and Monday morning are different weeks.
    expect(
      weekIndexOf(DateTime(2025, 3, 16)) + 1,
      weekIndexOf(DateTime(2025, 3, 17)),
    );
  });

  test('same inputs, same answer, whatever order they arrive in', () {
    final quotes = [for (final i in 'abcdef'.split('')) q(i)];
    final a = quoteOfTheWeek(quotes, mon)!.id;
    expect(quoteOfTheWeek(quotes.reversed, mon)!.id, a);
    expect(quoteOfTheWeek(List.of(quotes)..shuffle(), mon)!.id, a);
  });

  test('every quote has its turn before any repeats', () {
    final quotes = [for (var i = 0; i < 7; i++) q('q$i')];
    final seen = <String>[];
    for (var w = 0; w < 7; w++) {
      seen.add(quoteOfTheWeek(quotes, DateTime(2025, 3, 10 + 7 * w))!.id);
    }
    expect(seen.toSet(), hasLength(7));
    // The 8th week starts the cycle again.
    expect(quoteOfTheWeek(quotes, DateTime(2025, 3, 10 + 49))!.id, seen.first);
  });

  test('consecutive weeks differ when there is a choice', () {
    final quotes = [q('a'), q('b')];
    for (var w = 0; w < 10; w++) {
      final now = quoteOfTheWeek(quotes, DateTime(2025, 1, 6 + 7 * w))!.id;
      final next = quoteOfTheWeek(quotes, DateTime(2025, 1, 13 + 7 * w))!.id;
      expect(now, isNot(next));
    }
  });

  test('three or more favourites: only favourites are featured', () {
    final quotes = [
      q('a', fav: true),
      q('b', fav: true),
      q('c', fav: true),
      q('x'),
      q('y'),
    ];
    for (var w = 0; w < 12; w++) {
      final pick = quoteOfTheWeek(quotes, DateTime(2025, 1, 6 + 7 * w))!;
      expect(pick.isFavourite, isTrue);
    }
  });

  test('fewer favourites lead the rotation, then others follow', () {
    final quotes = [q('a', fav: true), q('x'), q('y'), q('z')];
    final start = DateTime(2025, 3, 10);
    // Walk one full cycle: the favourite shows up once, and the first week
    // of the cycle (index 0 mod 4) is the favourite.
    final firstIndex = weekIndexOf(start) % 4;
    final cycle = <String>[
      for (var w = 0; w < 4; w++)
        quoteOfTheWeek(quotes, DateTime(2025, 3, 10 + 7 * w))!.id,
    ];
    expect(cycle.toSet(), hasLength(4));
    expect(cycle[(4 - firstIndex) % 4], 'a');
  });

  test('a single quote is always the pick', () {
    expect(quoteOfTheWeek([q('only')], mon)!.id, 'only');
  });
}
