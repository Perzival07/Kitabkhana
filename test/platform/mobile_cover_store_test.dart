import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:kitabkhana/core/clock.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/image/cover_processor.dart';
import 'package:kitabkhana/platform/cover_store/mobile_cover_store.dart';

import '../helpers/test_images.dart';

final int _v1 = DateTime.utc(2025, 3, 10, 9).millisecondsSinceEpoch;

void main() {
  late Directory dir;
  late List<Uri> requests;
  late FutureOr<http.Response> Function(http.Request) handler;
  late FakeClock clock;

  MobileCoverStore make() => MobileCoverStore(
    client: MockClient((req) async {
      requests.add(req.url);
      return handler(req);
    }),
    documentsDir: () async => dir,
    clock: clock,
    process: (b) async => processCover(b),
  );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('kk_covers_');
    requests = <Uri>[];
    clock = FakeClock(DateTime.utc(2025, 3, 10, 9));
    handler = (_) => http.Response.bytes(jpegBytes(900, 1350), 200);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  group('saveFromUrl', () {
    test('downloads, resizes and stores as covers/<id>.jpg', () async {
      final r = await make().saveFromUrl('book1', 'https://x.test/c.jpg');
      expect(r.getOrNull(), 'covers/book1.jpg?v=$_v1');
      final file = File('${dir.path}/covers/book1.jpg');
      expect(file.existsSync(), isTrue);
      final out = img.decodeJpg(file.readAsBytesSync())!;
      expect([out.width, out.height], [360, 540]);
      expect(requests.single.toString(), 'https://x.test/c.jpg');
    });

    test(
      'Open Library\'s 1x1 placeholder means no cover and writes nothing',
      () async {
        handler = (_) => http.Response.bytes(placeholderGif(), 200);
        final r = await make().saveFromUrl('book1', 'https://x.test/c.jpg');
        expect(r.isOk, isTrue);
        expect(r.getOrNull(), isNull);
        expect(File('${dir.path}/covers/book1.jpg').existsSync(), isFalse);
      },
    );

    test('404 and unreadable images also mean no cover', () async {
      handler = (_) => http.Response('nope', 404);
      expect(
        (await make().saveFromUrl('b', 'https://x.test/c.jpg')).getOrNull(),
        isNull,
      );
      handler = (_) => http.Response('<html>', 200);
      final r = await make().saveFromUrl('b', 'https://x.test/c.jpg');
      expect(r.isOk, isTrue);
      expect(r.getOrNull(), isNull);
    });

    test('network problems are failures, not "no cover"', () async {
      handler = (_) => http.Response('boom', 503);
      expect(
        (await make().saveFromUrl('b', 'https://x.test/c.jpg')).failureOrNull(),
        const NetworkFailure.server(503),
      );
      handler = (_) => throw http.ClientException('down');
      expect(
        (await make().saveFromUrl('b', 'https://x.test/c.jpg')).failureOrNull(),
        const NetworkFailure.offline(),
      );
      handler = (_) => throw TimeoutException('slow');
      expect(
        (await make().saveFromUrl('b', 'https://x.test/c.jpg')).failureOrNull(),
        const NetworkFailure.timeout(),
      );
    });

    test(
      'rejects non-http URLs and unsafe ids without touching disk',
      () async {
        expect(
          (await make().saveFromUrl('b', 'file:///etc/passwd')).failureOrNull(),
          isA<ValidationFailure>(),
        );
        for (final id in <String>['../evil', 'a/b', '', 'x.jpg', 'a b']) {
          expect(
            (await make().saveFromUrl(
              id,
              'https://x.test/c.jpg',
            )).failureOrNull(),
            isA<ValidationFailure>(),
            reason: id,
          );
        }
        expect(requests, isEmpty);
        expect(Directory('${dir.path}/covers').existsSync(), isFalse);
      },
    );

    test('re-saving replaces the file', () async {
      final store = make();
      await store.saveFromUrl('b', 'https://x.test/a.jpg');
      handler = (_) => http.Response.bytes(jpegBytes(300, 300), 200);
      await store.saveFromUrl('b', 'https://x.test/b.jpg');
      final out = img.decodeJpg(
        File('${dir.path}/covers/b.jpg').readAsBytesSync(),
      )!;
      expect([out.width, out.height], [300, 300]);
      expect(
        Directory('${dir.path}/covers').listSync(),
        hasLength(1),
      ); // no .tmp
    });
  });

  group('saveFromBytes (user photos)', () {
    test('stores a processed photo', () async {
      final r = await make().saveFromBytes('b', jpegBytes(3000, 4000));
      expect(r.getOrNull(), 'covers/b.jpg?v=$_v1');
      final out = img.decodeJpg(
        File('${dir.path}/covers/b.jpg').readAsBytesSync(),
      )!;
      expect(out.width, 360);
    });

    test('rejects bytes that are not a usable image', () async {
      for (final bytes in <Uint8List>[
        Uint8List(0),
        Uint8List.fromList([1, 2, 3]),
        placeholderGif(),
      ]) {
        expect(
          (await make().saveFromBytes('b', bytes)).failureOrNull(),
          isA<ValidationFailure>(),
        );
      }
      expect(File('${dir.path}/covers/b.jpg').existsSync(), isFalse);
    });

    test('rejects an unsafe id', () async {
      expect(
        (await make().saveFromBytes(
          '../x',
          jpegBytes(400, 600),
        )).failureOrNull(),
        isA<ValidationFailure>(),
      );
    });
  });

  group('read and delete', () {
    test('readBytes and imageFor resolve a stored reference', () async {
      final store = make();
      final ref = (await store.saveFromBytes(
        'b',
        jpegBytes(400, 600),
      )).getOrNull()!;
      expect(await store.readBytes(ref), isNotNull);
      expect(await store.imageFor(ref), isA<MemoryImage>());
    });

    test('missing and malformed references give null', () async {
      final store = make();
      expect(await store.readBytes('covers/none.jpg'), isNull);
      expect(await store.imageFor('covers/none.jpg'), isNull);
      for (final bad in <String>[
        '../x.jpg',
        '/etc/passwd',
        'covers/../x.jpg',
        '',
      ]) {
        expect(await store.readBytes(bad), isNull, reason: bad);
        expect(await store.imageFor(bad), isNull, reason: bad);
      }
    });

    test('delete removes the file and tolerates missing ones', () async {
      final store = make();
      await store.saveFromBytes('b', jpegBytes(400, 600));
      await store.delete('b');
      expect(File('${dir.path}/covers/b.jpg').existsSync(), isFalse);
      await store.delete('b');
      await store.delete('../x');
    });
  });

  test('references are relative so they survive a moved app container', () {
    final ref = MobileCoverStore.referenceFor('abc', DateTime.utc(2025));
    expect(ref, startsWith('covers/abc.jpg?v='));
    expect(ref, isNot(contains(Directory.systemTemp.path)));
  });

  test('replacing a cover yields a new reference and a new image', () async {
    final store = make();
    final a = (await store.saveFromBytes(
      'b',
      jpegBytes(400, 600),
    )).getOrNull()!;
    final imageA = (await store.imageFor(a))! as MemoryImage;
    clock.advance(const Duration(seconds: 5));
    final b = (await store.saveFromBytes(
      'b',
      jpegBytes(300, 300),
    )).getOrNull()!;
    expect(b, isNot(a));
    final imageB = (await store.imageFor(b))! as MemoryImage;
    expect(imageB, isNot(imageA));
    expect(imageB.bytes, isNot(imageA.bytes));
  });

  test('a reference with a tampered path or version is rejected', () async {
    final store = make();
    for (final bad in <String>[
      'covers/b.jpg?v=abc',
      'covers/b.jpg?v=1&x=2',
      'covers/b.jpg#frag',
      'covers/sub/b.jpg',
    ]) {
      expect(await store.readBytes(bad), isNull, reason: bad);
    }
  });
}
