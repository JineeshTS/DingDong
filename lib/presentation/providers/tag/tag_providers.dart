import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/tag_entity.dart';
import '../../../domain/usecases/tag/create_tag_usecase.dart';
import '../../../domain/usecases/tag/delete_tag_usecase.dart';
import '../../../domain/usecases/tag/get_popular_tags_usecase.dart';
import '../../../domain/usecases/tag/get_tags_usecase.dart';
import '../../../domain/usecases/tag/increment_tag_usage_usecase.dart';
import '../../../domain/usecases/tag/merge_tags_usecase.dart';
import '../../../domain/usecases/tag/restore_tag_usecase.dart';
import '../../../domain/usecases/tag/update_tag_usecase.dart';
import 'tag_notifier.dart';
import 'tag_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================
// These providers expose individual use cases from the DI container.
// They are auto-disposed when no longer needed for optimal memory management.

/// Provider for CreateTagUseCase
///
/// Handles tag creation with unique name validation and color customization
final createTagProvider = Provider.autoDispose<CreateTagUseCase>(
  (ref) => sl<CreateTagUseCase>(),
);

/// Provider for UpdateTagUseCase
///
/// Handles tag updates including color and hierarchy changes
final updateTagProvider = Provider.autoDispose<UpdateTagUseCase>(
  (ref) => sl<UpdateTagUseCase>(),
);

/// Provider for DeleteTagUseCase
///
/// Handles soft deletion of tags
final deleteTagProvider = Provider.autoDispose<DeleteTagUseCase>(
  (ref) => sl<DeleteTagUseCase>(),
);

/// Provider for GetTagsUseCase
///
/// Retrieves all tags with optional deleted tags inclusion
final getTagsProvider = Provider.autoDispose<GetTagsUseCase>(
  (ref) => sl<GetTagsUseCase>(),
);

/// Provider for MergeTagsUseCase
///
/// Handles tag merging and consolidation
final mergeTagsProvider = Provider.autoDispose<MergeTagsUseCase>(
  (ref) => sl<MergeTagsUseCase>(),
);

/// Provider for IncrementTagUsageUseCase
///
/// Tracks and updates tag usage counts
final incrementTagUsageProvider = Provider.autoDispose<IncrementTagUsageUseCase>(
  (ref) => sl<IncrementTagUsageUseCase>(),
);

/// Provider for GetPopularTagsUseCase
///
/// Retrieves most frequently used tags
final getPopularTagsProvider = Provider.autoDispose<GetPopularTagsUseCase>(
  (ref) => sl<GetPopularTagsUseCase>(),
);

/// Provider for RestoreTagUseCase
///
/// Restores previously deleted tags
final restoreTagProvider = Provider.autoDispose<RestoreTagUseCase>(
  (ref) => sl<RestoreTagUseCase>(),
);

// ============================================================================
// Tag State Notifier Provider
// ============================================================================

/// Main tag state notifier provider
///
/// This is the primary provider for tag state management.
/// It should NOT be auto-disposed as we want to maintain tag
/// state throughout the app lifecycle.
///
/// Usage:
/// ```dart
/// // In a ConsumerWidget
/// final tagState = ref.watch(tagNotifierProvider);
/// final tagNotifier = ref.read(tagNotifierProvider.notifier);
///
/// // Get all tags
/// ref.listen(tagNotifierProvider, (previous, next) {
///   if (next.flatAllTags.isNotEmpty) {
///     // Handle tags update
///   }
/// });
///
/// // Perform tag actions
/// await tagNotifier.createTag(newTag);
/// await tagNotifier.deleteTag(tagId);
/// ```
final tagNotifierProvider = StateNotifierProvider<TagNotifier, TagState>(
  (ref) {
    return TagNotifier(
      createTagUseCase: ref.read(createTagProvider),
      updateTagUseCase: ref.read(updateTagProvider),
      deleteTagUseCase: ref.read(deleteTagProvider),
      getTagsUseCase: ref.read(getTagsProvider),
      mergeTagsUseCase: ref.read(mergeTagsProvider),
      incrementTagUsageUseCase: ref.read(incrementTagUsageProvider),
      getPopularTagsUseCase: ref.read(getPopularTagsProvider),
      restoreTagUseCase: ref.read(restoreTagProvider),
    );
  },
);

// ============================================================================
// Derived State Providers - Tag Lists
// ============================================================================

