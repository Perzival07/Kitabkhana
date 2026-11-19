import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/library/application/add_book.dart';
import '../features/locations/domain/location.dart';
import '../platform/photo_picker/photo_picker.dart';
import '../platform/scanner/barcode_view.dart';
import 'cover_providers.dart';
import 'providers.dart';
import 'repositories.dart';

part 'add_book_providers.g.dart';

@Riverpod(keepAlive: true)
AddBook addBook(Ref ref) => AddBook(
  books: ref.watch(bookRepositoryProvider),
  covers: ref.watch(coverStoreProvider),
  clock: ref.watch(clockProvider),
  logger: ref.watch(appLoggerProvider),
);

/// Live list of locations for pickers.
@riverpod
Stream<List<Location>> locations(Ref ref) =>
    ref.watch(locationRepositoryProvider).watchAll();

@Riverpod(keepAlive: true)
PhotoPicker photoPicker(Ref ref) => ImagePickerPhotoPicker();

/// The camera view used by the scan screens; overridden in tests.
@Riverpod(keepAlive: true)
BarcodeViewBuilder barcodeViewBuilder(Ref ref) => mobileScannerView;
