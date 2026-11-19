import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';

import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;

  setUp(() => h = RepoHarness());
  tearDown(() => h.dispose());

  Future<List<String>> names() async =>
      (await h.locations.watchAll().first).map((l) => l.name).toList();

  test('upsert inserts then updates with rev and timestamps', () async {
    final a = await h.addLocation(id: 'a', name: 'Bedroom');
    expect(a.rev, 1);
    h.tick();
    final b = (await h.locations.upsert(a.copyWith(name: 'Bedroom shelf')))
        .getOrNull()!;
    expect(b.rev, 2);
    expect(b.name, 'Bedroom shelf');
    expect(b.createdAt, a.createdAt);
    expect(b.updatedAt.isAfter(a.updatedAt), isTrue);
  });

  test('names are trimmed; blank names are invalid', () async {
    final a = await h.addLocation(name: '  Attic  ');
    expect(a.name, 'Attic');
    final blank = Location.create(id: 'x', name: '   ', now: h.clock.now());
    expect(
      (await h.locations.upsert(blank)).failureOrNull(),
      isA<ValidationFailure>(),
    );
  });

  group('duplicate names', () {
    test('rejected ignoring case under the same parent', () async {
      await h.addLocation(name: 'Bedroom');
      final dup = Location.create(id: 'd', name: 'BEDROOM', now: h.clock.now());
      expect(
        (await h.locations.upsert(dup)).failureOrNull(),
        isA<ConflictFailure>(),
      );
      expect(await names(), ['Bedroom']);
    });

    test('allowed under a different parent', () async {
      final room = await h.addLocation(id: 'room', name: 'Bedroom');
      final ok = await h.locations.upsert(
        Location.create(
          id: 'c',
          name: 'Bedroom',
          parentId: room.id,
          now: h.clock.now(),
        ),
      );
      expect(ok.isOk, isTrue);
    });

    test('a location may keep its own name when edited', () async {
      final a = await h.addLocation(name: 'Bedroom');
      final r = await h.locations.upsert(a.copyWith(icon: 'shelf'));
      expect(r.getOrNull()!.icon, 'shelf');
    });

    test('a deleted location frees its name', () async {
      final a = await h.addLocation(name: 'Bedroom');
      await h.locations.softDelete(a.id);
      expect((await h.addLocation(name: 'Bedroom')).name, 'Bedroom');
    });
  });

  test('watchAll orders by sortOrder then name', () async {
    await h.addLocation(name: 'Zed', sortOrder: 0);
    await h.addLocation(name: 'Alpha', sortOrder: 1);
    await h.addLocation(name: 'Beta', sortOrder: 0);
    expect(await names(), ['Beta', 'Zed', 'Alpha']);
  });

  test('reorder persists the given order and bumps rev', () async {
    final a = await h.addLocation(name: 'A');
    final b = await h.addLocation(name: 'B');
    final c = await h.addLocation(name: 'C');
    expect((await h.locations.reorder([c.id, a.id, b.id])).isOk, isTrue);
    final list = await h.locations.watchAll().first;
    expect(list.map((l) => l.name), ['C', 'A', 'B']);
    expect(list.map((l) => l.sortOrder), [0, 1, 2]);
    expect(list.every((l) => l.rev == 2), isTrue);
  });

  group('softDelete', () {
    test('moves books to another location in one step', () async {
      final from = await h.addLocation(name: 'From');
      final to = await h.addLocation(name: 'To');
      await h.addBook(id: 'b1', locationId: from.id);
      await h.addBook(id: 'b2', locationId: from.id);
      await h.addBook(id: 'b3', locationId: to.id);
      expect(
        (await h.locations.softDelete(from.id, moveBooksTo: to.id)).isOk,
        isTrue,
      );
      expect(await names(), ['To']);
      for (final id in <String>['b1', 'b2', 'b3']) {
        expect((await h.books.getById(id)).getOrNull()!.locationId, to.id);
      }
      expect((await h.books.getById('b1')).getOrNull()!.rev, 2);
    });

    test('without a target, books end up with no location', () async {
      final from = await h.addLocation(name: 'From');
      await h.addBook(id: 'b1', locationId: from.id);
      await h.locations.softDelete(from.id);
      expect((await h.books.getById('b1')).getOrNull()!.locationId, isNull);
    });

    test('child locations are detached from the deleted parent', () async {
      final room = await h.addLocation(id: 'room', name: 'Bedroom');
      await h.addLocation(id: 'shelf', name: 'Shelf 2', parentId: room.id);
      await h.locations.softDelete(room.id);
      final shelf = (await h.locations.getById('shelf')).getOrNull()!;
      expect(shelf.parentId, isNull);
    });

    test('invalid targets leave everything untouched', () async {
      final from = await h.addLocation(name: 'From');
      await h.addBook(id: 'b1', locationId: from.id);
      expect(
        (await h.locations.softDelete(
          from.id,
          moveBooksTo: from.id,
        )).failureOrNull(),
        isA<ValidationFailure>(),
      );
      expect(
        (await h.locations.softDelete(
          from.id,
          moveBooksTo: 'missing',
        )).failureOrNull(),
        isA<NotFoundFailure>(),
      );
      expect(await names(), ['From']);
      expect((await h.books.getById('b1')).getOrNull()!.locationId, from.id);
    });

    test('deleting a missing location is NotFound and rolls back', () async {
      final to = await h.addLocation(name: 'To');
      await h.addBook(id: 'b1', locationId: null);
      expect(
        (await h.locations.softDelete(
          'nope',
          moveBooksTo: to.id,
        )).failureOrNull(),
        isA<NotFoundFailure>(),
      );
    });

    test('getById hides deleted locations', () async {
      final a = await h.addLocation(name: 'A');
      await h.locations.softDelete(a.id);
      expect((await h.locations.getById(a.id)).getOrNull(), isNull);
    });
  });

  test('book counts update live and ignore deleted books', () async {
    final a = await h.addLocation(name: 'A');
    final b = await h.addLocation(name: 'B');
    final seen = <Map<String, int>>[];
    final sub = h.locations.watchBookCounts().listen(seen.add);
    await pumpEventQueue();
    await h.addBook(id: 'x1', locationId: a.id);
    await h.addBook(id: 'x2', locationId: a.id);
    await h.addBook(id: 'x3', locationId: b.id);
    await h.addBook(id: 'x4');
    await pumpEventQueue();
    expect(seen.last, {a.id: 2, b.id: 1});
    await h.books.softDelete('x1');
    await pumpEventQueue();
    await sub.cancel();
    expect(seen.last, {a.id: 1, b.id: 1});
    expect(seen.first, isEmpty);
  });
}
