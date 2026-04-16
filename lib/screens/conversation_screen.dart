import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/pose_detection_service.dart';
import '../services/tts_service.dart';
import '../utils/constants.dart';
import 'sound_awareness_screen.dart' show sanitizeSoundLabel;

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
  bool _isCapturing = false; // guard against concurrent capture calls
  Timer? _captureTimer;
  late AnimationController _pulseController;

  // On-device ML pose detection
  final PoseDetectionService _poseService = PoseDetectionService();
  String _signingStatus = 'Ready';
  double _poseConfidence = 0.0;

  // Last interpreted sign + confidence for feedback UI
  String _lastSign = '';
  double _lastConfidence = 0.0;

  // Speech-to-text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _sttServerAvailable = false; // whether server-side STT is ready
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
    _checkServerStt();
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
              final captured = _currentWords;
              _currentWords = '';
              if (_sttServerAvailable) {
                _listenViaServerStt(
                  Uint8List.fromList(captured.codeUnits),
                  captured,
                );
              } else {
                _addHearingMessage(captured);
              }
            }
          }
        }
      },
    );
  }

  Future<void> _checkServerStt() async {
    try {
      // Probe server reachability via /ping first to avoid a blind STT call.
      final online = await _api.ping();
      if (!online || !mounted) return;
      // Use the ping result to infer only that the server is up.
      // The STT available flag is discovered lazily on first actual use.
      setState(() => _sttServerAvailable = true);
    } catch (_) {
      // Server unreachable — keep _sttServerAvailable false
    }
  }

  /// Sends [audioBytes] to the server for STT. On any failure or empty
  /// response, falls back to [fallbackText] (the on-device transcription)
  /// so no message is ever silently lost.
  Future<void> _listenViaServerStt(
    Uint8List audioBytes,
    String fallbackText,
  ) async {
    try {
      final result = await _api.speechToText(audioBytes);
      if (!result.available) {
        // STT engine not available — disable future server calls
        if (mounted) setState(() => _sttServerAvailable = false);
      } else if (mounted) {
        final text = sanitizeSoundLabel(result.text);
        if (text.isNotEmpty) {
          _addHearingMessage(text);
          return;
        }
      }
    } catch (_) {
      // Server unavailable — fall through to on-device result
    }
    if (!mounted) return;
    // Always deliver the on-device transcription as the fallback.
    _addHearingMessage(fallbackText);
  }

  void _addHearingMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, sender: MessageSender.hearing));
    });
    // ignore: deprecated_member_use
    SemanticsService.announce(
      'Hearing user said: $text',
      TextDirection.ltr,
      assertiveness: Assertiveness.assertive,
    );
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
        final captured = _currentWords;
        _currentWords = '';
        // Consistent with onResult: use server path when available.
        if (_sttServerAvailable) {
          _listenViaServerStt(
            Uint8List.fromList(captured.codeUnits),
            captured,
          );
        } else {
          _addHearingMessage(captured);
        }
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
            final captured = _currentWords;
            _currentWords = '';
            setState(() => _isListening = false);
            if (_sttServerAvailable) {
              // Pass on-device text as bytes + as explicit fallback so no
              // message is lost on server failure or empty response.
              // TODO(#issue): replace codeUnits with raw PCM bytes from
              // the `record` package when audio capture is added.
              _listenViaServerStt(
                Uint8List.fromList(captured.codeUnits),
                captured,
              );
            } else {
              _addHearingMessage(captured);
            }
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
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No cameras available on this device'),
            ),
          );
        }
        return;
      }

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Camera error: $e')));
      }
    }
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
    // Guard against overlapping calls — skip if a capture is already in flight
    if (_isCapturing) return;
    _isCapturing = true;
    try {
      final image = await _cameraController!.takePicture();

      // ━━━ On-device ML: Pose analysis before sending to server ━━━
      final analysis = await _poseService.analyzeFrame(image.path);

      if (mounted) {
        setState(() {
          _signingStatus = analysis.status;
          _poseConfidence = analysis.confidence;
        });
      }

      if (!analysis.isSigning) {
        // No signing posture — skip expensive server call
        return;
      }
      // ━━━ End on-device ML gate ━━━

      final bytes = await image.readAsBytes();
      final result = await _api.interpretSign(bytes);
      final interpretation = sanitizeSoundLabel((result['sign'] as String?) ?? '');
      final confidence = (result['confidence'] as double?) ?? 0.0;

      // Only announce and speak results above the confidence threshold
      if (interpretation.isNotEmpty &&
          interpretation.toLowerCase() != 'no sign detected' &&
          confidence >= PoseThresholds.interpretConfidence) {
        setState(() {
          _lastSign = interpretation;
          _lastConfidence = confidence;
          _messages.add(
            ChatMessage(text: interpretation, sender: MessageSender.deaf),
          );
        });
        // ignore: deprecated_member_use
        SemanticsService.announce(
          'Sign interpreted: $interpretation',
          TextDirection.ltr,
          assertiveness: Assertiveness.assertive,
        );
        await _tts.speak(interpretation);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Interpretation error: $e')));
      }
    } finally {
      _isCapturing = false;
    }
  }

  void _showCorrectionDialog(String incorrectSign) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('What was the correct sign?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. "Thank you"',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final correct = controller.text.trim();
              Navigator.of(ctx).pop();
              if (correct.isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                await _api.sendFeedback(
                  interpretedSign: incorrectSign,
                  correctSign: correct,
                );
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Correction submitted — thank you!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
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
    _tts.stop();
    _scrollController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _poseService.dispose();
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
              tooltip: 'Clear chat',
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
                        Semantics(
                          label: 'Camera preview for sign interpretation',
                          child: CameraPreview(_cameraController!),
                        )
                      else
                        Center(
                          child: Semantics(
                            label: 'Loading camera',
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
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
                      // On-device ML status indicator
                      if (_isInterpreting)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _poseConfidence >
                                          PoseThresholds.signingConfidence
                                      ? Icons.person
                                      : Icons.person_outline,
                                  color:
                                      _poseConfidence >
                                          PoseThresholds.signingConfidence
                                      ? AppColors.success
                                      : Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _signingStatus,
                                    style: TextStyle(
                                      color:
                                          _poseConfidence >
                                              PoseThresholds.signingConfidence
                                          ? AppColors.success
                                          : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                // Confidence bar
                                SizedBox(
                                  width: 50,
                                  height: 4,
                                  child: Semantics(
                                    label: 'Signing confidence',
                                    value:
                                        '${(_poseConfidence * 100).round()}%',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: _poseConfidence,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.2),
                                        color:
                                            _poseConfidence >
                                                PoseThresholds.signingConfidence
                                            ? AppColors.success
                                            : Colors.white54,
                                      ),
                                    ),
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
                // Confidence + feedback row after last sign interpretation
                if (_lastSign.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last: "$_lastSign"',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_graph,
                                    size: 12,
                                    color: _lastConfidence >= 0.7
                                        ? AppColors.success
                                        : _lastConfidence >=
                                              PoseThresholds.interpretConfidence
                                        ? AppColors.warning
                                        : AppColors.danger,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(_lastConfidence * 100).toStringAsFixed(0)}% confidence',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _lastConfidence >= 0.7
                                          ? AppColors.success
                                          : _lastConfidence >=
                                                PoseThresholds
                                                    .interpretConfidence
                                          ? AppColors.warning
                                          : AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Mark interpretation as correct',
                          child: IconButton(
                            icon: const Icon(
                              Icons.thumb_up_outlined,
                              size: 20,
                              color: AppColors.success,
                            ),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await _api.sendFeedback(
                                interpretedSign: _lastSign,
                                correctSign: _lastSign,
                              );
                              if (mounted) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Thanks for the feedback!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Report incorrect interpretation',
                          child: IconButton(
                            icon: const Icon(
                              Icons.thumb_down_outlined,
                              size: 20,
                              color: AppColors.danger,
                            ),
                            onPressed: () => _showCorrectionDialog(_lastSign),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Server STT status chip
                if (_sttServerAvailable)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Semantics(
                      label: 'Server speech recognition active',
                      excludeSemantics: true,
                      child: Chip(
                        avatar: const Icon(
                          Icons.cloud_done,
                          size: 14,
                          color: AppColors.success,
                        ),
                        label: const Text(
                          'Server STT active — routing speech',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                          ),
                        ),
                        backgroundColor:
                            AppColors.success.withValues(alpha: 0.1),
                        side: BorderSide(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                        padding: EdgeInsets.zero,
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
                        child: Semantics(
                          label: 'Hearing person types here',
                          textField: true,
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
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: 'Send message',
                      child: InkWell(
                        onTap: _sendTextMessage,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const ExcludeSemantics(
                            child: Icon(
                              Icons.send_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: _isListening
                          ? 'Stop listening'
                          : 'Start listening',
                      child: InkWell(
                        onTap: _toggleMic,
                        borderRadius: BorderRadius.circular(50),
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
                          child: ExcludeSemantics(
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sign interpretation toggle
                Semantics(
                  button: true,
                  label: _isInterpreting
                      ? 'Stop sign reading'
                      : 'Start sign reading',
                  child: InkWell(
                    onTap: _isInterpreting
                        ? _stopInterpreting
                        : _startInterpreting,
                    borderRadius: BorderRadius.circular(28),
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
                          ExcludeSemantics(
                            child: Icon(
                              _isInterpreting ? Icons.stop : Icons.sign_language,
                              color: Colors.white,
                              size: 22,
                            ),
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
      child: Semantics(
        label: '${isDeaf ? "You said" : "Hearing user said"}: ${message.text}',
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
      ),
    );
  }
}
