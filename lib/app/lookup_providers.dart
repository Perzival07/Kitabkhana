import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/cache/drift_lookup_cache_store.dart';
import '../data/db/database_provider.dart';
import '../data/open_library/open_library_client.dart';
import '../features/library/application/book_lookup_service.dart';
import '../features/library/domain/book_info_source.dart';
import 'app_config_provider.dart';
import 'providers.dart';

part 'lookup_providers.g.dart';

@Riverpod(keepAlive: true)
http.Client httpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
BookInfoSource bookInfoSource(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return OpenLibraryClient(
    client: ref.watch(httpClientProvider),
    limiter: ref.watch(openLibraryRateLimiterProvider),
    clock: ref.watch(clockProvider),
    // Browsers do not allow overriding the User-Agent header.
    userAgent: kIsWeb ? null : config.userAgent,
  );
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
