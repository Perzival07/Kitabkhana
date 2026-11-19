import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/providers.dart';
import 'package:kitabkhana/app/repositories.dart';
import 'package:kitabkhana/core/clock.dart';
import 'package:kitabkhana/data/db/app_database.dart';
import 'package:kitabkhana/data/db/database_provider.dart';
import 'package:kitabkhana/features/library/domain/book.dart';

import '../helpers/test_db.dart';

void main() {
  late ProviderContainer container;
  late AppDatabase db;
  final clock = FakeClock(DateTime(2025, 3, 10, 9));

  setUp(() {
    db = createTestDb();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('every repository provider resolves and shares the database', () async {
    final books = container.read(bookRepositoryProvider);
    container
      ..read(locationRepositoryProvider)
      ..read(loanRepositoryProvider)
      ..read(readingRepositoryProvider)
      ..read(quoteRepositoryProvider)
      ..read(goalRepositoryProvider)
      ..read(tagRepositoryProvider);

    final saved = await books.upsert(
      Book.create(id: 'a', title: 'Godan', now: clock.now()),
    );
    expect(saved.isOk, isTrue);
    // Same instance on every read (keepAlive).
    expect(container.read(bookRepositoryProvider), same(books));
    expect((await db.liveBooks().get()).single.id, 'a');
  });

  test('database providers never retry', () {
    expect(noRetry(0, Exception('x')), isNull);
    expect(noRetry(5, StateError('y')), isNull);
  });
}
