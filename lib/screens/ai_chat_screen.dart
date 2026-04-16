import 'dart:async';
import 'package:flutter/material.dart';
import '../data/sign_dictionary.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatEntry> _messages = [];
  final ApiService _api = ApiService();
  final NotificationService _notif = NotificationService();
  final List<Map<String, String>> _chatHistory = [];

  // Draggable input state
  double _inputDy = 0; // will be set in build
  bool _inputMinimized = false;
  bool _inputPositionInitialized = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatEntry(
        text:
            'Ask me anything! I will reply in both text and sign language so everyone can understand.',
        role: _Role.system,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final input = text.trim();
    _textController.clear();

    setState(() {
      _messages.add(_ChatEntry(text: input, role: _Role.user));
    });
    _chatHistory.add({'role': 'user', 'content': input});
    _scrollToBottom();

    // Show thinking indicator
    setState(() {
      _messages.add(_ChatEntry(text: '', role: _Role.thinking));
    });
    _scrollToBottom();

    String response;
    try {
      // Try real LLM backend first
      response = await _api.chatLLM(input, history: _chatHistory);
      if (response.isEmpty) throw Exception('Empty response');
    } catch (_) {
      // Fallback to local keyword response
      response = _generateFallbackResponse(input);
    }

    _chatHistory.add({'role': 'assistant', 'content': response});

    // Cap history at 20 entries (10 turns) to prevent unbounded memory growth.
    // The backend only uses the last 6 entries for context anyway.
    if (_chatHistory.length > 20) {
      _chatHistory.removeRange(0, _chatHistory.length - 20);
    }

    final signTranslation = SignDictionary.translateSentence(
      '$input $response',
    );

    if (!mounted) return;
    setState(() {
      _messages.removeWhere((m) => m.role == _Role.thinking);
      _messages.add(_ChatEntry(text: response, role: _Role.assistant));
      if (signTranslation.isNotEmpty) {
        _messages.add(
          _ChatEntry(
            text: '',
            role: _Role.signAnimation,
            signs: signTranslation,
          ),
        );
      }
    });
    _scrollToBottom();

    // Send notification so user can read reply even outside the screen.
    // Errors are swallowed: notification plugin may be unavailable in tests
    // or on restricted devices and must not crash the chat.
    _notif.aiReply(response).catchError((_) {});
  }

  String _generateFallbackResponse(String input) {
    // The Ishara server is offline or unreachable.
    // Return an honest message rather than fake keyword-matched answers.
    // Still try a quick local dictionary lookup in case the user asked about a specific sign —
    // that helps even when the server is down.
    final lower = input.toLowerCase();
    for (final sign in SignDictionary.allSigns) {
      if (lower.contains(sign.word.toLowerCase())) {
        return 'The Ishara server is currently unreachable. '
            'From the offline dictionary: to sign "${sign.word}": ${sign.description}. '
            'Check your server settings and try again.';
      }
    }
    return 'The Ishara server is currently unreachable. '
        'Please check your server settings (tap the settings icon) and try again. '
        'You can still browse signs in the Sign Dictionary while offline.';
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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Initialize input position to near bottom
    if (!_inputPositionInitialized) {
      _inputDy = screenHeight - 200;
      _inputPositionInitialized = true;
    }

    // When keyboard opens, move input up so it stays visible
    final keyboardUp = bottomInset > 0;
    final effectiveInputDy = keyboardUp
        ? (screenHeight - bottomInset - 90).clamp(100.0, screenHeight - 100)
        : _inputDy.clamp(100.0, screenHeight - 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen message area
            Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                Expanded(
                  // GestureDetector (not InkWell) intentionally: full-scroll-area tap
                  // dismisses soft keyboard. No visual button feedback needed here.
                  child: GestureDetector(
                    onTap: () => _focusNode.unfocus(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        _inputMinimized ? 80 : 120,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) =>
                          _buildMessage(_messages[index]),
                    ),
                  ),
                ),
              ],
            ),

            // Draggable floating input
            Positioned(
              left: 16,
              right: 16,
              top: effectiveInputDy,
              child: _inputMinimized
                  ? _buildMinimizedInput()
                  : _buildDraggableInput(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Go back',
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.premiumShadows,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ishara AI',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Replies in Sign Language',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Clear chat',
            child: InkWell(
              onTap: () => setState(() {
                _messages.clear();
                _chatHistory.clear();
                _messages.add(
                  _ChatEntry(
                    text: 'Chat cleared! Ask me anything.',
                    role: _Role.system,
                  ),
                );
              }),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.premiumShadows,
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimizedInput() {
    return Align(
      alignment: Alignment.centerRight,
      child: Semantics(
        button: true,
        label: 'Open keyboard input',
        child: InkWell(
          onTap: () => setState(() => _inputMinimized = false),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.keyboard_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableInput() {
    // GestureDetector (not InkWell) intentionally: onVerticalDragUpdate is
    // required for drag repositioning — InkWell does not support drag callbacks.
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _inputDy += details.delta.dy;
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 40,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle + minimize
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                Semantics(
                  button: true,
                  label: 'Minimize input',
                  child: InkWell(
                    onTap: () {
                      _focusNode.unfocus();
                      setState(() => _inputMinimized = true);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.minimize_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Input row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Ask anything...',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _sendMessage,
                      textInputAction: TextInputAction.send,
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Semantics(
                  button: true,
                  label: 'Send message',
                  child: InkWell(
                    onTap: () => _sendMessage(_textController.text),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(_ChatEntry msg) {
    switch (msg.role) {
      case _Role.system:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                msg.text,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      case _Role.user:
        return Semantics(
          label: 'You: ${msg.text}',
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      case _Role.assistant:
        return Semantics(
          label: 'Ishara: ${msg.text}',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(18),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: AppColors.premiumShadows,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ishara AI',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    msg.text,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case _Role.thinking:
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppColors.premiumShadows,
            ),
            child: const _TypingIndicator(),
          ),
        );
      case _Role.signAnimation:
        return _CollapsibleSignReply(signs: msg.signs ?? []);
    }
  }
}

enum _Role { system, user, assistant, thinking, signAnimation }

class _ChatEntry {
  final String text;
  final _Role role;
  final List<SignEntry>? signs;

  _ChatEntry({required this.text, required this.role, this.signs});
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true);
    });
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 10,
              height: 10 + (6 * _controllers[i].value),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.3 + (0.7 * _controllers[i].value),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Collapsible wrapper for sign animation — lets user expand/collapse
class _CollapsibleSignReply extends StatefulWidget {
  final List<SignEntry> signs;
  const _CollapsibleSignReply({required this.signs});

  @override
  State<_CollapsibleSignReply> createState() => _CollapsibleSignReplyState();
}

class _CollapsibleSignReplyState extends State<_CollapsibleSignReply> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.signs.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.04),
            AppColors.primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle header
          Semantics(
            button: true,
            label: _expanded
                ? 'Collapse sign translation'
                : 'Expand sign translation',
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sign_language,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Sign Translation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.signs.length} signs',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Animated sign player — only shown when expanded
          if (_expanded) _AnimatedSignReply(signs: widget.signs),
        ],
      ),
    );
  }
}

/// Animated sign language reply - shows signs one by one with animation
class _AnimatedSignReply extends StatefulWidget {
  final List<SignEntry> signs;
  const _AnimatedSignReply({required this.signs});

  @override
  State<_AnimatedSignReply> createState() => _AnimatedSignReplyState();
}

class _AnimatedSignReplyState extends State<_AnimatedSignReply>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _currentStep = 0;
  bool _isPlaying = true;
  Timer? _timer;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeController.forward();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (!mounted || !_isPlaying) return;

      setState(() {
        final currentSign = widget.signs[_currentIndex];
        if (_currentStep < currentSign.steps.length - 1) {
          _currentStep++;
        } else if (_currentIndex < widget.signs.length - 1) {
          _currentIndex++;
          _currentStep = 0;
        } else {
          // Loop back
          _currentIndex = 0;
          _currentStep = 0;
        }
      });
      _fadeController.reset();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.signs.isEmpty) return const SizedBox.shrink();

    final sign = widget.signs[_currentIndex];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.primary.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sign_language, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Sign Translation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: _isPlaying
                    ? 'Pause sign animation'
                    : 'Play sign animation',
                child: InkWell(
                  onTap: () => setState(() => _isPlaying = !_isPlaying),
                  borderRadius: BorderRadius.circular(50),
                  child: Icon(
                    _isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sign dots indicator
          Row(
            children: widget.signs.asMap().entries.map((e) {
              final isActive = e.key == _currentIndex;
              return Container(
                margin: const EdgeInsets.only(right: 6),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Current sign display
          FadeTransition(
            opacity: _fadeController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated emoji display
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  key: ValueKey('$_currentIndex-$_currentStep'),
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.premiumShadows,
                    ),
                    child: Column(
                      children: [
                        Text(sign.emoji, style: const TextStyle(fontSize: 56)),
                        const SizedBox(height: 8),
                        Text(
                          sign.word,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Current step instruction
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                              '${_currentStep + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            ' / ${sign.steps.length}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sign.steps[_currentStep],
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Manual controls at bottom
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: Icons.skip_previous_rounded,
                onTap: () {
                  setState(() {
                    if (_currentIndex > 0) {
                      _currentIndex--;
                      _currentStep = 0;
                    }
                  });
                  _fadeController.reset();
                  _fadeController.forward();
                },
              ),
              const SizedBox(width: 16),
              _ControlButton(
                icon: Icons.replay_rounded,
                onTap: () {
                  setState(() {
                    _currentStep = 0;
                  });
                  _fadeController.reset();
                  _fadeController.forward();
                },
              ),
              const SizedBox(width: 16),
              _ControlButton(
                icon: Icons.skip_next_rounded,
                onTap: () {
                  setState(() {
                    if (_currentIndex < widget.signs.length - 1) {
                      _currentIndex++;
                      _currentStep = 0;
                    }
                  });
                  _fadeController.reset();
                  _fadeController.forward();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppColors.premiumShadows,
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
    );
  }
}
