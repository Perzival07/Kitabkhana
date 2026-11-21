/// The `.kitab` layout version this app reads and writes. See
/// `docs/BACKUP_FORMAT.md`.
const int backupFormatVersion = 1;

/// The tables in a backup, parents before children. Names are the archive
/// file names (`data/<name>.json`) and the keys of the manifest `counts`.
const List<String> backupTableNames = <String>[
  'locations',
  'tags',
  'goals',
  'books',
  'loans',
  'reading_logs',
  'quotes',
  'book_tags',
];

String dataFilePath(String table) => 'data/$table.json';
String coverFilePath(String bookId) => 'covers/$bookId.jpg';

const String manifestPath = 'manifest.json';

/// The `manifest.json` of a backup.
final class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.appVersion,
    required this.schemaVersion,
    required this.deviceId,
    required this.exportedAt,
    required this.counts,
    required this.files,
  });

  final int formatVersion;
  final String appVersion;
  final int schemaVersion;
  final String deviceId;
  final DateTime exportedAt;

  /// Rows per table, including soft-deleted ones.
  final Map<String, int> counts;

  /// SHA-256 hex of every other file in the archive.
  final Map<String, String> files;

  Map<String, Object?> toJson() => <String, Object?>{
    'formatVersion': formatVersion,
    'appVersion': appVersion,
    'schemaVersion': schemaVersion,
    'deviceId': deviceId,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'counts': counts,
    'files': files,
  };

  /// Throws a [FormatException] when a field is missing or the wrong type.
  factory BackupManifest.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('manifest is not an object');
    }
    T field<T>(String key) {
      final v = json[key];
      if (v is! T) throw FormatException('manifest field $key');
      return v;
    }

    Map<String, V> strMap<V>(String key) {
      final raw = field<Map<String, dynamic>>(key);
      return <String, V>{
        for (final e in raw.entries)
          e.key: e.value is V
              ? e.value as V
              : throw FormatException('manifest $key.${e.key}'),
      };
    }

    return BackupManifest(
      formatVersion: field<int>('formatVersion'),
      appVersion: field<String>('appVersion'),
      schemaVersion: field<int>('schemaVersion'),
      deviceId: field<String>('deviceId'),
      exportedAt: DateTime.parse(field<String>('exportedAt')),
      counts: strMap<int>('counts'),
      files: strMap<String>('files'),
    );
  }
}

/// What an import changed, for the "Imported 312 books…" message.
final class ImportSummary {
  const ImportSummary({
    required this.books,
    required this.loans,
    required this.quotes,
    required this.readingLogs,
    this.coversSkipped = 0,
  });

  /// Live (not deleted) rows written, whether new or updated.
  final int books;
  final int loans;
  final int quotes;
  final int readingLogs;

  /// Covers that could not be copied (the rest of the import stands).
  final int coversSkipped;

  @override
  String toString() =>
      'ImportSummary(books: $books, loans: $loans, quotes: $quotes)';
}

enum ImportMode { replace, merge }
