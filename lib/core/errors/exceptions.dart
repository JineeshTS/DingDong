/// Base exception class
class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic originalException;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server exception
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'ServerException: $message (code: $code)';
}

/// Cache exception
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'CacheException: $message (code: $code)';
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'NetworkException: $message (code: $code)';
}

/// Authentication exception
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'AuthenticationException: $message (code: $code)';
}

/// Authorization exception
class AuthorizationException extends AppException {
  const AuthorizationException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'AuthorizationException: $message (code: $code)';
}

/// Validation exception
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    required super.message,
    this.errors,
    super.code,
    super.originalException,
  });

  @override
  String toString() =>
      'ValidationException: $message (code: $code, errors: $errors)';
}

/// Not found exception
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'NotFoundException: $message (code: $code)';
}

/// Permission exception
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'PermissionException: $message (code: $code)';
}

/// Database exception
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'DatabaseException: $message (code: $code)';
}

/// File system exception
class FileSystemException extends AppException {
  const FileSystemException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'FileSystemException: $message (code: $code)';
}

/// Sync exception
class SyncException extends AppException {
  const SyncException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'SyncException: $message (code: $code)';
}

/// Conflict exception (for sync conflicts)
class ConflictException extends AppException {
  final dynamic localData;
  final dynamic remoteData;

  const ConflictException({
    required super.message,
    this.localData,
    this.remoteData,
    super.code,
    super.originalException,
  });

  @override
  String toString() =>
      'ConflictException: $message (code: $code, local: $localData, remote: $remoteData)';
}
