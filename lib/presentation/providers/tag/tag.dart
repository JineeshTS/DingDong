/// Tag providers module
///
/// Exports all tag-related providers, state, and notifiers.
///
/// This module provides comprehensive tag management functionality including:
/// - Tag CRUD operations (Create, Read, Update, Delete)
/// - Tag color customization and management
/// - Tag hierarchy support (parent/child relationships)
/// - Usage tracking and popular tags identification
/// - Tag merging functionality
/// - Soft delete with restore capability
/// - Tag search and filtering by color/parent
/// - Pagination support for large tag lists
/// - Real-time tag updates and statistics
/// - Derived providers for common queries
///
/// ## Architecture
///
/// The tag providers follow the Clean Architecture pattern:
/// - **State**: Immutable state managed by Freezed (`TagState`)
/// - **Notifier**: Business logic and state updates (`TagNotifier`)
/// - **Providers**: Dependency injection and state access
/// - **Use Cases**: Domain layer operations (8 tag use cases)
///
/// ## Usage
///
/// ```dart
/// import 'package:dingdong/presentation/providers/tag/tag.dart';
///
/// class TagListScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Watch all tags
///     final allTags = ref.watch(allTagsProvider);
///     final isLoading = ref.watch(isTagsLoadingProvider);
///
///     // Get notifier for actions
///     final tagNotifier = ref.read(tagNotifierProvider.notifier);
///
///     return Column(
///       children: [
///         if (isLoading)
///           CircularProgressIndicator()
///         else
///           ListView.builder(
///             itemCount: allTags.length,
///             itemBuilder: (context, index) {
///               final tag = allTags[index];
///               return TagTile(
///                 tag: tag,
///                 onDelete: () => tagNotifier.deleteTag(tag.id),
///                 onUpdate: (updated) => tagNotifier.updateTag(updated),
///               );
///             },
///           ),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## Available Providers
///
/// ### State Provider
/// - `tagNotifierProvider` - Main tag state and notifier
///
/// ### Tag List Providers
/// - `allTagsProvider` - All active tags
/// - `popularTagsProvider` - Most frequently used tags
/// - `deletedTagsProvider` - Soft-deleted tags
/// - `parentTagsProvider` - Root-level tags (without parent)
/// - `hierarchicalTagsProvider` - Nested tags (with parent)
/// - `tagSearchResultsProvider` - Tag search results
/// - `selectedTagProvider` - Currently selected tag
///
/// ### Count Providers
/// - `activeTagCountProvider` - Count of active tags
/// - `deletedTagCountProvider` - Count of deleted tags
/// - `totalTagCountProvider` - Total tag count
/// - `uniqueColorCountProvider` - Count of unique colors
/// - `parentTagCountProvider` - Count of parent tags
/// - `mostUsedTagProvider` - Most frequently used tag
///
/// ### Loading State Providers
/// - `isTagsLoadingProvider` - Tags loading state
/// - `isPopularTagsLoadingProvider` - Popular tags loading state
/// - `isDeletedTagsLoadingProvider` - Deleted tags loading state
/// - `isAnyTagLoadingProvider` - Any tag list loading
/// - `isTagOperationInProgressProvider` - Tag operation in progress
///
/// ### Error Providers
/// - `tagOperationErrorProvider` - Operation errors
/// - `tagsErrorProvider` - Tag loading errors
/// - `popularTagsErrorProvider` - Popular tags errors
/// - `hasAnyTagErrorProvider` - Any error state
///
/// ### Filter Providers
/// - `currentTagSearchQueryProvider` - Current search query
/// - `currentColorFilterProvider` - Current color filter
/// - `currentParentTagFilterProvider` - Current parent tag filter
/// - `sortByUsageProvider` - Sort by usage flag
/// - `isSortAscendingProvider` - Sort direction
/// - `includeDeletedTagsProvider` - Include deleted tags
///
/// ### Color Management Providers
/// - `tagColorsProvider` - Unique colors from all tags
/// - `tagsGroupedByColorProvider` - Tags grouped by color
/// - `tagsByColorFilterProvider` - Tags filtered by color
/// - `colorStatisticsProvider` - Color usage statistics
///
/// ### Hierarchy Providers
/// - `childTagsOfSelectedProvider` - Child tags of selected tag
/// - `tagsByParentFilterProvider` - Tags filtered by parent
///
/// ### Sorted & Computed Providers
/// - `sortedTagsProvider` - Tags sorted by current option
/// - `frequentTagsProvider` - Frequently used tags
/// - `rarelyUsedTagsProvider` - Rarely used tags
/// - `currentMergeOperationProvider` - Current merge operation
/// - `tagsNeedRefreshProvider` - Refresh needed indicator
///
/// ### Use Case Providers (8 total)
/// - `createTagProvider` - Create tag use case
/// - `updateTagProvider` - Update tag use case
/// - `deleteTagProvider` - Delete tag use case (soft delete)
/// - `getTagsProvider` - Get all tags use case
/// - `mergeTagsProvider` - Merge tags use case
/// - `incrementTagUsageProvider` - Increment tag usage use case
/// - `getPopularTagsProvider` - Get popular tags use case
/// - `restoreTagProvider` - Restore deleted tag use case
///
/// ## Best Practices
///
/// 1. **Watch vs Read**
///    - Use `ref.watch()` to rebuild on state changes
///    - Use `ref.read()` for one-time actions/callbacks
///
/// 2. **Error Handling**
///    - Listen to error providers with `ref.listen()`
///    - Show user-friendly error messages
///    - Clear errors after handling
///
/// 3. **Color Management**
///    - Use `tagColorsProvider` to get unique colors
///    - Use `tagsGroupedByColorProvider` for color-based organization
///    - Filter by color with `currentColorFilterProvider`
///
/// 4. **Tag Hierarchy**
///    - Use `parentTagsProvider` for root-level tags
///    - Use `childTagsOfSelectedProvider` for nested tags
///    - Support parent/child relationships with filtering
///
/// 5. **Usage Tracking**
///    - Use `popularTagsProvider` for most-used tags
///    - Call `incrementTagUsage()` when assigning tags to tasks
///    - Use `frequentTagsProvider` for high-usage recommendations
///
/// 6. **Tag Merging**
///    - Check `currentMergeOperationProvider` for merge status
///    - Use `mergeTags()` to consolidate duplicate tags
///    - Update task associations after merge
///
/// 7. **Performance**
///    - Use specific providers instead of watching entire state
///    - Leverage auto-dispose providers for temporary data
///    - Implement proper list keys for efficient rebuilds
///
/// 8. **Soft Delete & Restore**
///    - Use `deleteTag()` for soft deletion
///    - Use `restoreTag()` to recover deleted tags
///    - Monitor `deletedTagsProvider` for restore UI
///
/// ## Common Patterns
///
/// ### Creating a Tag
/// ```dart
/// final tagNotifier = ref.read(tagNotifierProvider.notifier);
/// await tagNotifier.createTag(
///   TagEntity(
///     id: 'tag_1',
///     userId: userId,
///     name: 'Important',
///     color: '#FF5733',
///     createdAt: DateTime.now(),
///     updatedAt: DateTime.now(),
///   ),
/// );
/// ```
///
/// ### Merging Tags
/// ```dart
/// await tagNotifier.mergeTags(
///   sourceTagId: 'old_tag_id',
///   targetTagId: 'new_tag_id',
/// );
/// ```
///
/// ### Tracking Usage
/// ```dart
/// await tagNotifier.incrementTagUsage('tag_id');
/// ```
///
/// ### Filtering by Color
/// ```dart
/// final tagNotifier = ref.read(tagNotifierProvider.notifier);
/// tagNotifier.filterByColor('#FF5733');
/// final filtered = ref.watch(tagsByColorFilterProvider);
/// ```
///
export 'tag_notifier.dart';
export 'tag_providers.dart';
export 'tag_state.dart';
