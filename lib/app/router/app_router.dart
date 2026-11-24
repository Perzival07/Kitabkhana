import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/library/presentation/add/add_args.dart';
import '../../features/library/presentation/add/add_batch_screen.dart';
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
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/quotes/presentation/quote_capture_screen.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/tags/presentation/tags_screen.dart';
import '../../features/quotes/presentation/quotes_screen.dart';
import '../../features/reading/presentation/reading_screen.dart';
import '../../features/scan_check/presentation/scan_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../ui/gallery/dev_gallery_screen.dart';
import '../../ui/gallery/dev_lookup_screen.dart';
import '../app_config.dart';
import '../app_config_provider.dart';
import '../settings_providers.dart';
import '../shell/adaptive_scaffold.dart';
import 'not_found_screen.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// Builds the app's [GoRouter]. Exposed for tests with a custom [initial].
GoRouter buildRouter(AppConfig config, {String initial = Routes.library}) {
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
                        path: 'batch',
                        builder: (_, _) => const AddBatchScreen(),
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
      GoRoute(path: Routes.quotes, builder: (_, _) => const QuotesScreen()),
      GoRoute(
        path: Routes.locations,
        builder: (_, _) => const LocationsScreen(),
      ),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(path: Routes.tags, builder: (_, _) => const TagsScreen()),
      GoRoute(path: Routes.about, builder: (_, _) => const AboutScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
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
  final router = buildRouter(
    ref.watch(appConfigProvider),
    initial: ref.watch(initialRouteProvider),
  );
  ref.onDispose(router.dispose);
  return router;
}
