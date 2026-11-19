import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';

void main() {
  const failure = NotFoundFailure('book');

  test('Ok exposes value, fold, map, flatMap, getOrNull', () {
    const Result<int> r = Ok<int>(2);
    expect(r.isOk, isTrue);
    expect(r.isErr, isFalse);
    expect(r.getOrNull(), 2);
    expect(r.failureOrNull(), isNull);
    expect(r.fold((v) => 'v$v', (f) => 'f'), 'v2');
    expect(r.map((v) => v * 10), const Ok<int>(20));
    expect(r.flatMap((v) => Ok<String>('x$v')), const Ok<String>('x2'));
    expect(r.flatMap((v) => const Err<int>(failure)), const Err<int>(failure));
  });

  test('Err short-circuits map and flatMap', () {
    const Result<int> r = Err<int>(failure);
    expect(r.isErr, isTrue);
    expect(r.getOrNull(), isNull);
    expect(r.failureOrNull(), failure);
    expect(r.fold((v) => 'v', (f) => 'f:${f.messageKey}'), 'f:failureNotFound');
    var called = false;
    expect(
      r.map((v) {
        called = true;
        return v;
      }),
      const Err<int>(failure),
    );
    expect(
      r.flatMap((v) {
        called = true;
        return Ok<int>(v);
      }),
      const Err<int>(failure),
    );
    expect(called, isFalse);
  });

  test('equality and hashCode', () {
    expect(const Ok<int>(1), const Ok<int>(1));
    expect(const Ok<int>(1).hashCode, const Ok<int>(1).hashCode);
    expect(const Ok<int>(1), isNot(const Ok<int>(2)));
    expect(const Ok<int>(1), isNot(const Err<int>(failure)));
  });

  test('exhaustive switch over Result compiles and works', () {
    String describe(Result<int> r) => switch (r) {
      Ok<int>(:final value) => 'ok $value',
      Err<int>(:final failure) => 'err ${failure.messageKey}',
    };
    expect(describe(const Ok<int>(3)), 'ok 3');
    expect(describe(const Err<int>(failure)), 'err failureNotFound');
  });

  group('guardAsync', () {
    test('wraps a value', () async {
      expect(await guardAsync(() async => 5), const Ok<int>(5));
    });

    test('turns a thrown error into UnexpectedFailure', () async {
      final r = await guardAsync<int>(() async => throw StateError('boom'));
      final f = r.failureOrNull();
      expect(f, isA<UnexpectedFailure>());
      expect((f! as UnexpectedFailure).error, isA<StateError>());
      expect((f as UnexpectedFailure).stack, isNotNull);
    });
  });
}
