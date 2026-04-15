import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ishara/main.dart';
import 'package:ishara/screens/home_screen.dart';
import 'package:ishara/utils/constants.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HomeScreen', () {
    testWidgets('renders bottom navigation with three tabs', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      // Home, Search, Settings icons in nav bar
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    });

    testWidgets('shows greeting and welcome text', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      // Should have one of the greeting messages
      final greeting = find.textContaining(RegExp(r'Good (Morning|Afternoon|Evening),'));
      expect(greeting, findsOneWidget);
    });

    testWidgets('renders all mode buttons', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.conversationMode), findsOneWidget);
      expect(find.text(AppStrings.soundAwarenessMode), findsOneWidget);
      expect(find.text(AppStrings.emergencyMode), findsOneWidget);
      expect(find.text(AppStrings.worldReaderMode), findsOneWidget);
      expect(find.text(AppStrings.learnSignsMode), findsOneWidget);
      expect(find.text('Sign Dictionary'), findsAtLeastNWidgets(1));
      expect(find.text('Ishara AI'), findsOneWidget);
    });

    testWidgets('tapping search tab shows sign dictionary search', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Search signs, phrases, alphabet...'), findsOneWidget);
    });

    testWidgets('tapping settings tab shows settings content', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Server Connection'), findsOneWidget);
    });
  });

  group('IsharaApp', () {
    testWidgets('launches and shows MaterialApp', (tester) async {
      await tester.pumpWidget(const IsharaApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('uses ValueListenableBuilder for theme', (tester) async {
      await tester.pumpWidget(const IsharaApp());
      expect(find.byType(ValueListenableBuilder<ThemeMode>), findsOneWidget);
    });

    testWidgets('respects light theme', (tester) async {
      themeNotifier.value = ThemeMode.light;
      await tester.pumpWidget(const IsharaApp());
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);
    });

    testWidgets('respects dark theme', (tester) async {
      themeNotifier.value = ThemeMode.dark;
      await tester.pumpWidget(const IsharaApp());
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);

      // Cleanup
      themeNotifier.value = ThemeMode.system;
    });
  });
}
