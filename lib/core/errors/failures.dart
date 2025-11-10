import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  final int? code;
  final dynamic exception;

  const Failure({
    required this.message,
    this.code,
    this.exception,
  });

  @override
  List<Object?> get props => [message, code, exception];
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Authentication failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Authorization failure
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Validation failure
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    required super.message,
    this.errors,
    super.code,
    super.exception,
  });

  @override
  List<Object?> get props => [message, code, exception, errors];
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Database failure
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// File system failure
class FileSystemFailure extends Failure {
  const FileSystemFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Sync failure
class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Conflict failure (for sync conflicts)
class ConflictFailure extends Failure {
  final dynamic localData;
  final dynamic remoteData;

  const ConflictFailure({
    required super.message,
    this.localData,
    this.remoteData,
    super.code,
    super.exception,
  });

  @override
  List<Object?> get props => [
        message,
        code,
        exception,
        localData,
        remoteData,
      ];
}
