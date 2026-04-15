/// Custom exception hierarchy for clearer error handling in ApiService.
sealed class IsharaApiException implements Exception {
  final String message;
  final int? statusCode;
  const IsharaApiException(this.message, {this.statusCode});

  @override
  String toString() => '$runtimeType: $message';
}

/// Server is unreachable (network timeout, no connection).
class ServerUnreachableException extends IsharaApiException {
  const ServerUnreachableException([super.message = 'Cannot reach server']);
}

/// Server returned a non-200 HTTP status.
class ApiResponseException extends IsharaApiException {
  const ApiResponseException(super.message, {required super.statusCode});
}

/// All retry attempts exhausted for a transient failure.
class RetryExhaustedException extends IsharaApiException {
  final Object originalError;
  const RetryExhaustedException(this.originalError)
    : super('All retry attempts failed');
}