/// Provider that exposes all active tags
///
/// Returns list of non-deleted tags
///
/// Usage:
/// ```dart
/// final allTags = ref.watch(allTagsProvider);
/// ListView.builder(
///   itemCount: allTags.length,
///   itemBuilder: (context, index) => TagTile(tag: allTags[index]),
/// );
/// ```
final allTagsProvider = Provider.autoDispose<List<TagEntity>>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.flatAllTags;
});

/// Provider that exposes popular tags (most used)
///
/// Returns list of tags sorted by usage count
///
/// Usage:
/// ```dart
/// final popularTags = ref.watch(popularTagsProvider);
/// PopularTagsWidget(tags: popularTags);
/// ```
final popularTagsProvider = Provider.autoDispose<List<TagEntity>>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.flatPopularTags;
});

/// Provider that exposes deleted tags
///
/// Returns list of soft-deleted tags
///
/// Usage:
/// ```dart
/// final deletedTags = ref.watch(deletedTagsProvider);
/// if (deletedTags.isNotEmpty) {
///   showTrashBin(deletedTags.length);
/// }
/// ```
final deletedTagsProvider = Provider.autoDispose<List<TagEntity>>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.flatDeletedTags;
});

/// Provider that exposes parent tags (without parent)
///
/// Returns list of root-level tags in hierarchy
///
/// Usage:
/// ```dart
/// final parentTags = ref.watch(parentTagsProvider);
/// for (final parent in parentTags) {
///   TagSection(tag: parent, children: getChildren(parent.id));
/// }
/// ```
final parentTagsProvider = Provider.autoDispose<List<TagEntity>>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.parentTags;
});

/// Provider that exposes hierarchical tags
///
/// Returns list of nested tags (with parents)
final hierarchicalTagsProvider = Provider.autoDispose<List<TagEntity>>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.hierarchicalTags;
});

/// Provider that exposes search results
///
/// Returns paginated search results for tags
///
/// Usage:
/// ```dart
/// final searchResults = ref.watch(tagSearchResultsProvider);
/// SearchResultsView(results: searchResults);
/// ```
final tagSearchResultsProvider = Provider.autoDispose((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.searchResults;
});

/// Provider that exposes selected tag
///
/// Returns currently selected/viewed tag
///
/// Usage:
/// ```dart
/// final selectedTag = ref.watch(selectedTagProvider);
/// if (selectedTag != null) {
///   TagDetailView(tag: selectedTag);
/// }
/// ```
final selectedTagProvider = Provider.autoDispose<TagEntity?>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.selectedTag;
});

// ============================================================================
// Derived State Providers - Counts and Statistics
// ============================================================================

/// Provider for active tag count
///
/// Returns count of non-deleted tags
///
/// Usage:
/// ```dart
/// final activeCount = ref.watch(activeTagCountProvider);
/// Badge(label: '$activeCount');
/// ```
final activeTagCountProvider = Provider.autoDispose<int>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.activeTagCount;
});

/// Provider for deleted tag count
///
/// Returns count of soft-deleted tags
final deletedTagCountProvider = Provider.autoDispose<int>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.deletedTagCount;
});

/// Provider for total tag count
///
/// Returns total count of all tags including deleted
final totalTagCountProvider = Provider.autoDispose<int>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.totalTagCount;
});

/// Provider for unique color count
///
/// Returns number of unique colors used in tags
final uniqueColorCountProvider = Provider.autoDispose<int>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.uniqueColors.length;
});

/// Provider for parent tag count
///
/// Returns count of root-level tags
final parentTagCountProvider = Provider.autoDispose<int>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.parentTags.length;
});

/// Provider for most used tag
///
/// Returns the tag with highest usage count
///
/// Usage:
/// ```dart
/// final mostUsed = ref.watch(mostUsedTagProvider);
/// if (mostUsed != null) {
///   Text('Most popular: ${mostUsed.name}');
/// }
/// ```
final mostUsedTagProvider = Provider.autoDispose<TagEntity?>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  final allTags = tagState.flatAllTags;
  if (allTags.isEmpty) return null;
  return allTags.reduce((a, b) => a.usageCount > b.usageCount ? a : b);
});

// ============================================================================
// Derived State Providers - Loading States
// ============================================================================

/// Provider for tags loading state
///
/// Returns true if tags are loading
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(isTagsLoadingProvider);
/// if (isLoading) CircularProgressIndicator();
/// ```
final isTagsLoadingProvider = Provider.autoDispose<bool>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.isLoadingTags;
});

/// Provider for popular tags loading state
///
/// Returns true if popular tags are loading
final isPopularTagsLoadingProvider = Provider.autoDispose<bool>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.isLoadingPopular;
});

