import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ishara/screens/ai_chat_screen.dart';
import 'package:ishara/services/api_service.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Point ApiService to a failing client so tests use the fallback path
    ApiService().httpClient = MockClient((_) async => http.Response('', 503));
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

    testWidgets('send button has Send message semantics', (tester) async {
      await tester.pumpWidget(_wrap(const AiChatScreen()));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Send message'), findsOneWidget);
    });

    testWidgets('sending hello adds user message to chat', (tester) async {
      await tester.pumpWidget(_wrap(const AiChatScreen()));
      await tester.pumpAndSettle();

      // Type into the text field and send
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send message'));

      // Use runAsync to let async operations (platform channels for SharedPrefs,
      // MockClient, etc.) actually complete in real time
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(seconds: 2));
      });
      // Rebuild the widget tree after async operations complete
      await tester.pump();
      await tester.pump();

      // User message 'hello' should appear in the chat
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('server offline shows honest fallback response',
        (tester) async {
      await tester.pumpWidget(_wrap(const AiChatScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'emergency danger');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send message'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(seconds: 2));
      });
      await tester.pump();
      await tester.pump();

      // When server is unreachable, the fallback shows an honest offline message
      // rather than fake keyword-matched responses.
      expect(find.textContaining('unreachable'), findsOneWidget);
    });

    testWidgets('sending empty text does not add a message', (tester) async {
      await tester.pumpWidget(_wrap(const AiChatScreen()));
      await tester.pumpAndSettle();

      final messageBefore = find.byType(Container).evaluate().length;
      await tester.tap(find.bySemanticsLabel('Send message'));
      await tester.pumpAndSettle();

      // Only the initial system message — count unchanged
      expect(find.textContaining('Ask me anything'), findsOneWidget);
      final messageAfter = find.byType(Container).evaluate().length;
      expect(messageAfter, messageBefore);
    });

    testWidgets('clear button resets conversation', (tester) async {
      await tester.pumpWidget(_wrap(const AiChatScreen()));
      await tester.pumpAndSettle();

      // Send a message first
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send message'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(seconds: 2));
      });
      await tester.pump();
      await tester.pump();

      // Tap clear
      await tester.tap(find.bySemanticsLabel('Clear chat'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Chat cleared'), findsOneWidget);
    });

    testWidgets('go back button has correct semantics', (tester) async {
      await tester.pumpWidget(_wrap(const AiChatScreen()));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Go back'), findsOneWidget);
    });
  });
}
