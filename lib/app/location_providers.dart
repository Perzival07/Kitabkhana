import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/db/app_database.dart';
import '../data/db/database_provider.dart';
import 'providers.dart';
import 'repositories.dart';

part 'location_providers.g.dart';

/// Live number of books in each location, keyed by location id.
@riverpod
Stream<Map<String, int>> locationBookCounts(Ref ref) =>
    ref.watch(locationRepositoryProvider).watchBookCounts();

const String _recentKey = 'location.recent';
const String _starterKey = 'location.starter_done';

Future<String?> _readMeta(AppDatabase db, String key) async {
  final row = await (db.select(
    db.appMeta,
  )..where((t) => t.key.equals(key))).getSingleOrNull();
  return row?.value;
}

Future<void> _writeMeta(AppDatabase db, String key, String value) => db
    .into(db.appMeta)
    .insertOnConflictUpdate(
      AppMetaCompanion(key: Value(key), value: Value(value)),
    );

/// Ids of recently chosen locations, newest first. Kept on this device.
@Riverpod(keepAlive: true)
class RecentLocations extends _$RecentLocations {
  @override
  List<String> build() {
    _load();
    return const <String>[];
  }

  Future<void> _load() async {
    try {
      final raw = await _readMeta(ref.read(appDatabaseProvider), _recentKey);
      if (raw != null && raw.isNotEmpty && ref.mounted) {
        state = raw.split(',');
      }
    } on Object catch (e) {
      ref.read(appLoggerProvider).warn('Reading recent locations failed: $e');
    }
  }

  Future<void> touch(String id) async {
    final next = <String>[id, ...state.where((e) => e != id)].take(5).toList();
    state = next;
    try {
      await _writeMeta(
        ref.read(appDatabaseProvider),
        _recentKey,
        next.join(','),
      );
    } on Object catch (e) {
      ref.read(appLoggerProvider).warn('Saving recent locations failed: $e');
    }
  }
}

/// Whether the first-run starter suggestion was accepted or skipped.
@Riverpod(keepAlive: true)
class StarterLocationsDone extends _$StarterLocationsDone {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    try {
      final raw = await _readMeta(ref.read(appDatabaseProvider), _starterKey);
      if (raw == '1' && ref.mounted) state = true;
    } on Object catch (e) {
      ref.read(appLoggerProvider).warn('Reading starter flag failed: $e');
    }
  }

  Future<void> markDone() async {
    state = true;
    try {
      await _writeMeta(ref.read(appDatabaseProvider), _starterKey, '1');
    } on Object catch (e) {
      ref.read(appLoggerProvider).warn('Saving starter flag failed: $e');
    }
  }
}
