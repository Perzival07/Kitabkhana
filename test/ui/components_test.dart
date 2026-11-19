import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/tokens.dart';
import 'package:kitabkhana/ui/ui.dart';

import '../helpers/pump_app.dart';

void main() {
  group('KGeneratedCover', () {
    test('colour is stable per title and case/space-insensitive', () {
      final a = KGeneratedCover.colorFor('Godan', KColors.coverPalette);
      expect(KGeneratedCover.colorFor(' godan ', KColors.coverPalette), a);
      expect(KColors.coverPalette, contains(a));
    });

    test('ten sample titles use several different colours', () {
      final colours = <Color>{
        for (final t in <String>[
          'Godan',
          'Gitanjali',
          'A Suitable Boy',
          'The White Tiger',
          'Train to Pakistan',
          'Wings of Fire',
          'Pather Panchali',
          'The Shadow Lines',
          'Midnight’s Children',
          'The God of Small Things',
        ])
          KGeneratedCover.colorFor(t, KColors.coverPalette),
      };
      expect(colours.length, greaterThanOrEqualTo(5));
    });
  });

  group('KBookCover', () {
    testWidgets('is 2:3 and falls back to the generated cover', (t) async {
      await pumpThemed(
        t,
        const Center(
          child: KBookCover(
            title: 'Godan',
            author: 'Premchand',
            size: KCoverSize.md,
          ),
        ),
      );
      expect(find.byType(KGeneratedCover), findsOneWidget);
      final size = t.getSize(find.byType(KBookCover));
      expect(size.width, 112);
      expect(size.height, 168);
    });

    testWidgets('exposes the semantics label', (t) async {
      final handle = t.ensureSemantics();
      await pumpThemed(
        t,
        const KBookCover(
          title: 'Godan',
          author: 'Premchand',
          size: KCoverSize.sm,
        ),
      );
      expect(
        find.bySemanticsLabel('Cover of Godan by Premchand'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('omits the author when empty', (t) async {
      final handle = t.ensureSemantics();
      await pumpThemed(
        t,
        const KBookCover(title: 'Godan', size: KCoverSize.sm),
      );
      expect(find.bySemanticsLabel('Cover of Godan'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('fluid cover fills its width', (t) async {
      await pumpThemed(
        t,
        const SizedBox(width: 200, child: KBookCover.fluid(title: 'X')),
        scaffold: true,
      );
      expect(t.getSize(find.byType(KBookCover)).width, 200);
    });

    testWidgets('wraps in a Hero when a tag is given', (t) async {
      await pumpThemed(
        t,
        const KBookCover(title: 'X', heroTag: 'b1', size: KCoverSize.xs),
      );
      expect(find.byType(Hero), findsOneWidget);
    });
  });

  group('KButton', () {
    testWidgets('fires onPressed', (t) async {
      var taps = 0;
      await pumpThemed(
        t,
        Center(
          child: KButton(label: 'Go', onPressed: () => taps++),
        ),
      );
      await t.tap(find.text('Go'));
      expect(taps, 1);
    });

    testWidgets('loading disables taps and shows a spinner', (t) async {
      var taps = 0;
      await pumpThemed(
        t,
        Center(
          child: KButton(label: 'Go', loading: true, onPressed: () => taps++),
        ),
      );
      await t.tap(find.text('Go'));
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is at least 48dp tall in every variant', (t) async {
      await pumpThemed(
        t,
        Column(
          children: <Widget>[
            for (final v in KButtonVariant.values)
              KButton(label: 'B', variant: v, onPressed: () {}),
          ],
        ),
      );
      for (final e in t.widgetList(find.byType(KButton))) {
        expect(t.getSize(find.byWidget(e)).height, greaterThanOrEqualTo(48));
      }
    });
  });

  group('KSearchField', () {
    testWidgets('debounces and offers clear', (t) async {
      final calls = <String>[];
      await pumpThemed(t, KSearchField(hint: 'Search', onChanged: calls.add));
      await t.enterText(find.byType(TextField), 'ha');
      await t.pump(const Duration(milliseconds: 100));
      await t.enterText(find.byType(TextField), 'harr');
      await t.pump(const Duration(milliseconds: 249));
      expect(calls, isEmpty);
      await t.pump(const Duration(milliseconds: 2));
      expect(calls, <String>['harr']);

      await t.tap(find.byIcon(Icons.close_rounded));
      await t.pump();
      expect(calls.last, '');
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('shows the scan button when provided', (t) async {
      var scans = 0;
      await pumpThemed(
        t,
        KSearchField(
          hint: 'Search',
          onChanged: (_) {},
          onScanTap: () => scans++,
          scanTooltip: 'Scan',
        ),
      );
      await t.tap(find.byTooltip('Scan'));
      expect(scans, 1);
    });
  });

  group('KStatusPill', () {
    testWidgets('shows localised text and an icon for each status', (t) async {
      await pumpThemed(
        t,
        Column(
          children: <Widget>[
            for (final s in KStatus.values) KStatusPill(status: s),
          ],
        ),
      );
      for (final l in <String>[
        'Want to read',
        'Reading',
        'Finished',
        'Dropped',
      ]) {
        expect(find.text(l), findsOneWidget);
      }
      expect(find.byType(Icon), findsNWidgets(4));
    });
  });

  group('KEmptyState', () {
    testWidgets('renders copy and handles the action', (t) async {
      var taps = 0;
      await pumpThemed(
        t,
        KEmptyState(
          illustration: KIllustration.emptyShelf,
          title: 'Nothing yet',
          body: 'Add a book',
          actionLabel: 'Add',
          onAction: () => taps++,
        ),
      );
      expect(find.text('Nothing yet'), findsOneWidget);
      await t.tap(find.text('Add'));
      expect(taps, 1);
    });

    testWidgets('does not overflow at 320dp, 200% text, short height', (
      t,
    ) async {
      await pumpThemed(
        t,
        const KEmptyState(
          illustration: KIllustration.quoteMarks,
          title: 'A fairly long empty state title that wraps',
          body: 'A long supporting sentence that also needs to wrap nicely.',
          actionLabel: 'Do the thing',
          onAction: _noop,
        ),
        size: const Size(320, 480),
        textScale: 2,
      );
      expect(t.takeException(), isNull);
    });
  });

  group('KAvatarInitials', () {
    test('initials', () {
      expect(KAvatarInitials.initialsOf('priya sharma'), 'PS');
      expect(KAvatarInitials.initialsOf('Rahul'), 'R');
      expect(KAvatarInitials.initialsOf('  '), '?');
      expect(KAvatarInitials.initialsOf('অনির্বাণ দাস'), isNotEmpty);
    });
  });

  group('Progress', () {
    testWidgets('ring and bar clamp and label themselves', (t) async {
      final handle = t.ensureSemantics();
      await pumpThemed(
        t,
        const Column(
          children: <Widget>[
            KProgressRing(value: 1.7, semanticLabel: '18 of 24 books'),
            KProgressBar(value: 0.5),
          ],
        ),
      );
      expect(find.bySemanticsLabel('18 of 24 books'), findsOneWidget);
      expect(find.bySemanticsLabel('50 percent'), findsOneWidget);
      handle.dispose();
    });
  });

  group('Overlays', () {
    testWidgets('toast shows message and action', (t) async {
      var viewed = 0;
      await pumpThemed(
        t,
        Builder(
          builder: (context) => KButton(
            label: 'Show',
            onPressed: () => KToast.show(
              context,
              'Added',
              actionLabel: 'View',
              onAction: () => viewed++,
            ),
          ),
        ),
      );
      await t.tap(find.text('Show'));
      await t.pumpAndSettle();
      expect(find.text('Added'), findsOneWidget);
      await t.tap(find.text('View'));
      expect(viewed, 1);
    });

    testWidgets('confirm dialog resolves true / false', (t) async {
      bool? result;
      await pumpThemed(
        t,
        Builder(
          builder: (context) => KButton(
            label: 'Ask',
            onPressed: () async => result = await showKConfirmDialog(
              context: context,
              title: 'Sure?',
              message: 'm',
              confirmLabel: 'Yes',
              cancelLabel: 'No',
            ),
          ),
        ),
      );
      await t.tap(find.text('Ask'));
      await t.pumpAndSettle();
      await t.tap(find.text('Yes'));
      await t.pumpAndSettle();
      expect(result, isTrue);

      await t.tap(find.text('Ask'));
      await t.pumpAndSettle();
      await t.tap(find.text('No'));
      await t.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('bottom sheet shows content', (t) async {
      await pumpThemed(
        t,
        Builder(
          builder: (context) => KButton(
            label: 'Open',
            onPressed: () => showKBottomSheet<void>(
              context: context,
              builder: (_) => const Text('Sheet body'),
            ),
          ),
        ),
      );
      await t.tap(find.text('Open'));
      await t.pumpAndSettle();
      expect(find.text('Sheet body'), findsOneWidget);
    });
  });

  testWidgets('skeletons render without animating when motion is reduced', (
    t,
  ) async {
    await pumpThemed(
      t,
      const KBookTileSkeleton(size: KCoverSize.sm),
      disableAnimations: true,
    );
    // pumpAndSettle would time out if the shimmer kept running.
    await t.pumpAndSettle();
    expect(find.byType(KSkeleton), findsWidgets);
  });
}

void _noop() {}
