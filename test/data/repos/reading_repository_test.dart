import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/features/reading/domain/reading_log.dart';

import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;

  setUp(() async {
    h = RepoHarness();
    await h.addBook(id: 'b1', title: 'One');
    await h.addBook(id: 'b2', title: 'Two');
  });
  tearDown(() => h.dispose());

  test('ReadingLog.create computes pagesRead', () {
    final l = ReadingLog.create(
      id: 'x',
      bookId: 'b1',
      date: DateTime(2025, 3, 1),
      fromPage: 10,
      toPage: 35,
      now: DateTime(2025, 3, 1),
    );
    expect(l.pagesRead, 25);
  });

  test('upsert inserts then updates (rev, createdAt)', () async {
    final a = await h.addLog(bookId: 'b1', date: DateTime(2025, 3, 1), to: 20);
    expect(a.rev, 1);
    expect(a.pagesRead, 20);
    h.tick();
    final b = (await h.readings.upsert(a.copyWith(pagesRead: 35, toPage: 35)))
        .getOrNull()!;
    expect(b.rev, 2);
    expect(b.pagesRead, 35);
    expect(b.createdAt, a.createdAt);
    expect(b.date, DateTime(2025, 3, 1));
  });

  test('a zero-page log is rejected', () async {
    final bad = ReadingLog.create(
      id: 'z',
      bookId: 'b1',
      date: DateTime(2025, 3, 1),
      fromPage: 5,
      toPage: 5,
      now: h.clock.now(),
    );
    expect(
      (await h.readings.upsert(bad)).failureOrNull(),
      isA<ValidationFailure>(),
    );
  });

  test('findForDay matches book and day only', () async {
    final a = await h.addLog(bookId: 'b1', date: DateTime(2025, 3, 1));
    await h.addLog(bookId: 'b2', date: DateTime(2025, 3, 1));
    await h.addLog(bookId: 'b1', date: DateTime(2025, 3, 2));
    final found = (await h.readings.findForDay(
      'b1',
      DateTime(2025, 3, 1),
    )).getOrNull();
    expect(found!.id, a.id);
    expect(
      (await h.readings.findForDay('b1', DateTime(2025, 3, 9))).getOrNull(),
      isNull,
    );
  });

  test('watchForBook is newest day first', () async {
    await h.addLog(bookId: 'b1', date: DateTime(2025, 3, 1));
    await h.addLog(bookId: 'b1', date: DateTime(2025, 3, 3));
    await h.addLog(bookId: 'b1', date: DateTime(2025, 3, 2));
    await h.addLog(bookId: 'b2', date: DateTime(2025, 3, 5));
    final list = await h.readings.watchForBook('b1').first;
    expect(list.map((l) => l.date.day), [3, 2, 1]);
  });

  test('watchBetween is inclusive, oldest first, across books', () async {
    await h.addLog(bookId: 'b1', date: DateTime(2025, 2, 28));
    await h.addLog(bookId: 'b1', date: DateTime(2025, 3, 1));
    await h.addLog(bookId: 'b2', date: DateTime(2025, 3, 3));
    await h.addLog(bookId: 'b1', date: DateTime(2025, 3, 4));
    await h.addLog(bookId: 'b1', date: DateTime(2025, 3, 5));
    final list = await h.readings
        .watchBetween(DateTime(2025, 3, 1), DateTime(2025, 3, 4))
        .first;
    expect(list.map((l) => l.date.day), [1, 3, 4]);
  });

  test('logs of deleted books and deleted logs are hidden', () async {
    final a = await h.addLog(bookId: 'b1', date: DateTime(2025, 3, 1));
    await h.addLog(bookId: 'b2', date: DateTime(2025, 3, 1));
    await h.books.softDelete('b2');
    expect(
      (await h.readings
              .watchBetween(DateTime(2025, 3, 1), DateTime(2025, 3, 1))
              .first)
          .map((l) => l.bookId),
      ['b1'],
    );
    expect((await h.readings.softDelete(a.id)).isOk, isTrue);
    expect(await h.readings.watchForBook('b1').first, isEmpty);
    expect(
      (await h.readings.findForDay('b1', DateTime(2025, 3, 1))).getOrNull(),
      isNull,
    );
    expect(
      (await h.readings.softDelete(a.id)).failureOrNull(),
      isA<NotFoundFailure>(),
    );
  });
}
