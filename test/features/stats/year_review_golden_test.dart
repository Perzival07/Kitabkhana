@Tags(<String>['golden'])
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/stats/presentation/year_review_card.dart';

import '../../helpers/pump_app.dart';

const YearReviewCardData data = YearReviewCardData(
  title: 'My 2026 in books',
  bigNumber: '24',
  bigLabel: 'books finished',
  figures: <(String, String)>[
    ('7,412', 'pages read'),
    ('19', 'longest streak (days)'),
    ('24/20', 'reading goal'),
  ],
  monthInitials: <String>[
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
  ],
  perMonth: <int>[2, 1, 3, 2, 0, 4, 2, 1, 3, 2, 3, 1],
  lines: <(String, String)>[
    ('Favourite genre', 'Classics'),
    ('Most-read author', 'Jane Austen'),
    ('Longest book', 'Middlemarch · 880 pages'),
  ],
  footer: 'Made with Kitabkhana',
);

void main() {
  testWidgets('year review card', (t) async {
    await pumpThemed(
      t,
      const Center(
        child: SizedBox(width: 360, child: YearReviewCard(data: data)),
      ),
      size: const Size(400, 700),
    );
    await expectLater(
      find.byType(YearReviewCard),
      matchesGoldenFile('goldens/year_review_card.png'),
    );
  });

  testWidgets('the card renders to a 1080 x 1920 PNG', (t) async {
    final png = await t.runAsync(() => renderYearReviewPng(data));
    expect(png!.sublist(0, 4), <int>[0x89, 0x50, 0x4E, 0x47]);
    final codec = await t.runAsync(() async {
      final c = await ui.instantiateImageCodec(png);
      return (await c.getNextFrame()).image;
    });
    expect((codec!.width, codec.height), (1080, 1920));
  });
}
