import 'package:flutter_test/flutter_test.dart';
import 'package:ishara/models/chat_message.dart';

void main() {
  group('ChatMessage', () {
    test('creates with required fields and defaults', () {
      final msg = ChatMessage(text: 'Hello', sender: MessageSender.deaf);
      expect(msg.text, 'Hello');
      expect(msg.sender, MessageSender.deaf);
      expect(msg.isTranslating, false);
      expect(msg.timestamp, isNotNull);
    });

    test('accepts custom timestamp', () {
      final time = DateTime(2025, 1, 15);
      final msg = ChatMessage(
        text: 'Test',
        sender: MessageSender.hearing,
        timestamp: time,
      );
      expect(msg.timestamp, time);
    });

    test('supports translating state', () {
      final msg = ChatMessage(
        text: '',
        sender: MessageSender.system,
        isTranslating: true,
      );
      expect(msg.isTranslating, true);
      expect(msg.text, isEmpty);
    });

    test('supports all sender types', () {
      for (final sender in MessageSender.values) {
        final msg = ChatMessage(text: 'x', sender: sender);
        expect(msg.sender, sender);
      }
    });
  });

  group('MessageSender', () {
    test('has exactly three values', () {
      expect(MessageSender.values.length, 3);
    });

    test('contains expected values', () {
      expect(
        MessageSender.values,
        containsAll([
          MessageSender.deaf,
          MessageSender.hearing,
          MessageSender.system,
        ]),
      );
    });
  });
}
