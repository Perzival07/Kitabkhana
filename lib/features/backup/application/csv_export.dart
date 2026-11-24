import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';

import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../data/csv_store.dart';

/// A finished CSV file.
final class CsvFile {
  const CsvFile(this.name, this.bytes);

  final String name;
  final Uint8List bytes;
}

const List<String> booksCsvHeader = <String>[
  'title',
  'authors',
  'isbn13',
  'status',
  'ownership',
  'location',
  'rating',
  'pages',
  'startedOn',
  'finishedOn',
  'tags',
  'series',
  'seriesNumber',
];

const List<String> loansCsvHeader = <String>[
  'title',
  'authors',
  'direction',
  'person',
  'phone',
  'startedOn',
  'dueOn',
  'returnedOn',
  'note',
];

/// Makes text safe to open in a spreadsheet: a cell that starts like a
/// formula (`=`, `+`, `@`, or `-` before a non-digit, or a tab or return) gets
/// a leading apostrophe, so Excel and Sheets show it instead of running it.
String spreadsheetSafe(String text) {
  if (text.isEmpty) return text;
  final c = text[0];
  final formula =
      c == '=' ||
      c == '+' ||
      c == '@' ||
      c == '\t' ||
      c == '\r' ||
      (c == '-' && !(text.length > 1 && _isDigit(text[1])));
  return formula ? "'$text" : text;
}

bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

/// CSV text with a UTF-8 byte-order mark (so Excel reads Hindi and Bengali
/// correctly), CRLF line ends and quoting only where needed.
Uint8List encodeCsv(List<List<Object?>> rows) {
  final text = Csv(addBom: true).encode(rows);
  return Uint8List.fromList(utf8.encode(text));
}

/// Builds `books.csv` and `loans.csv` from the live library.
class ExportCsv {
  ExportCsv(this.store);

  final CsvStore store;

  Future<Result<List<CsvFile>>> call() async {
    try {
      return Ok(<CsvFile>[
        CsvFile('books.csv', await _books()),
        CsvFile('loans.csv', await _loans()),
      ]);
    } on Object catch (e, s) {
      return Err(UnexpectedFailure(e, s));
    }
  }

  String _s(Object? v) => spreadsheetSafe((v as String?) ?? '');

  Future<Uint8List> _books() async {
    final byId = <String, CsvRecord>{
      for (final l in await store.locations()) l['id']! as String: l,
    };
    // "Living room / Top shelf", walking up the parents (guarding cycles).
    String path(String? id) {
      final names = <String>[];
      final seen = <String>{};
      var at = id;
      while (at != null && seen.add(at)) {
        final loc = byId[at];
        if (loc == null) break;
        names.add(loc['name']! as String);
        at = loc['parent_id'] as String?;
      }
      return names.reversed.join(' / ');
    }

    final rows = <List<Object?>>[booksCsvHeader];
    for (final b in await store.books()) {
      rows.add(<Object?>[
        _s(b['title']),
        _s(b['authors']),
        b['isbn13'] ?? '',
        b['status'],
        b['ownership'],
        spreadsheetSafe(path(b['location_id'] as String?)),
        b['rating'] ?? '',
        b['pages'] ?? '',
        b['started_on'] ?? '',
        b['finished_on'] ?? '',
        _s(b['tag_names']),
        _s(b['series']),
        b['series_number'] ?? '',
      ]);
    }
    return encodeCsv(rows);
  }

  Future<Uint8List> _loans() async {
    final rows = <List<Object?>>[loansCsvHeader];
    for (final l in await store.loans()) {
      rows.add(<Object?>[
        _s(l['title']),
        _s(l['authors']),
        l['direction'],
        _s(l['person_name']),
        l['person_phone'] ?? '',
        l['started_on'] ?? '',
        l['due_on'] ?? '',
        l['returned_on'] ?? '',
        _s(l['note']),
      ]);
    }
    return encodeCsv(rows);
  }
}
