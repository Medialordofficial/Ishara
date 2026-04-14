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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

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
        title: const Text('Conversation'),
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
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _ConversationHero(
                  isInterpreting: _isInterpreting,
                  onPrimaryTap: _isInterpreting
                      ? _stopInterpreting
                      : _startInterpreting,
                ),
                const SizedBox(height: 18),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final borderColor = _isInterpreting
                        ? Color.lerp(
                            AppColors.primary.withValues(alpha: 0.35),
                            AppColors.primary,
                            _pulseController.value,
                          )!
                        : AppColors.border;

                    return Container(
                      height: 260,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: borderColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_isCameraReady)
                            CameraPreview(_cameraController!)
                          else
                            const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: _StatusPill(
                              label: _isInterpreting
                                  ? 'Live translation'
                                  : 'Camera ready',
                              icon: _isInterpreting
                                  ? Icons.graphic_eq_rounded
                                  : Icons.camera_alt_rounded,
                              background: _isInterpreting
                                  ? AppColors.danger
                                  : AppColors.surface,
                              foreground: _isInterpreting
                                  ? Colors.white
                                  : AppColors.secondary,
                            ),
                          ),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _isInterpreting
                                    ? 'Signing now...'
                                    : 'Align hands in frame',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ModeStat(
                          label: 'Status',
                          value: _isInterpreting ? 'Interpreting' : 'Standby',
                          accent: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: _ModeStat(
                          label: 'Messages',
                          value:
                              '${_messages.where((m) => m.sender != MessageSender.system).length}',
                          accent: AppColors.info,
                        ),
                      ),
                      Expanded(
                        child: _ModeStat(
                          label: 'Voice',
                          value: _isListening ? 'Listening' : 'Off',
                          accent: AppColors.warning,
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
                      Row(
                        children: [
                          Text(
                            'Conversation feed',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          Text(
                            'Real-time output',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_messages.isEmpty)
                        const _EmptyState(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'No interpreted messages yet',
                          subtitle:
                              'Start live interpretation and Ishara will place translated speech here.',
                        )
                      else
                        ..._messages.map(
                          (message) => _ChatBubble(message: message),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ControlButton(
                    icon: _isInterpreting
                        ? Icons.stop_circle_rounded
                        : Icons.play_circle_fill_rounded,
                    label: _isInterpreting
                        ? 'Stop live mode'
                        : 'Start live mode',
                    color: AppColors.primary,
                    isActive: _isInterpreting,
                    onTap: _isInterpreting
                        ? _stopInterpreting
                        : _startInterpreting,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ControlButton(
                    icon: _isListening
                        ? Icons.hearing_disabled_rounded
                        : Icons.mic_rounded,
                    label: _isListening ? 'Mute voice' : 'Listen back',
                    color: AppColors.info,
                    isActive: _isListening,
                    onTap: () {
                      setState(() => _isListening = !_isListening);
                    },
                  ),
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
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.text,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Align(
      alignment: isDeaf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDeaf ? const Color(0xFFFFF2CC) : AppColors.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isDeaf ? 20 : 6),
            bottomRight: Radius.circular(isDeaf ? 6 : 20),
          ),
          border: Border.all(
            color: isDeaf
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border,
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: isActive ? color : color.withValues(alpha: 0.12),
        foregroundColor: isActive ? Colors.white : color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withValues(alpha: 0.35)),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
    );
  }
}

class _ConversationHero extends StatelessWidget {
  final bool isInterpreting;
  final VoidCallback onPrimaryTap;

  const _ConversationHero({
    required this.isInterpreting,
    required this.onPrimaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E5), Color(0xFFFFE8B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StatusPill(
            label: 'Two-way communication',
            icon: Icons.forum_rounded,
            background: Colors.white,
            foreground: AppColors.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'See signing, hear the meaning, keep the flow natural.',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 10),
          Text(
            'Conversation mode turns visual signing into spoken output while keeping the camera and transcript in one place.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryLight),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onPrimaryTap,
            icon: Icon(
              isInterpreting
                  ? Icons.stop_circle_rounded
                  : Icons.play_circle_fill_rounded,
            ),
            label: Text(
              isInterpreting ? 'Stop interpreting' : 'Start interpreting',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _StatusPill({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _ModeStat({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: accent),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
