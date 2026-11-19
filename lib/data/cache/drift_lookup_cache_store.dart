import 'package:drift/drift.dart';

import '../../features/library/domain/book_info_source.dart';
import '../db/app_database.dart';

/// [LookupCacheStore] backed by the `lookup_cache` table.
class DriftLookupCacheStore implements LookupCacheStore {
  DriftLookupCacheStore(this._db);

  final AppDatabase _db;

  @override
  Future<LookupCacheEntry?> get(String key) async {
    final row = await (_db.select(
      _db.lookupCache,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    return LookupCacheEntry(
      key: row.key,
      payloadJson: row.payloadJson,
      fetchedAt: row.fetchedAt,
      isNotFound: row.isNotFound,
    );
  }

  @override
  Future<void> put(LookupCacheEntry entry) {
    return _db
        .into(_db.lookupCache)
        .insertOnConflictUpdate(
          LookupCacheCompanion.insert(
            key: entry.key,
            payloadJson: entry.payloadJson,
            fetchedAt: entry.fetchedAt,
            isNotFound: Value(entry.isNotFound),
          ),
        );
  }
}
