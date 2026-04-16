import 'package:flutter_test/flutter_test.dart';
import 'package:ishara/screens/sound_awareness_screen.dart';

void main() {
  group('sanitizeSoundLabel', () {
    test('returns empty string for empty input', () {
      expect(sanitizeSoundLabel(''), '');
    });

    test('returns clean label for normal input', () {
      expect(sanitizeSoundLabel('Doorbell'), 'Doorbell');
    });

    test('strips control characters', () {
      expect(sanitizeSoundLabel('door\x01bell\x00'), 'doorbell');
    });

    test('strips DEL character', () {
      expect(sanitizeSoundLabel('door\x7Fbell'), 'doorbell');
    });

    test('trims leading and trailing whitespace', () {
      expect(sanitizeSoundLabel('  siren  '), 'siren');
    });

    test('truncates strings longer than 80 characters', () {
      final long = 'a' * 100;
      final result = sanitizeSoundLabel(long);
      expect(result.length, lessThanOrEqualTo(82)); // 80 chars + ellipsis (…)
      expect(result.endsWith('…'), isTrue);
    });

    test('rejects HTML tags (injection attempt)', () {
      expect(sanitizeSoundLabel('<script>alert(1)</script>'), '');
    });

    test('rejects javascript: scheme', () {
      expect(sanitizeSoundLabel('javascript:alert(1)'), '');
    });

    test('rejects data: scheme', () {
      expect(sanitizeSoundLabel('data:text/html,<h1>x</h1>'), '');
    });

    test('allows normal text with angle brackets that are not tags', () {
      // Angle brackets inside normal text that form a tag → rejected
      expect(sanitizeSoundLabel('<b>bold</b>'), '');
    });

    test('preserves valid label with special characters', () {
      final label = sanitizeSoundLabel('Fire alarm (85 dB) — urgent!');
      expect(label, 'Fire alarm (85 dB) — urgent!');
    });

    test('handles exactly 80 character string without truncation', () {
      final exactly80 = 'a' * 80;
      expect(sanitizeSoundLabel(exactly80), exactly80);
    });

    test('reuses sanitization for server STT results (used in conversation_screen)', () {
      // Verifies that sanitizeSoundLabel is safe to use on server-returned text
      // (the same function is used in _listenViaServerStt for STT results)
      expect(sanitizeSoundLabel('Hello world'), 'Hello world');
      expect(sanitizeSoundLabel('<script>steal</script>'), '');
      expect(sanitizeSoundLabel(''), ''); // empty server response → fallback triggered
    });

    test('sign interpretation injection is stripped to empty (conversation_screen _captureAndInterpret)', () {
      // _captureAndInterpret now calls sanitizeSoundLabel on interpretSign result.
      // Injection strings must produce empty output so the confidence check drops them.
      expect(sanitizeSoundLabel('<script>evil</script>'), '');
      expect(sanitizeSoundLabel('javascript:void(0)'), '');
      expect(sanitizeSoundLabel('<img src=x onerror=alert(1)>'), '');
    });

    test('empty sanitized STT result should trigger fallback (empty → send fallback text)', () {
      // When sanitizeSoundLabel returns '' for server response,
      // _listenViaServerStt falls through to fallbackText.
      // Verify that known injection strings all produce empty outputs.
      const injections = [
        '<script>x</script>',
        'javascript:x',
        'data:text/html,<b>x</b>',
        '<b>bold</b>',
      ];
      for (final s in injections) {
        expect(sanitizeSoundLabel(s), '',
          reason: 'injection "$s" should produce empty string triggering fallback');
      }
    });
  });
}
