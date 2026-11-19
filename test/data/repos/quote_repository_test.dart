import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/features/quotes/domain/quote.dart';

import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;

  setUp(() async {
    h = RepoHarness();
    await h.addBook(id: 'b1', title: 'One');
    await h.addBook(id: 'b2', title: 'Two');
  });
  tearDown(() => h.dispose());

  Future<Quote> addQuote(
    String bookId,
    String body, {
    int? page,
    bool fav = false,
  }) async {
    h.tick();
    final r = await h.quotes.upsert(
      Quote.create(
        id: h.nextId('q'),
        bookId: bookId,
        body: body,
        page: page,
        isFavourite: fav,
        now: h.clock.now(),
      ),
    );
    return r.getOrNull()!;
  }

  Future<List<String>> bodies({String? bookId, bool fav = false}) async =>
      (await h.quotes.watchAll(bookId: bookId, favouritesOnly: fav).first)
          .map((q) => q.body)
          .toList();

  test('upsert inserts, then updates with rev', () async {
    final q = await addQuote('b1', 'Hello', page: 42);
    expect(q.rev, 1);
    expect(q.page, 42);
    h.tick();
    final u = (await h.quotes.upsert(q.copyWith(body: 'Hello!', page: null)))
        .getOrNull()!;
    expect(u.rev, 2);
    expect(u.body, 'Hello!');
    expect(u.page, isNull);
    expect(u.createdAt, q.createdAt);
  });

  test('watchAll is newest first and filters by book and favourite', () async {
    await addQuote('b1', 'first');
    await addQuote('b2', 'second', fav: true);
    await addQuote('b1', 'third', fav: true);
    expect(await bodies(), ['third', 'second', 'first']);
    expect(await bodies(bookId: 'b1'), ['third', 'first']);
    expect(await bodies(fav: true), ['third', 'second']);
    expect(await bodies(bookId: 'b1', fav: true), ['third']);
  });

  test('marking a favourite updates the list', () async {
    final q = await addQuote('b1', 'x');
    await h.quotes.upsert(q.copyWith(isFavourite: true));
    expect(await bodies(fav: true), ['x']);
  });

  test('soft delete hides, restore brings back', () async {
    final q = await addQuote('b1', 'x');
    expect((await h.quotes.softDelete(q.id)).isOk, isTrue);
    expect(await bodies(), isEmpty);
    expect((await h.quotes.getById(q.id)).getOrNull(), isNull);
    expect(
      (await h.quotes.softDelete(q.id)).failureOrNull(),
      isA<NotFoundFailure>(),
    );
    expect((await h.quotes.restore(q.id)).isOk, isTrue);
    expect(await bodies(), ['x']);
    expect(
      (await h.quotes.restore(q.id)).failureOrNull(),
      isA<NotFoundFailure>(),
    );
  });

  test('quotes of deleted books are hidden', () async {
    await addQuote('b1', 'keep');
    await addQuote('b2', 'drop');
    await h.books.softDelete('b2');
    expect(await bodies(), ['keep']);
  });

  test('a quote needs an existing book', () async {
    final r = await h.quotes.upsert(
      Quote.create(id: 'q', bookId: 'nope', body: 'x', now: h.clock.now()),
    );
    expect(r.failureOrNull(), isA<ValidationFailure>());
  });

  test('stores long and Unicode text intact', () async {
    final text = '${'गोदान ' * 500}— “quoted” 😀';
    final q = await addQuote('b1', text);
    expect((await h.quotes.getById(q.id)).getOrNull()!.body, text);
  });
}
