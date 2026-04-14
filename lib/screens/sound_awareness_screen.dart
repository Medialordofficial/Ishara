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
      duration: const Duration(milliseconds: 1000),
    );
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      _pulseController.repeat(reverse: true);
      // TODO: Start audio capture and send to backend for classification
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _triggerAlert(SoundAlert alert) {
    setState(() {
      _alerts.insert(0, alert);
    });

    // Haptic feedback based on severity
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
    setState(() => _flashColor = color.withValues(alpha: 0.3));
    Future.delayed(const Duration(milliseconds: 500), () {
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
      appBar: AppBar(title: const Text('Sound Awareness')),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _flashColor,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _ListeningHero(
              isListening: _isListening,
              onToggle: _toggleListening,
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
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final pulseSize = _isListening
                          ? _pulseController.value * 30
                          : 0.0;
                      return Container(
                        width: 150 + pulseSize,
                        height: 150 + pulseSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening
                              ? AppColors.info.withValues(
                                  alpha: 0.08 + _pulseController.value * 0.08,
                                )
                              : AppColors.surfaceLight,
                          border: Border.all(
                            color: _isListening
                                ? AppColors.info.withValues(
                                    alpha: 0.5 + _pulseController.value * 0.3,
                                  )
                                : AppColors.border,
                            width: 2.5,
                          ),
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color: AppColors.info.withValues(
                                      alpha:
                                          0.18 + _pulseController.value * 0.1,
                                    ),
                                    blurRadius:
                                        28 + _pulseController.value * 16,
                                    spreadRadius: _pulseController.value * 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isListening
                              ? Icons.hearing_rounded
                              : Icons.hearing_disabled_rounded,
                          size: 52,
                          color: _isListening
                              ? AppColors.info
                              : AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isListening
                        ? 'Monitoring your environment'
                        : 'Listening is paused',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isListening
                        ? 'Critical sounds trigger vibration and a visible flash for faster awareness.'
                        : 'Start listening to detect alarms, knocks, and urgent sounds nearby.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
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
                    'Alert priority',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Expanded(
                        child: _LegendItem(
                          color: AppColors.danger,
                          label: 'Critical',
                          icon: '🔥',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _LegendItem(
                          color: AppColors.warning,
                          label: 'Warning',
                          icon: '⚠️',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _LegendItem(
                          color: AppColors.info,
                          label: 'Info',
                          icon: 'ℹ️',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Preview alert behavior',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _PreviewAlertChip(
                        label: 'Fire alarm',
                        color: AppColors.danger,
                        onTap: () => _triggerAlert(
                          SoundAlert(
                            label: 'Fire alarm',
                            confidence: 0.98,
                            level: AlertLevel.critical,
                          ),
                        ),
                      ),
                      _PreviewAlertChip(
                        label: 'Door knock',
                        color: AppColors.warning,
                        onTap: () => _triggerAlert(
                          SoundAlert(
                            label: 'Door knock',
                            confidence: 0.84,
                            level: AlertLevel.warning,
                          ),
                        ),
                      ),
                      _PreviewAlertChip(
                        label: 'Phone vibration',
                        color: AppColors.info,
                        onTap: () => _triggerAlert(
                          SoundAlert(
                            label: 'Phone vibration',
                            confidence: 0.73,
                            level: AlertLevel.info,
                          ),
                        ),
                      ),
                    ],
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
                  Row(
                    children: [
                      Text(
                        'Recent alerts',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      Text(
                        _alerts.isEmpty
                            ? 'Waiting'
                            : '${_alerts.length} logged',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_alerts.isEmpty)
                    const _ScreenEmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'No alerts yet',
                      subtitle:
                          'Detected sounds will appear here as a readable timeline.',
                    )
                  else
                    ..._alerts.map((alert) => _AlertCard(alert: alert)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String icon;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final SoundAlert alert;

  const _AlertCard({required this.alert});

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
        '${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}:${alert.timestamp.second.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.label,
                  style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${(alert.confidence * 100).toStringAsFixed(0)}% confidence',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListeningHero extends StatelessWidget {
  final bool isListening;
  final VoidCallback onToggle;

  const _ListeningHero({required this.isListening, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF3FF), Color(0xFFDCEAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroPill(
            label: 'Environmental monitoring',
            icon: Icons.graphic_eq_rounded,
            foreground: AppColors.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Stay aware even when the room changes first.',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Ishara watches for critical sounds and turns them into visible, tactile alerts you can trust.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryLight),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onToggle,
            icon: Icon(
              isListening
                  ? Icons.pause_circle_rounded
                  : Icons.play_circle_fill_rounded,
            ),
            label: Text(isListening ? 'Pause listening' : 'Start listening'),
            style: FilledButton.styleFrom(
              backgroundColor: isListening ? AppColors.danger : AppColors.info,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foreground;

  const _HeroPill({
    required this.label,
    required this.icon,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ScreenEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

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
          Icon(icon, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PreviewAlertChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PreviewAlertChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.2)),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
