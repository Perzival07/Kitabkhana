import 'package:flutter/widgets.dart';

import '../app/theme/k_tokens.dart';
import '../app/theme/tokens.dart';
import '../app/theme/type_scale.dart';
import '../core/stable_hash.dart';

/// A circular avatar with the person's initials; colour from a name hash.
class KAvatarInitials extends StatelessWidget {
  const KAvatarInitials({required this.name, this.size = 40, super.key});

  final String name;
  final double size;

  /// Up to two initials (first letters of the first two words).
  static String initialsOf(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    final first = words.first.characters.first;
    final second = words.length > 1 ? words[1].characters.first : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.kTokens.coverPalette;
    final color =
        palette[stableHash(name.trim().toLowerCase()) % palette.length];
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: MediaQuery.withNoTextScaling(
              child: Text(
                initialsOf(name),
                style: TextStyle(
                  fontFamily: KFonts.sans,
                  fontWeight: FontWeight.w600,
                  fontSize: size * 0.38,
                  color: KColors.coverInk,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
