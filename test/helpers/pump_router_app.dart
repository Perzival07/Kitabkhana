import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [appConfigProvider.overrideWithValue(config)],
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

/// Current location of the app router.
String locationOf(ProviderContainer c) =>
    c.read(appRouterProvider).routerDelegate.currentConfiguration.uri.path;

GoRouter routerOf(ProviderContainer c) => c.read(appRouterProvider);