/// Provider for deleted tags loading state
///
/// Returns true if deleted tags are loading
final isDeletedTagsLoadingProvider = Provider.autoDispose<bool>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.isLoadingDeleted;
});

/// Provider for any loading state
///
/// Returns true if any tag operation is loading
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(isAnyTagLoadingProvider);
/// if (isLoading) LoadingOverlay();
/// ```
final isAnyTagLoadingProvider = Provider.autoDispose<bool>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.isAnyLoading;
});

/// Provider for operation in progress state
///
/// Returns true if any tag operation (create, update, delete, merge) is in progress
///
/// Usage:
/// ```dart
/// final isProcessing = ref.watch(isTagOperationInProgressProvider);
/// ElevatedButton(
///   onPressed: isProcessing ? null : () => createTag(),
/// );
/// ```
final isTagOperationInProgressProvider = Provider.autoDispose<bool>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.isAnyOperationInProgress;
});

// ============================================================================
// Derived State Providers - Errors
// ============================================================================

/// Provider for operation error
///
/// Returns error from tag operations (create, update, delete, merge)
///
/// Usage:
/// ```dart
/// ref.listen(tagOperationErrorProvider, (previous, next) {
///   if (next != null) {
///     showErrorSnackBar(next.message);
///   }
/// });
/// ```
final tagOperationErrorProvider = Provider.autoDispose((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.operationError;
});

/// Provider for tags loading error
///
/// Returns error from loading tags
final tagsErrorProvider = Provider.autoDispose((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.error;
});

/// Provider for popular tags error
///
/// Returns error from loading popular tags
final popularTagsErrorProvider = Provider.autoDispose((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.popularError;
});

/// Provider for any error state
///
/// Returns true if any tag operation has an error
///
/// Usage:
/// ```dart
/// final hasError = ref.watch(hasAnyTagErrorProvider);
/// if (hasError) ErrorBanner();
/// ```
final hasAnyTagErrorProvider = Provider.autoDispose<bool>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.hasAnyError;
});

// ============================================================================
// Derived State Providers - Filters and Sorting
// ============================================================================

/// Provider for current search query
///
/// Returns current tag search query
final currentTagSearchQueryProvider = Provider.autoDispose<String?>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.currentSearchQuery;
});

/// Provider for current color filter
///
/// Returns currently selected color filter
///
/// Usage:
/// ```dart
/// final colorFilter = ref.watch(currentColorFilterProvider);
/// if (colorFilter != null) {
///   // Show filtered tags
/// }
/// ```
final currentColorFilterProvider = Provider.autoDispose<String?>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.currentColorFilter;
});

/// Provider for current parent tag filter
///
/// Returns currently selected parent tag filter (for hierarchy)
final currentParentTagFilterProvider = Provider.autoDispose<String?>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.currentParentTagFilter;
});

/// Provider for sort by usage flag
///
/// Returns true if sorting by usage count
final sortByUsageProvider = Provider.autoDispose<bool>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.sortByUsage;
});

/// Provider for sort direction (ascending/descending)
///
/// Returns true if sorting in ascending order
final isSortAscendingProvider = Provider.autoDispose<bool>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.sortAscending;
});

/// Provider for include deleted tags filter
///
/// Returns true if deleted tags should be included
final includeDeletedTagsProvider = Provider.autoDispose<bool>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.includeDeleted;
});

// ============================================================================
// Derived State Providers - Computed Values
// ============================================================================

/// Provider for unique colors from all tags
///
/// Returns set of color codes used in tags
///
/// Usage:
/// ```dart
/// final colors = ref.watch(tagColorsProvider);
/// for (final color in colors) {
///   ColorOption(color: color);
/// }
/// ```
final tagColorsProvider = Provider.autoDispose<Set<String>>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.uniqueColors;
});

/// Provider for tags grouped by color
///
/// Returns map of tags grouped by their color
///
/// Usage:
/// ```dart
/// final groupedTags = ref.watch(tagsGroupedByColorProvider);
/// for (final color in groupedTags.keys) {
///   ColorSection(color: color, tags: groupedTags[color]!);
/// }
/// ```
final tagsGroupedByColorProvider =
    Provider.autoDispose<Map<String, List<TagEntity>>>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.tagsByColor;
});

/// Provider for child tags of selected tag
///
/// Returns child tags of the currently selected tag
///
/// Usage:
/// ```dart
/// final childTags = ref.watch(childTagsOfSelectedProvider);
/// ChildTagsList(children: childTags);
/// ```
final childTagsOfSelectedProvider =
    Provider.autoDispose<List<TagEntity>>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  final selectedTag = tagState.selectedTag;

  if (selectedTag == null) return [];

  return tagState.getChildTags(selectedTag.id);
});

