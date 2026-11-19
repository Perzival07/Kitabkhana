import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/cover_providers.dart';
import '../../../ui/ui.dart';
import '../domain/book.dart';

/// A book's cover: stored local image first, then the catalogue URL, then the
/// generated cover. Resolves the cover store reference for you.
class BookCoverView extends ConsumerWidget {
  const BookCoverView({required this.book, this.size, this.heroTag, super.key});

  final Book book;

  /// Fixed size; fills the available width when null.
  final KCoverSize? size;
  final Object? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(coverImageProvider(book.coverLocalPath)).value;
    return size == null
        ? KBookCover.fluid(
            title: book.title,
            author: book.authors,
            localImage: image,
            imageUrl: book.coverUrl,
            heroTag: heroTag,
          )
        : KBookCover(
            title: book.title,
            author: book.authors,
            localImage: image,
            imageUrl: book.coverUrl,
            size: size,
            heroTag: heroTag,
          );
  }
}
