import 'package:flutter_test/flutter_test.dart';
import 'package:ishara/services/api_exceptions.dart';

void main() {
  group('IsharaApiException hierarchy', () {
    test('ServerUnreachableException has default message', () {
      const e = ServerUnreachableException();
      expect(e.message, 'Cannot reach server');
      expect(e.statusCode, isNull);
      expect(e.toString(), contains('ServerUnreachableException'));
    });

    test('ServerUnreachableException accepts custom message', () {
      const e = ServerUnreachableException('Timeout connecting');
      expect(e.message, 'Timeout connecting');
    });

    test('ApiResponseException stores status code', () {
      const e = ApiResponseException('Not found', statusCode: 404);
      expect(e.message, 'Not found');
      expect(e.statusCode, 404);
      expect(e.toString(), contains('ApiResponseException'));
    });

    test('RetryExhaustedException wraps original error', () {
      final original = Exception('timeout');
      final e = RetryExhaustedException(original);
      expect(e.message, 'All retry attempts failed');
      expect(e.originalError, original);
      expect(e.toString(), contains('RetryExhaustedException'));
    });

    test('all exceptions are IsharaApiException', () {
      const e1 = ServerUnreachableException();
      const e2 = ApiResponseException('err', statusCode: 500);
      final e3 = RetryExhaustedException(StateError('x'));

      expect(e1, isA<IsharaApiException>());
      expect(e2, isA<IsharaApiException>());
      expect(e3, isA<IsharaApiException>());
    });

    test('sealed class prevents instantiation of base', () {
      // IsharaApiException is sealed — can only be constructed via subclasses.
      // Verify the three subclasses switch exhaustively.
      IsharaApiException e = const ServerUnreachableException();
      final result = switch (e) {
        ServerUnreachableException() => 'unreachable',
        ApiResponseException() => 'response',
        RetryExhaustedException() => 'retry',
      };
      expect(result, 'unreachable');
    });
  });
}
