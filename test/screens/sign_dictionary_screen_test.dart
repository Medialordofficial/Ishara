import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ishara/screens/sign_dictionary_screen.dart';
import 'package:ishara/data/sign_dictionary.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  group('SignDictionaryScreen', () {
    testWidgets('renders header and search bar', (tester) async {
      await tester.pumpWidget(_wrap(const SignDictionaryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Sign Dictionary'), findsOneWidget);
      expect(find.text('Search signs, phrases, alphabet...'), findsOneWidget);
    });

    testWidgets('shows sign count badge', (tester) async {
      await tester.pumpWidget(_wrap(const SignDictionaryScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('${SignDictionary.allSigns.length} signs'),
        findsOneWidget,
      );
    });

    testWidgets('shows at least some category chips', (tester) async {
      await tester.pumpWidget(_wrap(const SignDictionaryScreen()));
      await tester.pumpAndSettle();

      // The first category should be visible in horizontal scroll
      final first = SignDictionary.categories.first;
      expect(find.text(first.name), findsAtLeastNWidgets(1));
    });

    testWidgets('shows category grid initially', (tester) async {
      await tester.pumpWidget(_wrap(const SignDictionaryScreen()));
      await tester.pumpAndSettle();

      // Each category gets a grid tile with its name
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('search filters signs', (tester) async {
      await tester.pumpWidget(_wrap(const SignDictionaryScreen()));
      await tester.pumpAndSettle();

      // Type a known sign name
      await tester.enterText(
        find.byType(TextField),
        'Hello',
      );
      await tester.pumpAndSettle();

      // Grid should be replaced by list
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Hello'), findsAtLeastNWidgets(1));
    });

    testWidgets('search with no results shows empty message', (tester) async {
      await tester.pumpWidget(_wrap(const SignDictionaryScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'xyznonexistent');
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.textContaining('No signs found'), findsOneWidget);
    });

    testWidgets('clear button resets search', (tester) async {
      await tester.pumpWidget(_wrap(const SignDictionaryScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pumpAndSettle();

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Grid should be back
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('tapping category chip replaces grid with sign list', (tester) async {
      await tester.pumpWidget(_wrap(const SignDictionaryScreen()));
      await tester.pumpAndSettle();

      final firstCategory = SignDictionary.categories.first;

      // Tap the first category chip (in the horizontal scroll)
      final chipFinder = find.text(firstCategory.name);
      await tester.tap(chipFinder.first);
      await tester.pumpAndSettle();

      // Grid gone
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('back button exists', (tester) async {
      await tester.pumpWidget(_wrap(const SignDictionaryScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });
  });
}
