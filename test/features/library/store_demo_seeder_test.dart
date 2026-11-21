import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/library/application/store_demo_seeder.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/reading/domain/streak.dart';

import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;
  late StoreDemoSeeder seeder;

  setUp(() {
    h = RepoHarness();
    seeder = StoreDemoSeeder(
      books: h.books,
      locations: h.locations,
      loans: h.loans,
      readings: h.readings,
      quotes: h.quotes,
      goals: h.goals,
      tags: h.tags,
      clock: h.clock,
    );
  });
  tearDown(() => h.db.close());

  test('seeds a believable classics library', () async {
    final n = await seeder.seed();
    final books = (await h.books.watchAll().first);
    expect(books, hasLength(n));
    expect(books.length, inInclusiveRange(10, 20));
    expect(books.map((b) => b.title), contains('Pride and Prejudice'));
    expect(books.map((b) => b.title), contains('Middlemarch'));

    // A spread of everything the screenshots show.
    expect(books.where((b) => b.status == ReadStatus.reading), hasLength(2));
    expect(
      books.where((b) => b.status == ReadStatus.finished).length,
      greaterThan(3),
    );
    expect(
      books.where((b) => b.status == ReadStatus.want).length,
      greaterThan(2),
    );
    expect(books.where((b) => b.ownership == Ownership.wishlist), isNotEmpty);
    expect(books.where((b) => b.locationId != null).length, greaterThan(8));
    expect((await h.locations.watchAll().first), hasLength(4));
    expect((await h.quotes.watchAll().first), hasLength(5));
    expect(
      (await h.goals.getForYear(h.clock.today().year)).getOrNull()!.targetBooks,
      24,
    );
  });

  test('one loan is due soon and one is overdue, relative to today', () async {
    await seeder.seed();
    final today = h.clock.today();
    final overdue = await h.loans.watchOverdue().first;
    expect(overdue, hasLength(1));
    expect(overdue.single.personName, 'Rahul Verma');
    final active = await h.loans.watchActive().first;
    expect(active, hasLength(2));
    final soon = active.firstWhere((l) => l.personName == 'Priya Sharma');
    expect(soon.dueOn!.difference(today).inDays, 2);
  });

  test('the reading streak runs into today', () async {
    await seeder.seed();
    final days = await h.readings.watchReadingDays().first;
    final s = computeStreak(days, h.clock.today());
    expect(s.current, 12);
  });

  test('the book the scan screenshot uses has its ISBN', () async {
    await seeder.seed();
    final b = (await h.books.getById(StoreDemoSeeder.prideId)).getOrNull()!;
    expect(b.isbn13!.value, StoreDemoSeeder.prideIsbn);
  });
}
