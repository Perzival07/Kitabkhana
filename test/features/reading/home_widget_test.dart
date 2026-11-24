import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/reading/application/widget_snapshot.dart';
import 'package:kitabkhana/l10n/app_localizations_en.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

Book reading(String id, String title, {int page = 100, int? pages = 400}) =>
    Book.create(
      id: id,
      title: title,
      authors: 'George Eliot',
      now: DateTime(2025),
      pages: pages,
      status: ReadStatus.reading,
    ).copyWith(currentPage: page);

void main() {
  final l10n = AppLocalizationsEn();

  test('the book being read, its page and progress', () {
    final s = buildWidgetSnapshot(
      l10n,
      reading: <Book>[reading('a', 'Middlemarch')],
      lentOut: 0,
      overdue: 0,
    );
    expect(s.label, 'Currently reading');
    expect(s.title, 'Middlemarch');
    expect(s.subtitle, 'George Eliot · Page 100 of 400');
    expect(s.progress, 25);
    expect(s.footer, '');
  });

  test('loans come first in the footer, then other books', () {
    final books = <Book>[reading('a', 'A'), reading('b', 'B')];
    expect(
      buildWidgetSnapshot(l10n, reading: books, lentOut: 2, overdue: 1).footer,
      '1 book overdue',
    );
    expect(
      buildWidgetSnapshot(l10n, reading: books, lentOut: 2, overdue: 0).footer,
      '2 books lent out',
    );
    expect(
      buildWidgetSnapshot(l10n, reading: books, lentOut: 0, overdue: 0).footer,
      'and 1 more on the go',
    );
  });

  test('nothing being read, and no page count', () {
    final empty = buildWidgetSnapshot(
      l10n,
      reading: const <Book>[],
      lentOut: 0,
      overdue: 0,
    );
    expect(empty.title, 'Nothing on the go');
    expect(empty.progress, isNull);
    final noPages = buildWidgetSnapshot(
      l10n,
      reading: <Book>[reading('a', 'A', page: 12, pages: null)],
      lentOut: 0,
      overdue: 0,
    );
    expect(noPages.progress, isNull);
    expect(noPages.subtitle, contains('12'));
  });

  testWidgets('the widget follows the library', (t) async {
    final h = AddFlowHarness();
    addTearDown(h.dispose);
    await t.runAsync(() => h.repos.books.upsert(reading('a', 'Middlemarch')));
    final c = await pumpRouterApp(
      t,
      size: const Size(420, 900),
      overrides: h.overrides,
    );
    routerOf(c).go('/reading');
    await t.pumpAndSettle();
    expect(h.homeWidget.shown.last.title, 'Middlemarch');
    expect(h.homeWidget.shown.last.progress, 25);

    await t.tap(find.text('Update page'));
    await t.pumpAndSettle();
    await t.tap(find.text('+25'));
    await t.pump();
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(h.homeWidget.shown.last.subtitle, 'George Eliot · Page 125 of 400');
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  });
}
