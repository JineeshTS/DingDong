import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/user_entity.dart';

part 'user_state.freezed.dart';

/// User management state for the application
///
/// Manages user data and user-related operations including:
/// - Profile management
/// - Preferences (theme, locale)
/// - Subscription management
/// - Security settings (biometric auth)
/// - Account status (active/deactivated)
/// - Data export
///
/// This state is used by [UserNotifier] to track user-related operations.
///
/// States:
/// - [initial]: Initial state, user data not yet loaded
/// - [loaded]: User data successfully loaded
/// - [loading]: User operation in progress
/// - [error]: User operation failed
/// - [dataExported]: User data export completed
@freezed
class UserState with _$UserState {
  /// Initial state when no user data is loaded
  ///
  /// Used before fetching user data
  const factory UserState.initial() = _Initial;

  /// User data successfully loaded
  ///
  /// Contains the current user entity
  const factory UserState.loaded({
    required UserEntity user,
  }) = _Loaded;

  /// User operation in progress
  ///
  /// Can optionally contain the current user to preserve state during updates
  const factory UserState.loading({
    UserEntity? user,
    String? message,
  }) = _Loading;

  /// User operation failed
  ///
  /// Contains the failure and optionally preserves the current user
  const factory UserState.error({
    required Failure failure,
    UserEntity? user,
  }) = _Error;

  /// User data export completed
  ///
  /// Contains the exported data as a map
  const factory UserState.dataExported({
    required Map<String, dynamic> data,
    required UserEntity user,
  }) = _DataExported;

  const UserState._();

  /// Check if user data is loaded
  bool get isLoaded => this is _Loaded;

  /// Check if state is loading
  bool get isLoading => this is _Loading;

  /// Check if state has error
  bool get hasError => this is _Error;

  /// Check if state is initial
  bool get isInitial => this is _Initial;

  /// Check if data was exported
  bool get isDataExported => this is _DataExported;

  /// Get current user or null
  UserEntity? get userOrNull => maybeWhen(
        loaded: (user) => user,
        loading: (user, _) => user,
        error: (_, user) => user,
        dataExported: (_, user) => user,
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

  /// Get exported data or null
  Map<String, dynamic>? get exportedDataOrNull => maybeWhen(
        dataExported: (data, _) => data,
        orElse: () => null,
      );
}
