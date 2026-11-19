import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'theme/tokens.dart';
import 'theme/type_scale.dart';

/// Friendly replacement for Flutter's red error screen. Built without
/// relying on any ancestor (theme, locale) since it renders in place of a
/// widget that failed to build.
Widget buildErrorFallback(FlutterErrorDetails details) {
  final dark =
      ui.PlatformDispatcher.instance.platformBrightness == Brightness.dark;
  final locale = ui.PlatformDispatcher.instance.locale;
  final l10n = lookupAppLocalizations(
    AppLocalizations.supportedLocales.any(
          (l) => l.languageCode == locale.languageCode,
        )
        ? Locale(locale.languageCode)
        : const Locale('en'),
  );
  final bg = dark ? KColors.lampSurfaceVariant : KColors.paperSurfaceVariant;
  final fg = dark ? KColors.lampText : KColors.paperText;
  final muted = dark ? KColors.lampMuted : KColors.paperMuted;
  return Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(KSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.errorWidgetTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: KFonts.serif,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: fg,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: KSpacing.sm),
              Text(
                l10n.errorWidgetBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: KFonts.sans,
                  fontSize: 14,
                  color: muted,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
