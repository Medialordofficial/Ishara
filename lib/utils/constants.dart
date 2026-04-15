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
  static const Color textSecondary = Color(
    0xFF555E75,
  ); // WCAG AA contrast on background (≥4.5:1)

  // Adjusted status colors for a more premium look
  static const Color success = Color(
    0xFF15803D,
  ); // Green-700: WCAG AA (≥4.55:1) on white/background
  static const Color warning = Color(
    0xFFB45309,
  ); // Amber-700: WCAG AA (≥4.5:1) on white/background
  static const Color danger = Color(
    0xFFB91C1C,
  ); // Red-700: WCAG AA (≥5.9:1) on white/background
  static const Color info = Color(
    0xFF1D4ED8,
  ); // Blue-700: WCAG AA (≥5.9:1) on white/background

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

/// Thresholds for on-device pose detection scoring.
class PoseThresholds {
  /// Min confidence to consider person is signing (0.0–1.0).
  static const double signingConfidence = 0.3;

  /// Min LLM model confidence to announce/speak an interpreted sign (0.0–1.0).
  static const double interpretConfidence = 0.5;

  /// Tolerance (px) added to shoulder-y when checking if hand is raised.
  static const double handRaiseTolerance = 80.0;

  /// X-axis range (px) for hand visibility check.
  static const double handFrameMin = 50.0;
  static const double handFrameMax = 600.0;

  /// Max distance (px) from nose for hand-near-face check.
  static const double handFaceDistance = 200.0;

  /// Score weights for each check.
  static const double weightHandRaised = 0.3;
  static const double weightHandVisible = 0.1;
  static const double weightElbowBent = 0.1;
  static const double weightNearFace = 0.15;
}

/// Sound awareness decibel thresholds.
class SoundThresholds {
  static const double warning = 75.0;
  static const double critical = 90.0;
  static const double maxDecibel = 130.0;
}

class AppConstants {
  static const List<Map<String, String>> dictionary = [
    {
      'name': 'Hello',
      'description': 'Wave your open hand side to side',
      'emoji': '👋',
    },
    {
      'name': 'Thank You',
      'description': 'Touch your chin with fingertips, then move hand forward',
      'emoji': '🙏',
    },
    {
      'name': 'Please',
      'description': 'Rub your chest in a circular motion with flat hand',
      'emoji': '🤲',
    },
    {
      'name': 'Yes',
      'description': 'Make a fist and nod it up and down like a head nodding',
      'emoji': '✅',
    },
    {
      'name': 'No',
      'description': 'Extend index and middle finger, snap them against thumb',
      'emoji': '❌',
    },
    {
      'name': 'Help',
      'description': 'Place fist on open palm and raise both hands together',
      'emoji': '🆘',
    },
    {
      'name': 'Water',
      'description':
          'Extend three middle fingers, tap index finger on chin twice',
      'emoji': '💧',
    },
    {
      'name': 'Food',
      'description': 'Bunch fingertips together and tap them to your mouth',
      'emoji': '🍽️',
    },
    {
      'name': 'Medicine',
      'description': 'Rock middle finger in the palm of your other hand',
      'emoji': '💊',
    },
    {
      'name': 'Pain',
      'description': 'Point both index fingers toward each other and twist',
      'emoji': '🤕',
    },
    {
      'name': 'Doctor',
      'description': 'Tap your wrist with fingertips (like taking a pulse)',
      'emoji': '👨‍⚕️',
    },
    {
      'name': 'Emergency',
      'description': 'Wave hand back and forth rapidly above your head',
      'emoji': '🚨',
    },
  ];
}
