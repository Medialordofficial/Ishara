import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  String _baseUrl;

  ApiService({String? baseUrl})
    : _baseUrl = baseUrl ?? 'http://192.168.1.100:8000';

  void updateBaseUrl(String host, {int port = 8000}) {
    _baseUrl = 'http://$host:$port';
  }

  String get baseUrl => _baseUrl;

  /// Send a camera frame for sign language interpretation
  Future<String> interpretSign(Uint8List imageBytes) async {
    final uri = Uri.parse('$_baseUrl/interpret-sign');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'frame.jpg',
        ),
      );

    final response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['sign'] ?? '';
    }
    throw Exception('Sign interpretation failed: ${response.statusCode}');
  }

  /// Send audio for speech-to-text
  Future<String> speechToText(Uint8List audioBytes) async {
    final uri = Uri.parse('$_baseUrl/speech-to-text');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'audio',
          audioBytes,
          filename: 'audio.wav',
        ),
      );

    final response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['text'] ?? '';
    }
    throw Exception('Speech-to-text failed: ${response.statusCode}');
  }

  /// Classify a sound description for sound awareness
  Future<Map<String, dynamic>> classifySound(String description) async {
    final uri = Uri.parse('$_baseUrl/classify-sound');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'description': description}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Sound classification failed: ${response.statusCode}');
  }

  /// Send a camera frame for world reading (documents, labels, etc.)
  Future<String> readWorld(Uint8List imageBytes, {String? question}) async {
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

    final response = await request.send();
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
    final uri = Uri.parse('$_baseUrl/emergency-message');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'emergency_type': emergencyType,
      }),
    );

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

    final response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      return jsonDecode(body);
    }
    throw Exception('Sign evaluation failed: ${response.statusCode}');
  }

  /// Health check
  Future<bool> ping() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/ping'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
