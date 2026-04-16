import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
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
  String _locationInfo = '';
  final TextEditingController _chatController = TextEditingController();
  // _chatMessages stores display strings for UI; _chatHistory tracks role-based
  // entries for /emergency-chat multi-turn threading.
  final List<String> _chatMessages = [];
  final List<Map<String, String>> _chatHistory = [];

  final List<Map<String, dynamic>> _emergencyTypes = [
    {
      'type': 'medical',
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
    {
      'type': 'natural_disaster',
      'icon': Icons.storm,
      'label': 'Disaster',
      'color': AppColors.textSecondary,
    },
    {
      'type': 'other',
      'icon': Icons.warning_rounded,
      'label': 'Other',
      'color': AppColors.textPrimary,
    },
  ];

  Future<Position?> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
      }
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission permanently denied. Enable in Settings.',
            ),
          ),
        );
      }
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> _sendEmergency() async {
    if (_selectedType == null) return;

    // Confirm before sending — prevents accidental taps.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Emergency'),
        content: Text(
          'Send a $_selectedType SOS alert with your current location?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSending = true);
    HapticFeedback.heavyImpact();

    // Vibrate for emergency feedback
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(pattern: [0, 300, 200, 300, 200, 300]);
    }

    // Get real GPS location
    double lat = 0.0;
    double lng = 0.0;
    try {
      final position = await _getLocation();
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
        _locationInfo =
            'Location: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      } else {
        _locationInfo = 'Location unavailable';
      }
    } catch (e) {
      _locationInfo = 'Location unavailable';
    }

    try {
      final result = await _api.emergencyMessage(
        latitude: lat,
        longitude: lng,
        emergencyType: _selectedType!,
      );

      setState(() {
        _emergencySent = true;
        _generatedMessage =
            result['message'] ?? 'Emergency help is on the way.';
        _isSending = false;
      });

      NotificationService().emergencyConfirm(_generatedMessage);
      await _tts.speak(_generatedMessage);
    } catch (e) {
      setState(() {
        _isSending = false;
        _emergencySent = true;
        _generatedMessage =
            'EMERGENCY: Deaf person needs $_selectedType assistance immediately. $_locationInfo';
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
    _chatHistory.add({'role': 'user', 'content': text});

    // Speak the user's message via TTS for the dispatcher to hear.
    _tts.speak(text);

    // Attempt operator reply via backend (async; failures are swallowed so
    // the emergency flow is never blocked by a backend error).
    _api
        .emergencyChat(
          text,
          context: _selectedType ?? '',
          history: List.from(_chatHistory),
        )
        .then((reply) {
          if (!mounted || reply.isEmpty) return;
          setState(() {
            _chatMessages.add('Operator: $reply');
          });
          _chatHistory.add({'role': 'assistant', 'content': reply});
          _tts.speak(reply);
        })
        .catchError((_) {
          // Backend offline — show a visible stub so the user knows the chat
          // relay is down, but the SOS flow is never blocked.
          if (!mounted) return;
          setState(() {
            _chatMessages.add('[Chat relay unavailable — call directly]');
          });
        });
  }

  Future<void> _dialEmergency() async {
    // Use the emergency number from ApiService settings (user-configurable)
    // Default: 112 (international standard, works in most countries)
    final emergencyNumber = ApiService().emergencyNumber;
    final uri = Uri(scheme: 'tel', path: emergencyNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open phone dialer')),
        );
      }
    }
  }

  void _reset() {
    setState(() {
      _selectedType = null;
      _isSending = false;
      _emergencySent = false;
      _generatedMessage = '';
      _chatMessages.clear();
      _chatHistory.clear();
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _tts.stop();
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
              tooltip: 'Reset emergency',
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
              child: const Icon(
                Icons.sos_rounded,
                size: 80,
                color: AppColors.danger,
              ),
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
            FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 16,
                runSpacing: 16,
                children: _emergencyTypes.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final type = entry.value;
                  final isSelected = _selectedType == type['type'];
                  return FocusTraversalOrder(
                    order: NumericFocusOrder(idx.toDouble()),
                    child: _PremiumEmergencyType(
                      label: type['label'] as String,
                      icon: type['icon'] as IconData,
                      color: type['color'] as Color,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedType = type['type'] as String);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: Semantics(
                button: true,
                label: 'Send SOS emergency alert',
                child: ElevatedButton(
                  onPressed: _selectedType != null && !_isSending
                      ? _sendEmergency
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
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
              ),
            ),
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
            border: Border.all(
              color: AppColors.danger.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 48,
              ),
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
              if (_locationInfo.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _locationInfo,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              // Direct emergency dial button
              Semantics(
                button: true,
                label: 'Call emergency services',
                hint: 'Dials your configured emergency number',
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _dialEmergency(),
                    icon: const Icon(Icons.phone, size: 20),
                    label: const Text(
                      'CALL EMERGENCY SERVICES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
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
                    (message) {
                      // Exact match against the single error string emitted by the
                      // emergency-chat catch block — avoids false positives for
                      // user messages like "[my location is X]".
                      const chatRelayError =
                          '[Chat relay unavailable — call directly]';
                      final isError = message == chatRelayError;
                      final isOperator = message.startsWith('Operator: ');
                      final isLeftAligned = isError || isOperator;
                      return Semantics(
                        label: isError
                            ? 'Error: ${message.replaceAll('[', '').replaceAll(']', '')}'
                            : isOperator
                                ? message
                                : 'You: $message',
                        child: Align(
                      alignment: isLeftAligned
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isError
                              ? AppColors.warning.withValues(alpha: 0.15)
                              : isOperator
                                  ? AppColors.surface
                                  : AppColors.primary,
                          border: isError
                              ? Border.all(color: AppColors.warning, width: 1.5)
                              : null,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isLeftAligned ? 6 : 20),
                            bottomRight: Radius.circular(isLeftAligned ? 20 : 6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isError) ...[
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.warning, size: 16),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: isError
                                      ? AppColors.warning
                                      : isOperator
                                          ? AppColors.textPrimary
                                          : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ), // Align
                    ); // Semantics
                    },
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
              Semantics(
                button: true,
                label: 'Send chat message',
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    onTap: _sendChatMessage,
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.send_rounded, color: Colors.white),
                    ),
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
    return Semantics(
      button: true,
      label: '$label emergency${isSelected ? ", selected" : ""}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
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
                  color: isSelected
                      ? Colors.transparent
                      : color.withValues(alpha: 0.2),
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
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
