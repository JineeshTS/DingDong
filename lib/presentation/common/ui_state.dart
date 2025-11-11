import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/errors/failures.dart';

part 'ui_state.freezed.dart';

/// Generic UI state for screens and widgets
///
/// Represents the overall state of a UI component:
/// - [idle]: No operation in progress
/// - [loading]: Operation in progress
/// - [success]: Operation succeeded
/// - [failure]: Operation failed
///
/// Can carry optional data and messages
@freezed
class UiState<T> with _$UiState<T> {
  const factory UiState.idle({T? data}) = _Idle<T>;

  const factory UiState.loading({
    T? data,
    String? message,
  }) = _Loading<T>;

  const factory UiState.success({
    required T data,
    String? message,
  }) = _Success<T>;

  const factory UiState.failure({
    required Failure failure,
    T? data,
  }) = _Failure<T>;

  const UiState._();

  /// Check if state is idle
  bool get isIdle => this is _Idle<T>;

  /// Check if state is loading
  bool get isLoading => this is _Loading<T>;

  /// Check if state is success
  bool get isSuccess => this is _Success<T>;

  /// Check if state is failure
  bool get isFailure => this is _Failure<T>;

  /// Get data or null
  T? get dataOrNull => maybeWhen(
        idle: (data) => data,
        loading: (data, _) => data,
        success: (data, _) => data,
        failure: (_, data) => data,
        orElse: () => null,
      );

  /// Get failure or null
  Failure? get failureOrNull => maybeWhen(
        failure: (failure, _) => failure,
        orElse: () => null,
      );

  /// Get message or null
  String? get messageOrNull => maybeWhen(
        loading: (_, message) => message,
        success: (_, message) => message,
        orElse: () => null,
      );
}
