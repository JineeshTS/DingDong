import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
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
import 'list_notifier.dart';
import 'list_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================
// These providers expose individual use cases from the DI container.
// They are auto-disposed when no longer needed for optimal memory management.

/// Provider for CreateListUseCase
///
/// Handles creating new lists
final createListProvider = Provider.autoDispose<CreateListUseCase>(
  (ref) => sl<CreateListUseCase>(),
);

/// Provider for UpdateListUseCase
///
/// Handles updating existing lists
final updateListProvider = Provider.autoDispose<UpdateListUseCase>(
  (ref) => sl<UpdateListUseCase>(),
);

/// Provider for DeleteListUseCase
///
/// Handles deleting lists (soft delete)
final deleteListProvider = Provider.autoDispose<DeleteListUseCase>(
  (ref) => sl<DeleteListUseCase>(),
);

/// Provider for GetListsUseCase
///
/// Retrieves all lists for a user
final getListsProvider = Provider.autoDispose<GetListsUseCase>(
  (ref) => sl<GetListsUseCase>(),
);

/// Provider for ToggleFavoriteListUseCase
///
/// Toggles favorite status of a list
final toggleFavoriteListProvider =
    Provider.autoDispose<ToggleFavoriteListUseCase>(
  (ref) => sl<ToggleFavoriteListUseCase>(),
);

/// Provider for ArchiveListUseCase
///
/// Handles archiving lists
final archiveListProvider = Provider.autoDispose<ArchiveListUseCase>(
  (ref) => sl<ArchiveListUseCase>(),
);

/// Provider for UnarchiveListUseCase
///
/// Handles unarchiving lists
final unarchiveListProvider = Provider.autoDispose<UnarchiveListUseCase>(
  (ref) => sl<UnarchiveListUseCase>(),
);

/// Provider for ShareListUseCase
///
/// Handles sharing lists with other users
final shareListProvider = Provider.autoDispose<ShareListUseCase>(
  (ref) => sl<ShareListUseCase>(),
);

/// Provider for GetFavoriteListsUseCase
///
/// Retrieves user's favorite lists
final getFavoriteListsProvider = Provider.autoDispose<GetFavoriteListsUseCase>(
  (ref) => sl<GetFavoriteListsUseCase>(),
);

/// Provider for GetSharedListsUseCase
///
/// Retrieves lists shared with the user
final getSharedListsProvider = Provider.autoDispose<GetSharedListsUseCase>(
  (ref) => sl<GetSharedListsUseCase>(),
);

// ============================================================================
// List State Notifier Provider
// ============================================================================

/// Main list state notifier provider
///
/// This is the primary provider for list state management.
/// It should NOT be auto-disposed as we want to maintain list
/// state throughout the app lifecycle.
///
/// Usage:
/// ```dart
/// // In a ConsumerWidget
/// final listState = ref.watch(listNotifierProvider);
/// final listNotifier = ref.read(listNotifierProvider.notifier);
///
/// // Load lists
/// await listNotifier.loadLists(userId: currentUserId);
///
/// // Access lists
/// if (listState.isLoaded) {
///   final lists = listState.activeLists;
///   // Display lists
/// }
///
/// // Create a new list
/// final newList = ListEntity(
///   id: uuid.v4(),
///   userId: currentUserId,
///   name: 'My New List',
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
///   createdBy: currentUserId,
/// );
/// await listNotifier.createList(newList);
/// ```
final listNotifierProvider = StateNotifierProvider<ListNotifier, ListState>(
  (ref) {
    return ListNotifier(
      createListUseCase: ref.read(createListProvider),
      updateListUseCase: ref.read(updateListProvider),
      deleteListUseCase: ref.read(deleteListProvider),
      getListsUseCase: ref.read(getListsProvider),
      toggleFavoriteListUseCase: ref.read(toggleFavoriteListProvider),
      archiveListUseCase: ref.read(archiveListProvider),
      unarchiveListUseCase: ref.read(unarchiveListProvider),
      shareListUseCase: ref.read(shareListProvider),
      getFavoriteListsUseCase: ref.read(getFavoriteListsProvider),
      getSharedListsUseCase: ref.read(getSharedListsProvider),
    );
  },
);

// ============================================================================
// Derived State Providers
// ============================================================================
// These providers derive specific values from the list state for convenience

/// Provider that exposes all lists
///
/// Returns empty list if lists are not loaded
///
/// Usage:
/// ```dart
/// final lists = ref.watch(allListsProvider);
/// ListView.builder(
///   itemCount: lists.length,
///   itemBuilder: (context, index) => ListTile(title: Text(lists[index].name)),
/// );
/// ```
final allListsProvider = Provider.autoDispose<List<ListEntity>>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.listsOrEmpty;
});

