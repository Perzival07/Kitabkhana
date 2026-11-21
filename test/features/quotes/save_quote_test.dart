import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/features/quotes/application/save_quote.dart';
import 'package:kitabkhana/platform/ocr/web_ocr_service.dart';

import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;
  late SaveQuote save;
  var n = 0;

  setUp(() {
    h = RepoHarness();
    n = 0;
    save = SaveQuote(
      quotes: h.quotes,
      books: h.books,
      clock: h.clock,
      newId: () => 'q${++n}',
    );
  });

  tearDown(() => h.db.close());

  test('saves trimmed text with its page', () async {
    final b = await h.addBook(pages: 300);
    final q = (await save(
      bookId: b.id,
      body: '  Hello.  ',
      page: 42,
    )).getOrNull()!;
    expect(q.body, 'Hello.');
    expect(q.page, 42);
    expect(q.id, 'q1');
    expect(q.isFavourite, isFalse);
  });

  test('page is optional', () async {
    final b = await h.addBook();
    expect((await save(bookId: b.id, body: 'x')).getOrNull()!.page, isNull);
  });

  test('empty text, a page below 1 or past the end are refused', () async {
    final b = await h.addBook(pages: 100);
    for (final r in [
      await save(bookId: b.id, body: '   '),
      await save(bookId: b.id, body: 'x', page: 0),
      await save(bookId: b.id, body: 'x', page: 101),
    ]) {
      expect((r as Err).failure, isA<ValidationFailure>());
    }
    expect(await h.db.liveQuotes().get(), isEmpty);
  });

  test('any page is fine when the page count is unknown', () async {
    final b = await h.addBook();
    expect((await save(bookId: b.id, body: 'x', page: 5000)).isOk, isTrue);
  });

  test('a missing or deleted book is NotFound', () async {
    expect(
      ((await save(bookId: 'nope', body: 'x')) as Err).failure,
      isA<NotFoundFailure>(),
    );
    final b = await h.addBook();
    await h.books.softDelete(b.id);
    expect(
      ((await save(bookId: b.id, body: 'x')) as Err).failure,
      isA<NotFoundFailure>(),
    );
  });

  test('the web reader is unsupported and says so', () async {
    const ocr = WebOcrService();
    expect(ocr.isSupported, isFalse);
    final r = await ocr.recognise(jpeg);
    expect((r as Err).failure, isA<UnsupportedOnPlatformFailure>());
  });
}

final jpeg = Uint8List.fromList(<int>[1, 2, 3]);
