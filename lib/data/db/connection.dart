import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Opens the on-device database: SQLite via FFI on mobile (WAL mode) and
/// sqlite3.wasm with a shared worker on web (`web/sqlite3.wasm` and
/// `web/drift_worker.js`).
QueryExecutor openAppConnection({String name = 'kitabkhana'}) {
  return driftDatabase(
    name: name,
    native: DriftNativeOptions(
      setup: (db) {
        db.execute('PRAGMA journal_mode = WAL');
        db.execute('PRAGMA foreign_keys = ON');
      },
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
