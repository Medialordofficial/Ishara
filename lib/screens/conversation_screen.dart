import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  final TextEditingController _textController = TextEditingController();
  bool _isInterpreting = false;
  bool _isCameraReady = false;
  bool _isListening = false;
  Timer? _captureTimer;
  late AnimationController _pulseController;

  // Speech-to-text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  String _currentWords = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _initCamera();
    _initSpeech();
    _addSystemMessage(
      'Point the camera at the signer, then tap to begin. The hearing person can use the mic or type below.',
    );
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) {
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Speech error: ${error.errorMsg}')),
          );
        }
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted && _isListening) {
            setState(() => _isListening = false);
            if (_currentWords.isNotEmpty) {
              _addHearingMessage(_currentWords);
              _currentWords = '';
            }
          }
        }
      },
    );
  }

  void _addHearingMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, sender: MessageSender.hearing));
    });
    _scrollToBottom();
  }

  void _toggleMic() async {
    if (!_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available on this device'),
          ),
        );
      }
      return;
    }

    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
      if (_currentWords.isNotEmpty) {
        _addHearingMessage(_currentWords);
        _currentWords = '';
      }
    } else {
      setState(() {
        _isListening = true;
        _currentWords = '';
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _currentWords = result.recognizedWords;
          });
          if (result.finalResult && _currentWords.isNotEmpty) {
            _addHearingMessage(_currentWords);
            _currentWords = '';
            setState(() => _isListening = false);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
      );
    }
  }

  void _sendTextMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _addHearingMessage(text);
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Interpretation error: $e')));
      }
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
    _speech.stop();
    _cameraController?.dispose();
    _tts.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Live Conversation',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_messages.length > 1)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 24,
                color: AppColors.danger,
              ),
              onPressed: () => setState(() {
                _messages.clear();
                _addSystemMessage('Chat cleared.');
              }),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Camera Preview inside Premium Floating Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: AppColors.premiumShadows,
                    border: Border.all(
                      color: _isInterpreting
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 4 * _pulseController.value,
                    ),
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
                      if (_isInterpreting)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.white,
                                  size: 10,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
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
          ),
          const SizedBox(height: 24),
          // Main Chat Body
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                boxShadow: AppColors.premiumShadows,
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _PremiumChatBubble(message: msg);
                },
              ),
            ),
          ),
          // Floating Bottom Controls
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live speech preview
                if (_isListening && _currentWords.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _currentWords,
                      style: const TextStyle(
                        color: AppColors.info,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                // Text input + mic + send
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: AppColors.premiumShadows,
                        ),
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: 'Hearing person types here...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendTextMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendTextMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleMic,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isListening
                              ? AppColors.danger
                              : AppColors.info,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_isListening
                                          ? AppColors.danger
                                          : AppColors.info)
                                      .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sign interpretation toggle
                GestureDetector(
                  onTap: _isInterpreting
                      ? _stopInterpreting
                      : _startInterpreting,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _isInterpreting
                          ? AppColors.danger
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isInterpreting
                                      ? AppColors.danger
                                      : AppColors.primary)
                                  .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isInterpreting ? Icons.stop : Icons.sign_language,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isInterpreting
                              ? 'Stop Sign Reading'
                              : 'Start Sign Reading',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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

class _PremiumChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _PremiumChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isSystem = message.sender == MessageSender.system;
    final isDeaf = message.sender == MessageSender.deaf;

    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            message.text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Align(
      alignment: isDeaf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isDeaf ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isDeaf ? 24 : 8),
            bottomRight: Radius.circular(isDeaf ? 8 : 24),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDeaf ? AppColors.primary : AppColors.secondary)
                  .withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isDeaf ? Colors.white : AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
