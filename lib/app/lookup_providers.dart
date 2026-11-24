import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/rate_limiter.dart';
import '../data/cache/drift_lookup_cache_store.dart';
import '../data/db/database_provider.dart';
import '../data/google_books/google_books_client.dart';
import '../data/open_library/open_library_client.dart';
import '../features/library/application/book_lookup_service.dart';
import '../features/library/application/fallback_book_info_source.dart';
import '../features/library/domain/book_info_source.dart';
import 'app_config.dart';
import 'app_config_provider.dart';
import 'providers.dart';

part 'lookup_providers.g.dart';

@Riverpod(keepAlive: true)
http.Client httpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}

/// Open Library first; Google Books only when it has no answer.
@Riverpod(keepAlive: true)
BookInfoSource bookInfoSource(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final client = ref.watch(httpClientProvider);
  final clock = ref.watch(clockProvider);
  return FallbackBookInfoSource(
    primary: OpenLibraryClient(
      client: client,
      limiter: ref.watch(openLibraryRateLimiterProvider),
      clock: clock,
      // Browsers do not allow overriding the User-Agent header.
      userAgent: kIsWeb ? null : config.userAgent,
    ),
    fallback: GoogleBooksClient(
      client: client,
      limiter: RateLimiter(rate: 1, burst: 3, clock: clock),
      apiKey: kGoogleBooksKey,
      appHeaders: googleAppHeaders(config),
    ),
  );
}

/// What Google checks for a key restricted to this app.
Map<String, String> googleAppHeaders(AppConfig config) {
  if (kIsWeb) return const <String, String>{};
  const id = 'com.kitabkhana.kitabkhana';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => <String, String>{
      // The dev flavor installs side by side under its own id.
      'X-Android-Package': config.isDev ? '$id.dev' : id,
      'X-Android-Cert': kReleaseCertSha1,
    },
    // iOS has no flavors yet (docs/IOS_FLAVORS.md): one bundle id.
    TargetPlatform.iOS => const <String, String>{'X-Ios-Bundle-Identifier': id},
    _ => const <String, String>{},
  };
}

@Riverpod(keepAlive: true)
LookupCacheStore lookupCacheStore(Ref ref) =>
    DriftLookupCacheStore(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
BookLookupService bookLookupService(Ref ref) => BookLookupService(
  source: ref.watch(bookInfoSourceProvider),
  cache: ref.watch(lookupCacheStoreProvider),
  clock: ref.watch(clockProvider),
);
