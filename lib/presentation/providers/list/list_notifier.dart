import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/list_entity.dart';
import '../../../domain/usecases/list/archive_list_usecase.dart';
import '../../../domain/usecases/list/create_list_usecase.dart';
import '../../../domain/usecases/list/delete_list_usecase.dart';
import '../../../domain/usecases/list/get_favorite_lists_usecase.dart';
import '../../../domain/usecases/list/get_lists_usecase.dart';
import '../../../domain/usecases/list/get_shared_lists_usecase.dart';
import '../../../domain/usecases/list/share_list_usecase.dart';
import '../../../domain/usecases/list/toggle_favorite_list_usecase.dart';
import '../../../domain/usecases/list/unarchive_list_usecase.dart';
import '../../../domain/usecases/list/update_list_usecase.dart';
import 'list_state.dart';

/// StateNotifier for managing list state
///
/// Handles all list-related operations including:
/// - Creating and updating lists
/// - Deleting lists (soft delete)
/// - Managing favorites
/// - Archiving and unarchiving
/// - Sharing lists with other users
/// - Fetching different list views (all, favorites, shared)
///
/// This notifier integrates with all 10 list use cases
/// and manages the ListState throughout the application lifecycle.
class ListNotifier extends StateNotifier<ListState> {
  final CreateListUseCase _createListUseCase;
  final UpdateListUseCase _updateListUseCase;
  final DeleteListUseCase _deleteListUseCase;
  final GetListsUseCase _getListsUseCase;
  final ToggleFavoriteListUseCase _toggleFavoriteListUseCase;
  final ArchiveListUseCase _archiveListUseCase;
  final UnarchiveListUseCase _unarchiveListUseCase;
  final ShareListUseCase _shareListUseCase;
  final GetFavoriteListsUseCase _getFavoriteListsUseCase;
  final GetSharedListsUseCase _getSharedListsUseCase;

  ListNotifier({
    required CreateListUseCase createListUseCase,
    required UpdateListUseCase updateListUseCase,
    required DeleteListUseCase deleteListUseCase,
    required GetListsUseCase getListsUseCase,
    required ToggleFavoriteListUseCase toggleFavoriteListUseCase,
    required ArchiveListUseCase archiveListUseCase,
    required UnarchiveListUseCase unarchiveListUseCase,
    required ShareListUseCase shareListUseCase,
    required GetFavoriteListsUseCase getFavoriteListsUseCase,
    required GetSharedListsUseCase getSharedListsUseCase,
  })  : _createListUseCase = createListUseCase,
        _updateListUseCase = updateListUseCase,
        _deleteListUseCase = deleteListUseCase,
        _getListsUseCase = getListsUseCase,
        _toggleFavoriteListUseCase = toggleFavoriteListUseCase,
        _archiveListUseCase = archiveListUseCase,
        _unarchiveListUseCase = unarchiveListUseCase,
        _shareListUseCase = shareListUseCase,
        _getFavoriteListsUseCase = getFavoriteListsUseCase,
        _getSharedListsUseCase = getSharedListsUseCase,
        super(const ListState.initial());