/// Provider for filtered tags by color
///
/// Returns tags filtered by current color filter
///
/// Usage:
/// ```dart
/// final filteredByColor = ref.watch(tagsByColorFilterProvider);
/// TagList(tags: filteredByColor);
/// ```
final tagsByColorFilterProvider = Provider.autoDispose<List<TagEntity>>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  final colorFilter = tagState.currentColorFilter;

  if (colorFilter == null) return tagState.flatAllTags;

  return tagState.flatAllTags
      .where((tag) => tag.color == colorFilter)
      .toList();
});

/// Provider for filtered tags by parent
///
/// Returns tags filtered by current parent tag filter
final tagsByParentFilterProvider = Provider.autoDispose<List<TagEntity>>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  final parentFilter = tagState.currentParentTagFilter;

  if (parentFilter == null) return tagState.flatAllTags;

  return tagState.getChildTags(parentFilter);
});

/// Provider for sorted tags
///
/// Returns tags sorted by current sort option
///
/// Usage:
/// ```dart
/// final sortedTags = ref.watch(sortedTagsProvider);
/// TagsList(tags: sortedTags);
/// ```
final sortedTagsProvider = Provider.autoDispose<List<TagEntity>>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  final tags = List<TagEntity>.from(tagState.flatAllTags);

  if (tagState.sortByUsage) {
    tags.sort((a, b) => tagState.sortAscending
        ? a.usageCount.compareTo(b.usageCount)
        : b.usageCount.compareTo(a.usageCount));
  } else {
    tags.sort((a, b) => tagState.sortAscending
        ? a.name.compareTo(b.name)
        : b.name.compareTo(a.name));
  }

  return tags;
});

/// Provider for checking if refresh is needed
///
/// Returns true if any tag list needs refresh (based on 5-minute threshold)
///
/// Usage:
/// ```dart
/// final needsRefresh = ref.watch(tagsNeedRefreshProvider);
/// if (needsRefresh) {
///   ref.read(tagNotifierProvider.notifier).refreshAll(userId);
/// }
/// ```
final tagsNeedRefreshProvider = Provider.autoDispose<bool>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.needsRefreshAll ||
      tagState.needsRefreshPopular ||
      tagState.needsRefreshDeleted;
});

/// Provider for current merge operation
///
/// Returns the merge operation currently in progress
///
/// Usage:
/// ```dart
/// final mergeOp = ref.watch(currentMergeOperationProvider);
/// if (mergeOp != null) {
///   Text('Merging ${mergeOp.sourceTagId} into ${mergeOp.targetTagId}');
/// }
/// ```
final currentMergeOperationProvider =
    Provider.autoDispose<MergeOperation?>((ref) {
  final tagState = ref.watch(tagNotifierProvider);
  return tagState.currentMergeOperation;
});

/// Provider for high-usage tags
///
/// Returns tags with usage count above average
///
/// Usage:
/// ```dart
/// final frequentTags = ref.watch(frequentTagsProvider);
/// FrequentTagsWidget(tags: frequentTags);
/// ```
final frequentTagsProvider = Provider.autoDispose<List<TagEntity>>((ref) {
  final allTags = ref.watch(allTagsProvider);
  if (allTags.isEmpty) return [];

  final avgUsage =
      allTags.map((t) => t.usageCount).reduce((a, b) => a + b) /
          allTags.length;

  return allTags.where((tag) => tag.usageCount > avgUsage).toList();
});

/// Provider for rarely-used tags
///
/// Returns tags with low usage count
final rarelyUsedTagsProvider = Provider.autoDispose<List<TagEntity>>((ref) {
  final allTags = ref.watch(allTagsProvider);
  return allTags.where((tag) => tag.usageCount <= 1).toList();
});

/// Provider for tags by color with usage info
///
/// Returns color statistics
///
/// Usage:
/// ```dart
/// final colorStats = ref.watch(colorStatisticsProvider);
/// for (final stat in colorStats) {
///   ColorStat(color: stat['color'], count: stat['count']);
/// }
/// ```
final colorStatisticsProvider =
    Provider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final groupedByColor = ref.watch(tagsGroupedByColorProvider);
  return groupedByColor.entries.map((e) {
    final usageSum = e.value.fold(0, (sum, tag) => sum + tag.usageCount);
    return {
      'color': e.key,
      'count': e.value.length,
      'totalUsage': usageSum,
      'avgUsage': usageSum / e.value.length,
    };
  }).toList();
});
