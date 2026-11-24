/// A series name and the book's place in it (null when not numbered).
typedef SeriesPlace = ({String name, double? number});

final RegExp _trailingNumber = RegExp(
  r'^(.*?)[\s,;:#(\-–—]*(?:(?:book|vol\.?|volume|no\.?|part)\s*)?#?\s*'
  r'(\d+(?:\.\d+)?)\)?\s*$',
  caseSensitive: false,
);

/// Reads catalogue series text: `Discworld`, `Discworld (4)`, `Discworld ;
/// 4`, `Discworld, #4`, `Discworld -- 4`, `Harry Potter, book 1`. Null for
/// blank input.
SeriesPlace? parseSeries(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  final m = _trailingNumber.firstMatch(text);
  if (m != null) {
    final name = _tidy(m.group(1)!);
    if (name.isNotEmpty) {
      return (name: name, number: double.tryParse(m.group(2)!));
    }
  }
  return (name: _tidy(text), number: null);
}

String _tidy(String s) => s
    .replaceAll(RegExp(r'[\s,;:#(\-–—]+$'), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

final RegExp _titleSeries = RegExp(
  r'^(.*\S)\s*\(([^()]*?),?\s*#\s*(\d+(?:\.\d+)?)(?:\s*-\s*\d+)?\)\s*$',
);

/// Goodreads and StoryGraph put the series in the title:
/// `The Colour of Magic (Discworld, #1)`. Splits it off, or returns null when
/// the title has no such suffix.
({String title, String series, double number})? splitSeriesFromTitle(
  String title,
) {
  final m = _titleSeries.firstMatch(title.trim());
  if (m == null) return null;
  final series = m.group(2)!.trim();
  if (series.isEmpty) return null;
  return (
    title: m.group(1)!.trim(),
    series: series,
    number: double.parse(m.group(3)!),
  );
}

/// `4`, or `2.5`.
String seriesNumberText(double n) =>
    n == n.roundToDouble() ? n.toInt().toString() : n.toString();

/// The whole-numbered places missing between 1 and the highest owned one.
List<int> seriesGaps(Iterable<double?> owned) {
  final whole = <int>{
    for (final n in owned)
      if (n != null && n >= 1 && n == n.roundToDouble()) n.toInt(),
  };
  if (whole.isEmpty) return const <int>[];
  final top = whole.reduce((a, b) => a > b ? a : b);
  return <int>[
    for (var i = 1; i <= top; i++)
      if (!whole.contains(i)) i,
  ];
}
