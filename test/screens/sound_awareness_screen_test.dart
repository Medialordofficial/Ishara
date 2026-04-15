import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ishara/screens/sound_awareness_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SoundAwarenessScreen', () {
    testWidgets('renders AppBar with Sound Awareness title', (tester) async {
      await tester.pumpWidget(_wrap(const SoundAwarenessScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Sound Awareness'), findsOneWidget);
    });

    testWidgets('renders listening toggle with hearing disabled icon', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SoundAwarenessScreen()));
      await tester.pumpAndSettle();

      // Initially not listening → hearing_disabled icon
      expect(find.byIcon(Icons.hearing_disabled), findsOneWidget);
    });

    testWidgets('renders Tap to Listen text initially', (tester) async {
      await tester.pumpWidget(_wrap(const SoundAwarenessScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Tap to Listen'), findsOneWidget);
    });

    testWidgets('renders test alerts section', (tester) async {
      await tester.pumpWidget(_wrap(const SoundAwarenessScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Test Alerts'), findsOneWidget);
    });

    testWidgets('renders test alert icons', (tester) async {
      await tester.pumpWidget(_wrap(const SoundAwarenessScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.byIcon(Icons.doorbell), findsOneWidget);
      expect(find.byIcon(Icons.vibration), findsOneWidget);
    });

    testWidgets('renders Recent Activity section', (tester) async {
      await tester.pumpWidget(_wrap(const SoundAwarenessScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('shows no sounds message initially', (tester) async {
      await tester.pumpWidget(_wrap(const SoundAwarenessScreen()));
      await tester.pumpAndSettle();

      expect(find.text('No sounds detected yet.'), findsOneWidget);
    });

    testWidgets('has scaffold with proper background', (tester) async {
      await tester.pumpWidget(_wrap(const SoundAwarenessScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
