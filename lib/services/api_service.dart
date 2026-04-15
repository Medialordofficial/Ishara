import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';

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

  /// Injectable HTTP client for testability.
  http.Client _client = http.Client();
  set httpClient(http.Client c) => _client = c;

  /// Load saved server URL from SharedPreferences on first use.
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    final savedHost = prefs.getString('ishara_host');
    final savedPort = prefs.getInt('ishara_port');
    if (savedHost != null) {
      _baseUrl = 'http://$savedHost:${savedPort ?? 8000}';
    }
  }

  Future<void> updateBaseUrl(String host, {int port = 8000}) async {
    _baseUrl = 'http://$host:$port';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ishara_host', host);
    await prefs.setInt('ishara_port', port);
  }

  String get baseUrl => _baseUrl;

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

  /// Send a camera frame for sign language interpretation
  Future<String> interpretSign(Uint8List imageBytes) async {
    await _ensureInitialized();
    return _retry(() async {
      final uri = Uri.parse('$_baseUrl/interpret-sign');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'frame.jpg',
          ),
        );

      final response = await _client.send(request).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);
        return json['sign'] ?? '';
      }
      throw ApiResponseException('Sign interpretation failed', statusCode: response.statusCode);
    });
  }

  /// Send audio for speech-to-text
  Future<String> speechToText(Uint8List audioBytes) async {
    await _ensureInitialized();
    final uri = Uri.parse('$_baseUrl/speech-to-text');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'audio',
          audioBytes,
          filename: 'audio.wav',
        ),
      );

    final response = await _client.send(request).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['text'] ?? '';
    }
    throw ApiResponseException('Speech-to-text failed', statusCode: response.statusCode);
  }

  /// Classify a sound description for sound awareness
  Future<Map<String, dynamic>> classifySound(String description) async {
    await _ensureInitialized();
    return _retry(() async {
      final uri = Uri.parse('$_baseUrl/classify-sound');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'description': description}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw ApiResponseException('Sound classification failed', statusCode: response.statusCode);
    });
  }

  /// Send a camera frame for world reading (documents, labels, etc.)
  Future<String> readWorld(Uint8List imageBytes, {String? question}) async {
    await _ensureInitialized();
    final uri = Uri.parse('$_baseUrl/read-world');
    final request = http.MultipartRequest('POST', uri)
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

    final response = await _client.send(request).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['description'] ?? '';
    }
    throw ApiResponseException('World reading failed', statusCode: response.statusCode);
  }

  /// Generate emergency message with location
  Future<Map<String, dynamic>> emergencyMessage({
    required double latitude,
    required double longitude,
    required String emergencyType,
  }) async {
    await _ensureInitialized();
    final uri = Uri.parse('$_baseUrl/emergency-message');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
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
    throw ApiResponseException('Emergency message generation failed', statusCode: response.statusCode);
  }

  /// Evaluate a sign attempt for the Learn mode
  Future<Map<String, dynamic>> evaluateSign(
    Uint8List imageBytes,
    String targetSign,
  ) async {
    await _ensureInitialized();
    final uri = Uri.parse('$_baseUrl/evaluate-sign');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'frame.jpg',
        ),
      )
      ..fields['target_sign'] = targetSign;

    final response = await _client.send(request).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      return jsonDecode(body);
    }
    throw ApiResponseException('Sign evaluation failed', statusCode: response.statusCode);
  }

  /// Health check
  Future<bool> ping() async {
    await _ensureInitialized();
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/ping'))
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
            headers: {'Content-Type': 'application/json'},
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
      throw ApiResponseException('LLM chat failed', statusCode: response.statusCode);
    });
  }
}
