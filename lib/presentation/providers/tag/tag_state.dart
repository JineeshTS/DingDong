import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/tag_entity.dart';
import '../../common/pagination_state.dart';

part 'tag_state.freezed.dart';

/// Tag management state for the application
///
/// Manages tag operations, hierarchies, and usage tracking with pagination support.
/// This state is used by [TagNotifier] to track all tag-related operations.
///
/// Features:
/// - Tag CRUD operations with color customization
/// - Tag hierarchy (parent/child relationships)
/// - Usage tracking and popular tags management
/// - Tag merging functionality
/// - Soft delete with restore capability
/// - Pagination support for tag lists
/// - Tag filtering by color, hierarchy, and popularity
@freezed
class TagState with _$TagState {
  const factory TagState({
    /// All active tags with pagination
    @Default(PaginationState()) PaginationState<TagEntity> allTags,

    /// All tags including deleted ones
    @Default(PaginationState()) PaginationState<TagEntity> allTagsIncludingDeleted,

    /// Popular tags (most used) with pagination
    @Default(PaginationState()) PaginationState<TagEntity> popularTags,

    /// Deleted tags with pagination
    @Default(PaginationState()) PaginationState<TagEntity> deletedTags,

    /// Tags grouped by color
    @Default({}) Map<String, List<TagEntity>> tagsByColor,

    /// Hierarchical tags (with parent-child relationships)
    @Default([]) List<TagEntity> hierarchicalTags,

    /// Currently selected/viewed tag
    TagEntity? selectedTag,

    /// Search results for tags
    @Default(PaginationState()) PaginationState<TagEntity> searchResults,

    /// Current search query
    String? currentSearchQuery,

    /// Current color filter
    String? currentColorFilter,

    /// Current parent tag filter (for hierarchy)
    String? currentParentTagFilter,

    /// Sort by usage count
    @Default(false) bool sortByUsage,

    /// Sort in ascending order
    @Default(true) bool sortAscending,

    /// Include deleted tags in lists
    @Default(false) bool includeDeleted,

    /// Tags being merged (source and target IDs)
    MergeOperation? currentMergeOperation,

    /// Loading states
    @Default(false) bool isLoadingTags,
    @Default(false) bool isLoadingPopular,
    @Default(false) bool isLoadingDeleted,
    @Default(false) bool isLoadingTag,
    @Default(false) bool isSearching,

    /// Operation loading states
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,
    @Default(false) bool isDeleting,
    @Default(false) bool isRestoring,
    @Default(false) bool isMerging,

    /// Error states
    Failure? error,
    Failure? popularError,
    Failure? deletedError,
    Failure? operationError,

    /// Last refresh timestamps
    DateTime? lastRefreshAll,
    DateTime? lastRefreshPopular,
    DateTime? lastRefreshDeleted,
  }) = _TagState;

  const TagState._();

  /// Check if any tag list is loading
  bool get isAnyLoading =>
      isLoadingTags ||
      isLoadingPopular ||
      isLoadingDeleted ||
      isLoadingTag ||
      isSearching ||
      allTags.isLoading ||
      popularTags.isLoading ||
      deletedTags.isLoading ||
      searchResults.isLoading;

  /// Check if any operation is in progress
  bool get isAnyOperationInProgress =>
      isCreating ||
      isUpdating ||
      isDeleting ||
      isRestoring ||
      isMerging;

  /// Check if there are any errors
  bool get hasAnyError =>
      error != null ||
      popularError != null ||
      deletedError != null ||
      operationError != null;

  /// Get total count of active tags
  int get activeTagCount => allTags.itemCount;

  /// Get total count of deleted tags
  int get deletedTagCount => deletedTags.itemCount;

  /// Get total count of all tags
  int get totalTagCount => allTags.itemCount + deletedTags.itemCount;

  /// Check if data needs refresh (based on 5 minute threshold)
  bool needsRefresh(DateTime? lastRefresh) {
    if (lastRefresh == null) return true;
    final now = DateTime.now();
    return now.difference(lastRefresh).inMinutes >= 5;
  }

  /// Check if all tags need refresh
  bool get needsRefreshAll => needsRefresh(lastRefreshAll);

  /// Check if popular tags need refresh
  bool get needsRefreshPopular => needsRefresh(lastRefreshPopular);

  /// Check if deleted tags need refresh
  bool get needsRefreshDeleted => needsRefresh(lastRefreshDeleted);

  /// Get flat list of all tags (excluding deleted)
  List<TagEntity> get flatAllTags => allTags.items;

  /// Get flat list of all deleted tags
  List<TagEntity> get flatDeletedTags => deletedTags.items;

  /// Get flat list of popular tags
  List<TagEntity> get flatPopularTags => popularTags.items;

  /// Get unique colors from all tags
  Set<String> get uniqueColors =>
      allTags.items.map((tag) => tag.color).toSet();

  /// Get parent tags (tags without parent)
  List<TagEntity> get parentTags =>
      allTags.items.where((tag) => !tag.isNested).toList();

  /// Get child tags for a specific parent
  List<TagEntity> getChildTags(String parentTagId) =>
      allTags.items.where((tag) => tag.parentTagId == parentTagId).toList();
}

/// Represents a merge operation in progress
@freezed
class MergeOperation with _$MergeOperation {
  const factory MergeOperation({
    required String sourceTagId,
    required String targetTagId,
  }) = _MergeOperation;
}
