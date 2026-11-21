import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/add_flow_harness.dart';
import '../helpers/seed_library.dart';
import 'matrix.dart';

/// Screens must keep clear of a notch, a punch-hole camera and the gesture
/// bar: nothing may overflow with the system insets applied, and no text may
/// start under the status bar or beside a landscape notch.
void main() {
  // (name, size, insets as left, top, right, bottom)
  const cases = <(String, Size, EdgeInsets)>[
    (
      'portrait with a notch',
      Size(390, 844),
      EdgeInsets.only(top: 47, bottom: 34),
    ),
    (
      'landscape with a notch',
      Size(844, 390),
      EdgeInsets.only(left: 47, right: 47, bottom: 21),
    ),
  ];

  // Screens that are laid out from the top-left, where an inset matters most.
  final screens = matrixScreens.where(
    (s) => const {
      'library-grid',
      'add-book',
      'book-detail',
      'loans',
      'reading',
      'stats',
      'quotes',
      'settings',
      'onboarding',
    }.contains(s.name),
  );

  for (final (caseName, size, insets) in cases) {
    for (final screen in screens) {
      testWidgets('${screen.name}: $caseName', (t) async {
        final h = AddFlowHarness();
        addTearDown(h.dispose);
        await t.runAsync(() => seedDemoLibrary(h));
        final c = await h.pump(
          t,
          start: screen.path,
          size: size,
          padding: insets,
          disableAnimations: true,
        );
        expect(c, isNotNull);
        expect(t.takeException(), isNull);

        // Every visible piece of text starts inside the safe area.
        final texts = find.byType(Text).hitTestable();
        for (final e in texts.evaluate()) {
          // A row that scrolls sideways (the filter chips) may pass under a
          // notch while it moves; only fixed content is held to the edge.
          final inSideScroller = find
              .ancestor(
                of: find.byElementPredicate((x) => x == e),
                matching: find.byWidgetPredicate(
                  (w) => w is Scrollable && w.axis == Axis.horizontal,
                ),
              )
              .evaluate()
              .isNotEmpty;
          if (inSideScroller) continue;
          final box = t.getRect(find.byElementPredicate((x) => x == e));
          // The status-bar strip belongs to the system.
          expect(
            box.top,
            greaterThanOrEqualTo(insets.top - 1),
            reason: 'text ${(e.widget as Text).data} sits under the status bar',
          );
          // A notch on the left or right edge.
          if (box.width < size.width * 0.9) {
            expect(
              box.left,
              greaterThanOrEqualTo(insets.left - 1),
              reason: 'text ${(e.widget as Text).data} is under the left notch',
            );
            expect(
              box.right,
              lessThanOrEqualTo(size.width - insets.right + 1),
              reason:
                  'text ${(e.widget as Text).data} is under the right notch',
            );
          }
        }
        await closeMatrixScreen(t, h);
      });
    }
  }
}
