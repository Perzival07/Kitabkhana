import '../../../core/result.dart';
import 'goal.dart';

abstract interface class GoalRepository {
  /// Live goal for [year]; emits null when none is set.
  Stream<Goal?> watchForYear(int year);

  Future<Result<Goal?>> getForYear(int year);

  /// Creates the goal for [year] or updates its target. Fails with a
  /// ValidationFailure when [targetBooks] is not positive.
  Future<Result<Goal>> setTarget(int year, int targetBooks);

  /// Removes the goal for [year].
  Future<Result<void>> clear(int year);
}
