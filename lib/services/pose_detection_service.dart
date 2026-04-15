import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// On-device ML service for detecting signing posture using Google ML Kit.
/// Runs entirely on the phone — no backend needed.
class PoseDetectionService {
  static final PoseDetectionService _instance =
      PoseDetectionService._internal();
  factory PoseDetectionService() => _instance;
  PoseDetectionService._internal();

  PoseDetector? _detector;
  bool _closed = false;

  PoseDetector get _poseDetector {
    if (_detector == null || _closed) {
      _detector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.single,
          model: PoseDetectionModel.base,
        ),
      );
      _closed = false;
    }
    return _detector!;
  }

  /// Analyze an image and determine if the person is in a signing posture.
  /// Returns [SigningAnalysis] with landmark data and confidence.
  Future<SigningAnalysis> analyzeFrame(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isEmpty) {
        return SigningAnalysis(
          isSigning: false,
          confidence: 0.0,
          landmarks: [],
          status: 'No person detected',
        );
      }

      final pose = poses.first;
      return _evaluateSigningPosture(pose);
    } catch (e) {
      return SigningAnalysis(
        isSigning: false,
        confidence: 0.0,
        landmarks: [],
        status: 'Detection error',
      );
    }
  }

  SigningAnalysis _evaluateSigningPosture(Pose pose) {
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final nose = pose.landmarks[PoseLandmarkType.nose];

    final landmarks = _extractLandmarks(pose);

    // Need at least shoulders and wrists for analysis
    if (leftShoulder == null || rightShoulder == null) {
      return SigningAnalysis(
        isSigning: false,
        confidence: 0.1,
        landmarks: landmarks,
        status: 'Upper body not visible',
      );
    }

    // Calculate signing indicators
    double score = 0.0;

    // Check 1: At least one hand at or above shoulder level
    bool leftHandUp = false;
    bool rightHandUp = false;
    if (leftWrist != null) {
      leftHandUp = leftWrist.y <= leftShoulder.y + 80;
      if (leftHandUp) score += 0.3;
    }
    if (rightWrist != null) {
      rightHandUp = rightWrist.y <= rightShoulder.y + 80;
      if (rightHandUp) score += 0.3;
    }

    // Check 2: Hands are within frame (not at edges)
    if (leftWrist != null && leftWrist.x > 50 && leftWrist.x < 600) {
      score += 0.1;
    }
    if (rightWrist != null && rightWrist.x > 50 && rightWrist.x < 600) {
      score += 0.1;
    }

    // Check 3: Arms are bent (elbows between shoulders and wrists)
    if (leftElbow != null && leftWrist != null) {
      final elbowBent =
          leftElbow.y < leftShoulder.y && leftElbow.y > leftWrist.y - 100;
      if (elbowBent) score += 0.1;
    }
    if (rightElbow != null && rightWrist != null) {
      final elbowBent =
          rightElbow.y < rightShoulder.y && rightElbow.y > rightWrist.y - 100;
      if (elbowBent) score += 0.1;
    }

    // Check 4: Hands near face region (many signs are near the face)
    if (nose != null) {
      if (leftWrist != null) {
        final distToFace = _distance(leftWrist, nose);
        if (distToFace < 200) score += 0.15;
      }
      if (rightWrist != null) {
        final distToFace = _distance(rightWrist, nose);
        if (distToFace < 200) score += 0.15;
      }
    }

    final confidence = score.clamp(0.0, 1.0);
    final isSigning = (leftHandUp || rightHandUp) && confidence > 0.3;

    String status;
    if (isSigning && confidence > 0.6) {
      status = 'Clear signing detected';
    } else if (isSigning) {
      status = 'Possible signing detected';
    } else if (leftHandUp || rightHandUp) {
      status = 'Hands raised — adjusting...';
    } else {
      status = 'Waiting for signing posture';
    }

    return SigningAnalysis(
      isSigning: isSigning,
      confidence: confidence,
      landmarks: landmarks,
      leftHandRaised: leftHandUp,
      rightHandRaised: rightHandUp,
      status: status,
    );
  }

  double _distance(PoseLandmark a, PoseLandmark b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }

  List<LandmarkPoint> _extractLandmarks(Pose pose) {
    return pose.landmarks.entries.map((e) {
      return LandmarkPoint(
        type: e.key.name,
        x: e.value.x,
        y: e.value.y,
        confidence: e.value.likelihood,
      );
    }).toList();
  }

  void dispose() {
    _detector?.close();
    _closed = true;
  }
}

class SigningAnalysis {
  final bool isSigning;
  final double confidence;
  final List<LandmarkPoint> landmarks;
  final bool leftHandRaised;
  final bool rightHandRaised;
  final String status;

  SigningAnalysis({
    required this.isSigning,
    required this.confidence,
    required this.landmarks,
    this.leftHandRaised = false,
    this.rightHandRaised = false,
    this.status = '',
  });
}

class LandmarkPoint {
  final String type;
  final double x;
  final double y;
  final double confidence;

  LandmarkPoint({
    required this.type,
    required this.x,
    required this.y,
    required this.confidence,
  });
}
