import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'app_config_provider.dart';
import 'reminder_providers.dart';
import 'router/app_router.dart';
import 'router/routes.dart';
import 'theme/app_theme.dart';
import 'theme/system_ui.dart';
import 'theme/theme_mode_provider.dart';

/// The root widget: themed, localised and routed.
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final mode = ref.watch(themeModeControllerProvider);
    final router = ref.watch(appRouterProvider);
    // A tapped loan reminder opens that book.
    ref.listen<String?>(notificationTapProvider, (_, bookId) {
      if (bookId == null) return;
      router.push(Routes.book(bookId));
      ref.read(notificationTapProvider.notifier).handled();
    });
    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final overlay = systemOverlayFor(Theme.of(context).brightness);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