  /// Load all lists for a user
  ///
  /// Parameters:
  /// - [userId]: The ID of the user whose lists to load
  /// - [includeArchived]: Whether to include archived lists (default: false)
  /// - [includeDeleted]: Whether to include deleted lists (default: false)
  Future<void> loadLists({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    state = ListState.loading(
      lists: state.listsOrEmpty,
      message: 'Loading lists...',
    );

    final result = await _getListsUseCase(
      userId: userId,
      includeArchived: includeArchived,
      includeDeleted: includeDeleted,
    );

    result.fold(
      (failure) => state = ListState.error(
        failure: failure,
        lists: state.listsOrEmpty,
      ),
      (lists) => state = ListState.loaded(lists: lists),
    );
  }

  /// Create a new list
  ///
  /// Parameters:
  /// - [list]: The list entity to create
  ///
  /// Returns: The created list or null if creation failed
  Future<ListEntity?> createList(ListEntity list) async {
    final currentLists = state.listsOrEmpty;

    state = ListState.loading(
      lists: currentLists,
      message: 'Creating list...',
    );

    final result = await _createListUseCase(list);

    return result.fold(
      (failure) {
        state = ListState.error(
          failure: failure,
          lists: currentLists,
        );
        return null;
      },
      (createdList) {
        final updatedLists = [...currentLists, createdList];
        state = ListState.loaded(lists: updatedLists);
        return createdList;
      },
    );
  }

  /// Update an existing list
  ///
  /// Parameters:
  /// - [list]: The updated list entity
  ///
  /// Returns: The updated list or null if update failed
  Future<ListEntity?> updateList(ListEntity list) async {
    final currentLists = state.listsOrEmpty;

    state = ListState.loading(
      lists: currentLists,
      message: 'Updating list...',
    );

    final result = await _updateListUseCase(list);

    return result.fold(
      (failure) {
        state = ListState.error(
          failure: failure,
          lists: currentLists,
        );
        return null;
      },
      (updatedList) {
        final updatedLists = currentLists.map((l) {
          return l.id == updatedList.id ? updatedList : l;
        }).toList();
        state = ListState.loaded(lists: updatedLists);
        return updatedList;
      },
    );
  }

  /// Delete a list (soft delete)
  ///
  /// Parameters:
  /// - [listId]: The ID of the list to delete
  ///
  /// Returns: true if deletion was successful, false otherwise
  Future<bool> deleteList(String listId) async {
    final currentLists = state.listsOrEmpty;

    state = ListState.loading(
      lists: currentLists,
      message: 'Deleting list...',
    );

    final result = await _deleteListUseCase(listId);

    return result.fold(
      (failure) {
        state = ListState.error(
          failure: failure,
          lists: currentLists,
        );
        return false;
      },
      (_) {
        // Remove the deleted list from state
        final updatedLists = currentLists
            .where((list) => list.id != listId)
            .toList();
        state = ListState.loaded(lists: updatedLists);
        return true;
      },
    );
  }

  /// Toggle favorite status of a list
  ///
  /// Parameters:
  /// - [listId]: The ID of the list to toggle
  ///
  /// Returns: The updated list or null if toggle failed
  Future<ListEntity?> toggleFavorite(String listId) async {
    final currentLists = state.listsOrEmpty;

    state = ListState.loading(
      lists: currentLists,
      message: 'Updating favorite status...',
    );

    final result = await _toggleFavoriteListUseCase(listId);

    return result.fold(
      (failure) {
        state = ListState.error(
          failure: failure,
          lists: currentLists,
        );
        return null;
      },
      (updatedList) {
        final updatedLists = currentLists.map((l) {
          return l.id == updatedList.id ? updatedList : l;
        }).toList();
        state = ListState.loaded(lists: updatedLists);
        return updatedList;
      },
    );
  }

  /// Archive a list
  ///
  /// Parameters:
  /// - [listId]: The ID of the list to archive
  ///
  /// Returns: The archived list or null if archiving failed
  Future<ListEntity?> archiveList(String listId) async {
    final currentLists = state.listsOrEmpty;

    state = ListState.loading(
      lists: currentLists,
      message: 'Archiving list...',
    );

    final result = await _archiveListUseCase(listId);

    return result.fold(
      (failure) {
        state = ListState.error(
          failure: failure,
          lists: currentLists,
        );
        return null;
      },
      (archivedList) {
        final updatedLists = currentLists.map((l) {
          return l.id == archivedList.id ? archivedList : l;
        }).toList();
        state = ListState.loaded(lists: updatedLists);
        return archivedList;
      },
    );
  }

  /// Unarchive a list
  ///
  /// Parameters:
  /// - [listId]: The ID of the list to unarchive
  ///
  /// Returns: The unarchived list or null if unarchiving failed
  Future<ListEntity?> unarchiveList(String listId) async {
    final currentLists = state.listsOrEmpty;

    state = ListState.loading(
      lists: currentLists,
      message: 'Unarchiving list...',
    );

    final result = await _unarchiveListUseCase(listId);

    return result.fold(
      (failure) {
        state = ListState.error(
          failure: failure,
          lists: currentLists,
        );
        return null;
      },
      (unarchivedList) {
        final updatedLists = currentLists.map((l) {
          return l.id == unarchivedList.id ? unarchivedList : l;
        }).toList();
        state = ListState.loaded(lists: updatedLists);
        return unarchivedList;
      },
    );
  }

  /// Share a list with other users
  ///
  /// Parameters:
  /// - [listId]: The ID of the list to share
  /// - [userIds]: List of user IDs to share with
  /// - [permission]: The permission level to grant
  ///
  /// Returns: The updated list with share settings or null if sharing failed
  Future<ListEntity?> shareList({
    required String listId,
    required List<String> userIds,
    required ListPermission permission,
  }) async {
    final currentLists = state.listsOrEmpty;

    state = ListState.loading(
      lists: currentLists,
      message: 'Sharing list...',
    );

    final result = await _shareListUseCase(
      listId: listId,
      userIds: userIds,
      permission: permission,
    );

    return result.fold(
      (failure) {
        state = ListState.error(
          failure: failure,
          lists: currentLists,
        );
        return null;
      },
      (sharedList) {
        final updatedLists = currentLists.map((l) {
          return l.id == sharedList.id ? sharedList : l;
        }).toList();
        state = ListState.loaded(lists: updatedLists);
        return sharedList;
      },
    );
  }

  /// Load favorite lists for a user
  ///
  /// Parameters:
  /// - [userId]: The ID of the user whose favorite lists to load
  Future<void> loadFavoriteLists(String userId) async {
    state = ListState.loading(
      lists: state.listsOrEmpty,
      message: 'Loading favorite lists...',
    );

    final result = await _getFavoriteListsUseCase(userId);

    result.fold(
      (failure) => state = ListState.error(
        failure: failure,
        lists: state.listsOrEmpty,
      ),
      (favoriteLists) {
        // Merge with existing lists, replacing duplicates
        final currentLists = state.listsOrEmpty;
        final favoriteIds = favoriteLists.map((l) => l.id).toSet();
        final nonFavoriteLists = currentLists
            .where((l) => !favoriteIds.contains(l.id))
            .toList();
        final mergedLists = [...nonFavoriteLists, ...favoriteLists];
        state = ListState.loaded(lists: mergedLists);
      },
    );
  }

  /// Load shared lists for a user
  ///
  /// Parameters:
  /// - [userId]: The ID of the user whose shared lists to load
  Future<void> loadSharedLists(String userId) async {
    state = ListState.loading(
      lists: state.listsOrEmpty,
      message: 'Loading shared lists...',
    );

    final result = await _getSharedListsUseCase(userId);

    result.fold(
      (failure) => state = ListState.error(
        failure: failure,
        lists: state.listsOrEmpty,
      ),
      (sharedLists) {
        // Merge with existing lists, replacing duplicates
        final currentLists = state.listsOrEmpty;
        final sharedIds = sharedLists.map((l) => l.id).toSet();
        final nonSharedLists = currentLists
            .where((l) => !sharedIds.contains(l.id))
            .toList();
        final mergedLists = [...nonSharedLists, ...sharedLists];
        state = ListState.loaded(lists: mergedLists);
      },
    );
  }

  /// Refresh lists by reloading from repository
  ///
  /// Parameters:
  /// - [userId]: The ID of the user whose lists to refresh
  /// - [includeArchived]: Whether to include archived lists
  /// - [includeDeleted]: Whether to include deleted lists
  Future<void> refreshLists({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    await loadLists(
      userId: userId,
      includeArchived: includeArchived,
      includeDeleted: includeDeleted,
    );
  }

  /// Clear error state
  ///
  /// Returns to previous loaded state with current lists
  void clearError() {
    final currentLists = state.listsOrEmpty;
    state = ListState.loaded(lists: currentLists);
  }

  /// Clear all lists and reset to initial state
  void reset() {
    state = const ListState.initial();
  }

  /// Update a list in the local state without calling the repository
  ///
  /// Useful for optimistic updates or when the list was updated elsewhere
  ///
  /// Parameters:
  /// - [list]: The updated list entity
  void updateListLocally(ListEntity list) {
    final currentLists = state.listsOrEmpty;
    final updatedLists = currentLists.map((l) {
      return l.id == list.id ? list : l;
    }).toList();
    state = ListState.loaded(lists: updatedLists);
  }

  /// Add a list to the local state without calling the repository
  ///
  /// Useful for adding a list that was created elsewhere
  ///
  /// Parameters:
  /// - [list]: The list entity to add
  void addListLocally(ListEntity list) {
    final currentLists = state.listsOrEmpty;
    final updatedLists = [...currentLists, list];
    state = ListState.loaded(lists: updatedLists);
  }

  /// Remove a list from the local state without calling the repository
  ///
  /// Useful for removing a list that was deleted elsewhere
  ///
  /// Parameters:
  /// - [listId]: The ID of the list to remove
  void removeListLocally(String listId) {
    final currentLists = state.listsOrEmpty;
    final updatedLists = currentLists
        .where((list) => list.id != listId)
        .toList();
    state = ListState.loaded(lists: updatedLists);
  }

  /// Get a list by ID from the current state
  ///
  /// Parameters:
  /// - [listId]: The ID of the list to find
  ///
  /// Returns: The list entity or null if not found
  ListEntity? getListById(String listId) {
    return state.findListById(listId);
  }
}
