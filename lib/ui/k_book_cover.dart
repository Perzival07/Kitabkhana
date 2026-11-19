import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../app/theme/k_tokens.dart';
import '../app/theme/tokens.dart';
import '../l10n/app_localizations.dart';
import 'k_generated_cover.dart';

/// Preset cover widths.
enum KCoverSize {
  xs(40),
  sm(72),
  md(112),
  lg(160),
  hero(220);

  const KCoverSize(this.width);
  final double width;
}

/// A 2:3 book cover with radius 6, soft shadow and a subtle spine highlight.
///
/// Uses the local file first, then the network image, then [KGeneratedCover].
/// With no [size] the cover fills the width it is given (for grids).
class KBookCover extends StatelessWidget {
  const KBookCover({
    required this.title,
    this.author = '',
    this.localPath,
    this.imageUrl,
    this.size,
    this.heroTag,
    super.key,
  });

  /// Fills available width, keeping the 2:3 ratio.
  const KBookCover.fluid({
    required this.title,
    this.author = '',
    this.localPath,
    this.imageUrl,
    this.heroTag,
    super.key,
  }) : size = null;

  final String title;
  final String author;
  final String? localPath;
  final String? imageUrl;
  final KCoverSize? size;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = author.trim().isEmpty
        ? l10n.coverSemanticsNoAuthor(title)
        : l10n.coverSemantics(title, author);
    final tokens = context.kTokens;

    Widget cover = LayoutBuilder(
      builder: (context, constraints) {
        final width =
            size?.width ??
            (constraints.maxWidth.isFinite ? constraints.maxWidth : 112.0);
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = (width * dpr).round();
        return SizedBox(
          width: width,
          height: width * 1.5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(KRadii.cover),
              boxShadow: tokens.shadows,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(KRadii.cover),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  KGeneratedCover(title: title, author: author),
                  ?_image(cacheWidth),
                  _SpineHighlight(width: width),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (heroTag != null) {
      cover = Hero(tag: heroTag!, child: cover);
    }
    return Semantics(
      label: label,
      image: true,
      excludeSemantics: true,
      child: cover,
    );
  }

  Widget? _image(int cacheWidth) {
    ImageProvider? provider;
    final path = localPath;
    final url = imageUrl;
    if (!kIsWeb && path != null && path.isNotEmpty) {
      provider = ResizeImage(FileImage(File(path)), width: cacheWidth);
    } else if (url != null && url.isNotEmpty) {
      provider = ResizeImage(NetworkImage(url), width: cacheWidth);
    }
    if (provider == null) return null;
    return Image(
      image: provider,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, sync) {
        if (sync) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : KDurations.normal,
          curve: KCurves.standard,
          child: child,
        );
      },
      errorBuilder: (context, error, stack) => const SizedBox.shrink(),
    );
  }
}

class _SpineHighlight extends StatelessWidget {
  const _SpineHighlight({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IgnorePointer(
        child: Container(
          width: width * 0.12,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Colors.white.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
