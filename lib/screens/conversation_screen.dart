import 'dart:async';
import 'package:flutter/material.dart';
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

class _ConversationScreenState extends State<ConversationScreen> {
  CameraController? _cameraController;
  final ApiService _api = ApiService();
  final TtsService _tts = TtsService();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isInterpreting = false;
  bool _isCameraReady = false;
  bool _isListening = false;
  Timer? _captureTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _addSystemMessage('Ishara Conversation Mode active. Point camera at signer.');
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use front camera
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

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, sender: MessageSender.system));
    });
  }

  void _startInterpreting() {
    setState(() => _isInterpreting = true);
    _captureTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _captureAndInterpret();
    });
  }

  void _stopInterpreting() {
    _captureTimer?.cancel();
    setState(() => _isInterpreting = false);
  }

  Future<void> _captureAndInterpret() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();

      final interpretation = await _api.interpretSign(bytes);
      if (interpretation.isNotEmpty) {
        setState(() {
          _messages.add(ChatMessage(
            text: interpretation,
            sender: MessageSender.deaf,
          ));
        });
        await _tts.speak(interpretation);
        _scrollToBottom();
      }
    } catch (e) {
      // Silently handle — don't spam errors during continuous capture
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sign_language, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Conversation'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Camera preview
          Container(
            height: 280,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isInterpreting
                    ? AppColors.primary
                    : AppColors.surfaceLight,
                width: _isInterpreting ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isCameraReady
                ? CameraPreview(_cameraController!)
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 12),
                        Text('Starting camera...',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
          ),

          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Tap the button below to start interpreting',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _ChatBubble(message: _messages[index]);
                    },
                  ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Interpret button (deaf user signs)
                _ControlButton(
                  icon: _isInterpreting ? Icons.stop : Icons.sign_language,
                  label: _isInterpreting ? 'Stop' : 'Interpret Signs',
                  color: AppColors.primary,
                  isActive: _isInterpreting,
                  onTap: _isInterpreting
                      ? _stopInterpreting
                      : _startInterpreting,
                ),
                // Listen button (hearing user speaks)
                _ControlButton(
                  icon: _isListening ? Icons.mic_off : Icons.mic,
                  label: _isListening ? 'Stop' : 'Listen',
                  color: AppColors.info,
                  isActive: _isListening,
                  onTap: () {
                    // TODO: Implement speech-to-text
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

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDeaf = message.sender == MessageSender.deaf;
    final isSystem = message.sender == MessageSender.system;

    if (isSystem) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          message.text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Align(
      alignment: isDeaf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isDeaf ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isDeaf ? const Radius.circular(4) : null,
            bottomLeft: !isDeaf ? const Radius.circular(4) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isDeaf ? '🤟 Signed' : '🎤 Spoken',
              style: TextStyle(
                fontSize: 10,
                color: isDeaf
                    ? AppColors.secondary.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message.text,
              style: TextStyle(
                color: isDeaf ? AppColors.secondary : AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? color : color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : color,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
