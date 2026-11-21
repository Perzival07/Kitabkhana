import 'package:flutter/material.dart';

import '../app/theme/k_tokens.dart';
import '../app/theme/tokens.dart';
import '../app/theme/type_scale.dart';
import '../core/stable_hash.dart';

/// A designed fallback cover: a muted colour picked from a hash of the title,
/// the title in Fraunces, a thin rule and the author in small caps.
class KGeneratedCover extends StatelessWidget {
  const KGeneratedCover({required this.title, this.author = '', super.key});

  final String title;
  final String author;

  static const Color _ink = KColors.coverInk;

  /// The palette colour used for [title]; stable across runs and platforms.
  static Color colorFor(String title, List<Color> palette) {
    final key = title.trim().toLowerCase();
    return palette[stableHash(key) % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.kTokens.coverPalette;
    final base = colorFor(title, palette);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 112.0;
        // Size everything by the smaller of the width and a 2:3 cover's
        // width for this height, so a very wide, short area (the blurred
        // backdrop on a landscape screen) cannot push the text out of it.
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : width * 1.5;
        final w = width < height / 1.5 ? width : height / 1.5;
        final pad = w * 0.11;
        final length = title.trim().length;
        final baseSize =
            w *
            (length <= 18
                ? 0.15
                : length <= 36
                ? 0.12
                : 0.1);
        // Room for text inside the frame and its padding.
        final room = w - pad * 0.6 * 2 - pad * 0.7 * 2 - 2;
        final titleSize = _fitLongestWord(context, title, baseSize, room);
        final authorSize = (w * 0.075).clamp(7.0, 18.0);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color.lerp(base, KColors.highlight, 0.08) ?? base,
                Color.lerp(base, KColors.shade, 0.18) ?? base,
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(pad * 0.6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _ink.withValues(alpha: 0.28),
                  width: 0.8,
                ),
                borderRadius: BorderRadius.circular(KRadii.cover / 2),
              ),
              child: Padding(
                padding: EdgeInsets.all(pad * 0.7),
                child: MediaQuery.withNoTextScaling(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          title.trim().isEmpty ? ' ' : title.trim(),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: KFonts.serif,
                            fontWeight: FontWeight.w600,
                            fontSize: titleSize,
                            height: 1.12,
                            color: _ink,
                          ),
                        ),
                      ),
                      SizedBox(height: w * 0.06),
                      Container(
                        width: w * 0.22,
                        height: 1.2,
                        color: _ink.withValues(alpha: 0.7),
                      ),
                      const Spacer(),
                      if (author.trim().isNotEmpty)
                        Text(
                          author.trim().toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: KFonts.sans,
                            fontWeight: FontWeight.w600,
                            fontSize: authorSize,
                            letterSpacing: authorSize * 0.12,
                            height: 1.25,
                            color: _ink.withValues(alpha: 0.92),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// [size], shrunk (but never below 62% of it) so the longest word fits on
  /// one line instead of breaking in the middle.
  static double _fitLongestWord(
    BuildContext context,
    String title,
    double size,
    double room,
  ) {
    final words = title.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty || room <= 0) return size;
    final longest = words.reduce((a, b) => a.length >= b.length ? a : b);
    final painter = TextPainter(
      text: TextSpan(
        text: longest,
        // The same style the title is drawn in, including what it inherits
        // (letter spacing, for one), or the measure comes out too small.
        style: DefaultTextStyle.of(context).style.merge(
          TextStyle(
            fontFamily: KFonts.serif,
            fontWeight: FontWeight.w600,
            fontSize: size,
            height: 1.12,
          ),
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    // A little slack for rounding.
    final fitted = room * 0.96;
    if (width <= fitted) return size;
    return (size * fitted / width).clamp(size * 0.62, size);
  }
}
