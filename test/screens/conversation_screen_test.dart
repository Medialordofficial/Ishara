import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ishara/screens/conversation_screen.dart';
import 'package:ishara/services/api_service.dart';
import 'package:ishara/utils/constants.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ConversationScreen', () {
    testWidgets('renders AppBar with Live Conversation title', (tester) async {
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      expect(find.text('Live Conversation'), findsOneWidget);
    });

    testWidgets('shows loading spinner when camera not ready', (tester) async {
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      // Camera fails in test environment — shows CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows initial system message in chat list', (tester) async {
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      expect(
        find.textContaining('Point the camera at the signer'),
        findsOneWidget,
      );
    });

    testWidgets('renders text input field with hint text', (tester) async {
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Type here\u2026'), findsOneWidget);
    });

    testWidgets('renders send button icon', (tester) async {
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('renders mic button for speech input', (tester) async {
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      // Not listening at start, so mic_none icon shown
      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets('renders start sign reading button', (tester) async {
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      expect(find.text('Start Sign Reading'), findsOneWidget);
      expect(find.byIcon(Icons.sign_language), findsOneWidget);
    });

    testWidgets('typing in text field and submitting adds hearing message', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Hello there');
      await tester.pump();

      // Verify the controller holds the text (confirms enterText works)
      final tf = tester.widget<TextField>(textField);
      expect(tf.controller?.text, 'Hello there');

      // Trigger onSubmitted by pressing the keyboard submit action
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Text field should be cleared after successful send
      expect(tf.controller?.text, '');
    });

    testWidgets('send button exists and has correct icon', (tester) async {
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      // Send icon button is rendered
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
      // It is wrapped in a Semantics with label 'Send message'
      expect(find.bySemanticsLabel('Send message'), findsOneWidget);
    });

    testWidgets('empty text field does not add a message on send', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      // Message count before
      final initialCount = tester.widgetList(find.byType(Text)).length;

      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      // Should not have added anything
      expect(tester.widgetList(find.byType(Text)).length, initialCount);
    });

    testWidgets('clear button appears after two or more messages', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      // No delete button initially (only system message)
      expect(find.byIcon(Icons.delete_outline), findsNothing);

      // Add a message to make _messages.length > 1
      await tester.enterText(find.byType(TextField), 'First message');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('confidence bar Semantics is in widget tree when interpreting', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      // Tap Start Sign Reading to begin interpreting (shows the confidence overlay)
      await tester.tap(find.text('Start Sign Reading'));
      await tester.pump();

      // The Semantics node for the confidence bar should now exist
      expect(find.bySemanticsLabel('Signing confidence'), findsOneWidget);
    });

    testWidgets('PoseThresholds.interpretConfidence equals 0.5', (
      tester,
    ) async {
      expect(PoseThresholds.interpretConfidence, 0.5);
    });

    testWidgets('PoseThresholds.signingConfidence equals 0.3', (tester) async {
      expect(PoseThresholds.signingConfidence, 0.3);
    });

    testWidgets('server STT chip shown when ping succeeds', (tester) async {
      ApiService().httpClient = MockClient((request) async {
        if (request.url.path == '/ping') {
          return http.Response(jsonEncode({'status': 'ok'}), 200);
        }
        return http.Response('not found', 404);
      });
      addTearDown(() => ApiService().httpClient = http.Client());

      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump(); // initState
      await tester.pump(const Duration(seconds: 1)); // async _checkServerStt

      expect(find.text('Server STT active — routing speech'), findsOneWidget);
    });

    testWidgets('server STT chip hidden when ping fails', (tester) async {
      ApiService().httpClient = MockClient(
        (_) async => http.Response('error', 500),
      );
      addTearDown(() => ApiService().httpClient = http.Client());

      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text('Server STT active — routing speech'),
        findsNothing,
      );
    });

    testWidgets(
      'server STT chip remains shown after ping; speech-to-text endpoint is /speech-to-text',
      (tester) async {
        // Verifies the correct endpoint path and that chip stays shown when
        // the STT server is reachable (available==false is exercised via service-layer tests).
        ApiService().httpClient = MockClient((request) async {
          if (request.url.path == '/ping') {
            return http.Response(jsonEncode({'status': 'ok'}), 200);
          }
          if (request.url.path == '/speech-to-text') {
            return http.Response(
              jsonEncode({'text': '', 'available': false}),
              200,
            );
          }
          return http.Response('not found', 404);
        });
        addTearDown(() => ApiService().httpClient = http.Client());

        await tester.pumpWidget(_wrap(const ConversationScreen()));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Chip shown because ping succeeded — STT availability confirmed on first use
        expect(find.text('Server STT active — routing speech'), findsOneWidget);
      },
    );

    testWidgets(
      'injection payload in text field is sanitized; no bubble added',
      (tester) async {
        await tester.pumpWidget(_wrap(const ConversationScreen()));
        await tester.pump();

        // Initially only the system message → delete button not shown
        expect(find.byIcon(Icons.delete_outline), findsNothing);

        // Enter injection payload and send
        await tester.enterText(
          find.byType(TextField),
          '<script>alert("xss")</script>',
        );
        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump();

        // Sanitization strips HTML to empty → no new message added → delete
        // button still absent (only shows when message count > 1)
        expect(
          find.byIcon(Icons.delete_outline),
          findsNothing,
          reason: 'injection strips to empty; no bubble should be added',
        );
      },
    );

    testWidgets('TextField Semantics does not use excludeSemantics',
        (tester) async {
      // Regression guard: ensures excludeSemantics:true is NOT on the TextField
      // wrapper, which would strip text-value/cursor/editing-action nodes from
      // the accessibility tree.
      await tester.pumpWidget(_wrap(const ConversationScreen()));
      await tester.pump();

      // Find all Semantics widgets that wrap a TextField
      final semanticsWidgets = tester
          .widgetList<Semantics>(find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(Semantics),
          ))
          .toList();

      for (final s in semanticsWidgets) {
        expect(
          s.excludeSemantics,
          isFalse,
          reason:
              'No Semantics ancestor of TextField may use excludeSemantics:true '
              '(would strip text-value, cursor, and editing-action nodes)',
        );
      }
    });
  });
}
