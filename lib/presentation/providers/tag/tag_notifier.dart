import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/tag_entity.dart';
import '../../../domain/usecases/tag/create_tag_usecase.dart';
import '../../../domain/usecases/tag/delete_tag_usecase.dart';
import '../../../domain/usecases/tag/get_popular_tags_usecase.dart';
import '../../../domain/usecases/tag/get_tags_usecase.dart';
import '../../../domain/usecases/tag/increment_tag_usage_usecase.dart';
import '../../../domain/usecases/tag/merge_tags_usecase.dart';
import '../../../domain/usecases/tag/restore_tag_usecase.dart';
import '../../../domain/usecases/tag/update_tag_usecase.dart';
import 'tag_state.dart';

/// StateNotifier for managing tag state
///
/// Handles all tag-related operations including:
/// - CRUD operations (Create, Read, Update, Delete)
/// - Tag deletion and restoration (soft delete)
/// - Tag color customization
/// - Tag hierarchy management (parent/child)
/// - Usage tracking and popular tags
/// - Tag merging functionality
/// - Tag search and filtering
/// - Pagination support
///
/// This notifier integrates with all 8 tag use cases
/// and manages the TagState throughout the application lifecycle.
class TagNotifier extends StateNotifier<TagState> {
  // Use cases
  final CreateTagUseCase _createTagUseCase;
  final UpdateTagUseCase _updateTagUseCase;
  final DeleteTagUseCase _deleteTagUseCase;
  final GetTagsUseCase _getTagsUseCase;
  final MergeTagsUseCase _mergeTagsUseCase;
  final IncrementTagUsageUseCase _incrementTagUsageUseCase;
  final GetPopularTagsUseCase _getPopularTagsUseCase;
  final RestoreTagUseCase _restoreTagUseCase;

  TagNotifier({
    required CreateTagUseCase createTagUseCase,
    required UpdateTagUseCase updateTagUseCase,
    required DeleteTagUseCase deleteTagUseCase,
    required GetTagsUseCase getTagsUseCase,
    required MergeTagsUseCase mergeTagsUseCase,
    required IncrementTagUsageUseCase incrementTagUsageUseCase,
    required GetPopularTagsUseCase getPopularTagsUseCase,
    required RestoreTagUseCase restoreTagUseCase,
  })  : _createTagUseCase = createTagUseCase,
        _updateTagUseCase = updateTagUseCase,
        _deleteTagUseCase = deleteTagUseCase,
        _getTagsUseCase = getTagsUseCase,
        _mergeTagsUseCase = mergeTagsUseCase,
        _incrementTagUsageUseCase = incrementTagUsageUseCase,
        _getPopularTagsUseCase = getPopularTagsUseCase,
        _restoreTagUseCase = restoreTagUseCase,
        super(const TagState());

  // ============================================================================
  // CRUD Operations
  // ============================================================================

