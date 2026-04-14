import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0A66C2); // Premium Blue
  static const Color primaryDark = Color(0xFF004182);
  static const Color secondary = Color(0xFFE8F0FE); // Soft Blue background
  static const Color secondaryLight = Color(0xFFF3F7FF);
  static const Color background = Color(
    0xFFF7F9FF,
  ); // Clean premium white-blue tint
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8FAFF);
  static const Color border = Color(0xFFE5E9F2);
  static const Color textPrimary = Color(0xFF1E2638);
  static const Color textSecondary = Color(0xFF7B849C);

  // Adjusted status colors for a more premium look
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC05);
  static const Color danger = Color(0xFFEA4335);
  static const Color info = Color(0xFF4285F4);

  // Soft Shadows for Neumorphic/Premium Feel
  static List<BoxShadow> get premiumShadows => [
    BoxShadow(
      color: const Color(0xFF8C9AB5).withValues(alpha: 0.15),
      blurRadius: 24,
      offset: const Offset(0, 10),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: const Color(0xFFFFFFFF).withValues(alpha: 0.8),
      blurRadius: 16,
      offset: const Offset(-8, -8),
      spreadRadius: 2,
    ),
  ];
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
