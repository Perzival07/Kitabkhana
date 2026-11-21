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

@ProviderFor(editQuote)
final editQuoteProvider = EditQuoteProvider._();

final class EditQuoteProvider
    extends $FunctionalProvider<EditQuote, EditQuote, EditQuote>
    with $Provider<EditQuote> {
  EditQuoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editQuoteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editQuoteHash();

  @$internal
  @override
  $ProviderElement<EditQuote> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EditQuote create(Ref ref) {
    return editQuote(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditQuote value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditQuote>(value),
    );
  }
}

String _$editQuoteHash() => r'bc0e091d0ce319dc0037d3b40aede0946d95f850';

@ProviderFor(shareService)
final shareServiceProvider = ShareServiceProvider._();

final class ShareServiceProvider
    extends $FunctionalProvider<ShareService, ShareService, ShareService>
    with $Provider<ShareService> {
  ShareServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareServiceHash();

  @$internal
  @override
  $ProviderElement<ShareService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareService create(Ref ref) {
    return shareService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareService>(value),
    );
  }
}

String _$shareServiceHash() => r'8e3b6b1695f76b77de74f25a134ae27de38f6a25';

/// The Quotes screen's search text, favourites switch and book filter.

@ProviderFor(QuotesFilter)
final quotesFilterProvider = QuotesFilterProvider._();

/// The Quotes screen's search text, favourites switch and book filter.
final class QuotesFilterProvider
    extends
        $NotifierProvider<
          QuotesFilter,
          ({String? bookId, bool favourites, String query})
        > {
  /// The Quotes screen's search text, favourites switch and book filter.
  QuotesFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quotesFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quotesFilterHash();

  @$internal
  @override
  QuotesFilter create() => QuotesFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    ({String? bookId, bool favourites, String query}) value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<({String? bookId, bool favourites, String query})>(
            value,
          ),
    );
  }
}

String _$quotesFilterHash() => r'5a37e6f7221d28fc1cd86073fc93bd54a219fb1e';

/// The Quotes screen's search text, favourites switch and book filter.

abstract class _$QuotesFilter
    extends $Notifier<({String? bookId, bool favourites, String query})> {
  ({String? bookId, bool favourites, String query}) build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({String? bookId, bool favourites, String query}),
              ({String? bookId, bool favourites, String query})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({String? bookId, bool favourites, String query}),
                ({String? bookId, bool favourites, String query})
              >,
              ({String? bookId, bool favourites, String query}),
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Every quote with its book, newest first (no filters).

@ProviderFor(allQuotes)
final allQuotesProvider = AllQuotesProvider._();

/// Every quote with its book, newest first (no filters).

final class AllQuotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuoteWithBook>>,
          List<QuoteWithBook>,
          Stream<List<QuoteWithBook>>
        >
    with
        $FutureModifier<List<QuoteWithBook>>,
        $StreamProvider<List<QuoteWithBook>> {
  /// Every quote with its book, newest first (no filters).
  AllQuotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allQuotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allQuotesHash();

  @$internal
  @override
  $StreamProviderElement<List<QuoteWithBook>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<QuoteWithBook>> create(Ref ref) {
    return allQuotes(ref);
  }
}

String _$allQuotesHash() => r'0f223b6ab771481e30a6e2542e1677d4bc8abdaf';

/// The quotes matching the filter. Search looks in the text, the book title
/// and the authors, ignoring case.

@ProviderFor(filteredQuotes)
final filteredQuotesProvider = FilteredQuotesProvider._();

/// The quotes matching the filter. Search looks in the text, the book title
/// and the authors, ignoring case.

final class FilteredQuotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuoteWithBook>>,
          AsyncValue<List<QuoteWithBook>>,
          AsyncValue<List<QuoteWithBook>>
        >
    with $Provider<AsyncValue<List<QuoteWithBook>>> {
  /// The quotes matching the filter. Search looks in the text, the book title
  /// and the authors, ignoring case.
  FilteredQuotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredQuotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredQuotesHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<QuoteWithBook>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<QuoteWithBook>> create(Ref ref) {
    return filteredQuotes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<QuoteWithBook>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<QuoteWithBook>>>(
        value,
      ),
    );
  }
}

String _$filteredQuotesHash() => r'f5081d403c90a7e07d1fbf4518409e8f6e11fbfc';

/// This week's featured quote; null while there are no quotes.

@ProviderFor(quoteOfWeek)
final quoteOfWeekProvider = QuoteOfWeekProvider._();

/// This week's featured quote; null while there are no quotes.

final class QuoteOfWeekProvider
    extends $FunctionalProvider<QuoteWithBook?, QuoteWithBook?, QuoteWithBook?>
    with $Provider<QuoteWithBook?> {
  /// This week's featured quote; null while there are no quotes.
  QuoteOfWeekProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quoteOfWeekProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quoteOfWeekHash();

  @$internal
  @override
  $ProviderElement<QuoteWithBook?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QuoteWithBook? create(Ref ref) {
    return quoteOfWeek(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuoteWithBook? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuoteWithBook?>(value),
    );
  }
}

String _$quoteOfWeekHash() => r'cc793f7ab38c38cf4a87c514ce9cc08c4a83234a';
