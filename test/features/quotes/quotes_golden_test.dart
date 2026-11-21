@Tags(<String>['golden'])
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/quotes/domain/quote.dart';
import 'package:kitabkhana/features/quotes/presentation/quote_card.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_app.dart';

void main() {
  const short = QuoteCardData(
    body:
        'It is a truth universally acknowledged, that a single man in '
        'possession of a good fortune, must be in want of a wife.',
    attribution: 'Pride and Prejudice, p. 1',
  );
  final long = QuoteCardData(
    body: List<String>.filled(
      14,
      'The only people for me are the mad ones, the ones who are mad to live.',
    ).join(' '),
    attribution: 'On the Road, a book with a rather long title, p. 8',
  );

  for (final (name, data) in <(String, QuoteCardData)>[
    ('short', short),
    ('long', long),
  ]) {
    testWidgets('quote card ($name)', (t) async {
      await pumpThemed(
        t,
        Center(
          child: SizedBox(width: 360, child: QuoteCardPreview(data: data)),
        ),
        size: const Size(400, 500),
      );
      await expectLater(
        find.byType(QuoteCardPreview),
        matchesGoldenFile('goldens/quote_card_$name.png'),
      );
    });
  }

  testWidgets('the card renders to a 1080 x 1350 PNG', (t) async {
    final png = await t.runAsync(() => renderQuoteCardPng(short));
    expect(png!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    final codec = await t.runAsync(() => instantiate(png));
    expect((codec!.width, codec.height), (1080, 1350));
  });

  for (final dark in <bool>[false, true]) {
    final mode = dark ? 'dark' : 'light';
    testWidgets('quotes screen ($mode)', (t) async {
      final h = AddFlowHarness();
      addTearDown(h.dispose);
      final now = DateTime(2025, 3, 10);
      await h.repos.books.upsert(
        Book.create(id: 'b', title: 'Middlemarch', now: now, pages: 880),
      );
      await h.repos.quotes.upsert(
        Quote.create(
          id: 'q1',
          bookId: 'b',
          body: 'It is a narrow mind which cannot look at a subject from various points of view.',
          page: 193,
          isFavourite: true,
          now: now,
        ),
      );
      await h.repos.quotes.upsert(
        Quote.create(
          id: 'q2',
          bookId: 'b',
          body: 'Every limit is a beginning as well as an ending.',
          now: now,
        ),
      );
      final c = await h.pump(
        t,
        start: '/quotes',
        size: const Size(360, 780),
        disableAnimations: true,
      );
      if (dark) {
        c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
        await t.pumpAndSettle();
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/quotes_$mode.png'),
      );
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 400));
    });
  }
}

Future<({int width, int height})> instantiate(List<int> png) async {
  final codec = await ui.instantiateImageCodec(Uint8List.fromList(png));
  final f = await codec.getNextFrame();
  return (width: f.image.width, height: f.image.height);
}
