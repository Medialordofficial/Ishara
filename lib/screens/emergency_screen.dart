import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../utils/constants.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final ApiService _api = ApiService();
  final TtsService _tts = TtsService();
  String? _selectedType;
  bool _isSending = false;
  bool _emergencySent = false;
  String _generatedMessage = '';
  final TextEditingController _chatController = TextEditingController();
  final List<String> _chatMessages = [];

  final List<Map<String, dynamic>> _emergencyTypes = [
    {
      'type': 'ambulance',
      'icon': Icons.local_hospital,
      'label': 'Medical',
      'color': AppColors.danger,
    },
    {
      'type': 'police',
      'icon': Icons.local_police,
      'label': 'Police',
      'color': AppColors.info,
    },
    {
      'type': 'fire',
      'icon': Icons.local_fire_department,
      'label': 'Fire',
      'color': AppColors.warning,
    },
  ];

  Future<void> _sendEmergency() async {
    if (_selectedType == null) return;

    setState(() => _isSending = true);
    HapticFeedback.heavyImpact();

    try {
      // TODO: Get actual GPS coordinates
      final result = await _api.emergencyMessage(
        latitude: 0.0,
        longitude: 0.0,
        emergencyType: _selectedType!,
      );

      setState(() {
        _emergencySent = true;
        _generatedMessage =
            result['message'] ?? 'Emergency help is on the way.';
        _isSending = false;
      });

      await _tts.speak(_generatedMessage);
    } catch (e) {
      setState(() {
        _isSending = false;
        _emergencySent = true;
        _generatedMessage =
            'This is an emergency call from a deaf person. Please send $_selectedType assistance immediately.';
      });
      await _tts.speak(_generatedMessage);
    }
  }

  void _sendChatMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.add(text);
      _chatController.clear();
    });

    // Speak the message for the operator
    _tts.speak(text);
  }

  void _reset() {
    setState(() {
      _selectedType = null;
      _isSending = false;
      _emergencySent = false;
      _generatedMessage = '';
      _chatMessages.clear();
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        actions: [
          if (_emergencySent)
            IconButton(onPressed: _reset, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _emergencySent ? _buildActiveEmergency() : _buildEmergencySetup(),
    );
  }

  Widget _buildEmergencySetup() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        _EmergencyHero(
          selectedType: _selectedType,
          isSending: _isSending,
          onTap: _selectedType != null && !_isSending ? _sendEmergency : null,
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
              Text(
                'Choose emergency type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Pick the type of help you need first. Ishara will generate a message and speak for you.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ..._emergencyTypes.map((type) {
                final isSelected = _selectedType == type['type'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EmergencyTypeCard(
                    label: type['label'] as String,
                    type: type['type'] as String,
                    icon: type['icon'] as IconData,
                    color: type['color'] as Color,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedType = type['type'] as String);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _selectedType != null && !_isSending
              ? _sendEmergency
              : null,
          icon: _isSending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.sos_rounded),
          label: Text(
            _isSending
                ? 'Sending emergency message...'
                : 'Send emergency message',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveEmergency() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9E7),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Emergency message sent',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _generatedMessage,
                      style: Theme.of(context).textTheme.bodyLarge,
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
                    Text(
                      'Operator chat',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Type here and Ishara will speak your message aloud for the operator.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    if (_chatMessages.isEmpty)
                      const _EmergencyEmptyState()
                    else
                      ..._chatMessages.map(
                        (message) => Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF2CC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              message,
                              style: const TextStyle(
                                color: AppColors.secondary,
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
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: const InputDecoration(
                    hintText: 'Type to speak to operator...',
                  ),
                  onSubmitted: (_) => _sendChatMessage(),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _sendChatMessage,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(18),
                ),
                child: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmergencyHero extends StatelessWidget {
  final String? selectedType;
  final bool isSending;
  final VoidCallback? onTap;

  const _EmergencyHero({
    required this.selectedType,
    required this.isSending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE7E4), Color(0xFFFFD0CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _EmergencyPill(),
          const SizedBox(height: 16),
          Text(
            'Fast help, without fighting the interface.',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the emergency type and Ishara prepares a spoken text message for responders immediately.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryLight),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onTap,
            icon: isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sos_rounded),
            label: Text(
              selectedType == null
                  ? 'Choose a type below'
                  : 'Send ${selectedType![0].toUpperCase()}${selectedType!.substring(1)} emergency',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyPill extends StatelessWidget {
  const _EmergencyPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high_rounded, size: 16, color: AppColors.danger),
          SizedBox(width: 8),
          Text(
            'Priority response',
            style: TextStyle(
              color: AppColors.danger,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyTypeCard extends StatelessWidget {
  final String label;
  final String type;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmergencyTypeCard({
    required this.label,
    required this.type,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : AppColors.background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to route your emergency message correctly.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_rounded,
              color: isSelected ? color : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyEmptyState extends StatelessWidget {
  const _EmergencyEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.forum_outlined,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No operator messages yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Your typed messages will appear here before being spoken aloud.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
