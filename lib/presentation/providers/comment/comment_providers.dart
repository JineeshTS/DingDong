import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/comment_entity.dart';
import '../../../domain/usecases/comment/add_reaction_usecase.dart';
import '../../../domain/usecases/comment/create_comment_usecase.dart';
import '../../../domain/usecases/comment/delete_comment_usecase.dart';
import '../../../domain/usecases/comment/get_comment_count_usecase.dart';
import '../../../domain/usecases/comment/get_comments_with_mentions_usecase.dart';
import '../../../domain/usecases/comment/remove_reaction_usecase.dart';
import '../../../domain/usecases/comment/search_comments_usecase.dart';
import '../../../domain/usecases/comment/update_comment_usecase.dart';
import 'comment_notifier.dart';
import 'comment_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================
// These providers expose individual use cases from the DI container.
// They are auto-disposed when no longer needed for optimal memory management.

/// Provider for CreateCommentUseCase
///
/// Handles creation of new comments (top-level and threaded replies)
/// with support for mentions and attachments
final createCommentProvider = Provider.autoDispose<CreateCommentUseCase>(
  (ref) => sl<CreateCommentUseCase>(),
);

/// Provider for UpdateCommentUseCase
///
/// Handles updating existing comments with validation
/// and edit timestamp tracking
final updateCommentProvider = Provider.autoDispose<UpdateCommentUseCase>(
  (ref) => sl<UpdateCommentUseCase>(),
);

/// Provider for DeleteCommentUseCase
///
/// Handles soft deletion of comments
final deleteCommentProvider = Provider.autoDispose<DeleteCommentUseCase>(
  (ref) => sl<DeleteCommentUseCase>(),
);

/// Provider for AddReactionUseCase
///
/// Handles adding emoji reactions to comments
final addReactionProvider = Provider.autoDispose<AddReactionUseCase>(
  (ref) => sl<AddReactionUseCase>(),
);

/// Provider for RemoveReactionUseCase
///
/// Handles removing emoji reactions from comments
final removeReactionProvider = Provider.autoDispose<RemoveReactionUseCase>(
  (ref) => sl<RemoveReactionUseCase>(),
);

/// Provider for SearchCommentsUseCase
///
/// Searches comments with filters and pagination
final searchCommentsProvider = Provider.autoDispose<SearchCommentsUseCase>(
  (ref) => sl<SearchCommentsUseCase>(),
);

/// Provider for GetCommentsWithMentionsUseCase
///
/// Retrieves comments where user is mentioned
final getCommentsWithMentionsProvider =
    Provider.autoDispose<GetCommentsWithMentionsUseCase>(
  (ref) => sl<GetCommentsWithMentionsUseCase>(),
);

/// Provider for GetCommentCountUseCase
///
/// Gets count of comments for a task
final getCommentCountProvider = Provider.autoDispose<GetCommentCountUseCase>(
  (ref) => sl<GetCommentCountUseCase>(),
);

// ============================================================================
// Comment State Notifier Provider
// ============================================================================

/// Main comment state notifier provider
///
/// This is the primary provider for comment state management.
/// It should NOT be auto-disposed as we want to maintain comment
/// state throughout the app lifecycle.
///
/// Usage:
/// ```dart
/// // In a ConsumerWidget
/// final commentState = ref.watch(commentNotifierProvider);
/// final commentNotifier = ref.read(commentNotifierProvider.notifier);
///
/// // Get task comments
/// ref.listen(commentNotifierProvider, (previous, next) {
///   if (next.taskComments.items.isNotEmpty) {
///     // Handle comments update
///   }
/// });
///
/// // Perform comment actions
/// await commentNotifier.createComment(newComment);
/// await commentNotifier.addReaction(commentId, userId, '👍');
/// ```
final commentNotifierProvider =
    StateNotifierProvider<CommentNotifier, CommentState>(
  (ref) {
    return CommentNotifier(
      createCommentUseCase: ref.read(createCommentProvider),
      updateCommentUseCase: ref.read(updateCommentProvider),
      deleteCommentUseCase: ref.read(deleteCommentProvider),
      addReactionUseCase: ref.read(addReactionProvider),
      removeReactionUseCase: ref.read(removeReactionProvider),
      searchCommentsUseCase: ref.read(searchCommentsProvider),
      getCommentsWithMentionsUseCase:
          ref.read(getCommentsWithMentionsProvider),
      getCommentCountUseCase: ref.read(getCommentCountProvider),
    );
  },
);

