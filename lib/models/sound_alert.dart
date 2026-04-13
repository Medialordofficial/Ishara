class SoundAlert {
  final String label;
  final double confidence;
  final DateTime timestamp;
  final AlertLevel level;

  SoundAlert({
    required this.label,
    required this.confidence,
    required this.level,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum AlertLevel { critical, warning, info }
