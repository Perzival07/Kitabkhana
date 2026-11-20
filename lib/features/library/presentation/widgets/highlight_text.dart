import 'package:flutter/material.dart';

/// Text with the words the user searched for emphasised. Matches word
/// prefixes, the same way the full-text search does, ignoring case.
class HighlightText extends StatelessWidget {
  const HighlightText(
    this.text, {
    required this.query,
    this.style,
    this.maxLines,
    super.key,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final int? maxLines;

  static final RegExp _word = RegExp(r'[\p{L}\p{N}]+', unicode: true);

  /// The [text] split into runs, each flagged as a match or not.
  static List<(String, bool)> split(String text, String query) {
    final words = _word
        .allMatches(query)
        .map((m) => RegExp.escape(m.group(0)!))
        .toList();
    if (words.isEmpty) return <(String, bool)>[(text, false)];
    final pattern = RegExp(
      '(?<![\\p{L}\\p{N}])(?:${words.join('|')})',
      caseSensitive: false,
      unicode: true,
    );
    final runs = <(String, bool)>[];
    var cursor = 0;
    for (final m in pattern.allMatches(text)) {
      if (m.start > cursor) runs.add((text.substring(cursor, m.start), false));
      runs.add((m.group(0)!, true));
      cursor = m.end;
    }
    if (cursor < text.length) runs.add((text.substring(cursor), false));
    return runs.isEmpty ? <(String, bool)>[(text, false)] : runs;
  }

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final cs = Theme.of(context).colorScheme;
    final runs = split(text, query);
    if (runs.length == 1 && !runs.first.$2) {
      return Text(
        text,
        style: base,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
      );
    }
    return Text.rich(
      TextSpan(
        style: base,
        children: <InlineSpan>[
          for (final (part, hit) in runs)
            TextSpan(
              text: part,
              style: hit
                  ? TextStyle(
                      backgroundColor: cs.primary.withValues(alpha: 0.18),
                      fontWeight: FontWeight.w700,
                    )
                  : null,
            ),
        ],
      ),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
