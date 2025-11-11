import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/task_entity.dart';
import '../../common/pagination_state.dart';

part 'task_state.freezed.dart';

/// Task management state for the application
///
/// Manages task operations, lists, and filters with pagination support.
/// This state is used by [TaskNotifier] to track all task-related operations.
///
/// Features:
/// - Pagination support for task lists
/// - Multiple task views (all, today, overdue, completed, etc.)
/// - Real-time task updates
/// - Filter and sort capabilities
/// - Batch operations support
@freezed
class TaskState with _$TaskState {
  const factory TaskState({
    /// All tasks with pagination
    @Default(PaginationState()) PaginationState<TaskEntity> allTasks,

    /// Tasks due today
    @Default([]) List<TaskEntity> todayTasks,

    /// Overdue tasks
    @Default([]) List<TaskEntity> overdueTasks,

    /// Upcoming tasks (due within 7 days)
    @Default([]) List<TaskEntity> upcomingTasks,

    /// Completed tasks with pagination
    @Default(PaginationState()) PaginationState<TaskEntity> completedTasks,

    /// Tasks filtered by current list
    @Default(PaginationState()) PaginationState<TaskEntity> listTasks,

    /// Tasks filtered by current tag
    @Default([]) List<TaskEntity> tagTasks,

    /// Tasks filtered by current priority
    @Default([]) List<TaskEntity> priorityTasks,

    /// Tasks assigned to current user
    @Default([]) List<TaskEntity> assignedTasks,

    /// Search results with pagination
    @Default(PaginationState()) PaginationState<TaskEntity> searchResults,

    /// Currently selected/viewed task
    TaskEntity? selectedTask,

    /// Current list filter
    String? currentListId,

    /// Current tag filter
    String? currentTag,

    /// Current priority filter
    TaskPriority? currentPriority,

    /// Current search query
    String? currentSearchQuery,

    /// Current sort option
    @Default(TaskSortOption.dueDate) TaskSortOption sortOption,

    /// Sort in ascending order
    @Default(true) bool sortAscending,

    /// Include completed tasks in lists
    @Default(false) bool includeCompleted,

    /// Loading states
    @Default(false) bool isLoadingToday,
    @Default(false) bool isLoadingOverdue,
    @Default(false) bool isLoadingUpcoming,
    @Default(false) bool isLoadingAssigned,
    @Default(false) bool isLoadingTag,
    @Default(false) bool isLoadingPriority,
    @Default(false) bool isLoadingTask,

    /// Operation loading states
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,
    @Default(false) bool isDeleting,
    @Default(false) bool isCompleting,
    @Default(false) bool isBatchProcessing,

    /// Error states
    Failure? error,
    Failure? todayError,
    Failure? overdueError,
    Failure? upcomingError,
    Failure? assignedError,
    Failure? tagError,
    Failure? priorityError,
    Failure? operationError,

    /// Last refresh timestamps
    DateTime? lastRefreshAll,
    DateTime? lastRefreshToday,
    DateTime? lastRefreshOverdue,
    DateTime? lastRefreshUpcoming,
  }) = _TaskState;

  const TaskState._();

  /// Check if any task list is loading
  bool get isAnyLoading =>
      isLoadingToday ||
      isLoadingOverdue ||
      isLoadingUpcoming ||
      isLoadingAssigned ||
      isLoadingTag ||
      isLoadingPriority ||
      isLoadingTask ||
      allTasks.isLoading ||
      completedTasks.isLoading ||
      listTasks.isLoading ||
      searchResults.isLoading;

  /// Check if any operation is in progress
  bool get isAnyOperationInProgress =>
      isCreating ||
      isUpdating ||
      isDeleting ||
      isCompleting ||
      isBatchProcessing;

  /// Check if there are any errors
  bool get hasAnyError =>
      error != null ||
      todayError != null ||
      overdueError != null ||
      upcomingError != null ||
      assignedError != null ||
      tagError != null ||
      priorityError != null ||
      operationError != null;

  /// Get total count of today's tasks
  int get todayTaskCount => todayTasks.length;

  /// Get total count of overdue tasks
  int get overdueTaskCount => overdueTasks.length;

  /// Get total count of upcoming tasks
  int get upcomingTaskCount => upcomingTasks.length;

  /// Get total count of assigned tasks
  int get assignedTaskCount => assignedTasks.length;

  /// Check if data needs refresh (based on 5 minute threshold)
  bool needsRefresh(DateTime? lastRefresh) {
    if (lastRefresh == null) return true;
    final now = DateTime.now();
    return now.difference(lastRefresh).inMinutes >= 5;
  }

  /// Check if all tasks need refresh
  bool get needsRefreshAll => needsRefresh(lastRefreshAll);

  /// Check if today tasks need refresh
  bool get needsRefreshToday => needsRefresh(lastRefreshToday);

  /// Check if overdue tasks need refresh
  bool get needsRefreshOverdue => needsRefresh(lastRefreshOverdue);

  /// Check if upcoming tasks need refresh
  bool get needsRefreshUpcoming => needsRefresh(lastRefreshUpcoming);
}

/// Task sort options
enum TaskSortOption {
  dueDate,
  priority,
  title,
  createdDate,
  updatedDate,
  status,
  completedDate,
}
