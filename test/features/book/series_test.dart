import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/core/text/series.dart';
import 'package:kitabkhana/data/open_library/open_library_mapper.dart';
import 'package:kitabkhana/features/backup/application/reading_app_import.dart';
import 'package:kitabkhana/features/library/domain/book.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';
import '../../helpers/repo_harness.dart';

void main() {
  group('parsing', () {
    test('catalogue series text', () {
      expect(parseSeries('Discworld'), (name: 'Discworld', number: null));
      expect(parseSeries('Discworld (4)'), (name: 'Discworld', number: 4.0));
      expect(parseSeries('Discworld ; 4'), (name: 'Discworld', number: 4.0));
      expect(parseSeries('Discworld, #4'), (name: 'Discworld', number: 4.0));
      expect(parseSeries('Discworld -- 4'), (name: 'Discworld', number: 4.0));
      expect(parseSeries('Harry Potter, book 1'), (
        name: 'Harry Potter',
        number: 1.0,
      ));
      expect(parseSeries('Earthsea #2.5'), (name: 'Earthsea', number: 2.5));
      expect(parseSeries('  '), isNull);
    });

    test('series in a Goodreads title', () {
      expect(splitSeriesFromTitle('The Colour of Magic (Discworld, #1)'), (
        title: 'The Colour of Magic',
        series: 'Discworld',
        number: 1.0,
      ));
      expect(splitSeriesFromTitle('Tales (Earthsea Cycle #5.5)'), (
        title: 'Tales',
        series: 'Earthsea Cycle',
        number: 5.5,
      ));
      expect(splitSeriesFromTitle('Dune (40th Anniversary Edition)'), isNull);
      expect(splitSeriesFromTitle('Middlemarch'), isNull);
    });

    test('copyWith takes a whole series number', () {
      final b = Book.create(
        id: 'x',
        title: 'X',
        now: DateTime(2025),
      ).copyWith(series: 'S', seriesNumber: 4);
      expect(b.seriesNumber, 4.0);
      expect(b.copyWith(seriesNumber: null).seriesNumber, isNull);
      expect(b.copyWith(title: 'Y').seriesNumber, 4.0);
    });

    test('gaps and numbers', () {
      expect(seriesGaps(<double?>[1, 4, null, 2.5]), <int>[2, 3]);
      expect(seriesGaps(<double?>[1, 2, 3]), isEmpty);
      expect(seriesGaps(<double?>[null]), isEmpty);
      expect(seriesNumberText(4), '4');
      expect(seriesNumberText(2.5), '2.5');
    });
  });

  test('Open Library editions carry their series', () {
    final info = OpenLibraryMapper.edition(<String, Object?>{
      'title': 'Mort',
      'series': <Object?>['Discworld (4)'],
    }, isbn: parseIsbn('9780552131063')!)!;
    expect(info.series, 'Discworld');
    expect(info.seriesNumber, 4);
  });

  test('a Goodreads import splits the series off the title', () {
    final r = parseReadingAppCsv(
      'Title,Author,ISBN13,Exclusive Shelf\n'
      '"Mort (Discworld, #4)",Terry Pratchett,,read\n',
    );
    final b = (r as Ok<ReadingAppExport>).value.books.single;
    expect(b.title, 'Mort');
    expect(b.series, 'Discworld');
    expect(b.seriesNumber, 4);
  });

  test('the library lists a series in order', () async {
    final h = RepoHarness();
    addTearDown(h.db.close);
    Future<void> add(String id, String title, double? n) => h.addBook(
      id: id,
      title: title,
      tweak: (b) => b.copyWith(series: 'Discworld', seriesNumber: n),
    );
    await add('c', 'Mort', 4);
    await add('a', 'The Colour of Magic', 1);
    await add('x', 'Unnumbered', null);
    await h.addBook(id: 'o', title: 'Other');
    final list = await h.books.watchSeries('discworld').first;
    expect(list.map((b) => b.id), <String>['a', 'c', 'x']);
  });

  testWidgets('the book page shows its place in the series and the gaps', (
    t,
  ) async {
    final h = AddFlowHarness();
    addTearDown(h.dispose);
    await t.runAsync(() async {
      for (final (id, title, n) in <(String, String, double)>[
        ('a', 'The Colour of Magic', 1),
        ('d', 'Mort', 4),
      ]) {
        await h.repos.books.upsert(
          Book.create(
            id: id,
            title: title,
            now: DateTime(2025),
            series: 'Discworld',
            seriesNumber: n,
          ),
        );
      }
    });
    final c = await pumpRouterApp(
      t,
      size: const Size(420, 1600),
      overrides: h.overrides,
    );
    routerOf(c).go('/book/d');
    await t.pumpAndSettle();
    expect(find.text('Book 4 of Discworld'), findsOneWidget);
    expect(find.text('In your library'), findsOneWidget);
    expect(find.text('The Colour of Magic'), findsOneWidget);
    expect(find.text('Missing: 2, 3'), findsOneWidget);
  });

  testWidgets('series can be typed on the edit form', (t) async {
    final h = AddFlowHarness();
    addTearDown(h.dispose);
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(id: 'b', title: 'Wyrd Sisters', now: DateTime(2025)),
      ),
    );
    final c = await pumpRouterApp(
      t,
      size: const Size(420, 2400),
      overrides: h.overrides,
    );
    routerOf(c).go('/book/b/edit');
    await t.pumpAndSettle();
    await t.enterText(
      find.widgetWithText(TextFormField, 'Series'),
      'Discworld',
    );
    await t.enterText(find.widgetWithText(TextFormField, 'No.'), '6');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    final book = (await t.runAsync(() => h.repos.books.getById('b')))!
        .getOrNull()!;
    expect(book.series, 'Discworld');
    expect(book.seriesNumber, 6);
  });
}