// ============================================================================
// Derived State Providers - Comment Lists
// ============================================================================

/// Provider that exposes comments for current task
///
/// Returns paginated list of comments for the selected task
///
/// Usage:
/// ```dart
/// final taskComments = ref.watch(taskCommentsProvider);
/// ListView.builder(
///   itemCount: taskComments.itemCount,
///   itemBuilder: (context, index) => CommentTile(
///     comment: taskComments.items[index]
///   ),
/// );
/// ```
final taskCommentsProvider = Provider.autoDispose((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.taskComments;
});

/// Provider that exposes search results
///
/// Returns paginated search results
///
/// Usage:
/// ```dart
/// final searchResults = ref.watch(searchResultsProvider);
/// SearchResultsView(results: searchResults);
/// ```
final searchResultsProvider = Provider.autoDispose((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.searchResults;
});

/// Provider that exposes comments with mentions
///
/// Returns list of comments where user is mentioned
///
/// Usage:
/// ```dart
/// final mentionedComments = ref.watch(mentionedCommentsProvider);
/// MentionedCommentsView(comments: mentionedComments);
/// ```
final mentionedCommentsProvider =
    Provider.autoDispose<List<CommentEntity>>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.mentionedComments;
});

/// Provider that exposes replies to selected comment (thread)
///
/// Returns list of comments that are replies to the selected comment
///
/// Usage:
/// ```dart
/// final threadReplies = ref.watch(threadRepliesProvider);
/// ThreadView(replies: threadReplies);
/// ```
final threadRepliesProvider = Provider.autoDispose<List<CommentEntity>>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.threadReplies;
});

/// Provider that exposes selected comment
///
/// Returns currently selected/viewed comment
///
/// Usage:
/// ```dart
/// final selectedComment = ref.watch(selectedCommentProvider);
/// if (selectedComment != null) {
///   CommentDetailView(comment: selectedComment);
/// }
/// ```
final selectedCommentProvider = Provider.autoDispose<CommentEntity?>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.selectedComment;
});

// ============================================================================
// Derived State Providers - Counts and Statistics
// ============================================================================

/// Provider for task comment count
///
/// Returns count of comments for current task
///
/// Usage:
/// ```dart
/// final commentCount = ref.watch(taskCommentCountProvider);
/// Badge(label: '$commentCount');
/// ```
final taskCommentCountProvider = Provider.autoDispose<int>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.currentTaskCommentCount;
});

/// Provider for mentioned comments count
///
/// Returns count of comments where user is mentioned
///
/// Usage:
/// ```dart
/// final mentionCount = ref.watch(mentionedCommentsCountProvider);
/// if (mentionCount > 0) {
///   NotificationBadge(count: mentionCount);
/// }
/// ```
final mentionedCommentsCountProvider = Provider.autoDispose<int>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.mentionedCommentsCount;
});

/// Provider for thread replies count
///
/// Returns count of replies to selected comment
final threadRepliesCountProvider = Provider.autoDispose<int>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.threadReplies.length;
});

/// Provider for total reactions count in selected comment
///
/// Returns total count of all reactions on selected comment
final totalReactionsCountProvider = Provider.autoDispose<int>((ref) {
  final selectedComment = ref.watch(selectedCommentProvider);
  if (selectedComment == null) return 0;
  return selectedComment.totalReactions;
});

/// Provider for comment count for a specific task
///
/// Returns count of comments for the given task ID
/// Useful for displaying comment count in task lists
///
/// Usage:
/// ```dart
/// final taskId = 'task-123';
/// final count = ref.watch(commentCountForTaskProvider(taskId));
/// Text('${count} comments');
/// ```
final commentCountForTaskProvider =
    Provider.autoDispose.family<int, String>((ref, taskId) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.commentCountsByTask[taskId] ?? 0;
});

