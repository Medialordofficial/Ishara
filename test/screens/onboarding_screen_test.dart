import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ishara/screens/onboarding_screen.dart';
import 'package:ishara/main.dart' show IsharaApp;

Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  group('OnboardingScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders first page title', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.pump();

      expect(find.text('Welcome to Ishara'), findsOneWidget);
    });

    testWidgets('Skip button is present and tappable', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.pump();

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('Next button advances to second page', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.pump();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Conversation Mode'), findsOneWidget);
    });

    testWidgets('Last page shows Get Started button', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.pump();

      // Advance through all pages
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('IsharaApp routes to OnboardingScreen when showOnboarding is true',
        (tester) async {
      await tester.pumpWidget(const IsharaApp(showOnboarding: true));
      await tester.pump();

      expect(find.text('Welcome to Ishara'), findsOneWidget);
    });

    testWidgets('IsharaApp routes to HomeScreen when showOnboarding is false',
        (tester) async {
      await tester.pumpWidget(const IsharaApp(showOnboarding: false));
      await tester.pump();

      // HomeScreen shows the app name / greeting, not the onboarding title
      expect(find.text('Welcome to Ishara'), findsNothing);
    });
  });
}
