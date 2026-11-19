import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/library/presentation/library_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/reading/presentation/reading_screen.dart';
import '../../features/scan_check/presentation/scan_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/gallery/dev_gallery_screen.dart';
import '../../ui/ui.dart';
import '../app_config.dart';
import '../app_config_provider.dart';
import '../shell/adaptive_scaffold.dart';
import '../shell/placeholder_screen.dart';
import 'not_found_screen.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// Builds the app's [GoRouter]. Exposed for tests with a custom [initial].
GoRouter buildRouter(AppConfig config, {String initial = Routes.library}) {
  Widget stub(
    String Function(AppLocalizations) title,
    KIllustration illustration,
  ) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return PlaceholderScreen(
          illustration: illustration,
          title: title(l10n),
          body: l10n.routeStubBody,
          appBarTitle: title(l10n),
        );
      },
    );
  }

  return GoRouter(
    initialLocation: initial,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            AdaptiveScaffold(navigationShell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.library,
                builder: (_, _) => const LibraryScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'add',
                    builder: (_, _) =>
                        stub((l) => l.routeAddBook, KIllustration.openBook),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: Routes.scan, builder: (_, _) => const ScanScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.reading,
                builder: (_, _) => const ReadingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.stats,
                builder: (_, _) => const StatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: Routes.more, builder: (_, _) => const MoreScreen()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/book/:id',
        builder: (_, _) => stub((l) => l.routeBook, KIllustration.openBook),
        routes: <RouteBase>[
          GoRoute(
            path: 'edit',
            builder: (_, _) =>
                stub((l) => l.routeEditBook, KIllustration.openBook),
          ),
        ],
      ),
      GoRoute(
        path: Routes.loans,
        builder: (_, _) => stub((l) => l.routeLoans, KIllustration.openBook),
      ),
      GoRoute(
        path: Routes.quotes,
        builder: (_, _) => stub((l) => l.routeQuotes, KIllustration.quoteMarks),
      ),
      GoRoute(
        path: Routes.locations,
        builder: (_, _) =>
            stub((l) => l.routeLocations, KIllustration.emptyShelf),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (_, _) => stub((l) => l.routeSettings, KIllustration.openBook),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) =>
            stub((l) => l.routeOnboarding, KIllustration.emptyShelf),
      ),
      if (config.isDev)
        GoRoute(
          path: Routes.devGallery,
          builder: (_, _) => const DevGalleryScreen(),
        ),
    ],
  );
}

/// The app router, one per [ProviderScope].
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = buildRouter(ref.watch(appConfigProvider));
  ref.onDispose(router.dispose);
  return router;
}
