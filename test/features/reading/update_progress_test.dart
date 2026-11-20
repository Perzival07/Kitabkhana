import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/reading/application/update_progress.dart';
import 'package:kitabkhana/features/reading/domain/streak.dart';

import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;
  late UpdateProgress update;
  var n = 0;

  setUp(() {
    h = RepoHarness();
    n = 0;
    update = UpdateProgress(
      books: h.books,
      readings: h.readings,
      clock: h.clock,
      newId: () => 'log${++n}',
    );
  });

  tearDown(() => h.db.close());

  Future<String> reading({int? pages = 300, int page = 0}) async {
    final b = await h.addBook(
      pages: pages,
      status: ReadStatus.reading,
      tweak: (b) => b.copyWith(currentPage: page, startedOn: h.clock.today()),
    );
    return b.id;
  }

  Future<List<int>> todayLogs(String id) async {
    final r = await h.readings.findForDay(id, h.clock.today());
    final log = r.getOrNull();
    return log == null ? <int>[] : [log.fromPage, log.toPage, log.pagesRead];
  }

  test('writes today\'s log with the delta', () async {
    final id = await reading(page: 10);
    final r = (await update(id, 35)).getOrNull()!;
    expect(r.book.currentPage, 35);
    expect(r.log!.pagesRead, 25);
    expect(await todayLogs(id), [10, 35, 25]);
  });

  test('several updates on one day merge into one row', () async {
    final id = await reading();
    await update(id, 20);
    await update(id, 50);
    await update(id, 55);
    final logs = await h.readings.watchForBook(id).first;
    expect(logs, hasLength(1));
    expect(await todayLogs(id), [0, 55, 55]);
  });

  test('going back shrinks today\'s log but never below nothing', () async {
    final id = await reading();
    await update(id, 50);
    await update(id, 30);
    expect(await todayLogs(id), [0, 30, 30]);
    final r = (await update(id, 0)).getOrNull()!;
    expect(r.log, isNull);
    expect(await todayLogs(id), isEmpty);
    expect((await h.books.getById(id)).getOrNull()!.currentPage, 0);
  });

  test(
    'going back with no log today logs nothing and leaves days alone',
    () async {
      final id = await reading();
      await update(id, 40);
      h.clock.advance(const Duration(days: 1));
      final r = (await update(id, 30)).getOrNull()!;
      expect(r.log, isNull);
      expect(r.book.currentPage, 30);
      final logs = await h.readings.watchForBook(id).first;
      expect(logs, hasLength(1), reason: 'yesterday\'s log is untouched');
      expect(logs.single.pagesRead, 40);
    },
  );

  test('reading again after a step back starts from the lower page', () async {
    final id = await reading();
    await update(id, 50);
    await update(id, 20); // log is now 0->20
    await update(id, 10); // 0->10
    await update(id, 0); // gone
    await update(id, 15);
    expect(await todayLogs(id), [0, 15, 15]);
  });

  test('a new day starts a new log from where the last one ended', () async {
    final id = await reading();
    await update(id, 40);
    h.clock.advance(const Duration(days: 1));
    await update(id, 60);
    final logs = await h.readings.watchForBook(id).first;
    expect(logs.map((l) => [l.fromPage, l.toPage]), [
      [40, 60],
      [0, 40],
    ]);
  });

  test('a page past the end is rejected and changes nothing', () async {
    final id = await reading(pages: 100);
    final r = await update(id, 101);
    expect(r, isA<Err<ProgressUpdate>>());
    expect((r as Err).failure, isA<ValidationFailure>());
    expect(await todayLogs(id), isEmpty);
    expect((await update(id, -1)).isOk, isFalse);
  });

  test('reaching the last page offers to finish, without finishing', () async {
    final id = await reading(pages: 100, page: 90);
    final r = (await update(id, 100)).getOrNull()!;
    expect(r.reachedEnd, isTrue);
    expect(r.book.status, ReadStatus.reading);
    final again = (await update(id, 99)).getOrNull()!;
    expect(again.reachedEnd, isFalse);
  });

  test(
    'unknown page count: any page is allowed, never offers finish',
    () async {
      final id = await reading(pages: null);
      final r = (await update(id, 999)).getOrNull()!;
      expect(r.reachedEnd, isFalse);
      expect(r.log!.pagesRead, 999);
    },
  );

  test('reading from the want shelf starts the book', () async {
    final b = await h.addBook(pages: 100);
    final r = (await update(b.id, 12)).getOrNull()!;
    expect(r.book.status, ReadStatus.reading);
    expect(r.book.startedOn, h.clock.today());
  });

  test('missing book is NotFound', () async {
    final r = await update('nope', 3);
    expect((r as Err).failure, isA<NotFoundFailure>());
  });

  test('streak follows the logs, using local dates at midnight', () async {
    final id = await reading();
    await update(id, 10);
    h.clock.advance(const Duration(days: 1));
    await update(id, 20);
    var days = await h.readings.watchReadingDays().first;
    expect(computeStreak(days, h.clock.today()).current, 2);

    // 23:59 the next day: yesterday's log keeps the streak alive.
    h.clock.set(DateTime(2025, 3, 12, 23, 59));
    expect(computeStreak(days, h.clock.today()).current, 2);
    // Two days later it is broken.
    h.clock.set(DateTime(2025, 3, 13, 0, 1));
    days = await h.readings.watchReadingDays().first;
    expect(computeStreak(days, h.clock.today()).current, 0);
    expect(computeStreak(days, h.clock.today()).longest, 2);
  });

  test('logs of a deleted book are left out of the reading days', () async {
    final id = await reading();
    await update(id, 10);
    await h.books.softDelete(id);
    expect(await h.readings.watchReadingDays().first, isEmpty);
  });
}
