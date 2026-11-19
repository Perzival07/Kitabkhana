import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/text/isbn.dart';

String? p(String raw) => parseIsbn(raw)?.value;

void main() {
  group('ISBN-13', () {
    test('accepts valid 978 and 979 numbers', () {
      expect(p('9780143127550'), '9780143127550');
      expect(p('9780306406157'), '9780306406157');
      expect(p('9791090636071'), '9791090636071');
    });

    test('strips hyphens, spaces and Unicode dashes', () {
      expect(p('978-0-306-40615-7'), '9780306406157');
      expect(p('978 0 306 40615 7'), '9780306406157');
      expect(p('  978-0-306-40615-7\n'), '9780306406157');
      expect(p('978–0–306–40615–7'), '9780306406157');
    });

    test('tolerates an ISBN label', () {
      expect(p('ISBN 978-0-306-40615-7'), '9780306406157');
      expect(p('ISBN-13: 9780306406157'), '9780306406157');
      expect(p('isbn:9780306406157'), '9780306406157');
    });

    test('rejects a wrong check digit', () {
      expect(p('9780306406158'), isNull);
      expect(p('9780143127551'), isNull);
    });

    test('rejects wrong lengths and non-digits', () {
      expect(p('978030640615'), isNull); // 12
      expect(p('97803064061570'), isNull); // 14
      expect(p('97803064O6157'), isNull); // letter O
      expect(p('978030640615X'), isNull); // X only valid in ISBN-10
    });

    test('rejects non-book EANs (wrong prefix) even with a valid checksum', () {
      expect(p('5901234123457'), isNull);
      expect(p('4006381333931'), isNull);
      expect(p('9770306406156'), isNull); // 977 = periodicals
      expect(p('0012345678905'), isNull); // UPC-A as EAN-13
    });
  });

  group('ISBN-10', () {
    test('converts to ISBN-13', () {
      expect(p('0306406152'), '9780306406157');
      expect(p('0-306-40615-2'), '9780306406157');
    });

    test('handles an X check digit (upper and lower case)', () {
      expect(p('080442957X'), '9780804429573');
      expect(p('080442957x'), '9780804429573');
      expect(p('0-8044-2957-X'), '9780804429573');
    });

    test('rejects a wrong check digit and a misplaced X', () {
      expect(p('0306406153'), isNull);
      expect(p('080442957Y'), isNull);
      expect(p('03064X6152'), isNull);
      expect(p('X306406152'), isNull);
    });

    test('rejects other lengths', () {
      expect(p('030640615'), isNull); // 9
      expect(p('03064061520'), isNull); // 11
      expect(p('030640615234'), isNull); // 12 (UPC length)
    });

    test('accepts an ISBN-10 label', () {
      expect(p('ISBN-10: 0-306-40615-2'), '9780306406157');
    });
  });

  group('barcodes with a 5-digit price add-on', () {
    test('the add-on is ignored', () {
      expect(p('978014312755051295'), '9780143127550');
      expect(p('978-0-306-40615-7 90000'), '9780306406157');
    });

    test('a bad base is still rejected', () {
      expect(p('978014312755151295'), isNull);
      expect(p('590123412345751295'), isNull);
    });

    test('other long lengths are rejected', () {
      expect(p('97801431275505'), isNull);
      expect(p('9780143127550512'), isNull);
    });
  });

  group('garbage', () {
    test('empty and blank', () {
      expect(p(''), isNull);
      expect(p('   '), isNull);
      expect(p('ISBN'), isNull);
    });

    test('text', () {
      expect(p('harry potter'), isNull);
      expect(p('---'), isNull);
    });
  });

  group('Isbn13', () {
    test('equality and hashCode', () {
      expect(parseIsbn('0306406152'), parseIsbn('978-0-306-40615-7'));
      expect(
        parseIsbn('0306406152').hashCode,
        parseIsbn('9780306406157').hashCode,
      );
      expect(parseIsbn('9780306406157'), isNot(parseIsbn('9780143127550')));
    });

    test('isbn10 round-trips for 978 and is null for 979', () {
      expect(parseIsbn('9780306406157')!.isbn10, '0306406152');
      expect(parseIsbn('9780804429573')!.isbn10, '080442957X');
      expect(parseIsbn('9791090636071')!.isbn10, isNull);
    });

    test('formats in groups', () {
      expect(formatIsbn13(parseIsbn('9780306406157')!), '978-030-640-615-7');
      expect(
        formatIsbn13(parseIsbn('9780143127550')!).replaceAll('-', ''),
        '9780143127550',
      );
    });
  });
}
