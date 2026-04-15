import 'package:flutter_test/flutter_test.dart';
import 'package:ishara/models/sound_alert.dart';

void main() {
  group('SoundAlert', () {
    test('creates with required fields and auto-timestamp', () {
      final alert = SoundAlert(
        label: 'Fire alarm',
        confidence: 0.95,
        level: AlertLevel.critical,
      );
      expect(alert.label, 'Fire alarm');
      expect(alert.confidence, 0.95);
      expect(alert.level, AlertLevel.critical);
      expect(alert.timestamp, isNotNull);
    });

    test('accepts custom timestamp', () {
      final time = DateTime(2025, 6, 15);
      final alert = SoundAlert(
        label: 'Doorbell',
        confidence: 0.8,
        level: AlertLevel.info,
        timestamp: time,
      );
      expect(alert.timestamp, time);
    });

    test('confidence can be zero', () {
      final alert = SoundAlert(
        label: 'Unknown',
        confidence: 0.0,
        level: AlertLevel.info,
      );
      expect(alert.confidence, 0.0);
    });

    test('confidence can be one', () {
      final alert = SoundAlert(
        label: 'Siren',
        confidence: 1.0,
        level: AlertLevel.critical,
      );
      expect(alert.confidence, 1.0);
    });
  });

  group('AlertLevel', () {
    test('has exactly three values', () {
      expect(AlertLevel.values.length, 3);
    });

    test('contains expected values', () {
      expect(
        AlertLevel.values,
        containsAll([AlertLevel.critical, AlertLevel.warning, AlertLevel.info]),
      );
    });
  });
}