/// Provider that exposes only active (non-archived, non-deleted) lists
///
/// Usage:
/// ```dart
/// final activeLists = ref.watch(activeListsProvider);
/// // Display active lists
/// ```
final activeListsProvider = Provider.autoDispose<List<ListEntity>>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.activeLists;
});

/// Provider that exposes only favorite lists
///
/// Usage:
/// ```dart
/// final favoriteLists = ref.watch(favoriteListsProvider);
/// if (favoriteLists.isEmpty) {
///   Text('No favorite lists yet');
/// }
/// ```
final favoriteListsProvider = Provider.autoDispose<List<ListEntity>>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.favoriteLists;
});

/// Provider that exposes only shared lists
///
/// Usage:
/// ```dart
/// final sharedLists = ref.watch(sharedListsProvider);
/// ListView.builder(
///   itemCount: sharedLists.length,
///   itemBuilder: (context, index) {
///     final list = sharedLists[index];
///     return ListTile(
///       title: Text(list.name),
///       subtitle: Text('Shared list'),
///     );
///   },
/// );
/// ```
final sharedListsProvider = Provider.autoDispose<List<ListEntity>>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.sharedLists;
});

/// Provider that exposes only archived lists
///
/// Usage:
/// ```dart
/// final archivedLists = ref.watch(archivedListsProvider);
/// // Display archived lists
/// ```
final archivedListsProvider = Provider.autoDispose<List<ListEntity>>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.archivedLists;
});

/// Provider that exposes only personal (non-shared) lists
///
/// Usage:
/// ```dart
/// final personalLists = ref.watch(personalListsProvider);
/// // Display personal lists only
/// ```
final personalListsProvider = Provider.autoDispose<List<ListEntity>>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.personalLists;
});

/// Provider that exposes only smart lists
///
/// Usage:
/// ```dart
/// final smartLists = ref.watch(smartListsProvider);
/// // Display smart/filtered lists
/// ```
final smartListsProvider = Provider.autoDispose<List<ListEntity>>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.smartLists;
});

/// Provider that exposes only top-level lists (no parent)
///
/// Usage:
/// ```dart
/// final topLevelLists = ref.watch(topLevelListsProvider);
/// // Display root-level lists in navigation
/// ```
final topLevelListsProvider = Provider.autoDispose<List<ListEntity>>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.topLevelLists;
});

/// Provider that exposes only nested lists (with parent)
///
/// Usage:
/// ```dart
/// final nestedLists = ref.watch(nestedListsProvider);
/// // Display sublists/nested lists
/// ```
final nestedListsProvider = Provider.autoDispose<List<ListEntity>>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.nestedLists;
});

/// Provider that exposes the loading state
///
/// Useful for showing loading indicators
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(isListLoadingProvider);
/// if (isLoading) {
///   CircularProgressIndicator();
/// }
/// ```
final isListLoadingProvider = Provider.autoDispose<bool>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.isLoading;
});

/// Provider that exposes list errors
///
/// Returns null if no error
///
/// Usage:
/// ```dart
/// final error = ref.watch(listErrorProvider);
/// if (error != null) {
///   SnackBar(content: Text(error.message));
/// }
/// ```
final listErrorProvider = Provider.autoDispose((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.errorOrNull;
});

/// Provider for total count of active lists
///
/// Usage:
/// ```dart
/// final activeCount = ref.watch(activeListsCountProvider);
/// Text('You have $activeCount active lists');
/// ```
final activeListsCountProvider = Provider.autoDispose<int>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.activeListsCount;
});

/// Provider for total count of favorite lists
///
/// Usage:
/// ```dart
/// final favoriteCount = ref.watch(favoriteListsCountProvider);
/// Badge(count: favoriteCount);
/// ```
final favoriteListsCountProvider = Provider.autoDispose<int>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.favoriteListsCount;
});

/// Provider for total count of shared lists
///
/// Usage:
/// ```dart
/// final sharedCount = ref.watch(sharedListsCountProvider);
/// Text('$sharedCount shared with you');
/// ```
final sharedListsCountProvider = Provider.autoDispose<int>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.sharedListsCount;
});

/// Provider for total count of archived lists
///
/// Usage:
/// ```dart
/// final archivedCount = ref.watch(archivedListsCountProvider);
/// if (archivedCount > 0) {
///   ListTile(
///     title: Text('Archived ($archivedCount)'),
///     onTap: () => navigateToArchivedLists(),
///   );
/// }
/// ```
final archivedListsCountProvider = Provider.autoDispose<int>((ref) {
  final listState = ref.watch(listNotifierProvider);
  return listState.archivedListsCount;
});

