import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService({String? baseUrl}) {
    if (baseUrl != null) _instance._baseUrl = baseUrl;
    return _instance;
  }
  ApiService._internal();

  String _baseUrl = 'http://192.168.1.100:8000';
  bool _initialized = false;

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

  /// Send a camera frame for sign language interpretation
  Future<String> interpretSign(Uint8List imageBytes) async {
    await _ensureInitialized();
    final uri = Uri.parse('$_baseUrl/interpret-sign');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'frame.jpg',
        ),
      );

    final response = await request.send().timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['sign'] ?? '';
    }
    throw Exception('Sign interpretation failed: ${response.statusCode}');
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

    final response = await request.send().timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['text'] ?? '';
    }
    throw Exception('Speech-to-text failed: ${response.statusCode}');
  }

  /// Classify a sound description for sound awareness
  Future<Map<String, dynamic>> classifySound(String description) async {
    await _ensureInitialized();
    final uri = Uri.parse('$_baseUrl/classify-sound');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'description': description}),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Sound classification failed: ${response.statusCode}');
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

    final response = await request.send().timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['description'] ?? '';
    }
    throw Exception('World reading failed: ${response.statusCode}');
  }

  /// Generate emergency message with location
  Future<Map<String, dynamic>> emergencyMessage({
    required double latitude,
    required double longitude,
    required String emergencyType,
  }) async {
    await _ensureInitialized();
    final uri = Uri.parse('$_baseUrl/emergency-message');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'emergency_type': emergencyType,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(
      'Emergency message generation failed: ${response.statusCode}',
    );
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

    final response = await request.send().timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      return jsonDecode(body);
    }
    throw Exception('Sign evaluation failed: ${response.statusCode}');
  }

  /// Health check
  Future<bool> ping() async {
    await _ensureInitialized();
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/ping'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Chat with LLM (Gemma 4 via Ollama backend)
  Future<String> chatLLM(
    String message, {
    List<Map<String, String>>? history,
  }) async {
    await _ensureInitialized();
    final uri = Uri.parse('$_baseUrl/chat');
    final response = await http
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
    throw Exception('LLM chat failed: ${response.statusCode}');
  }
}
