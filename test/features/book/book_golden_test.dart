@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/app_theme.dart';
import 'package:kitabkhana/features/book/presentation/book_detail_screen.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/l10n/app_localizations.dart';

import '../../helpers/add_flow_harness.dart';

void main() {
  const long =
      'The Extraordinarily Long and Winding Tale of a Small Book That Never '
      'Seems to End Despite Everyone Asking It To Please Stop Now';
  for (final dark in <bool>[false, true]) {
    for (final long0 in <bool>[false, true]) {
      final mode = dark ? 'dark' : 'light';
      final name = long0 ? 'longtitle' : 'reading';
      testWidgets('book detail $name ($mode)', (t) async {
        final h = AddFlowHarness();
        addTearDown(h.dispose);
        await h.repos.books.upsert(
          Book.create(
            id: 'b1',
            title: long0 ? long : 'Dune',
            authors: 'Frank Herbert',
            now: h.clock.now(),
            pages: 412,
            status: ReadStatus.reading,
            notes: 'Spice must flow.',
          ).copyWith(currentPage: 180, startedOn: DateTime(2025, 3)),
        );
        t.view
          ..physicalSize = const Size(360, 1500)
          ..devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          ProviderScope(
            overrides: h.overrides,
            child: MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const BookDetailScreen(bookId: 'b1', embedded: true),
            ),
          ),
        );
        await t.pump();
        await t.pump(const Duration(milliseconds: 500));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/detail_${name}_$mode.png'),
        );
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(milliseconds: 400));
      });
    }
  }
}
