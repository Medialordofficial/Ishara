import 'dart:async';
import 'package:flutter/material.dart';
import '../data/sign_dictionary.dart';
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
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final input = text.trim();
    _textController.clear();

    setState(() {
      _messages.add(_ChatEntry(text: input, role: _Role.user));
    });
    _scrollToBottom();

    // Simulate LLM thinking
    setState(() {
      _messages.add(_ChatEntry(text: '', role: _Role.thinking));
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      // Generate a response with sign translation
      final response = _generateResponse(input);
      final signTranslation = SignDictionary.translateSentence(
        '$input $response',
      );

      setState(() {
        // Remove thinking indicator
        _messages.removeWhere((m) => m.role == _Role.thinking);
        // Add text response
        _messages.add(_ChatEntry(text: response, role: _Role.assistant));
        // Add animated sign translation
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
    });
  }

  String _generateResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('hello') || lower.contains('hi')) {
      return 'Hello! How can I help you today? I\'m here to assist with anything you need.';
    } else if (lower.contains('name')) {
      return 'My name is Ishara AI. I help bridge communication between deaf and hearing people.';
    } else if (lower.contains('how are you')) {
      return 'I\'m doing great, thank you for asking! How are you?';
    } else if (lower.contains('help')) {
      return 'Of course! I can help you with sign language translation, learning signs, or just chatting. What do you need?';
    } else if (lower.contains('learn') || lower.contains('teach')) {
      return 'I\'d love to help you learn! Try asking me about specific signs like "How do I sign hello?" or "Teach me family signs".';
    } else if (lower.contains('sign') && lower.contains('how')) {
      // Try to find the specific sign they're asking about
      for (final sign in SignDictionary.allSigns) {
        if (lower.contains(sign.word.toLowerCase())) {
          return 'To sign "${sign.word}": ${sign.description}. Check the animated guide below!';
        }
      }
      return 'I can show you many signs! Try asking about specific words like hello, thank you, help, food, water, or any letter.';
    } else if (lower.contains('weather')) {
      return 'I can\'t check the weather, but I can teach you how to sign weather-related words! Try "How do I sign water?"';
    } else if (lower.contains('food') ||
        lower.contains('eat') ||
        lower.contains('hungry')) {
      return 'Are you hungry? Here\'s how to sign "food" and "hungry". You can also check the Food & Drink category in the Sign Dictionary!';
    } else if (lower.contains('emergency') ||
        lower.contains('help') ||
        lower.contains('danger')) {
      return 'In an emergency, use the Emergency SOS feature in the app. I can also teach you emergency signs like "help", "danger", and "call 911".';
    } else if (lower.contains('thank')) {
      return 'You\'re welcome! Is there anything else I can help you with?';
    } else if (lower.contains('love')) {
      return 'The sign for "I Love You" is one of the most famous! Extend your thumb, index finger, and pinky. It combines I, L, and Y.';
    } else {
      return 'That\'s a great question! While I process your request, check out the sign language translation below. You can also explore the Sign Dictionary for more signs.';
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
  Widget build(BuildContext context) {
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
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primary,
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
                  GestureDetector(
                    onTap: () => setState(() {
                      _messages.clear();
                      _messages.add(
                        _ChatEntry(
                          text: 'Chat cleared! Ask me anything.',
                          role: _Role.system,
                        ),
                      );
                    }),
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
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    _buildMessage(_messages[index]),
              ),
            ),

            // Input - thumb accessible at bottom
            Container(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Ask anything...',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _sendMessage,
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _sendMessage(_textController.text),
                    child: Container(
                      padding: const EdgeInsets.all(14),
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
                ],
              ),
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
        return Align(
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
        );
      case _Role.assistant:
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
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
            ),
            child: Text(
              msg.text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
        return _AnimatedSignReply(signs: msg.signs ?? []);
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
              GestureDetector(
                onTap: () => setState(() => _isPlaying = !_isPlaying),
                child: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: AppColors.primary,
                  size: 28,
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
    return GestureDetector(
      onTap: onTap,
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
