// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The on-device text reader; the web has none, so quotes are typed there.

@ProviderFor(ocrService)
final ocrServiceProvider = OcrServiceProvider._();

/// The on-device text reader; the web has none, so quotes are typed there.

final class OcrServiceProvider
    extends $FunctionalProvider<OcrService, OcrService, OcrService>
    with $Provider<OcrService> {
  /// The on-device text reader; the web has none, so quotes are typed there.
  OcrServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ocrServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ocrServiceHash();

  @$internal
  @override
  $ProviderElement<OcrService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OcrService create(Ref ref) {
    return ocrService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OcrService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OcrService>(value),
    );
  }
}

String _$ocrServiceHash() => r'79c327954e1262d692046c106ec70ebedd16a7f3';

@ProviderFor(pageEditor)
final pageEditorProvider = PageEditorProvider._();

final class PageEditorProvider
    extends $FunctionalProvider<PageEditor, PageEditor, PageEditor>
    with $Provider<PageEditor> {
  PageEditorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pageEditorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pageEditorHash();

  @$internal
  @override
  $ProviderElement<PageEditor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PageEditor create(Ref ref) {
    return pageEditor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PageEditor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PageEditor>(value),
    );
  }
}

String _$pageEditorHash() => r'26e21c37187a0985ddc9ba6a8be0c6b4b09e4f75';

@ProviderFor(saveQuote)
final saveQuoteProvider = SaveQuoteProvider._();

final class SaveQuoteProvider
    extends $FunctionalProvider<SaveQuote, SaveQuote, SaveQuote>
    with $Provider<SaveQuote> {
  SaveQuoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveQuoteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveQuoteHash();

  @$internal
  @override
  $ProviderElement<SaveQuote> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaveQuote create(Ref ref) {
    return saveQuote(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveQuote value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveQuote>(value),
    );
  }
}

String _$saveQuoteHash() => r'520f2a44fc1f5195282e7ff27b7d1623e89c27fe';

/// Live quotes of one book, newest first.

@ProviderFor(bookQuotes)
final bookQuotesProvider = BookQuotesFamily._();

/// Live quotes of one book, newest first.

final class BookQuotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Quote>>,
          List<Quote>,
          Stream<List<Quote>>
        >
    with $FutureModifier<List<Quote>>, $StreamProvider<List<Quote>> {
  /// Live quotes of one book, newest first.
  BookQuotesProvider._({
    required BookQuotesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookQuotesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookQuotesHash();

  @override
  String toString() {
    return r'bookQuotesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Quote>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Quote>> create(Ref ref) {
    final argument = this.argument as String;
    return bookQuotes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookQuotesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookQuotesHash() => r'1bc2603078d96325b12c793dd25aedde1b4bd9a7';

/// Live quotes of one book, newest first.

final class BookQuotesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Quote>>, String> {
  BookQuotesFamily._()
    : super(
        retry: null,
        name: r'bookQuotesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live quotes of one book, newest first.

  BookQuotesProvider call(String bookId) =>
      BookQuotesProvider._(argument: bookId, from: this);

  @override
  String toString() => r'bookQuotesProvider';
}
