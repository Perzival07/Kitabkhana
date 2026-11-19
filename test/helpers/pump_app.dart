import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/app_theme.dart';
import 'package:kitabkhana/l10n/app_localizations.dart';

/// Pumps [child] inside a themed, localised app at a given size/scale.
Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
  double textScale = 1,
  Size size = const Size(360, 800),
  bool scaffold = true,
  bool disableAnimations = false,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: c ?? const SizedBox.shrink(),
      ),
      home: scaffold ? Scaffold(body: child) : child,
    ),
  );
  await tester.pump();
}
