import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/list_entity.dart';

part 'list_state.freezed.dart';

/// List management state for the application
///
/// Manages the state of lists, including all user lists, favorites, shared lists,
/// and archived lists. This state is used by [ListNotifier] to track list-related operations.
///
/// States:
/// - [initial]: App just started, lists not yet loaded
/// - [loading]: List operation in progress
/// - [loaded]: Lists successfully loaded
/// - [error]: List operation failed
@freezed
class ListState with _$ListState {
  /// Initial state when lists haven't been loaded yet
  ///
  /// Used before fetching user's lists
  const factory ListState.initial() = _Initial;

  /// List operation in progress
  ///
  /// Preserves current lists during the operation and optionally shows a message
  const factory ListState.loading({
    @Default([]) List<ListEntity> lists,
    String? message,
  }) = _Loading;

  /// Lists successfully loaded
  ///
  /// Contains all lists for the current user
  const factory ListState.loaded({
    required List<ListEntity> lists,
  }) = _Loaded;

  /// List operation failed
  ///
  /// Contains the failure and preserves current lists
  const factory ListState.error({
    required Failure failure,
    @Default([]) List<ListEntity> lists,
  }) = _Error;

  const ListState._();

  /// Check if state is loading
  bool get isLoading => this is _Loading;

  /// Check if state has error
  bool get hasError => this is _Error;

  /// Check if state is initial
  bool get isInitial => this is _Initial;

  /// Check if lists are loaded
  bool get isLoaded => this is _Loaded;

  /// Get current lists or empty list
  List<ListEntity> get listsOrEmpty => maybeWhen(
        loading: (lists, _) => lists,
        loaded: (lists) => lists,
        error: (_, lists) => lists,
        orElse: () => [],
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

  /// Get non-archived lists
  List<ListEntity> get activeLists =>
      listsOrEmpty.where((list) => !list.isArchived && !list.isDeleted).toList();

  /// Get favorite lists
  List<ListEntity> get favoriteLists =>
      activeLists.where((list) => list.isFavorite).toList();

  /// Get shared lists
  List<ListEntity> get sharedLists =>
      activeLists.where((list) => list.isShared).toList();

  /// Get archived lists
  List<ListEntity> get archivedLists =>
      listsOrEmpty.where((list) => list.isArchived && !list.isDeleted).toList();

  /// Get personal lists (non-shared)
  List<ListEntity> get personalLists =>
      activeLists.where((list) => !list.isShared).toList();

  /// Get smart lists
  List<ListEntity> get smartLists =>
      activeLists.where((list) => list.isSmartList).toList();

  /// Get nested lists (lists with a parent)
  List<ListEntity> get nestedLists =>
      activeLists.where((list) => list.isNested).toList();

  /// Get top-level lists (no parent)
  List<ListEntity> get topLevelLists =>
      activeLists.where((list) => !list.isNested).toList();

  /// Find a list by ID
  ListEntity? findListById(String listId) {
    try {
      return listsOrEmpty.firstWhere((list) => list.id == listId);
    } catch (e) {
      return null;
    }
  }

  /// Get lists by workspace
  List<ListEntity> getListsByWorkspace(String workspaceId) =>
      activeLists.where((list) => list.workspaceId == workspaceId).toList();

  /// Get lists by parent
  List<ListEntity> getListsByParent(String parentListId) =>
      activeLists.where((list) => list.parentListId == parentListId).toList();

  /// Get total count of active lists
  int get activeListsCount => activeLists.length;

  /// Get total count of favorite lists
  int get favoriteListsCount => favoriteLists.length;

  /// Get total count of shared lists
  int get sharedListsCount => sharedLists.length;

  /// Get total count of archived lists
  int get archivedListsCount => archivedLists.length;
}
