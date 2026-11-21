import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/app_config.dart';
import 'package:kitabkhana/app/app_config_provider.dart';
import 'package:kitabkhana/app/app_root.dart';
import 'package:kitabkhana/app/router/app_router.dart';
import 'package:kitabkhana/app/scan_providers.dart';
import 'package:kitabkhana/app/theme/tokens.dart';
import 'package:kitabkhana/features/library/application/store_demo_seeder.dart';
import 'package:kitabkhana/features/scan_check/presentation/verdict_sheet.dart';

import '../helpers/add_flow_harness.dart';

/// Writes the store screenshots: real screens of the app, filled with the
/// public-domain classics from `StoreDemoSeeder`, set in a branded frame with a
/// caption.
///
///   GENERATE_ASSETS=1 flutter test test/tool/generate_store_screenshots_test.dart
///
/// Output: `docs/store/screenshots/<device>/<n>-<name>.png`. Skipped in
/// ordinary runs so tests never rewrite the repository.
void main() {
  final generate = Platform.environment['GENERATE_ASSETS'] == '1';

  /// Output sizes in pixels, and the logical size the app is laid out at.
  const devices = <_Device>[
    _Device('phone-ios', Size(1290, 2796), Size(430, 932), 3),
    _Device('phone-play', Size(1080, 1920), Size(360, 640), 3),
    _Device('tablet', Size(2048, 2732), Size(1024, 1366), 2),
  ];

  const shots = <_Shot>[
    _Shot(
      'never-buy-twice',
      'Never buy a book twice',
      '/library',
      verdict: true,
    ),
    _Shot('where-it-lives', 'Know where every book lives', '/locations'),
    _Shot('lend', 'Lend without losing', '/loans'),
    _Shot('quotes', 'Keep the lines you love', '/quotes'),
    _Shot(
      'private',
      'Your books, your device',
      '/onboarding',
      onboardingTaps: 2,
    ),
  ];

  for (final device in devices) {
    for (final (i, shot) in shots.indexed) {
      testWidgets('${device.name}: ${shot.name}', (t) async {
        final h = AddFlowHarness();
        addTearDown(h.dispose);
        await t.runAsync(() async {
          await StoreDemoSeeder(
            books: h.repos.books,
            locations: h.repos.locations,
            loans: h.repos.loans,
            readings: h.repos.readings,
            quotes: h.repos.quotes,
            goals: h.repos.goals,
            tags: h.repos.tags,
            clock: h.clock,
          ).seed();
        });

        // 1. The real screen, at the device's logical size and pixel ratio.
        t.view
          ..physicalSize = device.logical * device.ratio
          ..devicePixelRatio = device.ratio;
        addTearDown(t.view.reset);
        final key = GlobalKey();
        final container = ProviderContainer(
          overrides: <Override>[
            appConfigProvider.overrideWithValue(const AppConfig.prod()),
            ...h.overrides,
          ],
        );
        addTearDown(container.dispose);
        await t.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: RepaintBoundary(
              key: key,
              child: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: true),
                  child: const AppRoot(),
                ),
              ),
            ),
          ),
        );
        container.read(appRouterProvider).go(shot.path);
        await t.pumpAndSettle();
        for (var n = 0; n < shot.onboardingTaps; n++) {
          await t.tap(find.text('Next'));
          await t.pumpAndSettle();
        }
        if (shot.verdict) {
          final check = container.read(checkOwnershipProvider);
          final result = await t.runAsync(
            () => check(StoreDemoSeeder.prideIsbn),
          );
          final context = t.element(find.byType(Scaffold).first);
          unawaited(showVerdictSheet(context, result: result!, check: check));
          await t.pumpAndSettle();
        }
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final screen = (await t.runAsync(
          () => boundary.toImage(pixelRatio: device.ratio),
        ))!;

        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(seconds: 1));

        // 2. The frame: caption on terracotta, the screen in a bezel below it.
        final frameKey = GlobalKey();
        t.view
          ..physicalSize = device.output
          ..devicePixelRatio = 1;
        await t.pumpWidget(
          RepaintBoundary(
            key: frameKey,
            child: _Frame(
              size: device.output,
              caption: shot.caption,
              screen: screen,
            ),
          ),
        );
        await t.pump();
        final frame = (await t.runAsync(
          () =>
              (frameKey.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(),
        ))!;
        final png = (await t.runAsync(
          () => frame.toByteData(format: ui.ImageByteFormat.png),
        ))!;
        final file = File(
          'docs/store/screenshots/${device.name}/${i + 1}-${shot.name}.png',
        );
        file.parent.createSync(recursive: true);
        await t.runAsync(() => file.writeAsBytes(png.buffer.asUint8List()));
        screen.dispose();
        frame.dispose();
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(seconds: 1));
      }, skip: !generate);
    }
  }
}

class _Device {
  const _Device(this.name, this.output, this.logical, this.ratio);

  final String name;
  final Size output;
  final Size logical;
  final double ratio;
}

class _Shot {
  const _Shot(
    this.name,
    this.caption,
    this.path, {
    this.verdict = false,
    this.onboardingTaps = 0,
  });

  final String name;
  final String caption;
  final String path;
  final bool verdict;
  final int onboardingTaps;
}

/// Terracotta card with the caption in Fraunces and the app screen below it,
/// held in a dark bezel and running off the bottom edge.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.size,
    required this.caption,
    required this.screen,
  });

  final Size size;
  final String caption;
  final ui.Image screen;

  @override
  Widget build(BuildContext context) {
    final w = size.width;
    final deviceW = w * 0.80;
    final deviceH = deviceW * screen.height / screen.width;
    final bezel = w * 0.012;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ClipRect(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  KColors.paperPrimary,
                  KColors.paperPrimaryStrong,
                ],
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: w * 0.08,
                  right: w * 0.08,
                  top: size.height * 0.055,
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontWeight: FontWeight.w600,
                      fontSize: w * 0.078,
                      height: 1.12,
                      color: KColors.coverInk,
                    ),
                  ),
                ),
                Positioned(
                  left: (w - deviceW) / 2,
                  top: size.height * 0.145,
                  width: deviceW,
                  height: deviceH,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1B16),
                      borderRadius: BorderRadius.circular(deviceW * 0.10),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 60,
                          offset: Offset(0, 30),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(bezel),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          deviceW * 0.10 - bezel,
                        ),
                        child: RawImage(image: screen, fit: BoxFit.fill),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
