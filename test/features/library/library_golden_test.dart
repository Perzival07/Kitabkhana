@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';

import '../../helpers/add_flow_harness.dart';

void main() {
  const titles = <(String, String, ReadStatus)>[
    ('Piranesi', 'Susanna Clarke', ReadStatus.finished),
    ('The Name of the Wind', 'Patrick Rothfuss', ReadStatus.reading),
    ('A Gentleman in Moscow', 'Amor Towles', ReadStatus.want),
    ('Circe', 'Madeline Miller', ReadStatus.finished),
    ('Pride and Prejudice', 'Jane Austen', ReadStatus.want),
    ('Dune', 'Frank Herbert', ReadStatus.reading),
    ('The God of Small Things', 'Arundhati Roy', ReadStatus.finished),
    ('Norwegian Wood', 'Haruki Murakami', ReadStatus.dropped),
  ];
  const sizes = <String, Size>{'360': Size(360, 800), '800': Size(800, 1000)};
  for (final dark in <bool>[false, true]) {
    for (final s in sizes.entries) {
      for (final list in <bool>[false, true]) {
        final mode = dark ? 'dark' : 'light';
        final kind = list ? 'list' : 'grid';
        testWidgets('library $kind ${s.key} ($mode)', (t) async {
          final h = AddFlowHarness();
          addTearDown(h.dispose);
          for (var i = 0; i < titles.length; i++) {
            final (title, author, status) = titles[i];
            var b = Book.create(
              id: 'b$i',
              title: title,
              authors: author,
              now: h.clock.now(),
              status: status,
              pages: 300,
            );
            if (status == ReadStatus.reading) b = b.copyWith(currentPage: 120);
            await h.repos.books.upsert(b);
          }
          final c = await h.pump(t, start: '/library', size: s.value);
          if (list) {
            await t.tap(find.byTooltip('Show as list'));
            await t.pumpAndSettle();
          }
          if (dark) {
            c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
            await t.pumpAndSettle();
          }
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/library_${kind}_${s.key}_$mode.png'),
          );
        });
      }
    }
  }
}
