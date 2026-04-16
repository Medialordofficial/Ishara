import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sound_alert.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class SoundAwarenessScreen extends StatefulWidget {
  const SoundAwarenessScreen({super.key});

  @override
  State<SoundAwarenessScreen> createState() => _SoundAwarenessScreenState();
}

class _SoundAwarenessScreenState extends State<SoundAwarenessScreen>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  final List<SoundAlert> _alerts = [];
  Color _flashColor = Colors.transparent;
  late AnimationController _pulseController;

  final NoiseMeter _noiseMeter = NoiseMeter();
  StreamSubscription<NoiseReading>? _noiseSubscription;
  final ApiService _api = ApiService();

  double _currentDecibel = 0.0;
  double _peakDecibel = 0.0;

  static const double _warningThreshold = SoundThresholds.warning;
  static const double _criticalThreshold = SoundThresholds.critical;
  DateTime? _lastAlertTime;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Microphone permission is required for sound awareness',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _isListening = true);
    _pulseController.repeat(reverse: false);

    _noiseSubscription = _noiseMeter.noise.listen(
      (NoiseReading reading) {
        if (!mounted) return;
        setState(() {
          _currentDecibel = reading.meanDecibel.clamp(0.0, 130.0);
          if (_currentDecibel > _peakDecibel) _peakDecibel = _currentDecibel;
        });
        _evaluateNoise(reading);
      },
      onError: (Object error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Mic error: $error')));
          _stopListening();
        }
      },
    );
  }

  void _stopListening() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _isListening = false;
      _currentDecibel = 0;
    });
  }

  void _evaluateNoise(NoiseReading reading) {
    final now = DateTime.now();
    if (_lastAlertTime != null &&
        now.difference(_lastAlertTime!).inSeconds < 3) {
      return;
    }

    final db = reading.maxDecibel.clamp(0.0, 130.0);

    if (db >= _criticalThreshold) {
      _lastAlertTime = now;
      _triggerAlert(
        SoundAlert(
          label: 'Loud Sound Detected (${db.toInt()} dB)',
          confidence: (db / 130).clamp(0.0, 1.0),
          level: AlertLevel.critical,
        ),
      );
      _classifyViaBackend(db);
    } else if (db >= _warningThreshold) {
      _lastAlertTime = now;
      _triggerAlert(
        SoundAlert(
          label: 'Elevated Sound (${db.toInt()} dB)',
          confidence: (db / 130).clamp(0.0, 1.0),
          level: AlertLevel.warning,
        ),
      );
    }
  }

  Future<void> _classifyViaBackend(double db) async {
    try {
      // Use actual meanDecibel (_currentDecibel) as the noise floor proxy —
      // it reflects ambient level and avoids the fabricated db-20 constant.
      final noiseFloor = _currentDecibel;
      final description = 'Sudden sound event: '
          'peak ${db.toInt()} dB, '
          'noise floor ~${noiseFloor.toInt()} dB, '
          'duration approximately 1–3 seconds. '
          'Classify the most likely real-world sound source.';
      final result = await _api.classifySound(description);
      final rawLabel = result['label'] ?? result['sound'] ?? '';
      // Sanitize LLM output before announcing to users.
      final label = _safeSoundLabel(rawLabel);
      if (label.isNotEmpty && mounted) {
        // Update the existing alert label in-place to avoid a duplicate
        // screen-reader announcement and second notification for the same event.
        _updateLastAlertLabel(label);
      }
    } catch (_) {
      // Backend unavailable — local alert already triggered
    }
  }

  /// Sanitize LLM-returned sound labels: strip control characters, truncate, and
  /// reject any token that looks like an injection attempt.
  String _safeSoundLabel(String raw) {
    if (raw.isEmpty) return '';
    // Strip all control chars and leading/trailing whitespace.
    var clean = raw.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '').trim();
    // Truncate to a safe display length.
    if (clean.length > 80) clean = '${clean.substring(0, 80)}…';
    // Reject if it contains code-injection patterns.
    if (RegExp(r'<[^>]+>|javascript:|data:', caseSensitive: false)
        .hasMatch(clean)) {
      return '';
    }
    return clean;
  }

  void _updateLastAlertLabel(String label) {
    if (_alerts.isEmpty) return;
    setState(() {
      _alerts[0] = SoundAlert(
        label: label,
        confidence: _alerts[0].confidence,
        level: _alerts[0].level,
      );
    });
    // Re-announce the refined label to screen readers.
    // ignore: deprecated_member_use
    SemanticsService.announce(
      'Sound identified: $label',
      TextDirection.ltr,
      assertiveness: Assertiveness.assertive,
    );
  }

  void _triggerAlert(SoundAlert alert) {
    setState(() {
      _alerts.insert(0, alert);
      if (_alerts.length > 50) _alerts.removeLast();
    });

    // Announce to screen readers via live region
    // ignore: deprecated_member_use
    SemanticsService.announce(
      '${alert.level.name} alert: ${alert.label}',
      TextDirection.ltr,
      assertiveness: Assertiveness.assertive,
    );

    NotificationService().soundAlert(alert.label);

    switch (alert.level) {
      case AlertLevel.critical:
        HapticFeedback.heavyImpact();
        _flashScreen(AppColors.danger);
        break;
      case AlertLevel.warning:
        HapticFeedback.mediumImpact();
        _flashScreen(AppColors.warning);
        break;
      case AlertLevel.info:
        HapticFeedback.lightImpact();
        _flashScreen(AppColors.info);
        break;
    }
  }

  void _flashScreen(Color color) {
    setState(() => _flashColor = color.withValues(alpha: 0.15));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _flashColor = Colors.transparent);
    });
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sound Awareness',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: _flashColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPremiumListeningToggle(),
              if (_isListening) ...[
                const SizedBox(height: 30),
                _buildDecibelMeter(),
              ],
              const SizedBox(height: 40),
              _buildAlertTests(),
              const SizedBox(height: 40),
              _buildRecentAlerts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecibelMeter() {
    Color levelColor = AppColors.success;
    String levelLabel = 'Quiet';
    if (_currentDecibel >= _criticalThreshold) {
      levelColor = AppColors.danger;
      levelLabel = 'LOUD';
    } else if (_currentDecibel >= _warningThreshold) {
      levelColor = AppColors.warning;
      levelLabel = 'Moderate';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppColors.premiumShadows,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                levelLabel,
                style: TextStyle(
                  color: levelColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Peak: ${_peakDecibel.toInt()} dB',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Semantics(
              label: 'Sound level: ${_currentDecibel.toInt()} decibels',
              child: LinearProgressIndicator(
                value: (_currentDecibel / 130).clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: AppColors.secondary,
                valueColor: AlwaysStoppedAnimation<Color>(levelColor),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${_currentDecibel.toInt()} dB',
            style: TextStyle(
              color: levelColor,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumListeningToggle() {
    return Semantics(
      button: true,
      label: _isListening
          ? 'Stop listening for sounds'
          : 'Start listening for sounds',
      child: InkWell(
        onTap: _toggleListening,
        borderRadius: BorderRadius.circular(90),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = _isListening
                ? 1.0 + (_pulseController.value * 0.15)
                : 1.0;
            final opacity = _isListening ? 1.0 - _pulseController.value : 0.0;

            return Stack(
              alignment: Alignment.center,
              children: [
                if (_isListening)
                  Container(
                    width: 220 * scale,
                    height: 220 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: opacity * 0.2),
                    ),
                  ),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.premiumShadows,
                    border: Border.all(
                      color: _isListening
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isListening ? Icons.hearing : Icons.hearing_disabled,
                        size: 64,
                        color: _isListening
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isListening ? 'Listening...' : 'Tap to Listen',
                        style: TextStyle(
                          color: _isListening
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlertTests() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppColors.premiumShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Test Alerts',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PremiumTestButton(
                icon: Icons.local_fire_department,
                color: AppColors.danger,
                alertLabel: 'fire alarm',
                onTap: () => _triggerAlert(
                  SoundAlert(
                    label: 'Fire Alarm',
                    confidence: 0.98,
                    level: AlertLevel.critical,
                  ),
                ),
              ),
              _PremiumTestButton(
                icon: Icons.doorbell,
                color: AppColors.warning,
                alertLabel: 'door knock',
                onTap: () => _triggerAlert(
                  SoundAlert(
                    label: 'Door Knock',
                    confidence: 0.84,
                    level: AlertLevel.warning,
                  ),
                ),
              ),
              _PremiumTestButton(
                icon: Icons.vibration,
                color: AppColors.info,
                alertLabel: 'phone vibration',
                onTap: () => _triggerAlert(
                  SoundAlert(
                    label: 'Phone Vibration',
                    confidence: 0.73,
                    level: AlertLevel.info,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (_alerts.isNotEmpty)
              Semantics(
                button: true,
                label: 'Clear all alerts',
                child: InkWell(
                  onTap: () => setState(() {
                    _alerts.clear();
                    _peakDecibel = 0;
                  }),
                  borderRadius: BorderRadius.circular(8),
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_alerts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: AppColors.premiumShadows,
            ),
            child: const Column(
              children: [
                Icon(Icons.history, size: 48, color: AppColors.textSecondary),
                SizedBox(height: 16),
                Text(
                  'No sounds detected yet.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _alerts.length,
            itemBuilder: (context, index) {
              final alert = _alerts[index];
              return _PremiumAlertCard(alert: alert);
            },
          ),
      ],
    );
  }
}

class _PremiumTestButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String alertLabel;

  const _PremiumTestButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.alertLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Test $alertLabel alert',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}

class _PremiumAlertCard extends StatelessWidget {
  final SoundAlert alert;

  const _PremiumAlertCard({required this.alert});

  Color get _color {
    switch (alert.level) {
      case AlertLevel.critical:
        return AppColors.danger;
      case AlertLevel.warning:
        return AppColors.warning;
      case AlertLevel.info:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time =
        '${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}';
    return Semantics(
      label:
          '${alert.level.name} alert: ${alert.label}, ${(alert.confidence * 100).toInt()} percent confidence at $time',
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.premiumShadows,
          border: Border.all(color: _color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_active, color: _color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.label,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(alert.confidence * 100).toInt()}% Confidence',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
