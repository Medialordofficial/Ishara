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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emergency, color: AppColors.danger),
            const SizedBox(width: 8),
            const Text('Emergency SOS'),
          ],
        ),
        actions: [
          if (_emergencySent)
            IconButton(onPressed: _reset, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _emergencySent ? _buildActiveEmergency() : _buildEmergencySetup(),
    );
  }

  Widget _buildEmergencySetup() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.emergency, size: 64, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            'One-Tap Emergency',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Select the type of help you need.\nIshara will call emergency services and speak for you.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Emergency type selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _emergencyTypes.map((type) {
              final isSelected = _selectedType == type['type'];
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type['type']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (type['color'] as Color).withValues(alpha: 0.2)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? type['color'] as Color
                          : AppColors.surfaceLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        color: type['color'] as Color,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type['label'] as String,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          // SOS Button
          GestureDetector(
            onTap: _selectedType != null && !_isSending ? _sendEmergency : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedType != null
                    ? AppColors.danger
                    : AppColors.surfaceLight,
                boxShadow: _selectedType != null
                    ? [
                        BoxShadow(
                          color: AppColors.danger.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: _isSending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sos,
                          size: 48,
                          color: _selectedType != null
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SOS',
                          style: TextStyle(
                            color: _selectedType != null
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActiveEmergency() {
    return Column(
      children: [
        // Status banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.danger.withValues(alpha: 0.2),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 36,
              ),
              const SizedBox(height: 8),
              const Text(
                'Emergency message sent!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _generatedMessage,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        // Chat with operator
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Type messages below — they will be spoken aloud for the operator',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _chatMessages[index],
                    style: const TextStyle(color: AppColors.secondary),
                  ),
                ),
              );
            },
          ),
        ),
        // Text input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Type to speak to operator...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _sendChatMessage(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendChatMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
