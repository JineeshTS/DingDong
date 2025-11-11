import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task/add_subtask_usecase.dart';
import '../../../domain/usecases/task/archive_task_usecase.dart';
import '../../../domain/usecases/task/assign_task_usecase.dart';
import '../../../domain/usecases/task/batch_complete_tasks_usecase.dart';
import '../../../domain/usecases/task/batch_delete_tasks_usecase.dart';
import '../../../domain/usecases/task/complete_task_usecase.dart';
import '../../../domain/usecases/task/create_task_usecase.dart';
import '../../../domain/usecases/task/delete_task_usecase.dart';
import '../../../domain/usecases/task/duplicate_task_usecase.dart';
import '../../../domain/usecases/task/get_assigned_tasks_usecase.dart';
import '../../../domain/usecases/task/get_completed_tasks_usecase.dart';
import '../../../domain/usecases/task/get_overdue_tasks_usecase.dart';
import '../../../domain/usecases/task/get_task_usecase.dart';
import '../../../domain/usecases/task/get_tasks_by_date_range_usecase.dart';
import '../../../domain/usecases/task/get_tasks_by_list_usecase.dart';
import '../../../domain/usecases/task/get_tasks_by_priority_usecase.dart';
import '../../../domain/usecases/task/get_tasks_by_tag_usecase.dart';
import '../../../domain/usecases/task/get_tasks_due_today_usecase.dart';
import '../../../domain/usecases/task/get_upcoming_tasks_usecase.dart';
import '../../../domain/usecases/task/move_task_usecase.dart';
import '../../../domain/usecases/task/remove_subtask_usecase.dart';
import '../../../domain/usecases/task/search_tasks_usecase.dart';
import '../../../domain/usecases/task/unarchive_task_usecase.dart';
import '../../../domain/usecases/task/unassign_task_usecase.dart';
import '../../../domain/usecases/task/uncomplete_task_usecase.dart';
import '../../../domain/usecases/task/update_task_usecase.dart';
import 'task_state.dart';

/// StateNotifier for managing task state
///
/// Handles all task-related operations including:
/// - CRUD operations (Create, Read, Update, Delete)
/// - Task completion and uncomplete
/// - Batch operations
/// - Task assignment and unassignment
/// - Subtask management
/// - Task archiving
/// - Task search and filtering
/// - Pagination support
/// - Real-time task updates
///
/// This notifier integrates with all 26 task use cases
/// and manages the TaskState throughout the application lifecycle.
class TaskNotifier extends StateNotifier<TaskState> {
  // Use cases
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final GetTaskUseCase _getTaskUseCase;
  final CompleteTaskUseCase _completeTaskUseCase;
  final UncompleteTaskUseCase _uncompleteTaskUseCase;
  final GetTasksDueTodayUseCase _getTasksDueTodayUseCase;
  final GetOverdueTasksUseCase _getOverdueTasksUseCase;
  final GetUpcomingTasksUseCase _getUpcomingTasksUseCase;
  final GetCompletedTasksUseCase _getCompletedTasksUseCase;
  final GetTasksByListUseCase _getTasksByListUseCase;
  final GetTasksByPriorityUseCase _getTasksByPriorityUseCase;
  final GetTasksByTagUseCase _getTasksByTagUseCase;
  final GetAssignedTasksUseCase _getAssignedTasksUseCase;
  final GetTasksByDateRangeUseCase _getTasksByDateRangeUseCase;
  final SearchTasksUseCase _searchTasksUseCase;
  final BatchCompleteTasksUseCase _batchCompleteTasksUseCase;
  final BatchDeleteTasksUseCase _batchDeleteTasksUseCase;
  final DuplicateTaskUseCase _duplicateTaskUseCase;
  final MoveTaskUseCase _moveTaskUseCase;
  final AssignTaskUseCase _assignTaskUseCase;
  final UnassignTaskUseCase _unassignTaskUseCase;
  final ArchiveTaskUseCase _archiveTaskUseCase;
  final UnarchiveTaskUseCase _unarchiveTaskUseCase;
  final AddSubtaskUseCase _addSubtaskUseCase;
  final RemoveSubtaskUseCase _removeSubtaskUseCase;

