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

  static const Color _ink = Color(0xFFF7F1E6);

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
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 112.0;
        final pad = w * 0.11;
        final length = title.trim().length;
        final titleSize =
            w *
            (length <= 18
                ? 0.15
                : length <= 36
                ? 0.12
                : 0.1);
        final authorSize = (w * 0.075).clamp(7.0, 18.0);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color.lerp(base, Colors.white, 0.08) ?? base,
                Color.lerp(base, Colors.black, 0.18) ?? base,
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
}
