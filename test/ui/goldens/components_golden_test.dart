@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/tokens.dart';
import 'package:kitabkhana/ui/ui.dart';

import '../../helpers/pump_app.dart';

const List<(String, String)> _books = <(String, String)>[
  ('The God of Small Things', 'Arundhati Roy'),
  ('Godan', 'Premchand'),
  ('Gitanjali', 'Rabindranath Tagore'),
  (
    'The Shadow Lines: A Novel of Memory, Borders and Belonging',
    'Amitav Ghosh',
  ),
  ('A Suitable Boy', 'Vikram Seth'),
  ('Train to Pakistan', 'Khushwant Singh'),
  ('Wings of Fire', 'A. P. J. Abdul Kalam'),
  ('The White Tiger', 'Aravind Adiga'),
  ('Pather Panchali', 'Bibhutibhushan Bandyopadhyay'),
  ('Midnight’s Children', 'Salman Rushdie'),
];

void main() {
  for (final dark in <bool>[false, true]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('KBookCover sizes ($mode)', (t) async {
      await pumpThemed(
        t,
        Padding(
          padding: const EdgeInsets.all(KSpacing.screen),
          child: Wrap(
            spacing: KSpacing.lg,
            runSpacing: KSpacing.lg,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: <Widget>[
              for (final s in KCoverSize.values)
                KBookCover(
                  title: _books.first.$1,
                  author: _books.first.$2,
                  size: s,
                ),
            ],
          ),
        ),
        dark: dark,
        size: const Size(400, 600),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/k_book_cover_$mode.png'),
      );
    });

    testWidgets('KGeneratedCover palette ($mode)', (t) async {
      await pumpThemed(
        t,
        Padding(
          padding: const EdgeInsets.all(KSpacing.lg),
          child: Wrap(
            spacing: KSpacing.md,
            runSpacing: KSpacing.md,
            children: <Widget>[
              for (final b in _books)
                KBookCover(title: b.$1, author: b.$2, size: KCoverSize.md),
            ],
          ),
        ),
        dark: dark,
        size: const Size(620, 720),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/k_generated_cover_$mode.png'),
      );
    });

    testWidgets('KButton variants ($mode)', (t) async {
      await pumpThemed(
        t,
        Padding(
          padding: const EdgeInsets.all(KSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: KSpacing.md,
            children: <Widget>[
              KButton(label: 'Primary', onPressed: () {}),
              KButton(
                label: 'Secondary',
                variant: KButtonVariant.secondary,
                onPressed: () {},
              ),
              KButton(
                label: 'Tonal with icon',
                variant: KButtonVariant.tonal,
                icon: Icons.add_rounded,
                onPressed: () {},
              ),
              KButton(
                label: 'Text',
                variant: KButtonVariant.text,
                onPressed: () {},
              ),
              KButton(label: 'Loading', loading: true, onPressed: () {}),
              const KButton(label: 'Disabled', onPressed: null),
            ],
          ),
        ),
        dark: dark,
        size: const Size(360, 420),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/k_button_$mode.png'),
      );
    });

    testWidgets('KEmptyState ($mode)', (t) async {
      await pumpThemed(
        t,
        Row(
          children: <Widget>[
            for (final i in KIllustration.values)
              Expanded(
                child: KEmptyState(
                  illustration: i,
                  illustrationSize: 120,
                  title: 'Nothing yet',
                  body: 'A short, warm line about what to do next.',
                  actionLabel: 'Add a book',
                  onAction: () {},
                ),
              ),
          ],
        ),
        dark: dark,
        size: const Size(1280, 480),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/k_empty_state_$mode.png'),
      );
    });
  }
}
