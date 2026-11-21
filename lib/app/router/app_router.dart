import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/library/presentation/add/add_args.dart';
import '../../features/library/presentation/add/add_entry_screen.dart';
import '../../features/library/presentation/add/add_isbn_screen.dart';
import '../../features/library/presentation/add/add_scan_screen.dart';
import '../../features/library/presentation/add/add_search_screen.dart';
import '../../features/library/presentation/add/book_form_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/book/presentation/book_edit_screen.dart';
import '../../features/book/presentation/book_detail_screen.dart';
import '../../features/lending/presentation/loans_screen.dart';
import '../../features/locations/presentation/locations_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/quotes/presentation/quote_capture_screen.dart';
import '../../features/reading/presentation/reading_screen.dart';
import '../../features/scan_check/presentation/scan_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/gallery/dev_gallery_screen.dart';
import '../../ui/gallery/dev_lookup_screen.dart';
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
                    builder: (_, _) => const AddEntryScreen(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'scan',
                        builder: (_, _) => const AddScanScreen(),
                      ),
                      GoRoute(
                        path: 'isbn',
                        builder: (_, _) => const AddIsbnScreen(),
                      ),
                      GoRoute(
                        path: 'search',
                        builder: (_, _) => const AddSearchScreen(),
                      ),
                      GoRoute(
                        path: 'manual',
                        builder: (_, state) => BookFormScreen(
                          args: state.extra is BookFormArgs
                              ? state.extra! as BookFormArgs
                              : const BookFormArgs(),
                        ),
                      ),
                      GoRoute(
                        path: 'preview',
                        // A preview needs its data; without it (e.g. after a
                        // browser refresh) fall back to the manual form.
                        builder: (_, state) => BookFormScreen(
                          args: state.extra is BookFormArgs
                              ? state.extra! as BookFormArgs
                              : const BookFormArgs(),
                        ),
                      ),
                    ],
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
        builder: (_, state) =>
            BookDetailScreen(bookId: state.pathParameters['id']!),
        routes: <RouteBase>[
          GoRoute(
            path: 'edit',
            builder: (_, state) =>
                BookEditScreen(bookId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'quote',
            builder: (_, state) =>
                QuoteCaptureScreen(bookId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(path: Routes.loans, builder: (_, _) => const LoansScreen()),
      GoRoute(
        path: Routes.quotes,
        builder: (_, _) => stub((l) => l.routeQuotes, KIllustration.quoteMarks),
      ),
      GoRoute(
        path: Routes.locations,
        builder: (_, _) => const LocationsScreen(),
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
      if (config.isDev) ...<RouteBase>[
        GoRoute(
          path: Routes.devGallery,
          builder: (_, _) => const DevGalleryScreen(),
        ),
        GoRoute(
          path: Routes.devLookup,
          builder: (_, _) => const DevLookupScreen(),
        ),
      ],
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
