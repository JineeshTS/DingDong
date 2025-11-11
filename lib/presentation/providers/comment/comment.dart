/// Comment providers module
///
/// Exports all comment-related providers, state, and notifiers.
///
/// This module provides comprehensive comment management functionality including:
/// - Comment CRUD operations (Create, Read, Update, Delete)
/// - Thread/reply management for nested discussions
/// - Emoji reaction system with reaction tracking
/// - @mentions support and notification tracking
/// - Comment search with advanced filters
/// - Comment count tracking per task
/// - Pagination support for large comment lists
/// - Real-time comment updates
/// - Soft delete support
/// - Derived providers for common queries
///
/// ## Architecture
///
/// The comment providers follow the Clean Architecture pattern:
/// - **State**: Immutable state managed by Freezed (`CommentState`)
/// - **Notifier**: Business logic and state updates (`CommentNotifier`)
/// - **Providers**: Dependency injection and state access
/// - **Use Cases**: Domain layer operations (8 comment use cases)
///
/// ## Usage
///
/// ```dart
/// import 'package:dingdong/presentation/providers/comment/comment.dart';
///
/// class TaskCommentsScreen extends ConsumerWidget {
///   final String taskId;
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Watch task comments
///     final taskComments = ref.watch(taskCommentsProvider);
///     final isLoading = ref.watch(isLoadingTaskCommentsProvider);
///     final commentCount = ref.watch(taskCommentCountProvider);
///
///     // Get notifier for actions
///     final commentNotifier = ref.read(commentNotifierProvider.notifier);
///
///     return Column(
///       children: [
///         Text('Comments: $commentCount'),
///         if (isLoading)
///           CircularProgressIndicator()
///         else
///           ListView.builder(
///             itemCount: taskComments.itemCount,
///             itemBuilder: (context, index) {
///               final comment = taskComments.items[index];
///               return CommentTile(
///                 comment: comment,
///                 onReply: (content) => commentNotifier.createComment(
///                   CommentEntity(
///                     id: generateId(),
///                     taskId: taskId,
///                     userId: currentUserId,
///                     parentCommentId: comment.id,
///                     content: content,
///                     createdAt: DateTime.now(),
///                     updatedAt: DateTime.now(),
///                   ),
///                 ),
///                 onReact: (emoji) => commentNotifier.addReaction(
///                   commentId: comment.id,
///                   userId: currentUserId,
///                   emoji: emoji,
///                 ),
///                 onDelete: () => commentNotifier.deleteComment(comment.id),
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
/// - `commentNotifierProvider` - Main comment state and notifier
///
/// ### Comment List Providers
/// - `taskCommentsProvider` - Comments for current task (paginated)
/// - `searchResultsProvider` - Search results (paginated)
/// - `mentionedCommentsProvider` - Comments where user is mentioned
/// - `threadRepliesProvider` - Replies to selected comment
/// - `selectedCommentProvider` - Currently selected comment
/// - `topLevelCommentsProvider` - Top-level comments only
/// - `replyCommentsProvider` - Reply comments only
/// - `commentsWithMentionsProvider` - Comments with @mentions
/// - `commentsWithReactionsProvider` - Comments with emoji reactions
/// - `commentsWithAttachmentsProvider` - Comments with attachments
/// - `mostReactedCommentsProvider` - Sorted by reactions
/// - `editedCommentsProvider` - Comments that were edited
/// - `recentCommentsProvider` - Sorted by creation date
///
/// ### Count Providers
/// - `taskCommentCountProvider` - Count of comments for current task
/// - `mentionedCommentsCountProvider` - Count of mention comments
/// - `threadRepliesCountProvider` - Count of thread replies
/// - `totalReactionsCountProvider` - Total reactions on selected comment
/// - `commentCountForTaskProvider(taskId)` - Count for specific task (family)
///
/// ### Loading State Providers
/// - `isLoadingTaskCommentsProvider` - Task comments loading state
/// - `isLoadingMentionsProvider` - Mentions loading state
/// - `isLoadingThreadProvider` - Thread loading state
/// - `isSearchingProvider` - Search in progress
/// - `isAnyCommentLoadingProvider` - Any comment list loading
/// - `isCommentOperationInProgressProvider` - Comment operation in progress
///
/// ### Error Providers
/// - `commentOperationErrorProvider` - Operation errors
/// - `searchErrorProvider` - Search errors
/// - `mentionsErrorProvider` - Mention loading errors
/// - `threadErrorProvider` - Thread loading errors
/// - `hasAnyCommentErrorProvider` - Any error state
///
/// ### Filter Providers
/// - `currentTaskIdProvider` - Current task filter
/// - `currentSearchQueryProvider` - Current search query
///
/// ### Computed Providers
/// - `commentsGroupedByUserProvider` - Comments grouped by author
/// - `reactionFrequencyProvider` - Most used reactions
/// - `commentsNeedRefreshProvider` - Refresh needed indicator
///
/// ### Use Case Providers (8 total)
/// - `createCommentProvider` - Create comment use case
/// - `updateCommentProvider` - Update comment use case
/// - `deleteCommentProvider` - Delete comment use case
/// - `addReactionProvider` - Add reaction use case
/// - `removeReactionProvider` - Remove reaction use case
/// - `searchCommentsProvider` - Search comments use case
/// - `getCommentsWithMentionsProvider` - Get mentions use case
/// - `getCommentCountProvider` - Get comment count use case
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
/// 3. **Pagination**
///    - Check `canLoadMore` before loading next page
///    - Use `loadMore: true` parameter for pagination
///    - Handle loading states appropriately
///
/// 4. **Thread Management**
///    - Use `loadCommentThread(commentId)` to view replies
///    - Create replies with `parentCommentId` set
///    - Maximum thread depth is 5 levels
///
/// 5. **Reactions**
///    - Use `addReaction()` for emoji reactions
///    - Use `removeReaction()` to remove reactions
///    - Check `commentsWithReactionsProvider` for popular comments
///    - Use `reactionFrequencyProvider` to suggest common emojis
///
/// 6. **Mentions**
///    - Watch `mentionedCommentsProvider` for mention notifications
///    - Extract mentions from content before creating comments
///    - Use `getCommentsWithMentions()` to find mentions
///
/// 7. **Performance**
///    - Use specific providers instead of watching entire state
///    - Leverage auto-dispose providers for temporary data
///    - Implement proper list keys for efficient rebuilds
///    - Paginate large comment lists
///
/// 8. **Search**
///    - Query minimum 2 characters, maximum 100 characters
///    - Use `clearSearch()` to reset search state
///    - Results are case-insensitive
///
export 'comment_notifier.dart';
export 'comment_providers.dart';
export 'comment_state.dart';
