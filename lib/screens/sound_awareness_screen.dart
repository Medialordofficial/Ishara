import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hearing, color: AppColors.info),
            const SizedBox(width: 8),
            const Text('Sound Awareness'),
          ],
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _flashColor,
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Status indicator with outer glow ring
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final pulseSize = _isListening
                    ? _pulseController.value * 30
                    : 0.0;
                return Container(
                  width: 140 + pulseSize,
                  height: 140 + pulseSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? AppColors.info.withValues(
                            alpha: 0.08 + _pulseController.value * 0.08,
                          )
                        : AppColors.surfaceLight.withValues(alpha: 0.5),
                    border: Border.all(
                      color: _isListening
                          ? AppColors.info.withValues(
                              alpha: 0.4 + _pulseController.value * 0.4,
                            )
                          : AppColors.surfaceLight,
                      width: 2.5,
                    ),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: AppColors.info.withValues(
                                alpha: 0.15 + _pulseController.value * 0.1,
                              ),
                              blurRadius: 24 + _pulseController.value * 16,
                              spreadRadius: _pulseController.value * 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _isListening ? Icons.hearing : Icons.hearing_disabled,
                    size: 48,
                    color: _isListening
                        ? AppColors.info
                        : AppColors.textSecondary,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              _isListening ? 'Listening for sounds...' : 'Sound Awareness Off',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              _isListening
                  ? 'You will be alerted via vibration and visual flash'
                  : 'Tap below to start monitoring environmental sounds',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Toggle button
            ElevatedButton.icon(
              onPressed: _toggleListening,
              icon: Icon(_isListening ? Icons.stop : Icons.play_arrow),
              label: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening
                    ? AppColors.danger
                    : AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Alert legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _LegendItem(
                    color: AppColors.danger,
                    label: 'Critical',
                    icon: '🔥',
                  ),
                  _LegendItem(
                    color: AppColors.warning,
                    label: 'Warning',
                    icon: '⚠️',
                  ),
                  _LegendItem(color: AppColors.info, label: 'Info', icon: 'ℹ️'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.surfaceLight),
            // Alert history
            Expanded(
              child: _alerts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No alerts yet',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Detected sounds will appear here',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _alerts.length,
                      itemBuilder: (context, index) {
                        return _AlertCard(alert: _alerts[index]);
                      },
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
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
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
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
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
