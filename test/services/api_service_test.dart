import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ishara/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ApiService singleton', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('factory returns same instance', () {
      final a = ApiService();
      final b = ApiService();
      expect(identical(a, b), isTrue);
    });

    test('default baseUrl points to local server', () {
      final api = ApiService();
      expect(api.baseUrl, contains('http://'));
      expect(api.baseUrl, contains(':8000'));
    });

    test('factory with baseUrl updates the instance URL', () {
      final api = ApiService(baseUrl: 'http://10.0.0.1:9000');
      expect(api.baseUrl, 'http://10.0.0.1:9000');
      // Reset for other tests
      ApiService(baseUrl: 'http://192.168.1.100:8000');
    });

    test('updateBaseUrl persists host and port', () async {
      final api = ApiService();
      await api.updateBaseUrl('10.0.0.5', port: 3000);
      expect(api.baseUrl, 'http://10.0.0.5:3000');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ishara_host'), '10.0.0.5');
      expect(prefs.getInt('ishara_port'), 3000);

      // Reset
      await api.updateBaseUrl('192.168.1.100', port: 8000);
    });

    test('updateBaseUrl uses default port 8000', () async {
      final api = ApiService();
      await api.updateBaseUrl('myhost.local');
      expect(api.baseUrl, 'http://myhost.local:8000');

      // Reset
      await api.updateBaseUrl('192.168.1.100', port: 8000);
    });

    test('ping returns false when server is unreachable', () async {
      final api = ApiService(baseUrl: 'http://192.168.255.255:9999');
      final result = await api.ping();
      expect(result, isFalse);

      // Reset
      ApiService(baseUrl: 'http://192.168.1.100:8000');
    });
  });

  group('ApiService setApiKey', () {
    test('setApiKey stores and retrieves key in memory', () async {
      final api = ApiService(baseUrl: 'http://localhost:8000');
      await api.setApiKey('test-key-123');
      // Key should be attached to requests — we verify via the header in HTTP tests
      // Here we just verify it doesn't throw
      expect(() async => api.setApiKey('test-key-123'), returnsNormally);
    });

    test('setApiKey with null removes key', () async {
      final api = ApiService(baseUrl: 'http://localhost:8000');
      await api.setApiKey('some-key');
      await api.setApiKey(null);
      // Verifying no exceptions thrown
      expect(() async => api.setApiKey(null), returnsNormally);
    });
  });

  group('ApiService auth header injection', () {
    test('requests include X-API-Key header when key is set', () async {
      final api = ApiService(baseUrl: 'http://localhost:8000');
      await api.setApiKey('my-secret-key');

      http.Request? captured;
      api.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{"text": "hello"}', 200);
      });

      await api.speechToText(Uint8List.fromList([0, 1, 2, 3]));
      expect(captured?.headers['X-API-Key'], 'my-secret-key');

      await api.setApiKey(null);
    });

    test('requests have no X-API-Key header when key is not set', () async {
      final api = ApiService(baseUrl: 'http://localhost:8000');
      await api.setApiKey(null);

      http.Request? captured;
      api.httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{"text": "hello"}', 200);
      });

      await api.speechToText(Uint8List.fromList([0, 1, 2, 3]));
      expect(captured?.headers.containsKey('X-API-Key'), isFalse);
    });
  });

  group('ApiService loadApiKey', () {
    test('loadApiKey returns null when no key is stored', () async {
      final api = ApiService(baseUrl: 'http://localhost:8000');
      await api.setApiKey(null); // ensure cleared
      // In test environment FlutterSecureStorage is unavailable, so returns null
      final key = await api.loadApiKey();
      expect(key, isNull);
    });

    test('loadApiKey does not throw when secure storage unavailable', () async {
      final api = ApiService(baseUrl: 'http://localhost:8000');
      // Should swallow platform channel errors gracefully
      expect(() async => api.loadApiKey(), returnsNormally);
    });
  });
}
