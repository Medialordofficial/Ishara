// Integration tests verifying cross-component flows.
//
// These exercise multi-service pipelines (navigation → screen → service)
// without native plugins, using mocked HTTP + SharedPreferences.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ishara/main.dart';
import 'package:ishara/screens/home_screen.dart';
import 'package:ishara/services/api_service.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Navigation Integration', () {
    testWidgets('Home → Search tab shows dictionary', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      // Tap the search tab
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      // Should show the sign dictionary content
      expect(find.textContaining('Sign'), findsWidgets);
    });

    testWidgets('Home → Settings tab shows settings', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      // Tap the settings tab
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();

      // Should show settings content
      expect(find.text('Settings'), findsWidgets);
    });
  });

  group('Theme Integration', () {
    testWidgets('dark themeNotifier applies dark theme', (tester) async {
      SharedPreferences.setMockInitialValues({});
      themeNotifier.value = ThemeMode.dark;

      await tester.pumpWidget(const IsharaApp());
      await tester.pumpAndSettle();

      // Use a descendant widget context so we see the applied theme
      final scaffold = find.byType(Scaffold).first;
      final context = tester.element(scaffold);
      expect(Theme.of(context).brightness, Brightness.dark);
    });

    testWidgets('light themeNotifier applies light theme', (tester) async {
      SharedPreferences.setMockInitialValues({});
      themeNotifier.value = ThemeMode.light;

      await tester.pumpWidget(const IsharaApp());
      await tester.pumpAndSettle();

      final scaffold = find.byType(Scaffold).first;
      final context = tester.element(scaffold);
      expect(Theme.of(context).brightness, Brightness.light);
    });

    test('SharedPreferences dark value maps to ThemeMode.dark', () async {
      SharedPreferences.setMockInitialValues({'ishara_theme': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('ishara_theme') ?? 'system';
      final mode = switch (saved) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };
      expect(mode, ThemeMode.dark);
    });
  });

  group('ApiService Integration', () {
    test('ping returns true on 200', () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService();
      api.httpClient = MockClient((req) async {
        if (req.url.path == '/ping') {
          return http.Response('{"status":"ok","model":"gemma4"}', 200);
        }
        return http.Response('', 404);
      });

      expect(await api.ping(), isTrue);
      expect(api.isOnline, isTrue);
    });

    test('ping returns false → isOnline false', () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService();
      api.httpClient = MockClient((req) async {
        throw http.ClientException('no network');
      });

      expect(await api.ping(), isFalse);
      expect(api.isOnline, isFalse);
    });

    test('chatLLM integrates retry then succeeds', () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService();
      var attempts = 0;
      api.httpClient = MockClient((req) async {
        attempts++;
        if (attempts < 2) {
          throw http.ClientException('transient');
        }
        return http.Response(jsonEncode({'reply': 'Hello!'}), 200);
      });

      final reply = await api.chatLLM('Hi');
      expect(reply, 'Hello!');
      expect(attempts, 2);
    });

    test('classifySound returns parsed JSON', () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService();
      api.httpClient = MockClient((req) async {
        return http.Response(
          jsonEncode({
            'sound': 'alarm',
            'level': 'critical',
            'description': 'Fire alarm',
          }),
          200,
        );
      });

      final result = await api.classifySound('loud beeping');
      expect(result['sound'], 'alarm');
      expect(result['level'], 'critical');
    });

    test('interpretSign returns sign and confidence', () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService();
      api.httpClient = MockClient.streaming((req, _) async {
        expect(req.url.path, '/interpret-sign');
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(jsonEncode({'sign': 'Hello', 'confidence': 0.91})),
          ),
          200,
        );
      });

      final result =
          await api.interpretSign(Uint8List.fromList([0xFF, 0xD8, 0xFF]));
      expect(result['sign'], 'Hello');
      expect((result['confidence'] as double), closeTo(0.91, 0.001));
    });

    test('sendFeedback round-trip returns true', () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService();
      late Map<String, dynamic> captured;
      api.httpClient = MockClient((req) async {
        captured = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({'received': true}), 200);
      });

      final ok = await api.sendFeedback(
        interpretedSign: 'Hello',
        correctSign: 'Thank you',
        context: 'test-flow',
      );
      expect(ok, isTrue);
      expect(captured['interpreted_sign'], 'Hello');
      expect(captured['correct_sign'], 'Thank you');
      expect(captured['context'], 'test-flow');
    });

    test('emergencyMessage returns structured JSON', () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService();
      api.httpClient = MockClient((req) async {
        return http.Response(
          jsonEncode({
            'message': 'EMERGENCY: Medical help needed',
            'location': '-1.286,36.817',
          }),
          200,
        );
      });

      final result = await api.emergencyMessage(
        latitude: -1.286,
        longitude: 36.817,
        emergencyType: 'medical',
      );
      expect(result['message'], contains('EMERGENCY'));
    });
  });
}
