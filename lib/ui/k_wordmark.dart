import 'package:flutter/material.dart';

import '../app/theme/type_scale.dart';
import '../l10n/app_localizations.dart';

/// "Kitabkhana" in Fraunces with a tiny book glyph.
class KWordmark extends StatelessWidget {
  const KWordmark({this.size = 22, this.showGlyph = true, super.key});

  final double size;
  final bool showGlyph;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = AppLocalizations.of(context).appName;
    return Semantics(
      label: name,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showGlyph) ...<Widget>[
            Icon(Icons.auto_stories_rounded, size: size, color: cs.primary),
            SizedBox(width: size * 0.3),
          ],
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: KFonts.serif,
                fontWeight: FontWeight.w600,
                fontSize: size,
                color: cs.onSurface,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
