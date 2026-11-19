import '../../../core/result.dart';
import 'location.dart';

abstract interface class LocationRepository {
  /// Live non-deleted locations ordered by `sortOrder`, then name.
  Stream<List<Location>> watchAll();

  Future<Result<Location?>> getById(String id);

  /// Inserts or updates. Fails with a ConflictFailure when another live
  /// location under the same parent has the same name (ignoring case).
  Future<Result<Location>> upsert(Location location);

  /// Persists the order of [orderedIds] as `sortOrder` 0..n-1.
  Future<Result<void>> reorder(List<String> orderedIds);

  /// Soft-deletes the location. In the same transaction, books in it move to
  /// [moveBooksTo] (or to no location when null) and child locations are
  /// detached from their parent.
  Future<Result<void>> softDelete(String id, {String? moveBooksTo});

  /// Live count of live books in each location, keyed by location id.
  Stream<Map<String, int>> watchBookCounts();
}
