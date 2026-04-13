import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class LearnSignsScreen extends StatefulWidget {
  const LearnSignsScreen({super.key});

  @override
  State<LearnSignsScreen> createState() => _LearnSignsScreenState();
}

class _LearnSignsScreenState extends State<LearnSignsScreen> {
  CameraController? _cameraController;
  final ApiService _api = ApiService();
  bool _isCameraReady = false;
  bool _isPracticing = false;
  int _currentSignIndex = 0;
  String _feedback = '';

  final List<Map<String, String>> _signs = [
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

  String get _currentCategory {
    if (_currentSignIndex < 6) return 'Basic Communication';
    return 'Medical & Emergency';
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (mounted) {
      setState(() => _isCameraReady = true);
    }
  }

  Future<void> _checkSign() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isPracticing = true;
      _feedback = '';
    });

    try {
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();

      final result = await _api.evaluateSign(
        bytes,
        _signs[_currentSignIndex]['name']!,
      );

      setState(() {
        _feedback = result['feedback'] ?? 'Great attempt! Keep practicing.';
        _isPracticing = false;
      });
    } catch (e) {
      setState(() {
        _feedback =
            'Connect to the Ishara server to get feedback on your signs.';
        _isPracticing = false;
      });
    }
  }

  void _nextSign() {
    setState(() {
      _currentSignIndex = (_currentSignIndex + 1) % _signs.length;
      _feedback = '';
    });
  }

  void _prevSign() {
    setState(() {
      _currentSignIndex =
          (_currentSignIndex - 1 + _signs.length) % _signs.length;
      _feedback = '';
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sign = _signs[_currentSignIndex];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text('Learn Signs'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  _currentCategory,
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_currentSignIndex + 1} / ${_signs.length}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          LinearProgressIndicator(
            value: (_currentSignIndex + 1) / _signs.length,
            backgroundColor: AppColors.surfaceLight,
            color: AppColors.warning,
          ),

          // Sign to learn
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(sign['emoji']!, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  'Sign: "${sign['name']}"',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  sign['description']!,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Camera preview
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              clipBehavior: Clip.antiAlias,
              child: _isCameraReady
                  ? CameraPreview(_cameraController!)
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.warning,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),

          // Feedback
          if (_feedback.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _feedback,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _prevSign,
                  icon: const Icon(Icons.arrow_back_ios),
                  color: AppColors.textSecondary,
                  iconSize: 28,
                ),
                // Check button
                GestureDetector(
                  onTap: _isPracticing ? null : _checkSign,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _isPracticing
                          ? AppColors.surfaceLight
                          : AppColors.warning,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _isPracticing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.warning,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Check My Sign',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                IconButton(
                  onPressed: _nextSign,
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: AppColors.textSecondary,
                  iconSize: 28,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
