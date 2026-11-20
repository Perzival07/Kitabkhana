import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kitabkhana/app/app_config.dart';
import 'package:kitabkhana/app/app_config_provider.dart';
import 'package:kitabkhana/app/app_root.dart';
import 'package:kitabkhana/app/router/app_router.dart';
import 'package:kitabkhana/app/scan_providers.dart';
import 'package:kitabkhana/data/db/database_provider.dart';
import 'package:kitabkhana/platform/camera_permission/camera_permission.dart';

import 'fake_camera_permission.dart';
import 'test_db.dart';

/// Pumps the whole routed app at [size]; returns the container.
Future<ProviderContainer> pumpRouterApp(
  WidgetTester tester, {
  Size size = const Size(400, 800),
  AppConfig config = const AppConfig.dev(),
  double textScale = 1,
  bool disableAnimations = false,
  List<Override> overrides = const <Override>[],
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // Screens read the database, so every routed test gets an in-memory one
  // unless it supplies its own.
  final suppliesDb = overrides.any((o) => o.origin == appDatabaseProvider);
  // The Scan tab asks for camera permission; tests have no camera.
  final suppliesCamera = overrides.any(
    (o) => o.origin == cameraPermissionProvider,
  );
  final db = suppliesDb ? null : createTestDb();
  if (db != null) addTearDown(db.close);
  final container = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(config),
      if (db != null) appDatabaseProvider.overrideWithValue(db),
      if (!suppliesCamera)
        cameraPermissionProvider.overrideWithValue(
          FakeCameraPermission(current: CameraAccess.unavailable),
        ),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
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
