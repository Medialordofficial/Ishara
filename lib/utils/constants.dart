import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFD4A843); // Golden from logo
  static const Color primaryDark = Color(0xFFB8922E);
  static const Color secondary = Color(0xFF172033); // Deep navy from logo
  static const Color secondaryLight = Color(0xFF31415F);
  static const Color background = Color(0xFFF8F5EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1EBE1);
  static const Color border = Color(0xFFE4DDD0);
  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF6F7A8F);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFE53935);
  static const Color info = Color(0xFF2F6FED);
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
