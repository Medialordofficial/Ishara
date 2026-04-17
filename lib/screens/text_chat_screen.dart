import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../widgets/quick_phrases_board.dart';

/// A simple text-only chat for two deaf users sitting together.
/// Both sides type — no STT, no TTS. Messages alternate between
/// "Me" (this device) and "Them" (the other person types on same device
/// by flipping/passing it). Each side has a distinct colour.
class TextChatScreen extends StatefulWidget {
  const TextChatScreen({super.key});

  @override
  State<TextChatScreen> createState() => _TextChatScreenState();
}

enum _ChatSide { me, them }

class _TextChatMessage {
  final String text;
  final _ChatSide side;
  final DateTime timestamp;
  _TextChatMessage({
    required this.text,
    required this.side,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class _TextChatScreenState extends State<TextChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_TextChatMessage> _messages = [];
  _ChatSide _activeSide = _ChatSide.me;
  bool _showQuickPhrases = false;

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(_TextChatMessage(text: text, side: _activeSide));
    });
    _scrollToBottom();
  }

  void _sendPhrase(String phrase) {
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(_TextChatMessage(text: phrase, side: _activeSide));
      _showQuickPhrases = false;
    });
    _scrollToBottom();
  }

  void _switchSide() {
    HapticFeedback.mediumImpact();
    setState(() {
      _activeSide = _activeSide == _ChatSide.me ? _ChatSide.them : _ChatSide.me;
    });
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
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMe = _activeSide == _ChatSide.me;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Text Chat',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.danger,
                size: 24,
              ),
              tooltip: 'Clear chat',
              onPressed: () => setState(() => _messages.clear()),
            ),
        ],
      ),
      body: Column(
        children: [
          // Active side indicator + switch button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isMe
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: isMe ? AppColors.primary : AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isMe
                        ? 'You are typing (Person 1)'
                        : 'Other person typing (Person 2)',
                    style: TextStyle(
                      color: isMe ? AppColors.primary : AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Switch to ${isMe ? "other person" : "you"}',
                  child: Material(
                    color: isMe ? AppColors.primary : AppColors.success,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _switchSide,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Switch',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: AppColors.premiumShadows,
              ),
              child: _messages.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Pass the phone back and forth to chat.\nTap "Switch" when handing the phone over.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return _TextChatBubble(message: msg);
                      },
                    ),
            ),
          ),
          // Quick phrases (toggleable)
          if (_showQuickPhrases)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: QuickPhrasesBoard(onPhraseSelected: _sendPhrase),
              ),
            ),
          // Bottom input
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
            child: Row(
              children: [
                // Quick phrases toggle
                Semantics(
                  button: true,
                  label: _showQuickPhrases
                      ? 'Hide quick phrases'
                      : 'Show quick phrases',
                  child: InkWell(
                    onTap: () =>
                        setState(() => _showQuickPhrases = !_showQuickPhrases),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _showQuickPhrases
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.grid_view_rounded,
                        color: _showQuickPhrases
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppColors.premiumShadows,
                    ),
                    child: Semantics(
                      label: 'Type your message',
                      textField: true,
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type here…',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _send(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: 'Send message',
                  child: Material(
                    color: isMe ? AppColors.primary : AppColors.success,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: InkWell(
                      onTap: _send,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 52,
                        height: 52,
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
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

class _TextChatBubble extends StatelessWidget {
  final _TextChatMessage message;
  const _TextChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.side == _ChatSide.me;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Semantics(
        label: '${isMe ? "You" : "Other person"}: ${message.text}',
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : AppColors.success,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(22),
              topRight: const Radius.circular(22),
              bottomLeft: Radius.circular(isMe ? 22 : 6),
              bottomRight: Radius.circular(isMe ? 6 : 22),
            ),
            boxShadow: [
              BoxShadow(
                color: (isMe ? AppColors.primary : AppColors.success)
                    .withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMe ? 'You' : 'Them',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
