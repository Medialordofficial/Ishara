import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ishara/utils/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTheme.lightTheme', () {
    testWidgets('uses Material 3', (tester) async {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
    });

    testWidgets('has light brightness', (tester) async {
      expect(AppTheme.lightTheme.brightness, Brightness.light);
    });

    testWidgets('primary color matches AppColors.primary', (tester) async {
      expect(AppTheme.lightTheme.colorScheme.primary, const Color(0xFF0A66C2));
    });
  });

  group('AppTheme.darkTheme', () {
    testWidgets('uses Material 3', (tester) async {
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });

    testWidgets('has dark brightness', (tester) async {
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });

    testWidgets('scaffold background is dark', (tester) async {
      expect(
        AppTheme.darkTheme.scaffoldBackgroundColor,
        const Color(0xFF121620),
      );
    });

    testWidgets('surface color is dark', (tester) async {
      expect(
        AppTheme.darkTheme.colorScheme.surface,
        const Color(0xFF1A1F2E),
      );
    });

    testWidgets('onSurface is light for readability', (tester) async {
      expect(
        AppTheme.darkTheme.colorScheme.onSurface,
        const Color(0xFFE8EAF0),
      );
    });

    testWidgets('dark theme differs from light theme', (tester) async {
      expect(
        AppTheme.darkTheme.scaffoldBackgroundColor,
        isNot(equals(AppTheme.lightTheme.scaffoldBackgroundColor)),
      );
      expect(
        AppTheme.darkTheme.brightness,
        isNot(equals(AppTheme.lightTheme.brightness)),
      );
    });
  });
}
