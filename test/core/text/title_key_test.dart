import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/text/title_key.dart';

String k(String title, [String authors = '']) =>
    normalizeTitle(title, authors).value;

void main() {
  group('title normalisation', () {
    test('Harry Potter spellings share a key', () {
      expect(
        k("Harry Potter and the Philosopher's Stone", 'J. K. Rowling'),
        k('Harry Potter & the Philosophers Stone', 'J.K. Rowling'),
      );
      expect(
        k("Harry Potter and the Philosopher's Stone", 'J. K. Rowling'),
        'harry potter and the philosophers stone|rowling',
      );
    });

    test('case, whitespace and punctuation', () {
      expect(k('  THE   Hobbit!! '), 'hobbit');
      expect(k('Hobbit,'), 'hobbit');
      expect(k('x\ty\nz'), 'x y z');
      expect(k('Spider-Man'), 'spider man');
    });

    test('apostrophes are removed, not turned into spaces', () {
      for (final a in <String>["'", '’', '‘', 'ʼ', '`']) {
        expect(k("Don${a}t Look"), 'dont look', reason: a);
      }
    });

    test('ampersand becomes "and"', () {
      expect(k('Pride & Prejudice'), 'pride and prejudice');
      expect(k('Pride&Prejudice'), 'pride and prejudice');
    });

    test('leading articles are dropped only when more words follow', () {
      expect(k('The Hobbit'), 'hobbit');
      expect(k('A Suitable Boy'), 'suitable boy');
      expect(k('An Equal Music'), 'equal music');
      expect(k('The'), 'the');
      expect(k('A'), 'a');
      expect(k('Theory of Everything'), 'theory of everything');
      expect(k('Another Country'), 'another country');
    });

    test('subtitle after a colon is dropped', () {
      expect(
        k('Sapiens: A Brief History of Humankind', 'Yuval Noah Harari'),
        'sapiens|harari',
      );
      expect(k('Sapiens'), k('Sapiens: A Brief History'));
    });

    test('a leading colon does not erase the title', () {
      expect(k(':Hidden'), 'hidden');
    });

    test('accents are removed', () {
      expect(
        k('Cien años de soledad', 'Gabriel García Márquez'),
        k('Cien anos de soledad', 'Gabriel Garcia Marquez'),
      );
      expect(k('Les Misérables'), 'les miserables');
      expect(k('Über'), 'uber');
    });

    test('compatibility forms fold (NFKD)', () {
      expect(k('ﬁnd'), 'find'); // fi ligature
      expect(k('Ｈａｒｒｙ'), 'harry'); // fullwidth
    });

    test('digits and other scripts are kept', () {
      expect(k('1984', 'George Orwell'), '1984|orwell');
      expect(k('Fahrenheit 451'), 'fahrenheit 451');
    });

    test('empty and punctuation-only titles', () {
      expect(k(''), '');
      expect(k('?!...'), '');
      expect(k('', 'Rowling'), '|rowling');
    });
  });

  group('authors', () {
    test('forms of the same name agree', () {
      final a = k('Emma', 'Jane Austen');
      expect(k('Emma', 'Austen, Jane'), a);
      expect(k('Emma', 'AUSTEN'), a);
      expect(a, 'emma|austen');
    });

    test('initials and suffixes are skipped', () {
      expect(k('X', 'J. K. Rowling'), 'x|rowling');
      expect(k('X', 'Rowling, J. K.'), 'x|rowling');
      expect(k('X', 'Rowling J.K.'), 'x|rowling');
      expect(k('X', 'Martin Luther King Jr.'), 'x|king');
      expect(k('X', 'J.R.R. Tolkien'), 'x|tolkien');
    });

    test('only the first of several authors counts', () {
      expect(
        k('Good Omens', 'Neil Gaiman and Terry Pratchett'),
        'good omens|gaiman',
      );
      expect(
        k('Good Omens', 'Neil Gaiman, Terry Pratchett'),
        'good omens|gaiman',
      );
      expect(
        k('Good Omens', 'Neil Gaiman & Terry Pratchett'),
        'good omens|gaiman',
      );
      expect(
        k('Good Omens', 'Neil Gaiman; Terry Pratchett'),
        'good omens|gaiman',
      );
      expect(k('Good Omens', 'Gaiman, Neil'), 'good omens|gaiman');
    });

    test('single-name and blank authors', () {
      expect(k('Republic', 'Plato'), 'republic|plato');
      expect(k('Republic', '   '), 'republic');
      expect(k('Republic', ', ;'), 'republic');
    });

    test('accented surnames fold', () {
      expect(k('X', 'Gabriel García Márquez'), 'x|marquez');
    });
  });

  group('Hindi and Bengali', () {
    test('letters and vowel signs are preserved', () {
      final key = k('गोदान', 'प्रेमचंद');
      expect(key, 'गोदान|प्रेमचंद');
      expect(key, contains('ो')); // Devanagari vowel sign O
    });

    test('punctuation does not change the key', () {
      expect(k('गोदान!'), k('गोदान'));
      expect(k('गोदान।'), k('गोदान')); // danda
    });

    test('Bengali text keeps its marks (chandrabindu)', () {
      expect(k('পথের পাঁচালী'), contains('ঁ'));
      expect(k('পথের পাঁচালী'), isNot(k('পথের পচালী')));
    });

    test('canonically equivalent spellings agree', () {
      // Bengali vowel sign O: precomposed vs two-part form.
      expect(k('সো'), k('সো'));
      // Devanagari QA: precomposed vs KA + nukta.
      expect(k('क़'), k('क़'));
    });

    test('multi-word Indic author uses the last name', () {
      expect(k('X', 'अरुंधति रॉय'), 'x|रॉय');
    });

    test('Hindi and Latin titles do not collide', () {
      expect(k('गोदान'), isNot(k('Godan')));
    });
  });

  group('TitleKey', () {
    test('parts and equality', () {
      final key = normalizeTitle('The Hobbit', 'J. R. R. Tolkien');
      expect(key.titlePart, 'hobbit');
      expect(key.authorPart, 'tolkien');
      expect(key, normalizeTitle('Hobbit', 'Tolkien'));
      expect(key.hashCode, normalizeTitle('Hobbit', 'Tolkien').hashCode);
      expect(normalizeTitle('Hobbit').authorPart, '');
      expect(normalizeTitle('Hobbit').titlePart, 'hobbit');
    });
  });

  test('normalizeText is idempotent', () {
    for (final s in <String>[
      "Harry Potter & the Philosopher's Stone",
      'Cien años de soledad',
      'गोदान!',
      'পথের পাঁচালী',
    ]) {
      expect(normalizeText(normalizeText(s)), normalizeText(s), reason: s);
    }
  });
}
