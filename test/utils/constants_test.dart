import 'package:flutter_test/flutter_test.dart';
import 'package:ishara/utils/constants.dart';

void main() {
  group('AppColors', () {
    test('primary is premium blue', () {
      expect(AppColors.primary.value, 0xFF0A66C2);
    });

    test('premiumShadows returns two shadows', () {
      final shadows = AppColors.premiumShadows;
      expect(shadows.length, 2);
    });

    test('status colors are all non-transparent', () {
      expect(AppColors.success.a, 1.0);
      expect(AppColors.warning.a, 1.0);
      expect(AppColors.danger.a, 1.0);
    });
  });

  group('AppStrings', () {
    test('appName is Ishara', () {
      expect(AppStrings.appName, 'Ishara');
    });

    test('all mode names are non-empty', () {
      expect(AppStrings.conversationMode.isNotEmpty, isTrue);
      expect(AppStrings.soundAwarenessMode.isNotEmpty, isTrue);
      expect(AppStrings.emergencyMode.isNotEmpty, isTrue);
      expect(AppStrings.worldReaderMode.isNotEmpty, isTrue);
      expect(AppStrings.learnSignsMode.isNotEmpty, isTrue);
    });
  });

  group('ApiConfig', () {
    test('default port is 8000', () {
      expect(ApiConfig.defaultPort, 8000);
    });

    test('baseUrl uses http scheme', () {
      expect(ApiConfig.baseUrl, startsWith('http://'));
    });

    test('baseUrl includes default host and port', () {
      expect(
        ApiConfig.baseUrl,
        'http://${ApiConfig.defaultHost}:${ApiConfig.defaultPort}',
      );
    });
  });

  group('AppConstants dictionary', () {
    test('has at least 10 entries', () {
      expect(AppConstants.dictionary.length, greaterThanOrEqualTo(10));
    });

    test('every entry has name, description, emoji', () {
      for (final entry in AppConstants.dictionary) {
        expect(entry['name'], isNotEmpty);
        expect(entry['description'], isNotEmpty);
        expect(entry['emoji'], isNotEmpty);
      }
    });

    test('contains Hello and Emergency signs', () {
      final names = AppConstants.dictionary.map((e) => e['name']);
      expect(names, contains('Hello'));
      expect(names, contains('Emergency'));
    });
  });
}
