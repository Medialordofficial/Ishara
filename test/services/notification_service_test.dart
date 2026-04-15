import 'package:flutter_test/flutter_test.dart';
import 'package:ishara/services/notification_service.dart';

void main() {
  group('NotificationService singleton', () {
    test('factory returns same instance', () {
      final a = NotificationService();
      final b = NotificationService();
      expect(identical(a, b), isTrue);
    });
  });
}
