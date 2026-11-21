import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/app_version.dart';

void main() {
  test('appVersion matches pubspec.yaml', () {
    final line = File(
      'pubspec.yaml',
    ).readAsLinesSync().firstWhere((l) => l.startsWith('version:'));
    final version = line.split(':')[1].trim().split('+').first;
    expect(appVersion, version);
  });
}
