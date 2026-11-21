import '../../../core/stable_hash.dart';
import 'quote.dart';

/// Favourites are preferred, but a handful is not enough to fill a rotation
/// without nagging; below this many, other quotes top the pool up.
const int quoteOfWeekMinFavourites = 3;

/// Monday 5 January 1970, the first Monday of the Unix epoch.
final DateTime _firstMonday = DateTime.utc(1970, 1, 5);

/// Weeks since [_firstMonday]; changes every Monday (ISO weeks start then),
/// whatever the year or its week-53 quirks.
int weekIndexOf(DateTime day) =>
    DateTime.utc(
      day.year,
      day.month,
      day.day,
    ).difference(_firstMonday).inDays ~/
    7;

/// The quote to feature in the week containing [today], or null when there
/// are no quotes.
///
/// Deterministic: the same quotes and week always give the same answer, on
/// every device and run. The pool is the favourites (topped up with other
/// quotes while there are fewer than [quoteOfWeekMinFavourites]), put in a
/// stable shuffled order and stepped through one per week, so nothing comes
/// round again until every quote in the pool has had its turn.
Quote? quoteOfTheWeek(Iterable<Quote> quotes, DateTime today) {
  final live = quotes.where((q) => q.deletedAt == null).toList();
  if (live.isEmpty) return null;

  final favourites = live.where((q) => q.isFavourite).toList();
  final pool = favourites.length >= quoteOfWeekMinFavourites
      ? favourites
      : live;
  pool.sort((a, b) {
    final c = stableHash(a.id).compareTo(stableHash(b.id));
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  if (favourites.isNotEmpty && favourites.length < quoteOfWeekMinFavourites) {
    // Lead with the favourites so they get the first turns.
    pool.sort((a, b) {
      if (a.isFavourite != b.isFavourite) return a.isFavourite ? -1 : 1;
      final c = stableHash(a.id).compareTo(stableHash(b.id));
      return c != 0 ? c : a.id.compareTo(b.id);
    });
  }
  return pool[weekIndexOf(today) % pool.length];
}
