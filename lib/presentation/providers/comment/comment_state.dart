import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/comment_entity.dart';
import '../../common/pagination_state.dart';

part 'comment_state.freezed.dart';

/// Comment management state for the application
///
/// Manages comment operations, threads, reactions, and mentions with pagination support.
/// This state is used by [CommentNotifier] to track all comment-related operations.
///
/// Features:
/// - Thread/reply management (parent-child comments)
/// - Emoji reactions system with user tracking
/// - @mentions support with dedicated provider
/// - Search functionality with pagination
/// - Comment count tracking per task
/// - Real-time comment updates
/// - Soft delete support
@freezed
class CommentState with _$CommentState {
  const factory CommentState({
    /// Comments for the currently selected task with pagination
    @Default(PaginationState()) PaginationState<CommentEntity> taskComments,

    /// Search results with pagination
    @Default(PaginationState()) PaginationState<CommentEntity> searchResults,

    /// Comments where current user is mentioned
    @Default([]) List<CommentEntity> mentionedComments,

    /// Currently selected/viewed comment
    CommentEntity? selectedComment,

    /// Comments that are replies to selected comment (threaded)
    @Default([]) List<CommentEntity> threadReplies,

    /// Comment count for current task
    @Default(0) int currentTaskCommentCount,

    /// Map of task IDs to comment counts (for quick lookup)
    @Default({}) Map<String, int> commentCountsByTask,

    /// Currently selected task ID (for filtering comments)
    String? currentTaskId,

    /// Current search query
    String? currentSearchQuery,

    /// Map of comment IDs to their reactions for quick lookup
    /// Format: commentId -> (emoji -> count)
    @Default({}) Map<String, Map<String, int>> reactionsMap,

    /// Loading states
    @Default(false) bool isLoadingComments,
    @Default(false) bool isLoadingMentions,
    @Default(false) bool isLoadingThread,
    @Default(false) bool isSearching,

    /// Operation loading states
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,
    @Default(false) bool isDeleting,
    @Default(false) bool isReacting,

    /// Error states
    Failure? error,
    Failure? searchError,
    Failure? mentionsError,
    Failure? threadError,
    Failure? operationError,

    /// Last refresh timestamps
    DateTime? lastRefreshComments,
    DateTime? lastRefreshMentions,
  }) = _CommentState;

  const CommentState._();

  /// Check if any comment list is loading
  bool get isAnyLoading =>
      isLoadingComments ||
      isLoadingMentions ||
      isLoadingThread ||
      isSearching ||
      taskComments.isLoading ||
      searchResults.isLoading;

  /// Check if any operation is in progress
  bool get isAnyOperationInProgress =>
      isCreating || isUpdating || isDeleting || isReacting;

  /// Check if there are any errors
  bool get hasAnyError =>
      error != null ||
      searchError != null ||
      mentionsError != null ||
      threadError != null ||
      operationError != null;

  /// Get mentioned comments count
  int get mentionedCommentsCount => mentionedComments.length;

  /// Check if data needs refresh (based on 5 minute threshold)
  bool needsRefresh(DateTime? lastRefresh) {
    if (lastRefresh == null) return true;
    final now = DateTime.now();
    return now.difference(lastRefresh).inMinutes >= 5;
  }

  /// Check if comments need refresh
  bool get needsRefreshComments => needsRefresh(lastRefreshComments);

  /// Check if mentions need refresh
  bool get needsRefreshMentions => needsRefresh(lastRefreshMentions);
}

/// Sort options for comments
enum CommentSortOption {
  newestFirst,
  oldestFirst,
  mostReactions,
  leastReactions,
}
