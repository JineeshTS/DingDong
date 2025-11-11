import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

/// Authentication state for the application
///
/// Manages the current authentication status, user data, and operation states.
/// This state is used by [AuthNotifier] to track authentication-related operations.
///
/// States:
/// - [initial]: App just started, auth status unknown
/// - [authenticated]: User is logged in
/// - [unauthenticated]: User is not logged in
/// - [loading]: Authentication operation in progress
/// - [error]: Authentication operation failed
@freezed
class AuthState with _$AuthState {
  /// Initial state when app starts
  ///
  /// Used before checking if user is already authenticated
  const factory AuthState.initial() = _Initial;

  /// User is authenticated
  ///
  /// Contains the current user entity
  const factory AuthState.authenticated({
    required UserEntity user,
  }) = _Authenticated;

  /// User is not authenticated
  ///
  /// User needs to sign in or sign up
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// Authentication operation in progress
  ///
  /// Can optionally contain the current user if this is an update operation
  /// (e.g., updating profile, changing password)
  const factory AuthState.loading({
    UserEntity? user,
    String? message,
  }) = _Loading;

  /// Authentication operation failed
  ///
  /// Contains the failure and optionally preserves the current user
  const factory AuthState.error({
    required Failure failure,
    UserEntity? user,
  }) = _Error;

  const AuthState._();

  /// Check if user is authenticated
  bool get isAuthenticated => this is _Authenticated;

  /// Check if state is loading
  bool get isLoading => this is _Loading;

  /// Check if state has error
  bool get hasError => this is _Error;

  /// Check if state is initial
  bool get isInitial => this is _Initial;

  /// Check if user is unauthenticated
  bool get isUnauthenticated => this is _Unauthenticated;

  /// Get current user or null
  UserEntity? get userOrNull => maybeWhen(
        authenticated: (user) => user,
        loading: (user, _) => user,
        error: (_, user) => user,
        orElse: () => null,
      );

  /// Get error or null
  Failure? get errorOrNull => maybeWhen(
        error: (failure, _) => failure,
        orElse: () => null,
      );

  /// Get loading message or null
  String? get loadingMessageOrNull => maybeWhen(
        loading: (_, message) => message,
        orElse: () => null,
      );
}
