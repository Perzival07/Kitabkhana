import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';
import 'theme/app_theme.dart';
import 'theme/system_ui.dart';
import 'theme/theme_mode_provider.dart';

/// Minimal placeholder app; replaced by the routed shell in P01.3.
class AppRoot extends ConsumerWidget {
  const AppRoot({required this.config, super.key});

  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeControllerProvider);
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      builder: (context, child) {
        final overlay = systemOverlayFor(Theme.of(context).brightness);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Text(
              'Kitabkhana',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ),
      ),
    );
  }
}
