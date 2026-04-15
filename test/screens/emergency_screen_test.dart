import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ishara/screens/emergency_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('EmergencyScreen', () {
    testWidgets('renders AppBar with Emergency SOS title', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Emergency SOS'), findsOneWidget);
    });

    testWidgets('renders SOS icon', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencyScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sos_rounded), findsOneWidget);
    });

    testWidgets('renders Select Emergency Type heading', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Select Emergency Type'), findsOneWidget);
    });

    testWidgets('renders three emergency type buttons', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Medical'), findsOneWidget);
      expect(find.text('Police'), findsOneWidget);
      expect(find.text('Fire'), findsOneWidget);
    });

    testWidgets('renders emergency type icons', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencyScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_hospital), findsOneWidget);
      expect(find.byIcon(Icons.local_police), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('SEND SOS button is disabled initially', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('SEND SOS'), findsOneWidget);
      // Button text exists but button should be disabled (no type selected)
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'SEND SOS'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('selecting a type enables SEND SOS button', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencyScreen()));
      await tester.pumpAndSettle();

      // Tap Medical type
      await tester.tap(find.text('Medical'));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'SEND SOS'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('renders helper text', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencyScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('We will dispatch help to your location.'),
        findsOneWidget,
      );
    });

    testWidgets('has send SOS semantic label for accessibility', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencyScreen()));
      await tester.pumpAndSettle();

      // The Semantics wrapper around the button should have the label
      final semantics = find.bySemanticsLabel('Send SOS emergency alert');
      expect(semantics, findsOneWidget);
    });
  });
}
