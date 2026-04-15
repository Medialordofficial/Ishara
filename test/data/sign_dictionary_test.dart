import 'package:flutter_test/flutter_test.dart';
import 'package:ishara/data/sign_dictionary.dart';

void main() {
  group('SignDictionary', () {
    test('has at least 3 categories', () {
      expect(SignDictionary.categories.length, greaterThanOrEqualTo(3));
    });

    test('every category has a name and icon', () {
      for (final cat in SignDictionary.categories) {
        expect(cat.name, isNotEmpty);
        expect(cat.icon, isNotEmpty);
      }
    });

    test('every category has at least one sign', () {
      for (final cat in SignDictionary.categories) {
        expect(cat.signs, isNotEmpty, reason: '${cat.name} has no signs');
      }
    });

    test('every sign has word, description, emoji, and steps', () {
      for (final cat in SignDictionary.categories) {
        for (final sign in cat.signs) {
          expect(sign.word, isNotEmpty, reason: 'Sign missing word in ${cat.name}');
          expect(sign.description, isNotEmpty,
              reason: '${sign.word} missing description');
          expect(sign.emoji, isNotEmpty, reason: '${sign.word} missing emoji');
          expect(sign.steps, isNotEmpty, reason: '${sign.word} missing steps');
        }
      }
    });

    test('contains Alphabet category', () {
      final alpha =
          SignDictionary.categories.where((c) => c.name == 'Alphabet');
      expect(alpha, isNotEmpty);
    });

    test('contains Greetings & Basics category', () {
      final greetings = SignDictionary.categories
          .where((c) => c.name == 'Greetings & Basics');
      expect(greetings, isNotEmpty);
    });

    test('alphabet has 26 signs', () {
      final alpha =
          SignDictionary.categories.firstWhere((c) => c.name == 'Alphabet');
      expect(alpha.signs.length, 26);
    });
  });

  group('SignEntry', () {
    test('creates with required fields', () {
      const entry = SignEntry(
        word: 'Hello',
        description: 'Wave your hand',
        emoji: '👋',
        steps: ['Open palm', 'Wave side to side'],
        category: 'Greetings',
      );
      expect(entry.word, 'Hello');
      expect(entry.difficulty, 'Beginner');
    });

    test('supports custom difficulty', () {
      const entry = SignEntry(
        word: 'Complex',
        description: 'A complex sign',
        emoji: '🤲',
        steps: ['Step 1'],
        category: 'Advanced',
        difficulty: 'Advanced',
      );
      expect(entry.difficulty, 'Advanced');
    });
  });

  group('SignCategory', () {
    test('creates with required fields', () {
      const cat = SignCategory(
        name: 'Test',
        icon: '🧪',
        signs: [
          SignEntry(
            word: 'Test',
            description: 'desc',
            emoji: '🧪',
            steps: ['step'],
            category: 'Test',
          ),
        ],
      );
      expect(cat.name, 'Test');
      expect(cat.signs.length, 1);
    });
  });
}
