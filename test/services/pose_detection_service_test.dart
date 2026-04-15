import 'package:flutter_test/flutter_test.dart';
import 'package:ishara/services/pose_detection_service.dart';

void main() {
  group('SigningAnalysis', () {
    test('creates with required fields and defaults', () {
      final analysis = SigningAnalysis(
        isSigning: true,
        confidence: 0.85,
        landmarks: [],
      );
      expect(analysis.isSigning, isTrue);
      expect(analysis.confidence, 0.85);
      expect(analysis.landmarks, isEmpty);
      expect(analysis.leftHandRaised, isFalse);
      expect(analysis.rightHandRaised, isFalse);
      expect(analysis.status, '');
    });

    test('creates with all optional fields', () {
      final analysis = SigningAnalysis(
        isSigning: true,
        confidence: 0.9,
        landmarks: [
          LandmarkPoint(type: 'leftWrist', x: 100, y: 200, confidence: 0.95),
        ],
        leftHandRaised: true,
        rightHandRaised: false,
        status: 'Clear signing detected',
      );
      expect(analysis.leftHandRaised, isTrue);
      expect(analysis.rightHandRaised, isFalse);
      expect(analysis.status, 'Clear signing detected');
      expect(analysis.landmarks.length, 1);
    });

    test('confidence can be zero when not signing', () {
      final analysis = SigningAnalysis(
        isSigning: false,
        confidence: 0.0,
        landmarks: [],
        status: 'No person detected',
      );
      expect(analysis.confidence, 0.0);
      expect(analysis.isSigning, isFalse);
    });
  });

  group('LandmarkPoint', () {
    test('creates with required fields', () {
      final point = LandmarkPoint(
        type: 'nose',
        x: 320.0,
        y: 240.0,
        confidence: 0.99,
      );
      expect(point.type, 'nose');
      expect(point.x, 320.0);
      expect(point.y, 240.0);
      expect(point.confidence, 0.99);
    });

    test('supports low-confidence landmarks', () {
      final point = LandmarkPoint(
        type: 'leftPinky',
        x: 10.0,
        y: 500.0,
        confidence: 0.1,
      );
      expect(point.confidence, 0.1);
    });
  });

  group('PoseDetectionService singleton', () {
    test('factory returns same instance', () {
      final a = PoseDetectionService();
      final b = PoseDetectionService();
      expect(identical(a, b), isTrue);
    });
  });
}
