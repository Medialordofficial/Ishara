import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ishara/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ApiService api;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = ApiService(baseUrl: 'http://localhost:8000');
  });

  group('classifySound', () {
    test('returns parsed JSON on 200', () async {
      api.httpClient = MockClient((request) async {
        expect(request.url.path, '/classify-sound');
        expect(request.method, 'POST');
        final body = jsonDecode(request.body);
        expect(body['description'], 'loud bang');
        return http.Response(
          jsonEncode({
            'sound': 'alarm',
            'level': 'critical',
            'description': 'Fire alarm',
          }),
          200,
        );
      });

      final result = await api.classifySound('loud bang');
      expect(result['sound'], 'alarm');
      expect(result['level'], 'critical');
    });

    test('throws on non-200 status', () async {
      api.httpClient = MockClient(
        (_) async => http.Response('Server error', 500),
      );

      expect(
        () => api.classifySound('test'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('emergencyMessage', () {
    test('returns parsed JSON on 200', () async {
      api.httpClient = MockClient((request) async {
        expect(request.url.path, '/emergency-message');
        final body = jsonDecode(request.body);
        expect(body['emergency_type'], 'medical');
        expect(body['latitude'], 1.0);
        expect(body['longitude'], 2.0);
        return http.Response(
          jsonEncode({'message': 'Help needed at coordinates 1.0, 2.0'}),
          200,
        );
      });

      final result = await api.emergencyMessage(
        latitude: 1.0,
        longitude: 2.0,
        emergencyType: 'medical',
      );
      expect(result['message'], contains('Help'));
    });

    test('throws on server error', () async {
      api.httpClient = MockClient(
        (_) async => http.Response('Bad request', 400),
      );

      expect(
        () => api.emergencyMessage(
          latitude: 0,
          longitude: 0,
          emergencyType: 'fire',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('chatLLM', () {
    test('returns reply on 200', () async {
      api.httpClient = MockClient((request) async {
        expect(request.url.path, '/chat');
        final body = jsonDecode(request.body);
        expect(body['message'], 'hello');
        return http.Response(
          jsonEncode({'reply': 'Hi there! How can I help?'}),
          200,
        );
      });

      final result = await api.chatLLM('hello');
      expect(result, 'Hi there! How can I help?');
    });

    test('sends history when provided', () async {
      api.httpClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['history'], isNotNull);
        expect(body['history'], hasLength(1));
        return http.Response(
          jsonEncode({'reply': 'Noted.'}),
          200,
        );
      });

      final result = await api.chatLLM(
        'follow up',
        history: [{'role': 'user', 'content': 'first message'}],
      );
      expect(result, 'Noted.');
    });

    test('throws on non-200', () async {
      api.httpClient = MockClient(
        (_) async => http.Response('Unauthorized', 401),
      );

      expect(() => api.chatLLM('test'), throwsA(isA<Exception>()));
    });
  });

  group('ping', () {
    test('returns true on 200', () async {
      api.httpClient = MockClient((request) async {
        expect(request.url.path, '/ping');
        expect(request.method, 'GET');
        return http.Response(
          jsonEncode({'status': 'ok'}),
          200,
        );
      });

      expect(await api.ping(), isTrue);
    });

    test('returns false on 500', () async {
      api.httpClient = MockClient(
        (_) async => http.Response('error', 500),
      );

      expect(await api.ping(), isFalse);
    });

    test('returns false on exception', () async {
      api.httpClient = MockClient(
        (_) => throw Exception('network error'),
      );

      expect(await api.ping(), isFalse);
    });
  });

  group('interpretSign', () {
    test('sends multipart and returns sign', () async {
      api.httpClient = MockClient.streaming((request, _) async {
        expect(request.url.path, '/interpret-sign');
        expect(request.method, 'POST');
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'sign': 'hello'}))),
          200,
        );
      });

      final result = await api.interpretSign(Uint8List.fromList([1, 2, 3]));
      expect(result, 'hello');
    });

    test('throws on server error', () async {
      api.httpClient = MockClient.streaming((request, _) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode('error')),
          500,
        );
      });

      expect(
        () => api.interpretSign(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('readWorld', () {
    test('sends multipart with question and returns description', () async {
      api.httpClient = MockClient.streaming((request, _) async {
        expect(request.url.path, '/read-world');
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(jsonEncode({'description': 'A stop sign'})),
          ),
          200,
        );
      });

      final result = await api.readWorld(
        Uint8List.fromList([1, 2, 3]),
        question: 'What is this?',
      );
      expect(result, 'A stop sign');
    });
  });

  group('evaluateSign', () {
    test('sends multipart with target sign and returns feedback', () async {
      api.httpClient = MockClient.streaming((request, _) async {
        expect(request.url.path, '/evaluate-sign');
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(jsonEncode({'feedback': 'Good form!'})),
          ),
          200,
        );
      });

      final result = await api.evaluateSign(
        Uint8List.fromList([1, 2, 3]),
        'thank_you',
      );
      expect(result['feedback'], 'Good form!');
    });
  });

  group('retry logic', () {
    test('retries on timeout and eventually succeeds', () async {
      var callCount = 0;
      api.httpClient = MockClient((request) async {
        callCount++;
        if (callCount < 3) {
          throw http.ClientException('Connection refused');
        }
        return http.Response(
          jsonEncode({
            'sound': 'speech',
            'level': 'normal',
            'description': 'Talking',
          }),
          200,
        );
      });

      final result = await api.classifySound('talking');
      expect(result['sound'], 'speech');
      expect(callCount, 3); // 2 failures + 1 success
    });

    test('throws after max retries exhausted', () async {
      api.httpClient = MockClient((_) async {
        throw http.ClientException('Connection refused');
      });

      expect(
        () => api.classifySound('anything'),
        throwsA(isA<http.ClientException>()),
      );
    });

    test('chatLLM retries on transient failure', () async {
      var callCount = 0;
      api.httpClient = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          throw http.ClientException('Network error');
        }
        return http.Response(
          jsonEncode({'reply': 'Retried successfully'}),
          200,
        );
      });

      final result = await api.chatLLM('test');
      expect(result, 'Retried successfully');
      expect(callCount, 2);
    });
  });

  group('speechToText', () {
    test('sends audio multipart and returns text', () async {
      api.httpClient = MockClient.streaming((request, _) async {
        expect(request.url.path, '/speech-to-text');
        expect(request.method, 'POST');
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'text': 'hello world'}))),
          200,
        );
      });

      final result = await api.speechToText(Uint8List.fromList([0, 1, 2]));
      expect(result, 'hello world');
    });

    test('throws on server error', () async {
      api.httpClient = MockClient.streaming((request, _) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode('error')),
          503,
        );
      });

      expect(
        () => api.speechToText(Uint8List.fromList([0, 1])),
        throwsA(isA<Exception>()),
      );
    });
  });
}
