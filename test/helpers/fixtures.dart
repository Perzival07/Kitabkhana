import 'dart:convert';
import 'dart:io';

/// Reads a recorded Open Library response from `test/fixtures/open_library`.
String fixtureText(String name) =>
    File('test/fixtures/open_library/$name').readAsStringSync();

Map<String, Object?> fixtureJson(String name) =>
    (jsonDecode(fixtureText(name)) as Map).cast<String, Object?>();
