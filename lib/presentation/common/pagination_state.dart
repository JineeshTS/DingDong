import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/errors/failures.dart';

part 'pagination_state.freezed.dart';

/// State for paginated lists
///
/// Manages pagination state including:
/// - Current page data
/// - Loading states (initial, refresh, load more)
/// - Error handling
/// - End of list detection
@freezed
class PaginationState<T> with _$PaginationState<T> {
  const factory PaginationState({
    @Default([]) List<T> items,
    @Default(false) bool isLoadingInitial,
    @Default(false) bool isLoadingMore,
    @Default(false) bool isRefreshing,
    @Default(false) bool hasReachedEnd,
    Failure? error,
    @Default(1) int currentPage,
    @Default(20) int pageSize,
  }) = _PaginationState<T>;

  const PaginationState._();

  /// Check if there's any loading operation
  bool get isLoading => isLoadingInitial || isLoadingMore || isRefreshing;

  /// Check if list is empty and not loading
  bool get isEmpty => items.isEmpty && !isLoading;

  /// Check if list has items
  bool get hasItems => items.isNotEmpty;

  /// Check if can load more items
  bool get canLoadMore => !hasReachedEnd && !isLoading;

  /// Total number of items
  int get itemCount => items.length;

  /// Add items to the list (for load more)
  PaginationState<T> addItems(List<T> newItems) {
    return copyWith(
      items: [...items, ...newItems],
      isLoadingMore: false,
      hasReachedEnd: newItems.length < pageSize,
      currentPage: currentPage + 1,
      error: null,
    );
  }

  /// Replace items (for refresh)
  PaginationState<T> replaceItems(List<T> newItems) {
    return copyWith(
      items: newItems,
      isRefreshing: false,
      isLoadingInitial: false,
      hasReachedEnd: newItems.length < pageSize,
      currentPage: 1,
      error: null,
    );
  }

  /// Update a single item
  PaginationState<T> updateItem(
    bool Function(T item) predicate,
    T Function(T item) update,
  ) {
    final updatedItems = items.map((item) {
      return predicate(item) ? update(item) : item;
    }).toList();

    return copyWith(items: updatedItems);
  }

  /// Remove an item
  PaginationState<T> removeItem(bool Function(T item) predicate) {
    return copyWith(
      items: items.where((item) => !predicate(item)).toList(),
    );
  }

  /// Add a single item at the beginning
  PaginationState<T> prependItem(T item) {
    return copyWith(items: [item, ...items]);
  }

  /// Set loading state
  PaginationState<T> setLoadingInitial() {
    return copyWith(
      isLoadingInitial: true,
      error: null,
    );
  }

  /// Set loading more state
  PaginationState<T> setLoadingMore() {
    return copyWith(
      isLoadingMore: true,
      error: null,
    );
  }

  /// Set refreshing state
  PaginationState<T> setRefreshing() {
    return copyWith(
      isRefreshing: true,
      error: null,
    );
  }

  /// Set error state
  PaginationState<T> setError(Failure failure) {
    return copyWith(
      error: failure,
      isLoadingInitial: false,
      isLoadingMore: false,
      isRefreshing: false,
    );
  }
}
