import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ishara/screens/settings_screen.dart';
import 'package:ishara/main.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    themeNotifier.value = ThemeMode.system;
  });

  group('SettingsScreen', () {
    testWidgets('renders with appBar when showAppBar=true', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen(showAppBar: true)));
      await tester.pumpAndSettle();

      // AppBar title
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders inline when showAppBar=false', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen(showAppBar: false)));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Server Connection'), findsOneWidget);
    });

    testWidgets('shows server connection fields', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Server Host / IP'), findsOneWidget);
      expect(find.text('Port'), findsOneWidget);
      expect(find.text('Test Connection'), findsOneWidget);
    });

    testWidgets('shows appearance section with theme options', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Scroll down to reveal Appearance section (now after Emergency Services section)
      await tester.scrollUntilVisible(
        find.text('Appearance'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('shows quick start guide steps after scrolling', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Scroll down to reveal Quick Start section
      await tester.scrollUntilVisible(
        find.text('Quick Start'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Quick Start'), findsOneWidget);
    });

    testWidgets('shows About section after scrolling', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Scroll down to reveal About section
      await tester.scrollUntilVisible(
        find.text('About Ishara'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('About Ishara'), findsOneWidget);
    });

    testWidgets('theme toggle changes themeNotifier value', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(themeNotifier.value, ThemeMode.system);

      // Scroll to reveal Appearance section (now after Emergency Services section)
      await tester.scrollUntilVisible(
        find.text('Dark'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tap "Dark" radio option
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(themeNotifier.value, ThemeMode.dark);

      // Scroll to ensure "Light" is visible before tapping
      await tester.scrollUntilVisible(
        find.text('Light'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tap "Light" radio option
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(themeNotifier.value, ThemeMode.light);

      // Reset
      themeNotifier.value = ThemeMode.system;
    });

    testWidgets('shows Emergency Services section after scrolling', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Emergency Services'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Emergency Services'), findsOneWidget);
    });

    testWidgets('Emergency Number field renders with default value 112', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Emergency Services'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Emergency Number'), findsOneWidget);
      // Default value should be 112
      final controllers = tester.widgetList<TextField>(find.byType(TextField));
      final emergencyField = controllers.where(
        (tf) => tf.controller?.text == '112',
      );
      expect(emergencyField, isNotEmpty);
    });

    testWidgets('Emergency Number section has descriptive help text', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Emergency Services'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('112 (international)'),
        findsOneWidget,
      );
    });

    testWidgets('Emergency Number loads from SharedPreferences', (tester) async {
      SharedPreferences.setMockInitialValues({
        'ishara_emergency_number': '999',
      });

      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Emergency Services'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Field should display the saved value
      final controllers = tester.widgetList<TextField>(find.byType(TextField));
      final savedField = controllers.where(
        (tf) => tf.controller?.text == '999',
      );
      expect(savedField, isNotEmpty);
    });
  });
}