  TaskNotifier({
    required CreateTaskUseCase createTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required GetTaskUseCase getTaskUseCase,
    required CompleteTaskUseCase completeTaskUseCase,
    required UncompleteTaskUseCase uncompleteTaskUseCase,
    required GetTasksDueTodayUseCase getTasksDueTodayUseCase,
    required GetOverdueTasksUseCase getOverdueTasksUseCase,
    required GetUpcomingTasksUseCase getUpcomingTasksUseCase,
    required GetCompletedTasksUseCase getCompletedTasksUseCase,
    required GetTasksByListUseCase getTasksByListUseCase,
    required GetTasksByPriorityUseCase getTasksByPriorityUseCase,
    required GetTasksByTagUseCase getTasksByTagUseCase,
    required GetAssignedTasksUseCase getAssignedTasksUseCase,
    required GetTasksByDateRangeUseCase getTasksByDateRangeUseCase,
    required SearchTasksUseCase searchTasksUseCase,
    required BatchCompleteTasksUseCase batchCompleteTasksUseCase,
    required BatchDeleteTasksUseCase batchDeleteTasksUseCase,
    required DuplicateTaskUseCase duplicateTaskUseCase,
    required MoveTaskUseCase moveTaskUseCase,
    required AssignTaskUseCase assignTaskUseCase,
    required UnassignTaskUseCase unassignTaskUseCase,
    required ArchiveTaskUseCase archiveTaskUseCase,
    required UnarchiveTaskUseCase unarchiveTaskUseCase,
    required AddSubtaskUseCase addSubtaskUseCase,
    required RemoveSubtaskUseCase removeSubtaskUseCase,
  })  : _createTaskUseCase = createTaskUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        _getTaskUseCase = getTaskUseCase,
        _completeTaskUseCase = completeTaskUseCase,
        _uncompleteTaskUseCase = uncompleteTaskUseCase,
        _getTasksDueTodayUseCase = getTasksDueTodayUseCase,
        _getOverdueTasksUseCase = getOverdueTasksUseCase,
        _getUpcomingTasksUseCase = getUpcomingTasksUseCase,
        _getCompletedTasksUseCase = getCompletedTasksUseCase,
        _getTasksByListUseCase = getTasksByListUseCase,
        _getTasksByPriorityUseCase = getTasksByPriorityUseCase,
        _getTasksByTagUseCase = getTasksByTagUseCase,
        _getAssignedTasksUseCase = getAssignedTasksUseCase,
        _getTasksByDateRangeUseCase = getTasksByDateRangeUseCase,
        _searchTasksUseCase = searchTasksUseCase,
        _batchCompleteTasksUseCase = batchCompleteTasksUseCase,
        _batchDeleteTasksUseCase = batchDeleteTasksUseCase,
        _duplicateTaskUseCase = duplicateTaskUseCase,
        _moveTaskUseCase = moveTaskUseCase,
        _assignTaskUseCase = assignTaskUseCase,
        _unassignTaskUseCase = unassignTaskUseCase,
        _archiveTaskUseCase = archiveTaskUseCase,
        _unarchiveTaskUseCase = unarchiveTaskUseCase,
        _addSubtaskUseCase = addSubtaskUseCase,
        _removeSubtaskUseCase = removeSubtaskUseCase,
        super(const TaskState());

  // ============================================================================
  // CRUD Operations
  // ============================================================================

