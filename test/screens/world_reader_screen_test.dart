import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ishara/screens/world_reader_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorldReaderScreen', () {
    testWidgets('renders header with World Reader title', (tester) async {
      await tester.pumpWidget(_wrap(const WorldReaderScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('World Reader'), findsOneWidget);
    });

    testWidgets('renders back button', (tester) async {
      await tester.pumpWidget(_wrap(const WorldReaderScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('renders visibility icon', (tester) async {
      await tester.pumpWidget(_wrap(const WorldReaderScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
    });

    testWidgets('renders question input field', (tester) async {
      await tester.pumpWidget(_wrap(const WorldReaderScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders capture button', (tester) async {
      await tester.pumpWidget(_wrap(const WorldReaderScreen()));
      await tester.pump(const Duration(seconds: 1));

      // The read button with camera icon
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    });

    testWidgets('has scaffold with correct structure', (tester) async {
      await tester.pumpWidget(_wrap(const WorldReaderScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders semantic Go back label', (tester) async {
      await tester.pumpWidget(_wrap(const WorldReaderScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.bySemanticsLabel('Go back'), findsOneWidget);
    });
  });
}
