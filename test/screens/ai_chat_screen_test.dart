import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ishara/screens/ai_chat_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AiChatScreen', () {
    testWidgets('renders chat screen with app bar', (tester) async {
      await tester.pumpWidget(_wrap(const AiChatScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Ishara AI'), findsOneWidget);
    });

    testWidgets('shows initial system message', (tester) async {
      await tester.pumpWidget(_wrap(const AiChatScreen()));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Ask me anything'),
        findsOneWidget,
      );
    });

    testWidgets('has a text input field', (tester) async {
      await tester.pumpWidget(_wrap(const AiChatScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('has a send button', (tester) async {
      await tester.pumpWidget(_wrap(const AiChatScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });
  });
}
