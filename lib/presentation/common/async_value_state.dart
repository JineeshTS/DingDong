import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/errors/failures.dart';

part 'async_value_state.freezed.dart';

/// Generic state wrapper for async operations
///
/// Represents the current state of an asynchronous operation:
/// - [initial]: No operation has started yet
/// - [loading]: Operation is in progress
/// - [data]: Operation succeeded with data
/// - [error]: Operation failed with error
///
/// Example usage:
/// ```dart
/// AsyncValueState<List<Task>> tasksState = AsyncValueState.loading();
/// // ... after loading
/// tasksState = AsyncValueState.data(tasks);
/// ```
@freezed
class AsyncValueState<T> with _$AsyncValueState<T> {
  const factory AsyncValueState.initial() = _Initial<T>;
  const factory AsyncValueState.loading() = _Loading<T>;
  const factory AsyncValueState.data(T value) = _Data<T>;
  const factory AsyncValueState.error(Failure failure) = _Error<T>;

  const AsyncValueState._();

  /// Check if state is initial
  bool get isInitial => this is _Initial<T>;

  /// Check if state is loading
  bool get isLoading => this is _Loading<T>;

  /// Check if state has data
  bool get hasData => this is _Data<T>;

  /// Check if state has error
  bool get hasError => this is _Error<T>;

  /// Get data or null
  T? get dataOrNull => maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );

  /// Get error or null
  Failure? get errorOrNull => maybeWhen(
        error: (failure) => failure,
        orElse: () => null,
      );

  /// Map over the data value
  AsyncValueState<R> map<R>(R Function(T value) transform) {
    return maybeWhen(
      data: (value) => AsyncValueState.data(transform(value)),
      loading: () => AsyncValueState.loading(),
      error: (failure) => AsyncValueState.error(failure),
      orElse: () => AsyncValueState.initial(),
    );
  }

  /// Transform to a different type with error handling
  AsyncValueState<R> flatMap<R>(
    AsyncValueState<R> Function(T value) transform,
  ) {
    return maybeWhen(
      data: transform,
      loading: () => AsyncValueState.loading(),
      error: (failure) => AsyncValueState.error(failure),
      orElse: () => AsyncValueState.initial(),
    );
  }
}
