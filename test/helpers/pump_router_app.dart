import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kitabkhana/app/app_config.dart';
import 'package:kitabkhana/app/app_config_provider.dart';
import 'package:kitabkhana/app/app_root.dart';
import 'package:kitabkhana/app/router/app_router.dart';

/// Pumps the whole routed app at [size]; returns the container.
Future<ProviderContainer> pumpRouterApp(
  WidgetTester tester, {
  Size size = const Size(400, 800),
  AppConfig config = const AppConfig.dev(),
  double textScale = 1,
  List<Override> overrides = const <Override>[],
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [appConfigProvider.overrideWithValue(config), ...overrides],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: const AppRoot(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// The location of the top-most route, including routes opened with `push`
/// (`currentConfiguration.uri` only reflects declarative navigation).
String locationOf(ProviderContainer c) => c
    .read(appRouterProvider)
    .routerDelegate
    .currentConfiguration
    .last
    .matchedLocation;

GoRouter routerOf(ProviderContainer c) => c.read(appRouterProvider);
