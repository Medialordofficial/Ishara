import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../data/sign_dictionary.dart';
import '../services/api_service.dart';
import '../services/progress_service.dart';
import '../utils/constants.dart';

class LearnSignsScreen extends StatefulWidget {
  const LearnSignsScreen({super.key});

  @override
  State<LearnSignsScreen> createState() => _LearnSignsScreenState();
}

class _LearnSignsScreenState extends State<LearnSignsScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  final ApiService _api = ApiService();
  bool _isCameraReady = false;
  bool _isPracticing = false;
  int _currentSignIndex = 0;
  String _feedback = '';
  String _selectedCategory = 'Greetings & Basics';
  late AnimationController _bounceController;

  // Gamification
  final ProgressService _progressService = ProgressService();
  UserProgress _progress = UserProgress(
    signsPracticed: 0,
    currentStreak: 0,
    totalScore: 0,
    level: 1,
  );

  List<SignEntry> get _currentSigns {
    try {
      return SignDictionary.categories
          .firstWhere((c) => c.name == _selectedCategory)
          .signs;
    } catch (_) {
      return SignDictionary.categories.first.signs;
    }
  }

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _initCamera();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final p = await _progressService.getProgress();
    if (mounted) setState(() => _progress = p);
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
    if (mounted) setState(() => _isCameraReady = true);
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
      final sign = _currentSigns[_currentSignIndex];

      final result = await _api.evaluateSign(bytes, sign.word);

      // Record practice for gamification
      final updated = await _progressService.recordPractice(scoreGained: 15);

      setState(() {
        _feedback = result['feedback'] ?? 'Great attempt! Keep practicing.';
        _isPracticing = false;
        _progress = updated;
      });
      _bounceController.forward().then((_) => _bounceController.reverse());
    } catch (e) {
      setState(() {
        _feedback = 'Connect to the Ishara server to get AI feedback.';
        _isPracticing = false;
      });
    }
  }

  void _nextSign() {
    setState(() {
      _currentSignIndex = (_currentSignIndex + 1) % _currentSigns.length;
      _feedback = '';
    });
  }

  void _prevSign() {
    setState(() {
      _currentSignIndex =
          (_currentSignIndex - 1 + _currentSigns.length) % _currentSigns.length;
      _feedback = '';
    });
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signs = _currentSigns;
    final sign = signs[_currentSignIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.premiumShadows,
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Learn Signs',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentSignIndex + 1}/${signs.length}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Category selector
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: SignDictionary.categories.length,
                itemBuilder: (context, index) {
                  final cat = SignDictionary.categories[index];
                  final selected = _selectedCategory == cat.name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedCategory = cat.name;
                        _currentSignIndex = 0;
                        _feedback = '';
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: selected ? null : AppColors.premiumShadows,
                        ),
                        child: Text(
                          '${cat.icon} ${cat.name}',
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Main content - scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Gamification progress header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                  '🔥', '${_progress.currentStreak}', 'Streak'),
                              _buildStatItem(
                                  '⭐', 'Lv ${_progress.level}', _progress.levelName),
                              _buildStatItem(
                                  '📊', '${_progress.signsPracticed}', 'Practiced'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _progress.levelProgress,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              color: Colors.white,
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_progress.totalScore} / ${_progress.nextLevelScore} XP to ${_progress.level < 10 ? "next level" : "max!"}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppColors.premiumShadows,
                      ),
                      child: Column(
                        children: [
                          Text(sign.emoji,
                              style: const TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          Text(
                            sign.word,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sign.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // Steps
                          ...sign.steps.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (_currentSignIndex + 1) / signs.length,
                              backgroundColor: AppColors.background,
                              color: AppColors.primary,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Camera preview
                    Container(
                      height: 240,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppColors.premiumShadows,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _isCameraReady
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                CameraPreview(_cameraController!),
                                Center(
                                  child: Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.6),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Feedback
                    if (_feedback.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.premiumShadows,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.smart_toy,
                                    color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'AI Coach',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _feedback,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Bottom controls - thumb accessible
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: _prevSign,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.premiumShadows,
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.primary, size: 28),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isPracticing ? null : _checkSign,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _isPracticing
                            ? AppColors.textSecondary
                            : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _isPracticing
                          ? const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.verified_rounded,
                              color: Colors.white, size: 34),
                    ),
                  ),
                  GestureDetector(
                    onTap: _nextSign,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.premiumShadows,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.primary, size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
