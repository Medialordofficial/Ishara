import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sound_alert.dart';
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

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      _pulseController.repeat(reverse: false);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _triggerAlert(SoundAlert alert) {
    setState(() {
      _alerts.insert(0, alert);
    });

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
              const SizedBox(height: 50),
              _buildAlertTests(),
              const SizedBox(height: 40),
              _buildRecentAlerts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumListeningToggle() {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = _isListening ? 1.0 + (_pulseController.value * 0.15) : 1.0;
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
                    color: _isListening ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isListening ? Icons.hearing : Icons.hearing_disabled,
                      size: 64,
                      color: _isListening ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isListening ? 'Listening...' : 'Tap to Listen',
                      style: TextStyle(
                        color: _isListening ? AppColors.primary : AppColors.textSecondary,
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
                onTap: () => _triggerAlert(
                  SoundAlert(label: 'Fire Alarm', confidence: 0.98, level: AlertLevel.critical),
                ),
              ),
              _PremiumTestButton(
                icon: Icons.doorbell,
                color: AppColors.warning,
                onTap: () => _triggerAlert(
                  SoundAlert(label: 'Door Knock', confidence: 0.84, level: AlertLevel.warning),
                ),
              ),
              _PremiumTestButton(
                icon: Icons.vibration,
                color: AppColors.info,
                onTap: () => _triggerAlert(
                  SoundAlert(label: 'Phone Vibration', confidence: 0.73, level: AlertLevel.info),
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
        const Text(
          'Recent Activity',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
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

  const _PremiumTestButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}

class _PremiumAlertCard extends StatelessWidget {
  final SoundAlert alert;

  const _PremiumAlertCard({required this.alert});

  Color get _color {
    switch (alert.level) {
      case AlertLevel.critical: return AppColors.danger;
      case AlertLevel.warning: return AppColors.warning;
      case AlertLevel.info: return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = '${alert.timestamp.hour.toString().padLeft(2,'0')}:${alert.timestamp.minute.toString().padLeft(2,'0')}';
    return Container(
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
    );
  }
}
