import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../features/crash/domain/crash_report.dart';

/// A report waiting for the reader's decision, with its screenshot if any.
typedef PendingCrash = ({CrashReport report, Uint8List? screenshot});

/// Keeps at most one problem report on the device until it is sent or
/// dismissed. Never sends anything.
abstract interface class CrashStore {
  Future<void> save(CrashReport report, {Uint8List? screenshot});

  /// The waiting report, or null. Never throws.
  Future<PendingCrash?> pending();

  Future<void> clear();
}

/// Phones: `crash/report.json` and `crash/screenshot.png` in app support.
class FileCrashStore implements CrashStore {
  FileCrashStore(this._root);

  final Future<Directory> Function() _root;

  Future<Directory> _dir() async => Directory('${(await _root()).path}/crash');

  @override
  Future<void> save(CrashReport report, {Uint8List? screenshot}) async {
    final dir = await _dir();
    await dir.create(recursive: true);
    final png = File('${dir.path}/screenshot.png');
    if (screenshot != null) {
      await png.writeAsBytes(screenshot, flush: true);
    } else if (png.existsSync()) {
      await png.delete();
    }
    final json = File('${dir.path}/report.json');
    final tmp = File('${dir.path}/report.json.tmp');
    await tmp.writeAsString(
      jsonEncode(report.withScreenshot(value: screenshot != null).toJson()),
      flush: true,
    );
    await tmp.rename(json.path);
  }

  @override
  Future<PendingCrash?> pending() async {
    try {
      final dir = await _dir();
      final json = File('${dir.path}/report.json');
      if (!json.existsSync()) return null;
      final report = CrashReport.fromJson(
        jsonDecode(await json.readAsString()) as Map<String, Object?>,
      );
      final png = File('${dir.path}/screenshot.png');
      final shot = report.hasScreenshot && png.existsSync()
          ? await png.readAsBytes()
          : null;
      return (report: report, screenshot: shot);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> clear() async {
    try {
      final dir = await _dir();
      if (dir.existsSync()) await dir.delete(recursive: true);
    } on Object {
      // Nothing to clear.
    }
  }
}

/// The web (and tests): kept in memory for this visit only.
class MemoryCrashStore implements CrashStore {
  PendingCrash? _pending;

  @override
  Future<void> save(CrashReport report, {Uint8List? screenshot}) async {
    _pending = (
      report: report.withScreenshot(value: screenshot != null),
      screenshot: screenshot,
    );
  }

  @override
  Future<PendingCrash?> pending() async => _pending;

  @override
  Future<void> clear() async => _pending = null;
}
