// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's only source of time. Override with a `FakeClock` in tests.

@ProviderFor(clock)
final clockProvider = ClockProvider._();

/// The app's only source of time. Override with a `FakeClock` in tests.

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  /// The app's only source of time. Override with a `FakeClock` in tests.
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$clockHash() => r'55214d6539f7396a3ae1aa23b06eea79fdac0ebe';

/// App logger; overridden in `bootstrap` with the flavor's configuration.

@ProviderFor(appLogger)
final appLoggerProvider = AppLoggerProvider._();

/// App logger; overridden in `bootstrap` with the flavor's configuration.

final class AppLoggerProvider
    extends $FunctionalProvider<AppLogger, AppLogger, AppLogger>
    with $Provider<AppLogger> {
  /// App logger; overridden in `bootstrap` with the flavor's configuration.
  AppLoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLoggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLoggerHash();

  @$internal
  @override
  $ProviderElement<AppLogger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLogger create(Ref ref) {
    return appLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLogger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLogger>(value),
    );
  }
}

String _$appLoggerHash() => r'102e1a3e42aaea5b5789646dcd77e33e2b3e25dc';

/// Shared limiter for Open Library calls: 1 request/second, burst 3.

@ProviderFor(openLibraryRateLimiter)
final openLibraryRateLimiterProvider = OpenLibraryRateLimiterProvider._();

/// Shared limiter for Open Library calls: 1 request/second, burst 3.

final class OpenLibraryRateLimiterProvider
    extends $FunctionalProvider<RateLimiter, RateLimiter, RateLimiter>
    with $Provider<RateLimiter> {
  /// Shared limiter for Open Library calls: 1 request/second, burst 3.
  OpenLibraryRateLimiterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openLibraryRateLimiterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openLibraryRateLimiterHash();

  @$internal
  @override
  $ProviderElement<RateLimiter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RateLimiter create(Ref ref) {
    return openLibraryRateLimiter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RateLimiter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RateLimiter>(value),
    );
  }
}

String _$openLibraryRateLimiterHash() =>
    r'018ab2c3642f9ba8cf223351000e452bd0e688bf';
