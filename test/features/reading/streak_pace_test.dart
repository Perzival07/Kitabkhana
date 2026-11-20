import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/reading/domain/pace.dart';
import 'package:kitabkhana/features/reading/domain/reading_log.dart';
import 'package:kitabkhana/features/reading/domain/streak.dart';

DateTime d(int m, int day, [int h = 0, int min = 0]) =>
    DateTime(2025, m, day, h, min);

ReadingLog log(DateTime date, int pages, {String book = 'b'}) =>
    ReadingLog.create(
      id: '${date.toIso8601String()}-$pages',
      bookId: book,
      date: DateTime(date.year, date.month, date.day),
      fromPage: 0,
      toPage: pages,
      now: date,
    );

void main() {
  group('streak', () {
    test('no days is no streak', () {
      expect(computeStreak(const <DateTime>[], d(3, 10)), Streak.none);
    });

    test('alive when today has a log', () {
      final s = computeStreak([d(3, 8), d(3, 9), d(3, 10)], d(3, 10, 23, 59));
      expect(s.current, 3);
    });

    test('alive when only yesterday has a log', () {
      final s = computeStreak([d(3, 8), d(3, 9)], d(3, 10, 0, 1));
      expect(s.current, 2);
    });

    test('broken when the last log is two days back', () {
      final s = computeStreak([d(3, 7), d(3, 8)], d(3, 10));
      expect(s.current, 0);
      expect(s.longest, 2);
    });

    test('longest survives a gap and duplicates and times of day', () {
      final s = computeStreak([
        d(3, 1, 9),
        d(3, 1, 21),
        d(3, 2),
        d(3, 3),
        d(3, 4),
        d(3, 8),
        d(3, 9),
      ], d(3, 9, 22));
      expect(s.current, 2);
      expect(s.longest, 4);
    });

    test('runs across a month and year boundary', () {
      final s = computeStreak([
        DateTime(2024, 12, 30),
        DateTime(2024, 12, 31),
        DateTime(2025, 1, 1),
      ], DateTime(2025, 1, 1, 0, 5));
      expect(s.current, 3);
    });

    test('just after midnight yesterday still counts', () {
      // 00:05 local: the day rolled over but the streak is not yet lost.
      final s = computeStreak([d(3, 9)], d(3, 10, 0, 5));
      expect(s.current, 1);
    });

    test('is not thrown by daylight-saving changes', () {
      // Days around a spring-forward are still consecutive calendar days.
      final s = computeStreak([
        DateTime(2025, 3, 8),
        DateTime(2025, 3, 9),
        DateTime(2025, 3, 10),
      ], DateTime(2025, 3, 10));
      expect(s.current, 3);
    });

    test('future days are ignored', () {
      final s = computeStreak([d(3, 11), d(3, 12)], d(3, 10));
      expect(s, Streak.none);
    });
  });

  group('pace', () {
    final today = d(3, 20);

    test('averages over days since start, not a fixed 14', () {
      // Started 5 days ago (16..20): 100 pages over 5 days = 20/day.
      final p = predictPace(
        remainingPages: 100,
        logs: [log(d(3, 17), 40), log(d(3, 19), 60)],
        today: today,
        startedOn: d(3, 16),
      )!;
      expect(p.pagesPerDay, 20);
      expect(p.daysLeft, 5);
      expect(p.finishBy, d(3, 25));
    });

    test('caps the window at 14 days and ignores older logs', () {
      final p = predictPace(
        remainingPages: 140,
        logs: [
          log(d(2, 1), 500), // outside the window
          log(d(3, 10), 70),
          log(d(3, 15), 70),
        ],
        today: today,
        startedOn: d(2, 1),
      )!;
      expect(p.pagesPerDay, 10);
      expect(p.daysLeft, 14);
    });

    test('too few reading days gives null', () {
      expect(
        predictPace(
          remainingPages: 100,
          logs: [log(d(3, 19), 50)],
          today: today,
          startedOn: d(3, 19),
        ),
        isNull,
      );
      expect(
        predictPace(remainingPages: 100, logs: const [], today: today),
        isNull,
      );
    });

    test('nothing left to read gives null', () {
      expect(
        predictPace(
          remainingPages: 0,
          logs: [log(d(3, 18), 10), log(d(3, 19), 10)],
          today: today,
        ),
        isNull,
      );
    });

    test('rounds days up and never says zero', () {
      final p = predictPace(
        remainingPages: 1,
        logs: [log(d(3, 19), 50), log(d(3, 20), 50)],
        today: today,
        startedOn: d(3, 19),
      )!;
      expect(p.daysLeft, 1);
    });

    test('falls back to the first log when startedOn is missing or late', () {
      final p = predictPace(
        remainingPages: 30,
        logs: [log(d(3, 18), 10), log(d(3, 20), 20)],
        today: today,
        startedOn: d(3, 20),
      )!;
      // window = 3 days (18..20): 30 pages / 3 = 10 per day.
      expect(p.pagesPerDay, 10);
      expect(p.daysLeft, 3);
    });
  });
}
