import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_exceptions.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService({String? baseUrl}) {
    if (baseUrl != null) _instance._baseUrl = baseUrl;
    return _instance;
  }
  ApiService._internal();

  String _baseUrl = 'http://192.168.1.100:8000';
  bool _initialized = false;

  /// Whether the last ping succeeded (used for offline detection).
  bool _lastPingOk = false;
  bool get isOnline => _lastPingOk;

  /// API key stored in encrypted secure storage.
  String? _apiKey;
  static const _secureStorage = FlutterSecureStorage();

  /// Injectable HTTP client for testability.
  http.Client _client = http.Client();
  set httpClient(http.Client c) => _client = c;

  /// Load saved server URL and API key from storage on first use.
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    final savedHost = prefs.getString('ishara_host');
    final savedPort = prefs.getInt('ishara_port');
    if (savedHost != null) {
      _baseUrl = 'http://$savedHost:${savedPort ?? 8000}';
    }
    final savedEmergency = prefs.getString('ishara_emergency_number');
    if (savedEmergency != null && savedEmergency.isNotEmpty) {
      _emergencyNumber = savedEmergency;
    }
    try {
      _apiKey = await _secureStorage.read(key: 'ishara_api_key');
    } catch (_) {
      // Secure storage unavailable (e.g. in tests without platform channels).
    }
  }

  /// Save API key to encrypted secure storage.
  Future<void> setApiKey(String? key) async {
    _apiKey = key;
    try {
      if (key == null || key.isEmpty) {
        await _secureStorage.delete(key: 'ishara_api_key');
      } else {
        await _secureStorage.write(key: 'ishara_api_key', value: key);
      }
    } catch (_) {
      // Secure storage unavailable (e.g. in tests without platform channels).
    }
  }

  /// Load API key from encrypted secure storage.
  /// Returns null if no key is stored or secure storage is unavailable.
  Future<String?> loadApiKey() async {
    try {
      return await _secureStorage.read(key: 'ishara_api_key');
    } catch (_) {
      return null;
    }
  }

  /// Get auth headers if API key is set.
  Map<String, String> get _authHeaders =>
      _apiKey != null && _apiKey!.isNotEmpty ? {'X-API-Key': _apiKey!} : {};

  Future<void> updateBaseUrl(String host, {int port = 8000}) async {
    _baseUrl = 'http://$host:$port';
    if (!host.contains('localhost') && !host.contains('127.0.0.1')) {
      dev.log(
        'WARNING: Using plain HTTP on a non-local network is insecure. '
        'Configure HTTPS in production.',
        name: 'ApiService',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ishara_host', host);
    await prefs.setInt('ishara_port', port);
  }

  String get baseUrl => _baseUrl;

  /// Returns true when the configured URL uses plain HTTP on a non-local host.
  /// Used to show a security warning banner in the settings screen.
  bool get isInsecureHttp {
    if (_baseUrl.startsWith('https://')) return false;
    final host = Uri.tryParse(_baseUrl)?.host ?? '';
    return !host.contains('localhost') && !host.contains('127.0.0.1');
  }

  /// Regional emergency number (user-configurable, defaults to 112 international standard).
  String get emergencyNumber {
    // Read synchronously from SharedPreferences cache — set during _ensureInitialized.
    return _emergencyNumber;
  }

  String _emergencyNumber = '112';

  Future<void> setEmergencyNumber(String number) async {
    _emergencyNumber = number;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ishara_emergency_number', number);
  }

  /// Retry a function with exponential backoff.
  /// Retries up to [maxRetries] times on transient failures (timeouts, network errors).
  Future<T> _retry<T>(Future<T> Function() fn, {int maxRetries = 2}) async {
    Object? lastError;
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await fn();
      } on TimeoutException catch (e) {
        lastError = e;
        dev.log('Attempt ${attempt + 1} timed out', name: 'ApiService');
        if (attempt == maxRetries) break;
      } on http.ClientException catch (e) {
        lastError = e;
        dev.log('Attempt ${attempt + 1} network error: $e', name: 'ApiService');
        if (attempt == maxRetries) break;
      }
      // Exponential backoff: 500ms, 1s
      await Future<void>.delayed(Duration(milliseconds: 500 * (attempt + 1)));
    }
    throw RetryExhaustedException(lastError ?? StateError('Retry exhausted'));
  }

  /// Send a camera frame for sign language interpretation.
  /// Returns a map with 'sign' (String) and 'confidence' (double 0–1).
  Future<Map<String, dynamic>> interpretSign(Uint8List imageBytes) async {
    await _ensureInitialized();
    return _retry(() async {
      final uri = Uri.parse('$_baseUrl/interpret-sign');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_authHeaders)
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'frame.jpg',
          ),
        );

      final response = await _client
          .send(request)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        return {
          'sign': (json['sign'] as String?) ?? '',
          'confidence': (json['confidence'] as num?)?.toDouble() ?? 0.0,
        };
      }
      throw ApiResponseException(
        'Sign interpretation failed',
        statusCode: response.statusCode,
      );
    });
  }

  /// Send user feedback on a sign interpretation to improve the model.
  Future<bool> sendFeedback({
    required String interpretedSign,
    required String correctSign,
    String context = '',
  }) async {
    await _ensureInitialized();
    final uri = Uri.parse('$_baseUrl/feedback');
    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json', ..._authHeaders},
            body: jsonEncode({
              'interpreted_sign': interpretedSign,
              'correct_sign': correctSign,
              'context': context,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      dev.log('sendFeedback error: $e', name: 'ApiService');
      return false;
    }
  }

  /// Send audio for speech-to-text
  Future<String> speechToText(Uint8List audioBytes) async {
    await _ensureInitialized();
    final uri = Uri.parse('$_baseUrl/speech-to-text');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_authHeaders)
      ..files.add(
        http.MultipartFile.fromBytes(
          'audio',
          audioBytes,
          filename: 'audio.wav',
        ),
      );

    final response = await _client
        .send(request)
        .timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['text'] ?? '';
    }
    throw ApiResponseException(
      'Speech-to-text failed',
      statusCode: response.statusCode,
    );
  }

  /// Classify a sound description for sound awareness
  Future<Map<String, dynamic>> classifySound(String description) async {
    await _ensureInitialized();
    return _retry(() async {
      final uri = Uri.parse('$_baseUrl/classify-sound');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json', ..._authHeaders},
            body: jsonEncode({'description': description}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw ApiResponseException(
        'Sound classification failed',
        statusCode: response.statusCode,
      );
    });
  }

  /// Send a camera frame for world reading (documents, labels, etc.)
  Future<String> readWorld(Uint8List imageBytes, {String? question}) async {
    await _ensureInitialized();
    return _retry(() async {
      final uri = Uri.parse('$_baseUrl/read-world');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_authHeaders)
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'frame.jpg',
          ),
        );
      if (question != null) {
        request.fields['question'] = question;
      }

      final response = await _client
          .send(request)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);
        return json['description'] ?? '';
      }
      throw ApiResponseException(
        'World reading failed',
        statusCode: response.statusCode,
      );
    });
  }

  /// Generate emergency message with location
  Future<Map<String, dynamic>> emergencyMessage({
    required double latitude,
    required double longitude,
    required String emergencyType,
  }) async {
    await _ensureInitialized();
    return _retry(() async {
      final uri = Uri.parse('$_baseUrl/emergency-message');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json', ..._authHeaders},
            body: jsonEncode({
              'latitude': latitude,
              'longitude': longitude,
              'emergency_type': emergencyType,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw ApiResponseException(
        'Emergency message generation failed',
        statusCode: response.statusCode,
      );
    });
  }

  /// Evaluate a sign attempt for the Learn mode
  Future<Map<String, dynamic>> evaluateSign(
    Uint8List imageBytes,
    String targetSign,
  ) async {
    await _ensureInitialized();
    return _retry(() async {
      final uri = Uri.parse('$_baseUrl/evaluate-sign');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_authHeaders)
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'frame.jpg',
          ),
        )
        ..fields['target_sign'] = targetSign;

      final response = await _client
          .send(request)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        return jsonDecode(body);
      }
      throw ApiResponseException(
        'Sign evaluation failed',
        statusCode: response.statusCode,
      );
    });
  }

  /// Health check
  Future<bool> ping() async {
    await _ensureInitialized();
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/ping'), headers: _authHeaders)
          .timeout(const Duration(seconds: 3));
      _lastPingOk = response.statusCode == 200;
      return _lastPingOk;
    } catch (_) {
      _lastPingOk = false;
      return false;
    }
  }

  /// Chat with LLM (Gemma 4 via Ollama backend)
  Future<String> chatLLM(
    String message, {
    List<Map<String, String>>? history,
  }) async {
    await _ensureInitialized();
    return _retry(() async {
      final uri = Uri.parse('$_baseUrl/chat');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json', ..._authHeaders},
            body: jsonEncode({
              'message': message,
              if (history != null) ...{'history': history},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['reply'] ?? json['response'] ?? json['text'] ?? '';
      }
      throw ApiResponseException(
        'LLM chat failed',
        statusCode: response.statusCode,
      );
    });
  }

  /// Emergency operator chat — sends a message to the /emergency-chat endpoint
  /// with optional history for multi-turn threading.
  Future<String> emergencyChat(
    String message, {
    String context = '',
    List<Map<String, String>>? history,
  }) async {
    await _ensureInitialized();
    return _retry(() async {
      final uri = Uri.parse('$_baseUrl/emergency-chat');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json', ..._authHeaders},
            body: jsonEncode({
              'message': message,
              'context': context,
              if (history != null) ...{'history': history},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['reply'] as String? ?? '';
      }
      throw ApiResponseException(
        'Emergency chat failed',
        statusCode: response.statusCode,
      );
    });
  }
}
