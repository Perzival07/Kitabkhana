import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/clock.dart';
import '../core/logger.dart';
import '../core/rate_limiter.dart';

part 'providers.g.dart';

/// The app's only source of time. Override with a `FakeClock` in tests.
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();

/// App logger; overridden in `bootstrap` with the flavor's configuration.
@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref) => AppLogger();

/// Shared limiter for Open Library calls: 1 request/second, burst 3.
@Riverpod(keepAlive: true)
RateLimiter openLibraryRateLimiter(Ref ref) =>
    RateLimiter(rate: 1, burst: 3, clock: ref.watch(clockProvider));
