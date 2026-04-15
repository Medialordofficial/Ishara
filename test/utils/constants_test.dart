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

  group('PoseThresholds', () {
    test('signingConfidence is between 0 and 1', () {
      expect(PoseThresholds.signingConfidence, greaterThan(0));
      expect(PoseThresholds.signingConfidence, lessThanOrEqualTo(1));
    });

    test('handFrameMin is less than handFrameMax', () {
      expect(
        PoseThresholds.handFrameMin,
        lessThan(PoseThresholds.handFrameMax),
      );
    });

    test('score weights sum to a meaningful total', () {
      // With all checks triggered twice (left+right), max possible ≈ 2*(0.3+0.1+0.1+0.15) = 1.3
      final maxScore =
          2 *
          (PoseThresholds.weightHandRaised +
              PoseThresholds.weightHandVisible +
              PoseThresholds.weightElbowBent +
              PoseThresholds.weightNearFace);
      expect(maxScore, greaterThan(PoseThresholds.signingConfidence));
    });

    test('all values are positive', () {
      expect(PoseThresholds.handRaiseTolerance, greaterThan(0));
      expect(PoseThresholds.handFaceDistance, greaterThan(0));
      expect(PoseThresholds.weightHandRaised, greaterThan(0));
      expect(PoseThresholds.weightHandVisible, greaterThan(0));
      expect(PoseThresholds.weightElbowBent, greaterThan(0));
      expect(PoseThresholds.weightNearFace, greaterThan(0));
    });
  });

  group('SoundThresholds', () {
    test('warning is less than critical', () {
      expect(SoundThresholds.warning, lessThan(SoundThresholds.critical));
    });

    test('critical is less than maxDecibel', () {
      expect(SoundThresholds.critical, lessThan(SoundThresholds.maxDecibel));
    });

    test('all values are positive', () {
      expect(SoundThresholds.warning, greaterThan(0));
      expect(SoundThresholds.critical, greaterThan(0));
      expect(SoundThresholds.maxDecibel, greaterThan(0));
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
