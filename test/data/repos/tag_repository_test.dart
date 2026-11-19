import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/features/library/domain/book_filter.dart';

import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;

  setUp(() async {
    h = RepoHarness();
    await h.addBook(id: 'b1', title: 'One');
    await h.addBook(id: 'b2', title: 'Two');
  });
  tearDown(() => h.dispose());

  Future<List<String>> allTags() async =>
      (await h.tags.watchAll().first).map((t) => t.name).toList();

  Future<List<String>> tagsOf(String bookId) async =>
      (await h.tags.watchForBook(bookId).first).map((t) => t.name).toList();

  test(
    'createIfAbsent creates and returns the existing tag ignoring case',
    () async {
      final a = (await h.tags.createIfAbsent('Fiction')).getOrNull()!;
      final b = (await h.tags.createIfAbsent('  fiction ')).getOrNull()!;
      expect(b.id, a.id);
      expect(a.name, 'Fiction');
      expect(await allTags(), ['Fiction']);
    },
  );

  test('blank names are invalid', () async {
    expect(
      (await h.tags.createIfAbsent('   ')).failureOrNull(),
      isA<ValidationFailure>(),
    );
  });

  test('watchAll is ordered by name ignoring case', () async {
    for (final n in <String>['banana', 'Apple', 'cherry', 'Avocado']) {
      await h.tags.createIfAbsent(n);
    }
    expect(await allTags(), ['Apple', 'Avocado', 'banana', 'cherry']);
  });

  test('attach is idempotent and watchForBook lists a book\'s tags', () async {
    final fic = (await h.tags.createIfAbsent('Fiction')).getOrNull()!;
    final his = (await h.tags.createIfAbsent('History')).getOrNull()!;
    await h.tags.attach('b1', his.id);
    await h.tags.attach('b1', fic.id);
    await h.tags.attach('b1', fic.id);
    await h.tags.attach('b2', fic.id);
    expect(await tagsOf('b1'), ['Fiction', 'History']);
    expect(await tagsOf('b2'), ['Fiction']);
    final links = await h.db.select(h.db.bookTags).get();
    expect(links.where((l) => l.deletedAt == null), hasLength(3));
  });

  test('attach validates book and tag', () async {
    final fic = (await h.tags.createIfAbsent('Fiction')).getOrNull()!;
    expect(
      (await h.tags.attach('nope', fic.id)).failureOrNull(),
      isA<NotFoundFailure>(),
    );
    expect(
      (await h.tags.attach('b1', 'nope')).failureOrNull(),
      isA<NotFoundFailure>(),
    );
  });

  test('detach removes only that link and can be re-attached', () async {
    final fic = (await h.tags.createIfAbsent('Fiction')).getOrNull()!;
    await h.tags.attach('b1', fic.id);
    await h.tags.attach('b2', fic.id);
    expect((await h.tags.detach('b1', fic.id)).isOk, isTrue);
    expect(await tagsOf('b1'), isEmpty);
    expect(await tagsOf('b2'), ['Fiction']);
    expect((await h.tags.detach('b1', fic.id)).isOk, isTrue); // no-op
    await h.tags.attach('b1', fic.id);
    expect(await tagsOf('b1'), ['Fiction']);
  });

  test('softDelete hides the tag and detaches it everywhere', () async {
    final fic = (await h.tags.createIfAbsent('Fiction')).getOrNull()!;
    await h.tags.attach('b1', fic.id);
    expect((await h.tags.softDelete(fic.id)).isOk, isTrue);
    expect(await allTags(), isEmpty);
    expect(await tagsOf('b1'), isEmpty);
    expect(
      await h.books.watchAll(filter: BookFilter(tagId: fic.id)).first,
      isEmpty,
    );
    expect(
      (await h.tags.softDelete(fic.id)).failureOrNull(),
      isA<NotFoundFailure>(),
    );
    // The name is free again.
    final again = (await h.tags.createIfAbsent('Fiction')).getOrNull()!;
    expect(again.id, isNot(fic.id));
  });

  test('deleting a book hides its tags from watchForBook consumers', () async {
    final fic = (await h.tags.createIfAbsent('Fiction')).getOrNull()!;
    await h.tags.attach('b1', fic.id);
    await h.books.softDelete('b1');
    expect(
      await h.books.watchCount(filter: BookFilter(tagId: fic.id)).first,
      0,
    );
  });
}
