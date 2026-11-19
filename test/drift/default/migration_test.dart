import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/data/db/app_database.dart';

import '../../helpers/test_db.dart';
import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('a fresh v1 database matches the exported v1 schema', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 1);
  });

  test('onCreate builds every table, trigger and index', () async {
    final db = createTestDb();
    addTearDown(db.close);
    final names =
        (await db.customSelect('SELECT name FROM sqlite_master').get())
            .map((r) => r.read<String>('name'))
            .toSet();
    for (final n in <String>[
      'books',
      'locations',
      'loans',
      'reading_logs',
      'quotes',
      'goals',
      'tags',
      'book_tags',
      'lookup_cache',
      'app_meta',
      'books_fts',
      'books_fts_ai',
      'books_fts_ad',
      'books_fts_au',
      'uq_loans_one_active_per_book',
      'idx_loans_due_open',
      'idx_books_isbn13',
    ]) {
      expect(names, contains(n));
    }
  });
}
