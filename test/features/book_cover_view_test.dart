// These tests use ProviderScope as the root of a tiny app, not as a nested
// scope, so the lint about listing dependencies does not apply.
// ignore_for_file: scoped_providers_should_specify_dependencies
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/cover_providers.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/presentation/book_cover_view.dart';
import 'package:kitabkhana/platform/cover_store/cover_store.dart';
import 'package:kitabkhana/ui/ui.dart';

import 'dart:typed_data';

import '../helpers/pump_app.dart';
import '../helpers/test_images.dart';

class FakeCoverStore implements CoverStore {
  FakeCoverStore(this.image);

  final ImageProvider? image;
  final List<String> asked = <String>[];

  @override
  Future<ImageProvider?> imageFor(String reference) async {
    asked.add(reference);
    return image;
  }

  @override
  Future<void> delete(String bookId) async {}
  @override
  Future<Uint8List?> readBytes(String reference) async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final now = DateTime(2025, 3, 10);
  Book book({String? ref, String? url}) => Book.create(
    id: 'b1',
    title: 'Godan',
    authors: 'Premchand',
    now: now,
  ).copyWith(coverLocalPath: ref, coverUrl: url);

  Future<void> pumpView(
    WidgetTester t,
    Book b,
    FakeCoverStore store, {
    KCoverSize? size = KCoverSize.md,
  }) async {
    await pumpThemed(
      t,
      ProviderScope(
        overrides: [coverStoreProvider.overrideWithValue(store)],
        child: Center(
          child: BookCoverView(book: b, size: size),
        ),
      ),
    );
    await t.pump();
    await t.pump();
  }

  testWidgets('resolves the stored reference and passes the image down', (
    t,
  ) async {
    final image = MemoryImage(pngBytes(40, 60));
    final store = FakeCoverStore(image);
    await pumpView(
      t,
      book(ref: 'covers/b1.jpg', url: 'https://x/c.jpg'),
      store,
    );
    expect(store.asked, ['covers/b1.jpg']);
    final cover = t.widget<KBookCover>(find.byType(KBookCover));
    expect(cover.localImage, same(image));
    expect(cover.imageUrl, 'https://x/c.jpg');
    expect(cover.title, 'Godan');
  });

  testWidgets('no stored cover: never asks the store, shows the fallback', (
    t,
  ) async {
    final store = FakeCoverStore(MemoryImage(pngBytes(40, 60)));
    await pumpView(t, book(), store);
    expect(store.asked, isEmpty);
    expect(t.widget<KBookCover>(find.byType(KBookCover)).localImage, isNull);
    expect(find.byType(KGeneratedCover), findsOneWidget);
  });

  testWidgets('a missing file falls back gracefully', (t) async {
    final store = FakeCoverStore(null);
    await pumpView(t, book(ref: 'covers/gone.jpg'), store);
    expect(t.widget<KBookCover>(find.byType(KBookCover)).localImage, isNull);
    expect(find.byType(KGeneratedCover), findsOneWidget);
  });

  testWidgets('fluid mode fills the width', (t) async {
    final store = FakeCoverStore(null);
    await pumpThemed(
      t,
      ProviderScope(
        overrides: [coverStoreProvider.overrideWithValue(store)],
        child: SizedBox(width: 150, child: BookCoverView(book: book())),
      ),
    );
    expect(t.getSize(find.byType(KBookCover)).width, 150);
  });

  testWidgets('KBookCover prefers localImage over the network image', (
    t,
  ) async {
    final local = MemoryImage(pngBytes(40, 60));
    await pumpThemed(
      t,
      Center(
        child: KBookCover(
          title: 'T',
          localImage: local,
          imageUrl: 'https://x/c.jpg',
          size: KCoverSize.sm,
        ),
      ),
    );
    final image = t.widget<Image>(find.byType(Image));
    expect((image.image as ResizeImage).imageProvider, same(local));
  });
}
