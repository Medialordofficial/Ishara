import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/tts_service.dart';
import '../utils/constants.dart';
import '../widgets/quick_phrases_board.dart';

/// A screen where deaf/mute users type a message and the phone speaks it
/// aloud via TTS. Includes a quick-phrases board for common phrases and a
/// free-text input for anything custom.
class TypeToSpeakScreen extends StatefulWidget {
  const TypeToSpeakScreen({super.key});

  @override
  State<TypeToSpeakScreen> createState() => _TypeToSpeakScreenState();
}

class _TypeToSpeakScreenState extends State<TypeToSpeakScreen> {
  final TtsService _tts = TtsService();
  final TextEditingController _textController = TextEditingController();
  final List<String> _history = [];
  bool _isSpeaking = false;
  bool _showQuickPhrases = true;

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isSpeaking = true;
      if (!_history.contains(text)) {
        _history.insert(0, text);
        if (_history.length > 20) _history.removeLast();
      }
    });
    await _tts.speak(text);
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _speakFromInput() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _speak(text);
  }

  @override
  void dispose() {
    _textController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Type to Speak',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showQuickPhrases
                  ? Icons.grid_view_rounded
                  : Icons.grid_off_rounded,
              color: AppColors.primary,
            ),
            tooltip: _showQuickPhrases
                ? 'Hide quick phrases'
                : 'Show quick phrases',
            onPressed: () =>
                setState(() => _showQuickPhrases = !_showQuickPhrases),
          ),
        ],
      ),
      body: Column(
        children: [
          // Speaking indicator
          if (_isSpeaking)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: AppColors.primary.withValues(alpha: 0.1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Speaking…',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick phrases board
                  if (_showQuickPhrases) ...[
                    const Text(
                      'Tap to speak instantly',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your phone will say it out loud for you',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    QuickPhrasesBoard(onPhraseSelected: _speak),
                    const SizedBox(height: 24),
                    const Divider(),
                  ],
                  // Recent history
                  if (_history.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Recently spoken',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _history.map((phrase) {
                        return Semantics(
                          button: true,
                          label: 'Repeat: $phrase',
                          child: ActionChip(
                            avatar: const Icon(
                              Icons.replay,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              phrase.length > 30
                                  ? '${phrase.substring(0, 30)}…'
                                  : phrase,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                            backgroundColor: AppColors.surface,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                            onPressed: () => _speak(phrase),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
          // Bottom text input
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
            child: Row(
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
                      label: 'Type what you want to say',
                      textField: true,
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Type anything to speak…',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _speakFromInput(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: 'Speak typed message',
                  child: Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: InkWell(
                      onTap: _speakFromInput,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 26,
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
