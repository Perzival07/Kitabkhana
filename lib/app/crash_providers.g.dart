// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crash_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where a problem report waits for the reader. `bootstrap` overrides it with
/// the store the error handlers write to.

@ProviderFor(crashStore)
final crashStoreProvider = CrashStoreProvider._();

/// Where a problem report waits for the reader. `bootstrap` overrides it with
/// the store the error handlers write to.

final class CrashStoreProvider
    extends $FunctionalProvider<CrashStore, CrashStore, CrashStore>
    with $Provider<CrashStore> {
  /// Where a problem report waits for the reader. `bootstrap` overrides it with
  /// the store the error handlers write to.
  CrashStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crashStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crashStoreHash();

  @$internal
  @override
  $ProviderElement<CrashStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CrashStore create(Ref ref) {
    return crashStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrashStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrashStore>(value),
    );
  }
}

String _$crashStoreHash() => r'985a719434b3d238ae74a8a5e0575571665d5cb8';

@ProviderFor(reportMailer)
final reportMailerProvider = ReportMailerProvider._();

final class ReportMailerProvider
    extends $FunctionalProvider<ReportMailer, ReportMailer, ReportMailer>
    with $Provider<ReportMailer> {
  ReportMailerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportMailerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportMailerHash();

  @$internal
  @override
  $ProviderElement<ReportMailer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReportMailer create(Ref ref) {
    return reportMailer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportMailer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportMailer>(value),
    );
  }
}

String _$reportMailerHash() => r'd78eecc09c868f87a45186535689ea3f1b2bc552';

@ProviderFor(problemReporter)
final problemReporterProvider = ProblemReporterProvider._();

final class ProblemReporterProvider
    extends
        $FunctionalProvider<ProblemReporter, ProblemReporter, ProblemReporter>
    with $Provider<ProblemReporter> {
  ProblemReporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'problemReporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$problemReporterHash();

  @$internal
  @override
  $ProviderElement<ProblemReporter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProblemReporter create(Ref ref) {
    return problemReporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProblemReporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProblemReporter>(value),
    );
  }
}

String _$problemReporterHash() => r'99273f4f3cd28677cba5b6889552ce0524b33b2b';