// ============================================================================
// Derived State Providers - Loading States
// ============================================================================

/// Provider for task comments loading state
///
/// Returns true if task comments are loading
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(isLoadingTaskCommentsProvider);
/// if (isLoading) CircularProgressIndicator();
/// ```
final isLoadingTaskCommentsProvider = Provider.autoDispose<bool>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.isLoadingComments;
});

/// Provider for mentions loading state
///
/// Returns true if mentions are loading
final isLoadingMentionsProvider = Provider.autoDispose<bool>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.isLoadingMentions;
});

/// Provider for thread loading state
///
/// Returns true if thread is loading
final isLoadingThreadProvider = Provider.autoDispose<bool>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.isLoadingThread;
});

/// Provider for search loading state
///
/// Returns true if search is in progress
final isSearchingProvider = Provider.autoDispose<bool>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.isSearching;
});

/// Provider for any loading state
///
/// Returns true if any comment operation is loading
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(isAnyCommentLoadingProvider);
/// if (isLoading) LoadingOverlay();
/// ```
final isAnyCommentLoadingProvider = Provider.autoDispose<bool>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.isAnyLoading;
});

/// Provider for operation in progress state
///
/// Returns true if any comment operation (create, update, delete, react) is in progress
///
/// Usage:
/// ```dart
/// final isProcessing = ref.watch(isCommentOperationInProgressProvider);
/// ElevatedButton(
///   onPressed: isProcessing ? null : () => createComment(),
/// );
/// ```
final isCommentOperationInProgressProvider = Provider.autoDispose<bool>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.isAnyOperationInProgress;
});

// ============================================================================
// Derived State Providers - Errors
// ============================================================================

/// Provider for operation error
///
/// Returns error from comment operations
///
/// Usage:
/// ```dart
/// ref.listen(commentOperationErrorProvider, (previous, next) {
///   if (next != null) {
///     showErrorSnackBar(next.message);
///   }
/// });
/// ```
final commentOperationErrorProvider = Provider.autoDispose((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.operationError;
});

/// Provider for search error
///
/// Returns error from comment search
final searchErrorProvider = Provider.autoDispose((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.searchError;
});

/// Provider for mentions error
///
/// Returns error from loading mentions
final mentionsErrorProvider = Provider.autoDispose((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.mentionsError;
});

/// Provider for thread error
///
/// Returns error from loading thread
final threadErrorProvider = Provider.autoDispose((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.threadError;
});

/// Provider for any error state
///
/// Returns true if any comment operation has an error
///
/// Usage:
/// ```dart
/// final hasError = ref.watch(hasAnyCommentErrorProvider);
/// if (hasError) ErrorBanner();
/// ```
final hasAnyCommentErrorProvider = Provider.autoDispose<bool>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.hasAnyError;
});

// ============================================================================
// Derived State Providers - Filters and Queries
// ============================================================================

/// Provider for current task ID filter
///
/// Returns ID of currently selected task
final currentTaskIdProvider = Provider.autoDispose<String?>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.currentTaskId;
});

/// Provider for current search query
///
/// Returns current search query string
final currentSearchQueryProvider = Provider.autoDispose<String?>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.currentSearchQuery;
});

// ============================================================================
// Derived State Providers - Computed Values
// ============================================================================

/// Provider for comments grouped by user
///
/// Returns map of comments grouped by author user ID
///
/// Usage:
/// ```dart
/// final groupedComments = ref.watch(commentsGroupedByUserProvider);
/// for (final userId in groupedComments.keys) {
///   UserCommentsSection(userId: userId, comments: groupedComments[userId]!);
/// }
/// ```
final commentsGroupedByUserProvider =
    Provider.autoDispose<Map<String, List<CommentEntity>>>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  final comments = commentState.taskComments.items;

  final grouped = <String, List<CommentEntity>>{};

  for (final comment in comments) {
    if (!grouped.containsKey(comment.userId)) {
      grouped[comment.userId] = [];
    }
    grouped[comment.userId]!.add(comment);
  }

  return grouped;
});

