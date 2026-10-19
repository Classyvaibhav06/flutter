class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'No internet connection. Please check your network.',
  });

  @override
  String toString() => 'NetworkException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({
    this.message = 'Your session has expired. Please sign in again.',
  });

  @override
  String toString() => 'UnauthorizedException: $message';
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException({
    this.message = 'The requested resource was not found (404).',
  });

  @override
  String toString() => 'NotFoundException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({
    this.message = 'Failed to read or write local cache.',
  });
}
