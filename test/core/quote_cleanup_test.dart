import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/text/quote_cleanup.dart';

void main() {
  group('joining', () {
    test('lines become one paragraph', () {
      expect(
        cleanQuoteText(['It was the best', 'of times, it was', 'the worst.']),
        'It was the best of times, it was the worst.',
      );
    });

    test('a hyphenated break before lower case is rejoined', () {
      expect(
        cleanQuoteText(['an exam-', 'ple of it', 'and ordi-', 'nary words']),
        'an example of it and ordinary words',
      );
    });

    test('a real hyphen before a capital or digit is kept', () {
      expect(cleanQuoteText(['Anglo-', 'Saxon']), 'Anglo- Saxon');
      expect(cleanQuoteText(['page 3-', '4 only']), 'page 3- 4 only');
    });

    test('a dash that is not after a letter is left alone', () {
      expect(cleanQuoteText(['wait --', 'what']), 'wait -- what');
    });

    test('a soft hyphen at the break is dropped', () {
      expect(cleanQuoteText(['inter­', 'esting']), 'interesting');
    });

    test('blank lines separate paragraphs', () {
      expect(
        cleanQuoteText(['One.', '', '', 'Two', 'lines.', '']),
        'One.\n\nTwo lines.',
      );
    });

    test('nothing in, nothing out', () {
      expect(cleanQuoteText(const <String>[]), '');
      expect(cleanQuoteText(['  ', '\t']), '');
    });
  });

  group('spaces', () {
    test('collapses runs, odd spaces and space before punctuation', () {
      expect(
        cleanQuoteText(['  Hello  world ,  said   she  !']),
        'Hello world, said she!',
      );
    });

    test('drops zero-width spaces', () {
      expect(cleanQuoteText(['a​b']), 'ab');
    });
  });

  group('quotes', () {
    test('straight double quotes turn typographic', () {
      expect(
        cleanQuoteText(['She said "no way" twice.']),
        'She said “no way” twice.',
      );
      expect(cleanQuoteText(['"Yes," he said.']), '“Yes,” he said.');
    });

    test('apostrophes and single quotes', () {
      expect(cleanQuoteText(["don't"]), 'don’t');
      expect(cleanQuoteText(["He said 'hi' to us"]), 'He said ‘hi’ to us');
      expect(cleanQuoteText(["the '90s"]), 'the ‘90s');
    });

    test('OCR doubled marks and guillemets', () {
      expect(cleanQuoteText(["``Go,'' she said"]), '“Go,” she said');
      expect(cleanQuoteText(['«Bonjour»']), '“Bonjour”');
    });

    test('quote after a dash or bracket opens', () {
      expect(cleanQuoteText(['(“x") and —"y"']), '(“x”) and —“y”');
    });

    test('ellipsis', () {
      expect(cleanQuoteText(['and then...']), 'and then…');
    });

    test('Hindi and Bengali pass through untouched', () {
      expect(cleanQuoteText(['किताबें', 'पढ़ो']), 'किताबें पढ़ो');
      expect(cleanQuoteText(['বই', 'পড়ো']), 'বই পড়ো');
    });
  });
}
