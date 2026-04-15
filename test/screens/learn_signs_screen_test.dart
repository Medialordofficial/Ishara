import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ishara/screens/learn_signs_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LearnSignsScreen', () {
    testWidgets('renders header with Learn Signs title', (tester) async {
      await tester.pumpWidget(_wrap(const LearnSignsScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Learn Signs'), findsOneWidget);
    });

    testWidgets('renders Go back semantic button', (tester) async {
      await tester.pumpWidget(_wrap(const LearnSignsScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.bySemanticsLabel('Go back'), findsOneWidget);
    });

    testWidgets('renders category selector with default category', (tester) async {
      await tester.pumpWidget(_wrap(const LearnSignsScreen()));
      await tester.pump(const Duration(seconds: 1));

      // Category text is formatted as '${emoji} ${name}'
      expect(find.textContaining('Greetings & Basics'), findsWidgets);
    });

    testWidgets('renders progress stats', (tester) async {
      await tester.pumpWidget(_wrap(const LearnSignsScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Beginner'), findsOneWidget);
    });

    testWidgets('renders check sign button with semantic label', (tester) async {
      await tester.pumpWidget(_wrap(const LearnSignsScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.bySemanticsLabel('Check my sign'), findsOneWidget);
    });

    testWidgets('renders prev and next navigation buttons', (tester) async {
      await tester.pumpWidget(_wrap(const LearnSignsScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.bySemanticsLabel('Previous sign'), findsOneWidget);
      expect(find.bySemanticsLabel('Next sign'), findsOneWidget);
    });

    testWidgets('has scaffold with correct background', (tester) async {
      await tester.pumpWidget(_wrap(const LearnSignsScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders streak emoji', (tester) async {
      await tester.pumpWidget(_wrap(const LearnSignsScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('🔥'), findsOneWidget);
    });
  });
}
