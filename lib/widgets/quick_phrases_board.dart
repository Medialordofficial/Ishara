import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// A tappable board of pre-set phrases for users who cannot speak or sign.
/// Each tap fires the phrase via [onPhraseSelected] so the parent can route
/// it to TTS, chat, or any other output channel.
class QuickPhrasesBoard extends StatelessWidget {
  final void Function(String phrase) onPhraseSelected;

  const QuickPhrasesBoard({super.key, required this.onPhraseSelected});

  static const List<_PhraseGroup> _groups = [
    _PhraseGroup(
      label: 'Basics',
      icon: '👋',
      phrases: [
        'Hello',
        'Thank you',
        'Yes',
        'No',
        'Please',
        'Sorry',
        'Excuse me',
      ],
    ),
    _PhraseGroup(
      label: 'Needs',
      icon: '🙏',
      phrases: [
        'I need help',
        'I am deaf',
        'Please write it down',
        'Can you repeat that?',
        'Speak slowly please',
        'I don\'t understand',
        'Where is the bathroom?',
      ],
    ),
    _PhraseGroup(
      label: 'Emergency',
      icon: '🚨',
      phrases: [
        'Call an ambulance',
        'I need a doctor',
        'I am in danger',
        'Please call the police',
        'I am lost',
        'I have an allergy',
      ],
    ),
    _PhraseGroup(
      label: 'Daily',
      icon: '☀️',
      phrases: [
        'How much does this cost?',
        'Can I have the bill?',
        'Where is the exit?',
        'What time is it?',
        'I am waiting for someone',
        'Nice to meet you',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final group in _groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Row(
              children: [
                Text(group.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  group.label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.phrases.map((phrase) {
              return Semantics(
                button: true,
                label: 'Say: $phrase',
                child: Material(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onPhraseSelected(phrase);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Text(
                        phrase,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _PhraseGroup {
  final String label;
  final String icon;
  final List<String> phrases;
  const _PhraseGroup({
    required this.label,
    required this.icon,
    required this.phrases,
  });
}
