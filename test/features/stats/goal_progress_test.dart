import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/stats/domain/goal_progress.dart';

void main() {
  GoalProgress at(DateTime today, int finished, {int target = 24, int? year}) =>
      goalProgress(
        year: year ?? today.year,
        target: target,
        finished: finished,
        today: today,
      );

  test('reaching the target is reached in any year', () {
    expect(at(DateTime(2025, 3, 1), 24).status, GoalStatus.reached);
    expect(at(DateTime(2026, 1, 1), 30, year: 2025).status, GoalStatus.reached);
    expect(at(DateTime(2025, 1, 1), 24, year: 2027).status, GoalStatus.reached);
  });

  test('ahead and behind are whole books against an even pace', () {
    // Mid-year (day 182 of 365): 12 expected of 24.
    final mid = DateTime(2025, 7, 1);
    expect(at(mid, 15).status, GoalStatus.ahead);
    expect(at(mid, 15).books, 3);
    expect(at(mid, 9).status, GoalStatus.behind);
    expect(at(mid, 9).books, 3);
    expect(at(mid, 12).status, GoalStatus.onPace);
    expect(at(mid, 13).status, GoalStatus.ahead, reason: 'a full book up');
    expect(at(mid, 13).books, 1);
  });

  test('on 1 January nothing is behind', () {
    expect(at(DateTime(2025, 1, 1), 0).status, GoalStatus.onPace);
  });

  test('leap years use 366 days', () {
    // 30 Dec 2024 is day 365 of 366: 23.93 expected of 24.
    expect(at(DateTime(2024, 12, 30), 23).status, GoalStatus.onPace);
    expect(at(DateTime(2024, 12, 30), 22).status, GoalStatus.behind);
  });

  test('past years are missed by the shortfall; future years upcoming', () {
    final r = at(DateTime(2026, 2, 1), 18, year: 2025);
    expect(r.status, GoalStatus.missed);
    expect(r.books, 6);
    expect(at(DateTime(2025, 2, 1), 0, year: 2026).status, GoalStatus.upcoming);
  });

  test('fraction is clamped to 0..1', () {
    expect(at(DateTime(2025, 1, 1), 30).fraction, 1);
    expect(at(DateTime(2025, 1, 1), 6).fraction, 0.25);
    expect(at(DateTime(2025, 1, 1), 0).fraction, 0);
  });
}
