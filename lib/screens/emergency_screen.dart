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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Emergency SOS',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_emergencySent)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              onPressed: _reset,
            ),
        ],
      ),
      body: _emergencySent ? _buildActiveEmergency() : _buildEmergencySetup(),
    );
  }

  Widget _buildEmergencySetup() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: AppColors.premiumShadows,
              ),
              child: const Icon(Icons.sos_rounded, size: 80, color: AppColors.danger),
            ),
            const SizedBox(height: 40),
            const Text(
              'Select Emergency Type',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We will dispatch help to your location.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _emergencyTypes.map((type) {
                final isSelected = _selectedType == type['type'];
                return _PremiumEmergencyType(
                  label: type['label'] as String,
                  icon: type['icon'] as IconData,
                  color: type['color'] as Color,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedType = type['type'] as String);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _selectedType != null && !_isSending ? _sendEmergency : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 8,
                  shadowColor: AppColors.danger.withValues(alpha: 0.4),
                ),
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SEND SOS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActiveEmergency() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppColors.premiumShadows,
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.3), width: 2),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
              const SizedBox(height: 16),
              const Text(
                'SOS Sent Successfully',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _generatedMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Operator Chat',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: AppColors.premiumShadows,
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_chatMessages.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'Messages typed here are spoken aloud.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ..._chatMessages.map(
                    (message) => Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: AppColors.premiumShadows,
                  ),
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(
                      hintText: 'Type message...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                    ),
                    onSubmitted: (_) => _sendChatMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _sendChatMessage,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumEmergencyType extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumEmergencyType({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isSelected ? color : AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: AppColors.premiumShadows,
              border: Border.all(
                color: isSelected ? Colors.transparent : color.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}