/// Provider family for getting a specific list by ID
///
/// Auto-disposes when not in use
///
/// Usage:
/// ```dart
/// final list = ref.watch(listByIdProvider(listId));
/// if (list != null) {
///   Text(list.name);
/// } else {
///   Text('List not found');
/// }
/// ```
final listByIdProvider =
    Provider.autoDispose.family<ListEntity?, String>((ref, listId) {
  final listState = ref.watch(listNotifierProvider);
  return listState.findListById(listId);
});

/// Provider family for getting lists by workspace
///
/// Usage:
/// ```dart
/// final workspaceLists = ref.watch(listsByWorkspaceProvider(workspaceId));
/// // Display lists for a specific workspace
/// ```
final listsByWorkspaceProvider =
    Provider.autoDispose.family<List<ListEntity>, String>((ref, workspaceId) {
  final listState = ref.watch(listNotifierProvider);
  return listState.getListsByWorkspace(workspaceId);
});

/// Provider family for getting child lists by parent ID
///
/// Usage:
/// ```dart
/// final childLists = ref.watch(listsByParentProvider(parentListId));
/// // Display sublists/nested lists under a parent
/// ```
final listsByParentProvider =
    Provider.autoDispose.family<List<ListEntity>, String>((ref, parentListId) {
  final listState = ref.watch(listNotifierProvider);
  return listState.getListsByParent(parentListId);
});

/// Provider for sorting lists by name
///
/// Usage:
/// ```dart
/// final sortedLists = ref.watch(listsSortedByNameProvider);
/// // Display alphabetically sorted lists
/// ```
final listsSortedByNameProvider =
    Provider.autoDispose<List<ListEntity>>((ref) {
  final lists = ref.watch(activeListsProvider);
  final sortedLists = List<ListEntity>.from(lists);
  sortedLists.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return sortedLists;
});

/// Provider for sorting lists by creation date (newest first)
///
/// Usage:
/// ```dart
/// final recentLists = ref.watch(listsSortedByCreationDateProvider);
/// // Display recently created lists first
/// ```
final listsSortedByCreationDateProvider =
    Provider.autoDispose<List<ListEntity>>((ref) {
  final lists = ref.watch(activeListsProvider);
  final sortedLists = List<ListEntity>.from(lists);
  sortedLists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sortedLists;
});

/// Provider for sorting lists by update date (most recently updated first)
///
/// Usage:
/// ```dart
/// final recentlyUpdatedLists = ref.watch(listsSortedByUpdateDateProvider);
/// // Display recently modified lists first
/// ```
final listsSortedByUpdateDateProvider =
    Provider.autoDispose<List<ListEntity>>((ref) {
  final lists = ref.watch(activeListsProvider);
  final sortedLists = List<ListEntity>.from(lists);
  sortedLists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sortedLists;
});

/// Provider for sorting lists by sort order
///
/// Usage:
/// ```dart
/// final orderedLists = ref.watch(listsSortedBySortOrderProvider);
/// // Display lists in their custom sort order
/// ```
final listsSortedBySortOrderProvider =
    Provider.autoDispose<List<ListEntity>>((ref) {
  final lists = ref.watch(activeListsProvider);
  final sortedLists = List<ListEntity>.from(lists);
  sortedLists.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return sortedLists;
});

/// Provider for checking if there are any favorite lists
///
/// Usage:
/// ```dart
/// final hasFavorites = ref.watch(hasFavoriteListsProvider);
/// if (hasFavorites) {
///   // Show favorites section
/// }
/// ```
final hasFavoriteListsProvider = Provider.autoDispose<bool>((ref) {
  final count = ref.watch(favoriteListsCountProvider);
  return count > 0;
});

/// Provider for checking if there are any shared lists
///
/// Usage:
/// ```dart
/// final hasShared = ref.watch(hasSharedListsProvider);
/// if (hasShared) {
///   // Show shared lists section
/// }
/// ```
final hasSharedListsProvider = Provider.autoDispose<bool>((ref) {
  final count = ref.watch(sharedListsCountProvider);
  return count > 0;
});

/// Provider for checking if there are any archived lists
///
/// Usage:
/// ```dart
/// final hasArchived = ref.watch(hasArchivedListsProvider);
/// if (hasArchived) {
///   // Show archived lists option in menu
/// }
/// ```
final hasArchivedListsProvider = Provider.autoDispose<bool>((ref) {
  final count = ref.watch(archivedListsCountProvider);
  return count > 0;
});
