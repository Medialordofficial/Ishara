import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/constants.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  final ApiService _api = ApiService();
  final TtsService _tts = TtsService();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isInterpreting = false;
  bool _isCameraReady = false;
  bool _isListening = false;
  Timer? _captureTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _initCamera();
    _addSystemMessage(
      'Point the camera at the signer, then tap "Interpret" to begin.',
    );
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

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, sender: MessageSender.system));
    });
  }

  void _startInterpreting() {
    setState(() => _isInterpreting = true);
    _pulseController.repeat(reverse: true);
    _captureTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _captureAndInterpret();
    });
  }

  void _stopInterpreting() {
    _captureTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() => _isInterpreting = false);
  }

  Future<void> _captureAndInterpret() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      final interpretation = await _api.interpretSign(bytes);

      if (interpretation.isNotEmpty &&
          interpretation.toLowerCase() != 'no sign detected') {
        setState(() {
          _messages.add(
            ChatMessage(text: interpretation, sender: MessageSender.deaf),
          );
        });
        await _tts.speak(interpretation);
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _cameraController?.dispose();
    _tts.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sign_language,
              color: _isInterpreting
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text('Conversation'),
          ],
        ),
        actions: [
          if (_messages.length > 1)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => setState(() {
                _messages.clear();
                _addSystemMessage(
                  'Chat cleared. Tap "Interpret" to start again.',
                );
              }),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Camera preview ──
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final borderColor = _isInterpreting
                  ? Color.lerp(
                      AppColors.primary.withValues(alpha: 0.4),
                      AppColors.primary,
                      _pulseController.value,
                    )!
                  : AppColors.surfaceLight;

              return Container(
                height: 240,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: _isInterpreting
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_isCameraReady)
                      CameraPreview(_cameraController!)
                    else
                      Container(
                        color: AppColors.surface,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    // Live badge
                    if (_isInterpreting)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'LIVE',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // ── Chat messages ──
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 40,
                          color: AppColors.surfaceLight,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Interpreted signs will appear here',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _ChatBubble(message: _messages[index]);
                    },
                  ),
          ),

          // ── Controls ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlButton(
                  icon: _isInterpreting
                      ? Icons.stop_rounded
                      : Icons.sign_language,
                  label: _isInterpreting ? 'Stop' : 'Interpret',
                  color: AppColors.primary,
                  isActive: _isInterpreting,
                  onTap: _isInterpreting
                      ? _stopInterpreting
                      : _startInterpreting,
                ),
                _ControlButton(
                  icon: _isListening
                      ? Icons.mic_off_rounded
                      : Icons.mic_rounded,
                  label: _isListening ? 'Stop' : 'Listen',
                  color: AppColors.info,
                  isActive: _isListening,
                  onTap: () {
                    setState(() => _isListening = !_isListening);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat bubble ──────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDeaf = message.sender == MessageSender.deaf;
    final isSystem = message.sender == MessageSender.system;

    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: isDeaf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 3),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDeaf ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isDeaf ? 18 : 4),
            bottomRight: Radius.circular(isDeaf ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDeaf ? '🤟' : '🎤',
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(width: 4),
                Text(
                  isDeaf ? 'Signed' : 'Spoken',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDeaf
                        ? AppColors.secondary.withValues(alpha: 0.6)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              message.text,
              style: GoogleFonts.inter(
                color: isDeaf ? AppColors.secondary : AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Control button ───────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isActive ? color : color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: isActive ? Colors.white : color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isActive ? color : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
