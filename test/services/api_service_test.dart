import 'package:flutter_test/flutter_test.dart';
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
}
