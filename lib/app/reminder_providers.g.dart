// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The book id of a notification the user just tapped, for the router.

@ProviderFor(NotificationTap)
final notificationTapProvider = NotificationTapProvider._();

/// The book id of a notification the user just tapped, for the router.
final class NotificationTapProvider
    extends $NotifierProvider<NotificationTap, String?> {
  /// The book id of a notification the user just tapped, for the router.
  NotificationTapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationTapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationTapHash();

  @$internal
  @override
  NotificationTap create() => NotificationTap();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$notificationTapHash() => r'39f152a0fe9464549703d0bd1a8ced859de8ca06';

/// The book id of a notification the user just tapped, for the router.

abstract class _$NotificationTap extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Local notifications on phones; nothing on the web.

@ProviderFor(notificationScheduler)
final notificationSchedulerProvider = NotificationSchedulerProvider._();

/// Local notifications on phones; nothing on the web.

final class NotificationSchedulerProvider
    extends
        $FunctionalProvider<
          NotificationScheduler,
          NotificationScheduler,
          NotificationScheduler
        >
    with $Provider<NotificationScheduler> {
  /// Local notifications on phones; nothing on the web.
  NotificationSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSchedulerHash();

  @$internal
  @override
  $ProviderElement<NotificationScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationScheduler create(Ref ref) {
    return notificationScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationScheduler>(value),
    );
  }
}

String _$notificationSchedulerHash() =>
    r'87b4e6947f542182eb2ffead72e87916971884c1';

@ProviderFor(loanReminderService)
final loanReminderServiceProvider = LoanReminderServiceProvider._();

final class LoanReminderServiceProvider
    extends
        $FunctionalProvider<
          LoanReminderService,
          LoanReminderService,
          LoanReminderService
        >
    with $Provider<LoanReminderService> {
  LoanReminderServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loanReminderServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loanReminderServiceHash();

  @$internal
  @override
  $ProviderElement<LoanReminderService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoanReminderService create(Ref ref) {
    return loanReminderService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoanReminderService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoanReminderService>(value),
    );
  }
}

String _$loanReminderServiceHash() =>
    r'8e9258b24fa4c8f08762fb149f1f2f3994dd5fcf';

@ProviderFor(readingReminderService)
final readingReminderServiceProvider = ReadingReminderServiceProvider._();

final class ReadingReminderServiceProvider
    extends
        $FunctionalProvider<
          ReadingReminderService,
          ReadingReminderService,
          ReadingReminderService
        >
    with $Provider<ReadingReminderService> {
  ReadingReminderServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingReminderServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingReminderServiceHash();

  @$internal
  @override
  $ProviderElement<ReadingReminderService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadingReminderService create(Ref ref) {
    return readingReminderService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingReminderService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingReminderService>(value),
    );
  }
}

String _$readingReminderServiceHash() =>
    r'c4b302dc98aa75c4740feda146be6cb515461494';

@ProviderFor(loanNudge)
final loanNudgeProvider = LoanNudgeProvider._();

final class LoanNudgeProvider
    extends $FunctionalProvider<LoanNudge, LoanNudge, LoanNudge>
    with $Provider<LoanNudge> {
  LoanNudgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loanNudgeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loanNudgeHash();

  @$internal
  @override
  $ProviderElement<LoanNudge> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoanNudge create(Ref ref) {
    return loanNudge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoanNudge value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoanNudge>(value),
    );
  }
}

String _$loanNudgeHash() => r'a398d2601769e68d13438c638c6db69d4c84d4dc';
