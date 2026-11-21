import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/tokens.dart';
import 'package:kitabkhana/ui/ui.dart';

import '../helpers/pump_app.dart';

void main() {
  group('MotionPrefs', () {
    test('reduced: no time, a straight line', () {
      const m = MotionPrefs(reduce: true);
      expect(m.duration(KDurations.slow), Duration.zero);
      expect(m.curve(Curves.easeOutBack), Curves.linear);
    });

    test('normal: unchanged', () {
      const m = MotionPrefs(reduce: false);
      expect(m.duration(KDurations.slow), KDurations.slow);
      expect(m.curve(Curves.easeOutBack), Curves.easeOutBack);
    });

    testWidgets('follows MediaQuery.disableAnimations', (t) async {
      late MotionPrefs seen;
      Widget probe() => Builder(
        builder: (context) {
          seen = context.motion;
          return const SizedBox();
        },
      );
      await pumpThemed(t, probe());
      expect(seen.reduce, isFalse);
      await pumpThemed(t, probe(), disableAnimations: true);
      expect(seen.reduce, isTrue);
    });
  });

  group('KEnter', () {
    double opacityOf(WidgetTester t, String label) {
      final o = t.widgetList<Opacity>(
        find.ancestor(of: find.text(label), matching: find.byType(Opacity)),
      );
      return o.isEmpty ? 1 : o.first.opacity;
    }

    testWidgets('fades in, later items later, and settles without timers', (
      t,
    ) async {
      await pumpThemed(
        t,
        Column(
          children: <Widget>[
            for (var i = 0; i < 3; i++)
              KEnter(index: i * 4, play: true, child: Text('item $i')),
          ],
        ),
      );
      expect(opacityOf(t, 'item 0'), 0, reason: 'starts hidden');
      await t.pump(const Duration(milliseconds: 200));
      expect(
        opacityOf(t, 'item 0'),
        greaterThan(opacityOf(t, 'item 2')),
        reason: 'the first is further along',
      );
      await t.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        expect(opacityOf(t, 'item $i'), 1);
      }
    });

    testWidgets('slides up while arriving', (t) async {
      await pumpThemed(t, const KEnter(index: 0, play: true, child: Text('x')));
      final start = t.getTopLeft(find.text('x')).dy;
      await t.pumpAndSettle();
      expect(t.getTopLeft(find.text('x')).dy, lessThan(start));
    });

    testWidgets('play: false shows the child as it is', (t) async {
      await pumpThemed(
        t,
        const KEnter(index: 0, play: false, child: Text('x')),
      );
      expect(find.byType(Opacity), findsNothing);
      expect(find.text('x'), findsOneWidget);
    });

    testWidgets('reduce-motion: no animation at all', (t) async {
      await pumpThemed(
        t,
        const KEnter(index: 0, play: true, child: Text('x')),
        disableAnimations: true,
      );
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('late rows do not wait long', (t) async {
      await pumpThemed(
        t,
        const KEnter(index: 500, play: true, child: Text('x')),
      );
      // Capped stagger: done within the cap plus one slow transition.
      await t.pump(KDurations.stagger * 10 + KDurations.slow);
      expect(find.byType(Opacity), findsOneWidget);
      expect(opacityOf(t, 'x'), 1);
    });
  });

  group('KPop', () {
    double scaleOf(WidgetTester t) => t
        .widget<Transform>(
          find.descendant(
            of: find.byType(KPop),
            matching: find.byType(Transform),
          ),
        )
        .transform
        .storage[0];

    testWidgets('grows to full size, and again when replay changes', (t) async {
      Widget pop(Object key) => KPop(replay: key, child: const Text('badge'));
      await pumpThemed(t, pop('a'));
      expect(scaleOf(t), lessThan(0.85), reason: 'starts small');
      await t.pumpAndSettle();
      expect(scaleOf(t), closeTo(1, 0.001));

      await pumpThemed(t, pop('b'));
      expect(scaleOf(t), lessThan(1), reason: 'plays again');
      await t.pumpAndSettle();
      expect(scaleOf(t), closeTo(1, 0.001));
    });

    testWidgets('reduce-motion: simply there', (t) async {
      await pumpThemed(
        t,
        const KPop(child: Text('badge')),
        disableAnimations: true,
      );
      expect(find.byType(Opacity), findsNothing);
    });
  });

  group('KButton', () {
    final haptics = <String>[];

    setUp(() {
      haptics.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              haptics.add(call.arguments as String);
            }
            return null;
          });
    });

    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    double scale(WidgetTester t) =>
        t.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

    testWidgets('a primary button dips to 97% while pressed', (t) async {
      await pumpThemed(t, KButton(label: 'Go', onPressed: () {}));
      expect(scale(t), 1);
      final g = await t.startGesture(t.getCenter(find.text('Go')));
      await t.pump(const Duration(milliseconds: 100));
      expect(scale(t), 0.97);
      await g.up();
      await t.pumpAndSettle();
      expect(scale(t), 1);
    });

    testWidgets('a cancelled press springs back', (t) async {
      await pumpThemed(t, KButton(label: 'Go', onPressed: () {}));
      final g = await t.startGesture(t.getCenter(find.text('Go')));
      await t.pump(const Duration(milliseconds: 100));
      await g.cancel();
      await t.pumpAndSettle();
      expect(scale(t), 1);
    });

    testWidgets('other variants and disabled buttons do not scale', (t) async {
      await pumpThemed(
        t,
        Column(
          children: <Widget>[
            KButton(
              label: 'T',
              onPressed: () {},
              variant: KButtonVariant.tonal,
            ),
            const KButton(label: 'Off', onPressed: null),
          ],
        ),
      );
      expect(find.byType(AnimatedScale), findsNothing);
    });

    testWidgets('reduce-motion: no scaling', (t) async {
      await pumpThemed(
        t,
        KButton(label: 'Go', onPressed: () {}),
        disableAnimations: true,
      );
      final g = await t.startGesture(t.getCenter(find.text('Go')));
      await t.pump(const Duration(milliseconds: 100));
      expect(scale(t), 1);
      await g.up();
    });

    testWidgets('the press still reaches the button, with a light haptic', (
      t,
    ) async {
      var taps = 0;
      await pumpThemed(t, KButton(label: 'Go', onPressed: () => taps++));
      await t.tap(find.text('Go'));
      await t.pump();
      expect(taps, 1);
      expect(haptics, ['HapticFeedbackType.lightImpact']);
    });

    testWidgets('only primary buttons buzz', (t) async {
      await pumpThemed(
        t,
        KButton(label: 'T', onPressed: () {}, variant: KButtonVariant.tonal),
      );
      await t.tap(find.text('T'));
      await t.pump();
      expect(haptics, isEmpty);
    });

    testWidgets('Haptics: light, success and selection', (t) async {
      Haptics.light();
      Haptics.success();
      Haptics.selection();
      await t.pump();
      expect(haptics, [
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.mediumImpact',
        'HapticFeedbackType.selectionClick',
      ]);
    });
  });

  group('bottom sheet', () {
    Future<double> sheetTopAfter(
      WidgetTester t,
      Duration wait, {
      required bool reduce,
    }) async {
      await pumpThemed(
        t,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showKBottomSheet<void>(
              context: context,
              builder: (_) => const SizedBox(height: 200, child: Text('sheet')),
            ),
            child: const Text('open'),
          ),
        ),
        disableAnimations: reduce,
      );
      await t.tap(find.text('open'));
      await t.pump();
      await t.pump(wait);
      final y = t.getTopLeft(find.text('sheet')).dy;
      await t.pumpAndSettle();
      return y;
    }

    testWidgets('rises over time normally', (t) async {
      final early = await sheetTopAfter(
        t,
        const Duration(milliseconds: 40),
        reduce: false,
      );
      final rest = t.getTopLeft(find.text('sheet')).dy;
      expect(early, greaterThan(rest), reason: 'still on its way up');
    });

    testWidgets('reduce-motion: already in place', (t) async {
      final early = await sheetTopAfter(
        t,
        const Duration(milliseconds: 16),
        reduce: true,
      );
      final rest = t.getTopLeft(find.text('sheet')).dy;
      expect(early, closeTo(rest, 0.5));
    });
  });

  test('the spring curve overshoots a little and ends on 1', () {
    expect(KCurves.spring.transform(0), 0);
    expect(KCurves.spring.transform(1), closeTo(1, 1e-9));
    final peak = [
      for (var i = 1; i < 100; i++) KCurves.spring.transform(i / 100),
    ].reduce((a, b) => a > b ? a : b);
    expect(peak, greaterThan(1));
    expect(peak, lessThan(1.1));
  });
}
