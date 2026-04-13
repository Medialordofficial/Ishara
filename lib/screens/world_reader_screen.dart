import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.document_scanner, color: AppColors.success),
            const SizedBox(width: 8),
            const Text('World Reader'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Camera preview
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              clipBehavior: Clip.antiAlias,
              child: _isCameraReady
                  ? Stack(
                      children: [
                        CameraPreview(_cameraController!),
                        // Scanning overlay
                        if (_isReading)
                          Container(
                            color: AppColors.background.withValues(alpha: 0.5),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: AppColors.success,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Reading...',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Crosshair
                        if (!_isReading)
                          Center(
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.success.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.success,
                      ),
                    ),
            ),
          ),

          // Ask a question (optional)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _questionController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Ask a question about what you see (optional)',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(
                  Icons.help_outline,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Capture button
          GestureDetector(
            onTap: _isReading ? null : _captureAndRead,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isReading ? AppColors.surfaceLight : AppColors.success,
                shape: BoxShape.circle,
                boxShadow: !_isReading
                    ? [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _isReading
                    ? Icons.hourglass_top_rounded
                    : Icons.camera_alt_rounded,
                color: _isReading ? AppColors.textSecondary : Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Result
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: _readResult.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_stories,
                            size: 36,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Point at a document, label, sign, or menu\nand tap the camera button',
                            style: TextStyle(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Text(
                        _readResult,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
