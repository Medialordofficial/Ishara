import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFD4A843); // Golden from logo
  static const Color primaryDark = Color(0xFFB8922E);
  static const Color secondary = Color(0xFF1A2744); // Dark navy from logo
  static const Color secondaryLight = Color(0xFF2D3F5E);
  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF1B2838);
  static const Color surfaceLight = Color(0xFF243447);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
}

class AppStrings {
  static const String appName = 'Ishara';
  static const String tagline = 'Every gesture, understood.';
  static const String fullTagline =
      'Every gesture, understood. Every sound, felt. Every barrier, broken.';

  // Mode names
  static const String conversationMode = 'Conversation';
  static const String soundAwarenessMode = 'Sound Awareness';
  static const String emergencyMode = 'Emergency SOS';
  static const String worldReaderMode = 'World Reader';
  static const String learnSignsMode = 'Learn Signs';
}

class ApiConfig {
  static const String defaultHost = '192.168.1.100';
  static const int defaultPort = 8000;
  static String get baseUrl => 'http://$defaultHost:$defaultPort';
}
