import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('Learn Signs')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _LearningHero(
            category: _currentCategory,
            progress: '${_currentSignIndex + 1} / ${_signs.length}',
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(sign['emoji']!, style: const TextStyle(fontSize: 34)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sign['name']!,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: AppColors.warning),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Practice prompt',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  sign['description']!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: (_currentSignIndex + 1) / _signs.length,
                  backgroundColor: AppColors.surfaceLight,
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(999),
                  minHeight: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isCameraReady
                ? Stack(
                    children: [
                      CameraPreview(_cameraController!),
                      Center(
                        child: Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.8),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(color: AppColors.warning),
                  ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coach feedback',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                if (_feedback.isEmpty)
                  const _LearnEmptyState()
                else
                  Text(_feedback, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _prevSign,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _isPracticing ? null : _checkSign,
                  icon: _isPracticing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.verified_rounded),
                  label: Text(_isPracticing ? 'Checking...' : 'Check my sign'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: AppColors.secondary,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _nextSign,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LearningHero extends StatelessWidget {
  final String category;
  final String progress;

  const _LearningHero({required this.category, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5DD), Color(0xFFFFE8BA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(progress, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Practice with a clearer learning loop.',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 8),
          Text(
            'See the prompt, perform the sign in frame, and let Ishara review your attempt with feedback.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryLight),
          ),
        ],
      ),
    );
  }
}

class _LearnEmptyState extends StatelessWidget {
  const _LearnEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.school_outlined,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Feedback will appear here',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Perform the sign in frame and tap “Check my sign” to get feedback from the backend.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