/// Provider for top-level comments (non-threaded)
///
/// Returns list of comments that are not replies
///
/// Usage:
/// ```dart
/// final topLevelComments = ref.watch(topLevelCommentsProvider);
/// CommentsList(comments: topLevelComments);
/// ```
final topLevelCommentsProvider =
    Provider.autoDispose<List<CommentEntity>>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.taskComments.items
      .where((comment) => comment.parentCommentId == null)
      .toList();
});

/// Provider for reply comments (threaded)
///
/// Returns list of comments that are replies to other comments
final replyCommentsProvider =
    Provider.autoDispose<List<CommentEntity>>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.taskComments.items
      .where((comment) => comment.parentCommentId != null)
      .toList();
});

/// Provider for comments with mentions
///
/// Returns list of comments that contain @mentions
///
/// Usage:
/// ```dart
/// final mentioningComments = ref.watch(commentsWithMentionsProvider);
/// MentionedUsersView(comments: mentioningComments);
/// ```
final commentsWithMentionsProvider =
    Provider.autoDispose<List<CommentEntity>>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.taskComments.items
      .where((comment) => comment.hasMentions)
      .toList();
});

/// Provider for comments with reactions
///
/// Returns list of comments that have emoji reactions
final commentsWithReactionsProvider =
    Provider.autoDispose<List<CommentEntity>>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.taskComments.items
      .where((comment) => comment.totalReactions > 0)
      .toList();
});

/// Provider for most reacted comments
///
/// Returns top comments sorted by reaction count
///
/// Usage:
/// ```dart
/// final topComments = ref.watch(mostReactedCommentsProvider);
/// PopularCommentsView(comments: topComments);
/// ```
final mostReactedCommentsProvider =
    Provider.autoDispose<List<CommentEntity>>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  final comments = commentState.taskComments.items;

  return List<CommentEntity>.from(comments)
    ..sort((a, b) => b.totalReactions.compareTo(a.totalReactions));
});

/// Provider for edited comments
///
/// Returns list of comments that have been edited
final editedCommentsProvider =
    Provider.autoDispose<List<CommentEntity>>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.taskComments.items
      .where((comment) => comment.isEdited)
      .toList();
});

/// Provider for comments with attachments
///
/// Returns list of comments that have attachments
final commentsWithAttachmentsProvider =
    Provider.autoDispose<List<CommentEntity>>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.taskComments.items
      .where((comment) => comment.hasAttachments)
      .toList();
});

/// Provider for checking if refresh is needed
///
/// Returns true if comment data needs refresh (based on 5-minute threshold)
///
/// Usage:
/// ```dart
/// final needsRefresh = ref.watch(commentsNeedRefreshProvider);
/// if (needsRefresh) {
///   ref.read(commentNotifierProvider.notifier).refreshAll(userId);
/// }
/// ```
final commentsNeedRefreshProvider = Provider.autoDispose<bool>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  return commentState.needsRefreshComments ||
      commentState.needsRefreshMentions;
});

/// Provider for reaction emoji frequencies
///
/// Returns map of emoji to frequency count (most used reactions)
///
/// Usage:
/// ```dart
/// final reactionFrequency = ref.watch(reactionFrequencyProvider);
/// ReactionPickerPopup(frequentEmojis: reactionFrequency.keys.toList());
/// ```
final reactionFrequencyProvider =
    Provider.autoDispose<Map<String, int>>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  final frequency = <String, int>{};

  for (final reactions in commentState.reactionsMap.values) {
    for (final emoji in reactions.keys) {
      frequency[emoji] = (frequency[emoji] ?? 0) + 1;
    }
  }

  return frequency;
});

/// Provider for recent comments
///
/// Returns most recent comments (ordered by creation date)
///
/// Usage:
/// ```dart
/// final recentComments = ref.watch(recentCommentsProvider);
/// RecentActivityWidget(comments: recentComments);
/// ```
final recentCommentsProvider =
    Provider.autoDispose<List<CommentEntity>>((ref) {
  final commentState = ref.watch(commentNotifierProvider);
  final comments = commentState.taskComments.items;

  return List<CommentEntity>.from(comments)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});
