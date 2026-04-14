import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/constants.dart';

class WorldReaderScreen extends StatefulWidget {
  const WorldReaderScreen({super.key});

  @override
  State<WorldReaderScreen> createState() => _WorldReaderScreenState();
}

class _WorldReaderScreenState extends State<WorldReaderScreen> {
  CameraController? _cameraController;
  final ApiService _api = ApiService();
  final TtsService _tts = TtsService();
  bool _isCameraReady = false;
  bool _isReading = false;
  String _readResult = '';
  final TextEditingController _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use back camera for reading
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (mounted) {
      setState(() => _isCameraReady = true);
    }
  }

  Future<void> _captureAndRead() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isReading = true;
      _readResult = '';
    });

    try {
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      final question = _questionController.text.trim();

      final result = await _api.readWorld(
        bytes,
        question: question.isNotEmpty ? question : null,
      );

      setState(() {
        _readResult = result;
        _isReading = false;
      });

      await _tts.speak(result);
    } catch (e) {
      setState(() {
        _readResult =
            'Unable to read. Make sure the backend server is running.';
        _isReading = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _tts.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('World Reader')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _WorldReaderHero(onCapture: _isReading ? null : _captureAndRead),
          const SizedBox(height: 18),
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: _isCameraReady
                ? Stack(
                    children: [
                      CameraPreview(_cameraController!),
                      if (_isReading)
                        Container(
                          color: Colors.black.withValues(alpha: 0.42),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 12),
                                Text(
                                  'Reading the scene...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.8),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(color: AppColors.success),
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
                  'Optional question',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ask what the object says, what the sign means, or what stands out in the scene.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    hintText: 'What am I looking at?',
                    prefixIcon: Icon(Icons.help_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isReading ? null : _captureAndRead,
                  icon: Icon(
                    _isReading
                        ? Icons.hourglass_top_rounded
                        : Icons.camera_alt_rounded,
                  ),
                  label: Text(_isReading ? 'Reading...' : 'Capture and read'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ],
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
                  'Reader output',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                if (_readResult.isEmpty)
                  const _WorldEmptyState()
                else
                  Text(
                    _readResult,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldReaderHero extends StatelessWidget {
  final VoidCallback? onCapture;

  const _WorldReaderHero({required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAFBF1), Color(0xFFD4F2DE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _WorldPill(),
          const SizedBox(height: 16),
          Text(
            'Turn signs, menus, and scenes into clear answers.',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Point your camera at the world, ask a question if needed, and let Gemma describe what matters.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryLight),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCapture,
            icon: const Icon(Icons.camera_enhance_rounded),
            label: const Text('Open camera capture'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldPill extends StatelessWidget {
  const _WorldPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_rounded, size: 16, color: AppColors.success),
          SizedBox(width: 8),
          Text(
            'Visual understanding',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldEmptyState extends StatelessWidget {
  const _WorldEmptyState();

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
            Icons.auto_stories_rounded,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Nothing captured yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Point at a document, label, menu, or sign and tap capture to get a readable description.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