  /// Create a new tag
  ///
  /// Parameters:
  /// - [tag]: Tag entity to create
  ///
  /// Updates the tag list after creation and validates unique name
  Future<void> createTag(TagEntity tag) async {
    state = state.copyWith(isCreating: true, operationError: null);

    final result = await _createTagUseCase(tag: tag);

    result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          operationError: failure,
        );
      },
      (createdTag) {
        // Add to all tags list
        state = state.copyWith(
          isCreating: false,
          allTags: state.allTags.prependItem(createdTag),
          operationError: null,
        );

        // Update color grouping
        _updateColorGrouping(createdTag, isAdd: true);
      },
    );
  }

  /// Update an existing tag
  ///
  /// Parameters:
  /// - [tag]: Updated tag entity
  ///
  /// Updates the tag in all relevant lists
  Future<void> updateTag(TagEntity tag) async {
    state = state.copyWith(isUpdating: true, operationError: null);

    final result = await _updateTagUseCase(tag);

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          operationError: failure,
        );
      },
      (updatedTag) {
        // Update in all lists
        state = state.copyWith(
          isUpdating: false,
          allTags: state.allTags.updateItem(
            (t) => t.id == updatedTag.id,
            (_) => updatedTag,
          ),
          allTagsIncludingDeleted: state.allTagsIncludingDeleted.updateItem(
            (t) => t.id == updatedTag.id,
            (_) => updatedTag,
          ),
          popularTags: state.popularTags.updateItem(
            (t) => t.id == updatedTag.id,
            (_) => updatedTag,
          ),
          selectedTag: state.selectedTag?.id == updatedTag.id
              ? updatedTag
              : state.selectedTag,
          operationError: null,
        );

        // Update color grouping if color changed
        if (state.selectedTag?.color != updatedTag.color) {
          _updateColorGrouping(updatedTag, isAdd: true);
        }
      },
    );
  }

  /// Delete a tag (soft delete)
  ///
  /// Parameters:
  /// - [tagId]: ID of tag to delete
  ///
  /// Performs soft delete (sets isDeleted flag)
  Future<void> deleteTag(String tagId) async {
    state = state.copyWith(isDeleting: true, operationError: null);

    final result = await _deleteTagUseCase(tagId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          operationError: failure,
        );
      },
      (_) {
        // Move from active to deleted tags
        final deletedTag = state.allTags.items.firstWhere(
          (t) => t.id == tagId,
          orElse: () => state.selectedTag,
        );

        if (deletedTag != null) {
          state = state.copyWith(
            isDeleting: false,
            allTags: state.allTags.removeItem((t) => t.id == tagId),
            deletedTags: state.deletedTags.prependItem(
              deletedTag.copyWith(isDeleted: true),
            ),
            selectedTag: state.selectedTag?.id == tagId
                ? null
                : state.selectedTag,
            operationError: null,
          );

          // Remove from color grouping
          _updateColorGrouping(deletedTag, isAdd: false);
        }
      },
    );
  }

  /// Get all active tags with pagination
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  /// - [loadMore]: Whether to load next page or refresh
  /// - [forceRefresh]: Force refresh even if cached data is fresh
  Future<void> getTags(
    String userId, {
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && !loadMore && !state.needsRefreshAll) {
      return;
    }

    if (loadMore) {
      if (!state.allTags.canLoadMore) return;
      state = state.copyWith(
        allTags: state.allTags.setLoadingMore(),
      );
    } else {
      state = state.copyWith(
        allTags: state.allTags.setLoadingInitial(),
      );
    }

    final result = await _getTagsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          allTags: state.allTags.setError(failure),
        );
      },
      (tags) {
        // Filter out deleted tags by default
        final activeTags = tags.where((t) => !t.isDeleted).toList();

        if (loadMore) {
          state = state.copyWith(
            allTags: state.allTags.addItems(activeTags),
          );
        } else {
          state = state.copyWith(
            allTags: state.allTags.replaceItems(activeTags),
            lastRefreshAll: DateTime.now(),
          );
          _buildColorGrouping(activeTags);
          _buildHierarchy(activeTags);
        }
      },
    );
  }

  // ============================================================================
  // Tag Retrieval
  // ============================================================================

  /// Get popular tags (most used)
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  /// - [limit]: Maximum number of tags to return
  /// - [loadMore]: Whether to load next page or refresh
  /// - [forceRefresh]: Force refresh even if cached data is fresh
  Future<void> getPopularTags(
    String userId, {
    int limit = 20,
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && !loadMore && !state.needsRefreshPopular) {
      return;
    }

    if (loadMore) {
      if (!state.popularTags.canLoadMore) return;
      state = state.copyWith(
        popularTags: state.popularTags.setLoadingMore(),
      );
    } else {
      state = state.copyWith(
        isLoadingPopular: true,
        popularError: null,
      );
    }

    final result = await _getPopularTagsUseCase(
      userId: userId,
      limit: limit,
    );

    result.fold(
      (failure) {
        if (loadMore) {
          state = state.copyWith(
            popularTags: state.popularTags.setError(failure),
          );
        } else {
          state = state.copyWith(
            isLoadingPopular: false,
            popularError: failure,
          );
        }
      },
      (tags) {
        if (loadMore) {
          state = state.copyWith(
            popularTags: state.popularTags.addItems(tags),
          );
        } else {
          state = state.copyWith(
            isLoadingPopular: false,
            popularTags: state.popularTags.replaceItems(tags),
            lastRefreshPopular: DateTime.now(),
            popularError: null,
          );
        }
      },
    );
  }

  // ============================================================================
  // Tag Operations
  // ============================================================================

  /// Increment tag usage count
  ///
  /// Parameters:
  /// - [tagId]: ID of tag to increment
  /// - [increment]: Amount to increment by (default: 1)
  Future<void> incrementTagUsage(
    String tagId, {
    int increment = 1,
  }) async {
    final result = await _incrementTagUsageUseCase(
      tagId: tagId,
      increment: increment,
    );

    result.fold(
      (failure) {
        state = state.copyWith(operationError: failure);
      },
      (updatedTag) {
        // Update in all lists
        state = state.copyWith(
          allTags: state.allTags.updateItem(
            (t) => t.id == updatedTag.id,
            (_) => updatedTag,
          ),
          popularTags: state.popularTags.updateItem(
            (t) => t.id == updatedTag.id,
            (_) => updatedTag,
          ),
          selectedTag: state.selectedTag?.id == updatedTag.id
              ? updatedTag
              : state.selectedTag,
          operationError: null,
        );
      },
    );
  }

  /// Merge two tags
  ///
  /// Parameters:
  /// - [sourceTagId]: ID of the tag to merge from (will be deleted)
  /// - [targetTagId]: ID of the tag to merge into (will be kept)
  ///
  /// All tasks with source tag will be updated to use target tag.
  /// Source tag usage count is added to target tag.
  Future<void> mergeTags({
    required String sourceTagId,
    required String targetTagId,
  }) async {
    state = state.copyWith(
      isMerging: true,
      operationError: null,
      currentMergeOperation: MergeOperation(
        sourceTagId: sourceTagId,
        targetTagId: targetTagId,
      ),
    );

    final result = await _mergeTagsUseCase(
      sourceTagId: sourceTagId,
      targetTagId: targetTagId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isMerging: false,
          operationError: failure,
          currentMergeOperation: null,
        );
      },
      (targetTag) {
        // Remove source tag from lists
        state = state.copyWith(
          isMerging: false,
          allTags: state.allTags.removeItem((t) => t.id == sourceTagId),
          popularTags: state.popularTags.removeItem((t) => t.id == sourceTagId),
          deletedTags: state.deletedTags.removeItem((t) => t.id == sourceTagId),
          operationError: null,
          currentMergeOperation: null,
        );

        // Update target tag with merged usage count
        state = state.copyWith(
          allTags: state.allTags.updateItem(
            (t) => t.id == targetTagId,
            (_) => targetTag,
          ),
          popularTags: state.popularTags.updateItem(
            (t) => t.id == targetTagId,
            (_) => targetTag,
          ),
          selectedTag: state.selectedTag?.id == targetTagId
              ? targetTag
              : state.selectedTag,
        );
      },
    );
  }

  /// Restore a deleted tag
  ///
  /// Parameters:
  /// - [tagId]: ID of deleted tag to restore
  Future<void> restoreTag(String tagId) async {
    state = state.copyWith(isRestoring: true, operationError: null);

    final result = await _restoreTagUseCase(tagId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isRestoring: false,
          operationError: failure,
        );
      },
      (restoredTag) {
        // Move from deleted to active tags
        state = state.copyWith(
          isRestoring: false,
          deletedTags: state.deletedTags.removeItem((t) => t.id == tagId),
          allTags: state.allTags.prependItem(restoredTag),
          operationError: null,
        );

        // Update color grouping
        _updateColorGrouping(restoredTag, isAdd: true);
      },
    );
  }

  // ============================================================================
  // Search and Filtering
  // ============================================================================

  /// Search tags by name
  ///
  /// Parameters:
  /// - [query]: Search query string
  /// - [loadMore]: Whether to load next page or new search
  Future<void> searchTags({
    required String query,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (!state.searchResults.canLoadMore) return;
      state = state.copyWith(
        searchResults: state.searchResults.setLoadingMore(),
      );
    } else {
      state = state.copyWith(
        currentSearchQuery: query,
        isSearching: true,
        searchResults: state.searchResults.setLoadingInitial(),
      );
    }

    // Perform local search on active tags
    final results = state.allTags.items
        .where((tag) =>
            tag.name.toLowerCase().contains(query.toLowerCase()) ||
            (tag.description?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();

    if (loadMore) {
      state = state.copyWith(
        searchResults: state.searchResults.addItems(results),
      );
    } else {
      state = state.copyWith(
        isSearching: false,
        searchResults: state.searchResults.replaceItems(results),
      );
    }
  }

  /// Clear search results
  void clearSearch() {
    state = state.copyWith(
      currentSearchQuery: null,
      searchResults: const PaginationState(),
    );
  }

  /// Filter tags by color
  ///
  /// Parameters:
  /// - [color]: Hex color code to filter by
  void filterByColor(String? color) {
    state = state.copyWith(currentColorFilter: color);
  }

  /// Filter tags by parent tag (for hierarchy)
  ///
  /// Parameters:
  /// - [parentTagId]: Parent tag ID to filter by
  void filterByParentTag(String? parentTagId) {
    state = state.copyWith(currentParentTagFilter: parentTagId);
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Set selected tag
  void selectTag(TagEntity? tag) {
    state = state.copyWith(selectedTag: tag);
  }

  /// Set sort option (by usage or by name)
  void setSortOption(bool byUsage, {bool ascending = true}) {
    state = state.copyWith(
      sortByUsage: byUsage,
      sortAscending: ascending,
    );
  }

  /// Toggle include deleted tags
  void toggleIncludeDeleted() {
    state = state.copyWith(
      includeDeleted: !state.includeDeleted,
    );
  }

  /// Clear all errors
  void clearErrors() {
    state = state.copyWith(
      error: null,
      popularError: null,
      deletedError: null,
      operationError: null,
    );
  }

  /// Clear operation error
  void clearOperationError() {
    state = state.copyWith(operationError: null);
  }

  /// Get deleted tags with pagination
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  /// - [loadMore]: Whether to load next page or refresh
  /// - [forceRefresh]: Force refresh even if cached data is fresh
  Future<void> getDeletedTags(
    String userId, {
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && !loadMore && !state.needsRefreshDeleted) {
      return;
    }

    if (loadMore) {
      if (!state.deletedTags.canLoadMore) return;
      state = state.copyWith(
        deletedTags: state.deletedTags.setLoadingMore(),
      );
    } else {
      state = state.copyWith(
        isLoadingDeleted: true,
        deletedError: null,
      );
    }

    final result = await _getTagsUseCase();

    result.fold(
      (failure) {
        if (loadMore) {
          state = state.copyWith(
            deletedTags: state.deletedTags.setError(failure),
          );
        } else {
          state = state.copyWith(
            isLoadingDeleted: false,
            deletedError: failure,
          );
        }
      },
      (tags) {
        // Filter to show only deleted tags
        final deletedTags = tags.where((t) => t.isDeleted).toList();

        if (loadMore) {
          state = state.copyWith(
            deletedTags: state.deletedTags.addItems(deletedTags),
          );
        } else {
          state = state.copyWith(
            isLoadingDeleted: false,
            deletedTags: state.deletedTags.replaceItems(deletedTags),
            lastRefreshDeleted: DateTime.now(),
            deletedError: null,
          );
        }
      },
    );
  }

  /// Refresh all tag lists
  Future<void> refreshAll(String userId) async {
    await Future.wait([
      getTags(userId, forceRefresh: true),
      getPopularTags(userId, forceRefresh: true),
      getDeletedTags(userId, forceRefresh: true),
    ]);
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  /// Build color grouping map
  void _buildColorGrouping(List<TagEntity> tags) {
    final groupedByColor = <String, List<TagEntity>>{};

    for (final tag in tags) {
      if (!groupedByColor.containsKey(tag.color)) {
        groupedByColor[tag.color] = [];
      }
      groupedByColor[tag.color]!.add(tag);
    }

    state = state.copyWith(tagsByColor: groupedByColor);
  }

  /// Update color grouping when a tag is added or removed
  void _updateColorGrouping(TagEntity tag, {required bool isAdd}) {
    final groupedByColor = Map<String, List<TagEntity>>.from(state.tagsByColor);

    if (!groupedByColor.containsKey(tag.color)) {
      groupedByColor[tag.color] = [];
    }

    if (isAdd) {
      if (!groupedByColor[tag.color]!.any((t) => t.id == tag.id)) {
        groupedByColor[tag.color]!.add(tag);
      }
    } else {
      groupedByColor[tag.color]!.removeWhere((t) => t.id == tag.id);
      if (groupedByColor[tag.color]!.isEmpty) {
        groupedByColor.remove(tag.color);
      }
    }

    state = state.copyWith(tagsByColor: groupedByColor);
  }

  /// Build hierarchical tags structure
  void _buildHierarchy(List<TagEntity> tags) {
    final hierarchical = tags.where((tag) => tag.isNested).toList();
    state = state.copyWith(hierarchicalTags: hierarchical);
  }
}