  /// Create a new task
  ///
  /// Parameters:
  /// - [task]: Task entity to create
  ///
  /// Updates the relevant task lists after creation
  Future<void> createTask(TaskEntity task) async {
    state = state.copyWith(isCreating: true, operationError: null);

    final result = await _createTaskUseCase(task);

    result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          operationError: failure,
        );
      },
      (createdTask) {
        // Add to relevant lists
        state = state.copyWith(
          isCreating: false,
          allTasks: state.allTasks.prependItem(createdTask),
          operationError: null,
        );

        // Add to today's tasks if due today
        if (createdTask.isDueToday) {
          state = state.copyWith(
            todayTasks: [createdTask, ...state.todayTasks],
          );
        }

        // Add to list tasks if matches current list
        if (state.currentListId != null &&
            createdTask.listId == state.currentListId) {
          state = state.copyWith(
            listTasks: state.listTasks.prependItem(createdTask),
          );
        }

        // Refresh relevant lists
        _refreshRelevantLists(createdTask);
      },
    );
  }

  /// Update an existing task
  ///
  /// Parameters:
  /// - [task]: Updated task entity
  ///
  /// Updates the task in all relevant lists
  Future<void> updateTask(TaskEntity task) async {
    state = state.copyWith(isUpdating: true, operationError: null);

    final result = await _updateTaskUseCase(task);

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          operationError: failure,
        );
      },
      (updatedTask) {
        // Update in all lists
        state = state.copyWith(
          isUpdating: false,
          allTasks: state.allTasks.updateItem(
            (t) => t.id == updatedTask.id,
            (_) => updatedTask,
          ),
          todayTasks: state.todayTasks
              .map((t) => t.id == updatedTask.id ? updatedTask : t)
              .toList(),
          overdueTasks: state.overdueTasks
              .map((t) => t.id == updatedTask.id ? updatedTask : t)
              .toList(),
          upcomingTasks: state.upcomingTasks
              .map((t) => t.id == updatedTask.id ? updatedTask : t)
              .toList(),
          completedTasks: state.completedTasks.updateItem(
            (t) => t.id == updatedTask.id,
            (_) => updatedTask,
          ),
          listTasks: state.listTasks.updateItem(
            (t) => t.id == updatedTask.id,
            (_) => updatedTask,
          ),
          assignedTasks: state.assignedTasks
              .map((t) => t.id == updatedTask.id ? updatedTask : t)
              .toList(),
          tagTasks: state.tagTasks
              .map((t) => t.id == updatedTask.id ? updatedTask : t)
              .toList(),
          priorityTasks: state.priorityTasks
              .map((t) => t.id == updatedTask.id ? updatedTask : t)
              .toList(),
          selectedTask: state.selectedTask?.id == updatedTask.id
              ? updatedTask
              : state.selectedTask,
          operationError: null,
        );

        // Refresh relevant lists
        _refreshRelevantLists(updatedTask);
      },
    );
  }

  /// Delete a task
  ///
  /// Parameters:
  /// - [taskId]: ID of task to delete
  ///
  /// Removes the task from all lists
  Future<void> deleteTask(String taskId) async {
    state = state.copyWith(isDeleting: true, operationError: null);

    final result = await _deleteTaskUseCase(taskId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          operationError: failure,
        );
      },
      (_) {
        // Remove from all lists
        state = state.copyWith(
          isDeleting: false,
          allTasks: state.allTasks.removeItem((t) => t.id == taskId),
          todayTasks: state.todayTasks.where((t) => t.id != taskId).toList(),
          overdueTasks:
              state.overdueTasks.where((t) => t.id != taskId).toList(),
          upcomingTasks:
              state.upcomingTasks.where((t) => t.id != taskId).toList(),
          completedTasks: state.completedTasks.removeItem((t) => t.id == taskId),
          listTasks: state.listTasks.removeItem((t) => t.id == taskId),
          assignedTasks:
              state.assignedTasks.where((t) => t.id != taskId).toList(),
          tagTasks: state.tagTasks.where((t) => t.id != taskId).toList(),
          priorityTasks:
              state.priorityTasks.where((t) => t.id != taskId).toList(),
          selectedTask:
              state.selectedTask?.id == taskId ? null : state.selectedTask,
          operationError: null,
        );
      },
    );
  }

  /// Get a specific task by ID
  ///
  /// Parameters:
  /// - [taskId]: ID of task to retrieve
  ///
  /// Sets the task as the selected task
  Future<void> getTask(String taskId) async {
    state = state.copyWith(isLoadingTask: true, error: null);

    final result = await _getTaskUseCase(taskId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingTask: false,
          error: failure,
        );
      },
      (task) {
        state = state.copyWith(
          isLoadingTask: false,
          selectedTask: task,
          error: null,
        );
      },
    );
  }

  // ============================================================================
  // Task Completion Operations
  // ============================================================================

  /// Complete a task
  ///
  /// Parameters:
  /// - [taskId]: ID of task to complete
  ///
  /// Updates the task status and moves it to completed list
  Future<void> completeTask(String taskId) async {
    state = state.copyWith(isCompleting: true, operationError: null);

    final result = await _completeTaskUseCase(taskId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isCompleting: false,
          operationError: failure,
        );
      },
      (completedTask) {
        // Update in all lists
        state = state.copyWith(
          isCompleting: false,
          allTasks: state.allTasks.updateItem(
            (t) => t.id == taskId,
            (_) => completedTask,
          ),
          todayTasks: state.todayTasks
              .map((t) => t.id == taskId ? completedTask : t)
              .toList(),
          overdueTasks: state.overdueTasks
              .map((t) => t.id == taskId ? completedTask : t)
              .toList(),
          upcomingTasks: state.upcomingTasks
              .map((t) => t.id == taskId ? completedTask : t)
              .toList(),
          listTasks: state.listTasks.updateItem(
            (t) => t.id == taskId,
            (_) => completedTask,
          ),
          completedTasks: state.completedTasks.prependItem(completedTask),
          operationError: null,
        );
      },
    );
  }

  /// Uncomplete a task
  ///
  /// Parameters:
  /// - [taskId]: ID of task to uncomplete
  ///
  /// Reverts task to todo status
  Future<void> uncompleteTask(String taskId) async {
    state = state.copyWith(isCompleting: true, operationError: null);

    final result = await _uncompleteTaskUseCase(taskId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isCompleting: false,
          operationError: failure,
        );
      },
      (uncompletedTask) {
        // Update in all lists
        state = state.copyWith(
          isCompleting: false,
          allTasks: state.allTasks.updateItem(
            (t) => t.id == taskId,
            (_) => uncompletedTask,
          ),
          completedTasks: state.completedTasks.removeItem((t) => t.id == taskId),
          operationError: null,
        );

        // Add back to relevant lists
        if (uncompletedTask.isDueToday) {
          state = state.copyWith(
            todayTasks: [uncompletedTask, ...state.todayTasks],
          );
        }

        if (uncompletedTask.isOverdue) {
          state = state.copyWith(
            overdueTasks: [uncompletedTask, ...state.overdueTasks],
          );
        }
      },
    );
  }

  /// Batch complete multiple tasks
  ///
  /// Parameters:
  /// - [taskIds]: List of task IDs to complete
  Future<void> batchCompleteTasks(List<String> taskIds) async {
    state = state.copyWith(isBatchProcessing: true, operationError: null);

    final result = await _batchCompleteTasksUseCase(taskIds);

    result.fold(
      (failure) {
        state = state.copyWith(
          isBatchProcessing: false,
          operationError: failure,
        );
      },
      (completedTasks) {
        // Update all completed tasks in lists
        for (final task in completedTasks) {
          state = state.copyWith(
            allTasks: state.allTasks.updateItem(
              (t) => t.id == task.id,
              (_) => task,
            ),
            todayTasks: state.todayTasks
                .map((t) => t.id == task.id ? task : t)
                .toList(),
            overdueTasks: state.overdueTasks
                .map((t) => t.id == task.id ? task : t)
                .toList(),
            upcomingTasks: state.upcomingTasks
                .map((t) => t.id == task.id ? task : t)
                .toList(),
            listTasks: state.listTasks.updateItem(
              (t) => t.id == task.id,
              (_) => task,
            ),
          );
        }

        state = state.copyWith(
          isBatchProcessing: false,
          operationError: null,
        );

        // Refresh completed tasks list
        _refreshCompletedTasks();
      },
    );
  }

  /// Batch delete multiple tasks
  ///
  /// Parameters:
  /// - [taskIds]: List of task IDs to delete
  Future<void> batchDeleteTasks(List<String> taskIds) async {
    state = state.copyWith(isBatchProcessing: true, operationError: null);

    final result = await _batchDeleteTasksUseCase(taskIds);

    result.fold(
      (failure) {
        state = state.copyWith(
          isBatchProcessing: false,
          operationError: failure,
        );
      },
      (_) {
        // Remove all deleted tasks from lists
        for (final taskId in taskIds) {
          state = state.copyWith(
            allTasks: state.allTasks.removeItem((t) => t.id == taskId),
            todayTasks: state.todayTasks.where((t) => t.id != taskId).toList(),
            overdueTasks:
                state.overdueTasks.where((t) => t.id != taskId).toList(),
            upcomingTasks:
                state.upcomingTasks.where((t) => t.id != taskId).toList(),
            completedTasks:
                state.completedTasks.removeItem((t) => t.id == taskId),
            listTasks: state.listTasks.removeItem((t) => t.id == taskId),
            assignedTasks:
                state.assignedTasks.where((t) => t.id != taskId).toList(),
            tagTasks: state.tagTasks.where((t) => t.id != taskId).toList(),
            priorityTasks:
                state.priorityTasks.where((t) => t.id != taskId).toList(),
          );
        }

        state = state.copyWith(
          isBatchProcessing: false,
          operationError: null,
        );
      },
    );
  }

  // ============================================================================
  // Task List Retrieval
  // ============================================================================

  /// Get tasks due today
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  /// - [forceRefresh]: Force refresh even if cached data is fresh
  Future<void> getTasksDueToday(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && !state.needsRefreshToday) {
      return;
    }

    state = state.copyWith(isLoadingToday: true, todayError: null);

    final result = await _getTasksDueTodayUseCase(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingToday: false,
          todayError: failure,
        );
      },
      (tasks) {
        state = state.copyWith(
          isLoadingToday: false,
          todayTasks: tasks,
          lastRefreshToday: DateTime.now(),
          todayError: null,
        );
      },
    );
  }

  /// Get overdue tasks
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  /// - [forceRefresh]: Force refresh even if cached data is fresh
  Future<void> getOverdueTasks(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && !state.needsRefreshOverdue) {
      return;
    }

    state = state.copyWith(isLoadingOverdue: true, overdueError: null);

    final result = await _getOverdueTasksUseCase(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingOverdue: false,
          overdueError: failure,
        );
      },
      (tasks) {
        state = state.copyWith(
          isLoadingOverdue: false,
          overdueTasks: tasks,
          lastRefreshOverdue: DateTime.now(),
          overdueError: null,
        );
      },
    );
  }

  /// Get upcoming tasks (due within 7 days)
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  /// - [forceRefresh]: Force refresh even if cached data is fresh
  Future<void> getUpcomingTasks(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && !state.needsRefreshUpcoming) {
      return;
    }

    state = state.copyWith(isLoadingUpcoming: true, upcomingError: null);

    final result = await _getUpcomingTasksUseCase(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingUpcoming: false,
          upcomingError: failure,
        );
      },
      (tasks) {
        state = state.copyWith(
          isLoadingUpcoming: false,
          upcomingTasks: tasks,
          lastRefreshUpcoming: DateTime.now(),
          upcomingError: null,
        );
      },
    );
  }

  /// Get completed tasks with pagination
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  /// - [loadMore]: Whether to load next page or refresh
  Future<void> getCompletedTasks(
    String userId, {
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (!state.completedTasks.canLoadMore) return;
      state = state.copyWith(
        completedTasks: state.completedTasks.setLoadingMore(),
      );
    } else {
      state = state.copyWith(
        completedTasks: state.completedTasks.setLoadingInitial(),
      );
    }

    final result = await _getCompletedTasksUseCase(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          completedTasks: state.completedTasks.setError(failure),
        );
      },
      (tasks) {
        if (loadMore) {
          state = state.copyWith(
            completedTasks: state.completedTasks.addItems(tasks),
          );
        } else {
          state = state.copyWith(
            completedTasks: state.completedTasks.replaceItems(tasks),
          );
        }
      },
    );
  }

  /// Get tasks by list ID with pagination
  ///
  /// Parameters:
  /// - [listId]: ID of list to filter by
  /// - [loadMore]: Whether to load next page or refresh
  Future<void> getTasksByList(
    String listId, {
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (!state.listTasks.canLoadMore) return;
      state = state.copyWith(
        listTasks: state.listTasks.setLoadingMore(),
      );
    } else {
      state = state.copyWith(
        currentListId: listId,
        listTasks: state.listTasks.setLoadingInitial(),
      );
    }

    final result = await _getTasksByListUseCase(listId);

    result.fold(
      (failure) {
        state = state.copyWith(
          listTasks: state.listTasks.setError(failure),
        );
      },
      (tasks) {
        if (loadMore) {
          state = state.copyWith(
            listTasks: state.listTasks.addItems(tasks),
          );
        } else {
          state = state.copyWith(
            listTasks: state.listTasks.replaceItems(tasks),
          );
        }
      },
    );
  }

  /// Get tasks by priority
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  /// - [priority]: Priority level to filter by
  Future<void> getTasksByPriority(
    String userId,
    TaskPriority priority,
  ) async {
    state = state.copyWith(
      isLoadingPriority: true,
      currentPriority: priority,
      priorityError: null,
    );

    final result = await _getTasksByPriorityUseCase(
      userId: userId,
      priority: priority,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingPriority: false,
          priorityError: failure,
        );
      },
      (tasks) {
        state = state.copyWith(
          isLoadingPriority: false,
          priorityTasks: tasks,
          priorityError: null,
        );
      },
    );
  }

  /// Get tasks by tag
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  /// - [tag]: Tag to filter by
  Future<void> getTasksByTag(String userId, String tag) async {
    state = state.copyWith(
      isLoadingTag: true,
      currentTag: tag,
      tagError: null,
    );

    final result = await _getTasksByTagUseCase(userId: userId, tag: tag);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingTag: false,
          tagError: failure,
        );
      },
      (tasks) {
        state = state.copyWith(
          isLoadingTag: false,
          tagTasks: tasks,
          tagError: null,
        );
      },
    );
  }

  /// Get tasks assigned to current user
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  Future<void> getAssignedTasks(String userId) async {
    state = state.copyWith(isLoadingAssigned: true, assignedError: null);

    final result = await _getAssignedTasksUseCase(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingAssigned: false,
          assignedError: failure,
        );
      },
      (tasks) {
        state = state.copyWith(
          isLoadingAssigned: false,
          assignedTasks: tasks,
          assignedError: null,
        );
      },
    );
  }

  /// Get tasks by date range
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  /// - [startDate]: Start of date range
  /// - [endDate]: End of date range
  Future<void> getTasksByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    state = state.copyWith(
      allTasks: state.allTasks.setLoadingInitial(),
    );

    final result = await _getTasksByDateRangeUseCase(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          allTasks: state.allTasks.setError(failure),
        );
      },
      (tasks) {
        state = state.copyWith(
          allTasks: state.allTasks.replaceItems(tasks),
          lastRefreshAll: DateTime.now(),
        );
      },
    );
  }

  // ============================================================================
  // Search
  // ============================================================================

  /// Search tasks with filters
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  /// - [query]: Search query string
  /// - [listId]: Optional list filter
  /// - [tags]: Optional tags filter
  /// - [priority]: Optional priority filter
  /// - [status]: Optional status filter
  /// - [loadMore]: Whether to load next page or new search
  Future<void> searchTasks({
    required String userId,
    required String query,
    String? listId,
    List<String>? tags,
    TaskPriority? priority,
    TaskStatus? status,
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
        searchResults: state.searchResults.setLoadingInitial(),
      );
    }

    final result = await _searchTasksUseCase(
      userId: userId,
      query: query,
      listId: listId,
      tags: tags,
      priority: priority,
      status: status,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          searchResults: state.searchResults.setError(failure),
        );
      },
      (tasks) {
        if (loadMore) {
          state = state.copyWith(
            searchResults: state.searchResults.addItems(tasks),
          );
        } else {
          state = state.copyWith(
            searchResults: state.searchResults.replaceItems(tasks),
          );
        }
      },
    );
  }

  /// Clear search results
  void clearSearch() {
    state = state.copyWith(
      currentSearchQuery: null,
      searchResults: const PaginationState(),
    );
  }

  // ============================================================================
  // Task Operations
  // ============================================================================

  /// Duplicate a task
  ///
  /// Parameters:
  /// - [taskId]: ID of task to duplicate
  Future<void> duplicateTask(String taskId) async {
    state = state.copyWith(isCreating: true, operationError: null);

    final result = await _duplicateTaskUseCase(taskId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          operationError: failure,
        );
      },
      (duplicatedTask) {
        state = state.copyWith(
          isCreating: false,
          allTasks: state.allTasks.prependItem(duplicatedTask),
          operationError: null,
        );

        // Add to relevant lists
        _refreshRelevantLists(duplicatedTask);
      },
    );
  }

  /// Move task to a different list
  ///
  /// Parameters:
  /// - [taskId]: ID of task to move
  /// - [newListId]: ID of destination list
  Future<void> moveTask(String taskId, String newListId) async {
    state = state.copyWith(isUpdating: true, operationError: null);

    final result = await _moveTaskUseCase(
      taskId: taskId,
      newListId: newListId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          operationError: failure,
        );
      },
      (movedTask) {
        // Update in all lists
        state = state.copyWith(
          isUpdating: false,
          allTasks: state.allTasks.updateItem(
            (t) => t.id == taskId,
            (_) => movedTask,
          ),
          operationError: null,
        );

        // Refresh list tasks if needed
        if (state.currentListId != null) {
          getTasksByList(state.currentListId!);
        }
      },
    );
  }

  /// Assign task to a user
  ///
  /// Parameters:
  /// - [taskId]: ID of task to assign
  /// - [userId]: ID of user to assign to
  Future<void> assignTask(String taskId, String userId) async {
    state = state.copyWith(isUpdating: true, operationError: null);

    final result = await _assignTaskUseCase(
      taskId: taskId,
      userId: userId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          operationError: failure,
        );
      },
      (assignedTask) {
        // Update in all lists
        state = state.copyWith(
          isUpdating: false,
          allTasks: state.allTasks.updateItem(
            (t) => t.id == taskId,
            (_) => assignedTask,
          ),
          listTasks: state.listTasks.updateItem(
            (t) => t.id == taskId,
            (_) => assignedTask,
          ),
          operationError: null,
        );
      },
    );
  }

  /// Unassign task from a user
  ///
  /// Parameters:
  /// - [taskId]: ID of task to unassign
  /// - [userId]: ID of user to unassign from
  Future<void> unassignTask(String taskId, String userId) async {
    state = state.copyWith(isUpdating: true, operationError: null);

    final result = await _unassignTaskUseCase(
      taskId: taskId,
      userId: userId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          operationError: failure,
        );
      },
      (unassignedTask) {
        // Update in all lists
        state = state.copyWith(
          isUpdating: false,
          allTasks: state.allTasks.updateItem(
            (t) => t.id == taskId,
            (_) => unassignedTask,
          ),
          listTasks: state.listTasks.updateItem(
            (t) => t.id == taskId,
            (_) => unassignedTask,
          ),
          assignedTasks:
              state.assignedTasks.where((t) => t.id != taskId).toList(),
          operationError: null,
        );
      },
    );
  }

  /// Archive a task
  ///
  /// Parameters:
  /// - [taskId]: ID of task to archive
  Future<void> archiveTask(String taskId) async {
    state = state.copyWith(isUpdating: true, operationError: null);

    final result = await _archiveTaskUseCase(taskId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          operationError: failure,
        );
      },
      (_) {
        // Remove from active lists
        state = state.copyWith(
          isUpdating: false,
          allTasks: state.allTasks.removeItem((t) => t.id == taskId),
          todayTasks: state.todayTasks.where((t) => t.id != taskId).toList(),
          overdueTasks:
              state.overdueTasks.where((t) => t.id != taskId).toList(),
          upcomingTasks:
              state.upcomingTasks.where((t) => t.id != taskId).toList(),
          listTasks: state.listTasks.removeItem((t) => t.id == taskId),
          operationError: null,
        );
      },
    );
  }

  /// Unarchive a task
  ///
  /// Parameters:
  /// - [taskId]: ID of task to unarchive
  Future<void> unarchiveTask(String taskId) async {
    state = state.copyWith(isUpdating: true, operationError: null);

    final result = await _unarchiveTaskUseCase(taskId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          operationError: failure,
        );
      },
      (unarchivedTask) {
        // Add back to relevant lists
        state = state.copyWith(
          isUpdating: false,
          allTasks: state.allTasks.prependItem(unarchivedTask),
          operationError: null,
        );

        _refreshRelevantLists(unarchivedTask);
      },
    );
  }

  // ============================================================================
  // Subtask Operations
  // ============================================================================

  /// Add a subtask to a parent task
  ///
  /// Parameters:
  /// - [parentTaskId]: ID of parent task
  /// - [subtaskTitle]: Title of the new subtask
  /// - [subtaskDescription]: Optional description
  Future<void> addSubtask({
    required String parentTaskId,
    required String subtaskTitle,
    String? subtaskDescription,
  }) async {
    state = state.copyWith(isCreating: true, operationError: null);

    final result = await _addSubtaskUseCase(
      parentTaskId: parentTaskId,
      subtaskTitle: subtaskTitle,
      subtaskDescription: subtaskDescription,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          operationError: failure,
        );
      },
      (subtask) {
        state = state.copyWith(
          isCreating: false,
          allTasks: state.allTasks.prependItem(subtask),
          operationError: null,
        );

        // Refresh parent task to update subtask count
        getTask(parentTaskId);
      },
    );
  }

  /// Remove a subtask from its parent
  ///
  /// Parameters:
  /// - [subtaskId]: ID of subtask to remove
  Future<void> removeSubtask(String subtaskId) async {
    state = state.copyWith(isUpdating: true, operationError: null);

    final result = await _removeSubtaskUseCase(subtaskId: subtaskId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          operationError: failure,
        );
      },
      (_) {
        state = state.copyWith(
          isUpdating: false,
          operationError: null,
        );

        // The task still exists but is now standalone
        // Refresh to get updated version
        getTask(subtaskId);
      },
    );
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Set selected task
  void selectTask(TaskEntity? task) {
    state = state.copyWith(selectedTask: task);
  }

  /// Set sort option
  void setSortOption(TaskSortOption option, {bool ascending = true}) {
    state = state.copyWith(
      sortOption: option,
      sortAscending: ascending,
    );
  }

  /// Toggle include completed tasks
  void toggleIncludeCompleted() {
    state = state.copyWith(
      includeCompleted: !state.includeCompleted,
    );
  }

  /// Clear all errors
  void clearErrors() {
    state = state.copyWith(
      error: null,
      todayError: null,
      overdueError: null,
      upcomingError: null,
      assignedError: null,
      tagError: null,
      priorityError: null,
      operationError: null,
    );
  }

  /// Clear operation error
  void clearOperationError() {
    state = state.copyWith(operationError: null);
  }

  /// Refresh all task lists
  Future<void> refreshAll(String userId) async {
    await Future.wait([
      getTasksDueToday(userId, forceRefresh: true),
      getOverdueTasks(userId, forceRefresh: true),
      getUpcomingTasks(userId, forceRefresh: true),
    ]);
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  /// Refresh relevant lists after task changes
  void _refreshRelevantLists(TaskEntity task) {
    // This method can be expanded to refresh specific lists
    // based on task properties
  }

  /// Refresh completed tasks
  void _refreshCompletedTasks() {
    // Trigger a refresh of completed tasks
    // Implementation depends on how you want to handle this
  }
}
