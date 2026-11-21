import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/library_providers.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/ui/ui.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

void main() {
  late AddFlowHarness h;
  final now = DateTime(2025, 3, 10);

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Future<void> seed() async {
    for (var i = 0; i < 4; i++) {
      await h.repos.books.upsert(
        Book.create(
          id: 'b$i',
          title: 'Book $i',
          now: now.add(Duration(minutes: i)),
          status: i.isEven ? ReadStatus.reading : ReadStatus.want,
        ),
      );
    }
  }

  Finder opacities() =>
      find.descendant(of: find.byType(KEnter), matching: find.byType(Opacity));

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  testWidgets('books cascade in the first time, then just appear', (t) async {
    h = AddFlowHarness();
    await t.runAsync(seed);
    final c = await pumpRouterApp(
      t,
      size: const Size(420, 900),
      overrides: h.overrides,
    );
    // Let the stream deliver the books, but stop while they are arriving.
    await t.pump(const Duration(milliseconds: 50));
    await t.pump(const Duration(milliseconds: 20));
    expect(find.byType(KEnter), findsWidgets);
    expect(opacities(), findsWidgets, reason: 'the cascade is playing');

    await t.pumpAndSettle();
    expect(c.read(libraryEntrancePlayedProvider), isTrue);

    // Filtering brings the same books back without another cascade.
    c
        .read(libraryQueryControllerProvider.notifier)
        .setStatus(ReadStatus.reading);
    await t.pump();
    await t.pump(const Duration(milliseconds: 30));
    expect(opacities(), findsNothing);
    c.read(libraryQueryControllerProvider.notifier).showAll();
    await t.pump();
    await t.pump(const Duration(milliseconds: 30));
    expect(opacities(), findsNothing);
    await t.pumpAndSettle();
    await end(t);
  });

  testWidgets('reduce-motion: no cascade even the first time', (t) async {
    h = AddFlowHarness();
    await t.runAsync(seed);
    await pumpRouterApp(
      t,
      size: const Size(420, 900),
      disableAnimations: true,
      overrides: h.overrides,
    );
    await t.pump(const Duration(milliseconds: 50));
    await t.pump(const Duration(milliseconds: 20));
    expect(find.byType(KEnter), findsWidgets);
    expect(opacities(), findsNothing);
    await t.pumpAndSettle();
    await end(t);
  });
}
