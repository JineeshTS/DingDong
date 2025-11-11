import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
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
import 'task_notifier.dart';
import 'task_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================
// These providers expose individual use cases from the DI container.
// They are auto-disposed when no longer needed for optimal memory management.

/// Provider for CreateTaskUseCase
///
/// Handles task creation with validation
final createTaskProvider = Provider.autoDispose<CreateTaskUseCase>(
  (ref) => sl<CreateTaskUseCase>(),
);

/// Provider for UpdateTaskUseCase
///
/// Handles task updates
final updateTaskProvider = Provider.autoDispose<UpdateTaskUseCase>(
  (ref) => sl<UpdateTaskUseCase>(),
);

/// Provider for DeleteTaskUseCase
///
/// Handles task deletion
final deleteTaskProvider = Provider.autoDispose<DeleteTaskUseCase>(
  (ref) => sl<DeleteTaskUseCase>(),
);

/// Provider for GetTaskUseCase
///
/// Retrieves a specific task by ID
final getTaskProvider = Provider.autoDispose<GetTaskUseCase>(
  (ref) => sl<GetTaskUseCase>(),
);

/// Provider for CompleteTaskUseCase
///
/// Marks a task as completed
final completeTaskProvider = Provider.autoDispose<CompleteTaskUseCase>(
  (ref) => sl<CompleteTaskUseCase>(),
);

/// Provider for UncompleteTaskUseCase
///
/// Reverts a task from completed to todo
final uncompleteTaskProvider = Provider.autoDispose<UncompleteTaskUseCase>(
  (ref) => sl<UncompleteTaskUseCase>(),
);

/// Provider for GetTasksDueTodayUseCase
///
/// Retrieves tasks that are due today
final getTasksDueTodayProvider = Provider.autoDispose<GetTasksDueTodayUseCase>(
  (ref) => sl<GetTasksDueTodayUseCase>(),
);

/// Provider for GetOverdueTasksUseCase
///
/// Retrieves tasks that are past their due date
final getOverdueTasksProvider = Provider.autoDispose<GetOverdueTasksUseCase>(
  (ref) => sl<GetOverdueTasksUseCase>(),
);

/// Provider for GetUpcomingTasksUseCase
///
/// Retrieves tasks due in the next 7 days
final getUpcomingTasksProvider = Provider.autoDispose<GetUpcomingTasksUseCase>(
  (ref) => sl<GetUpcomingTasksUseCase>(),
);

/// Provider for GetCompletedTasksUseCase
///
/// Retrieves completed tasks with pagination
final getCompletedTasksProvider =
    Provider.autoDispose<GetCompletedTasksUseCase>(
  (ref) => sl<GetCompletedTasksUseCase>(),
);

/// Provider for GetTasksByListUseCase
///
/// Retrieves tasks filtered by list ID
final getTasksByListProvider = Provider.autoDispose<GetTasksByListUseCase>(
  (ref) => sl<GetTasksByListUseCase>(),
);

/// Provider for GetTasksByPriorityUseCase
///
/// Retrieves tasks filtered by priority level
final getTasksByPriorityProvider =
    Provider.autoDispose<GetTasksByPriorityUseCase>(
  (ref) => sl<GetTasksByPriorityUseCase>(),
);

/// Provider for GetTasksByTagUseCase
///
/// Retrieves tasks filtered by tag
final getTasksByTagProvider = Provider.autoDispose<GetTasksByTagUseCase>(
  (ref) => sl<GetTasksByTagUseCase>(),
);

/// Provider for GetAssignedTasksUseCase
///
/// Retrieves tasks assigned to the current user
final getAssignedTasksProvider = Provider.autoDispose<GetAssignedTasksUseCase>(
  (ref) => sl<GetAssignedTasksUseCase>(),
);

/// Provider for GetTasksByDateRangeUseCase
///
/// Retrieves tasks within a specific date range
final getTasksByDateRangeProvider =
    Provider.autoDispose<GetTasksByDateRangeUseCase>(
  (ref) => sl<GetTasksByDateRangeUseCase>(),
);

/// Provider for SearchTasksUseCase
///
/// Searches tasks with filters and pagination
final searchTasksProvider = Provider.autoDispose<SearchTasksUseCase>(
  (ref) => sl<SearchTasksUseCase>(),
);

/// Provider for BatchCompleteTasksUseCase
///
/// Completes multiple tasks at once
final batchCompleteTasksProvider =
    Provider.autoDispose<BatchCompleteTasksUseCase>(
  (ref) => sl<BatchCompleteTasksUseCase>(),
);

/// Provider for BatchDeleteTasksUseCase
///
/// Deletes multiple tasks at once
final batchDeleteTasksProvider = Provider.autoDispose<BatchDeleteTasksUseCase>(
  (ref) => sl<BatchDeleteTasksUseCase>(),
);

/// Provider for DuplicateTaskUseCase
///
/// Creates a copy of an existing task
final duplicateTaskProvider = Provider.autoDispose<DuplicateTaskUseCase>(
  (ref) => sl<DuplicateTaskUseCase>(),
);

/// Provider for MoveTaskUseCase
///
/// Moves a task to a different list
final moveTaskProvider = Provider.autoDispose<MoveTaskUseCase>(
  (ref) => sl<MoveTaskUseCase>(),
);

/// Provider for AssignTaskUseCase
///
/// Assigns a task to a user
final assignTaskProvider = Provider.autoDispose<AssignTaskUseCase>(
  (ref) => sl<AssignTaskUseCase>(),
);

/// Provider for UnassignTaskUseCase
///
/// Removes a user assignment from a task
final unassignTaskProvider = Provider.autoDispose<UnassignTaskUseCase>(
  (ref) => sl<UnassignTaskUseCase>(),
);

/// Provider for ArchiveTaskUseCase
///
/// Archives a task (removes from active lists)
final archiveTaskProvider = Provider.autoDispose<ArchiveTaskUseCase>(
  (ref) => sl<ArchiveTaskUseCase>(),
);

/// Provider for UnarchiveTaskUseCase
///
/// Unarchives a task (restores to active lists)
final unarchiveTaskProvider = Provider.autoDispose<UnarchiveTaskUseCase>(
  (ref) => sl<UnarchiveTaskUseCase>(),
);

/// Provider for AddSubtaskUseCase
///
/// Adds a subtask to a parent task
final addSubtaskProvider = Provider.autoDispose<AddSubtaskUseCase>(
  (ref) => sl<AddSubtaskUseCase>(),
);

/// Provider for RemoveSubtaskUseCase
///
/// Removes subtask relationship (converts to standalone task)
final removeSubtaskProvider = Provider.autoDispose<RemoveSubtaskUseCase>(
  (ref) => sl<RemoveSubtaskUseCase>(),
);

// ============================================================================
// Task State Notifier Provider
// ============================================================================

/// Main task state notifier provider
///
/// This is the primary provider for task state management.
/// It should NOT be auto-disposed as we want to maintain task
/// state throughout the app lifecycle.
///
/// Usage:
/// ```dart
/// // In a ConsumerWidget
/// final taskState = ref.watch(taskNotifierProvider);
/// final taskNotifier = ref.read(taskNotifierProvider.notifier);
///
/// // Get today's tasks
/// ref.listen(taskNotifierProvider, (previous, next) {
///   if (next.todayTasks.isNotEmpty) {
///     // Handle today's tasks update
///   }
/// });
///
/// // Perform task actions
/// await taskNotifier.createTask(newTask);
/// await taskNotifier.completeTask(taskId);
/// ```
final taskNotifierProvider = StateNotifierProvider<TaskNotifier, TaskState>(
  (ref) {
    return TaskNotifier(
      createTaskUseCase: ref.read(createTaskProvider),
      updateTaskUseCase: ref.read(updateTaskProvider),
      deleteTaskUseCase: ref.read(deleteTaskProvider),
      getTaskUseCase: ref.read(getTaskProvider),
      completeTaskUseCase: ref.read(completeTaskProvider),
      uncompleteTaskUseCase: ref.read(uncompleteTaskProvider),
      getTasksDueTodayUseCase: ref.read(getTasksDueTodayProvider),
      getOverdueTasksUseCase: ref.read(getOverdueTasksProvider),
      getUpcomingTasksUseCase: ref.read(getUpcomingTasksProvider),
      getCompletedTasksUseCase: ref.read(getCompletedTasksProvider),
      getTasksByListUseCase: ref.read(getTasksByListProvider),
      getTasksByPriorityUseCase: ref.read(getTasksByPriorityProvider),
      getTasksByTagUseCase: ref.read(getTasksByTagProvider),
      getAssignedTasksUseCase: ref.read(getAssignedTasksProvider),
      getTasksByDateRangeUseCase: ref.read(getTasksByDateRangeProvider),
      searchTasksUseCase: ref.read(searchTasksProvider),
      batchCompleteTasksUseCase: ref.read(batchCompleteTasksProvider),
      batchDeleteTasksUseCase: ref.read(batchDeleteTasksProvider),
      duplicateTaskUseCase: ref.read(duplicateTaskProvider),
      moveTaskUseCase: ref.read(moveTaskProvider),
      assignTaskUseCase: ref.read(assignTaskProvider),
      unassignTaskUseCase: ref.read(unassignTaskProvider),
      archiveTaskUseCase: ref.read(archiveTaskProvider),
      unarchiveTaskUseCase: ref.read(unarchiveTaskProvider),
      addSubtaskUseCase: ref.read(addSubtaskProvider),
      removeSubtaskUseCase: ref.read(removeSubtaskProvider),
    );
  },
);

// ============================================================================
// Derived State Providers - Task Lists
// ============================================================================

/// Provider that exposes today's tasks
///
/// Returns list of tasks due today
///
/// Usage:
/// ```dart
/// final todayTasks = ref.watch(todayTasksProvider);
/// ListView.builder(
///   itemCount: todayTasks.length,
///   itemBuilder: (context, index) => TaskTile(task: todayTasks[index]),
/// );
/// ```
final todayTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.todayTasks;
});

/// Provider that exposes overdue tasks
///
/// Returns list of tasks past their due date
///
/// Usage:
/// ```dart
/// final overdueTasks = ref.watch(overdueTasksProvider);
/// if (overdueTasks.isNotEmpty) {
///   showOverdueWarning(overdueTasks.length);
/// }
/// ```
final overdueTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.overdueTasks;
});

/// Provider that exposes upcoming tasks
///
/// Returns list of tasks due within 7 days
///
/// Usage:
/// ```dart
/// final upcomingTasks = ref.watch(upcomingTasksProvider);
/// UpcomingTasksWidget(tasks: upcomingTasks);
/// ```
final upcomingTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.upcomingTasks;
});

/// Provider that exposes completed tasks with pagination
///
/// Returns paginated list of completed tasks
///
/// Usage:
/// ```dart
/// final completedTasks = ref.watch(completedTasksProvider);
/// if (completedTasks.canLoadMore) {
///   ref.read(taskNotifierProvider.notifier).getCompletedTasks(userId, loadMore: true);
/// }
/// ```
final completedTasksProvider = Provider.autoDispose((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.completedTasks;
});

/// Provider that exposes tasks for current list
///
/// Returns paginated list of tasks filtered by current list
///
/// Usage:
/// ```dart
/// final listTasks = ref.watch(currentListTasksProvider);
/// TaskListView(paginationState: listTasks);
/// ```
final currentListTasksProvider = Provider.autoDispose((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.listTasks;
});

/// Provider that exposes tasks assigned to user
///
/// Returns list of assigned tasks
///
/// Usage:
/// ```dart
/// final myTasks = ref.watch(assignedTasksProvider);
/// AssignedTasksView(tasks: myTasks);
/// ```
final assignedTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.assignedTasks;
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
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.searchResults;
});

/// Provider that exposes selected task
///
/// Returns currently selected/viewed task
///
/// Usage:
/// ```dart
/// final selectedTask = ref.watch(selectedTaskProvider);
/// if (selectedTask != null) {
///   TaskDetailView(task: selectedTask);
/// }
/// ```
final selectedTaskProvider = Provider.autoDispose<TaskEntity?>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.selectedTask;
});

// ============================================================================
// Derived State Providers - Counts and Statistics
// ============================================================================

/// Provider for today's task count
///
/// Returns count of tasks due today
///
/// Usage:
/// ```dart
/// final todayCount = ref.watch(todayTaskCountProvider);
/// Badge(label: '$todayCount');
/// ```
final todayTaskCountProvider = Provider.autoDispose<int>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.todayTaskCount;
});

/// Provider for overdue task count
///
/// Returns count of overdue tasks
///
/// Usage:
/// ```dart
/// final overdueCount = ref.watch(overdueTaskCountProvider);
/// if (overdueCount > 0) {
///   WarningBadge(count: overdueCount);
/// }
/// ```
final overdueTaskCountProvider = Provider.autoDispose<int>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.overdueTaskCount;
});

/// Provider for upcoming task count
///
/// Returns count of upcoming tasks
///
/// Usage:
/// ```dart
/// final upcomingCount = ref.watch(upcomingTaskCountProvider);
/// Text('$upcomingCount tasks this week');
/// ```
final upcomingTaskCountProvider = Provider.autoDispose<int>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.upcomingTaskCount;
});

/// Provider for assigned task count
///
/// Returns count of tasks assigned to user
///
/// Usage:
/// ```dart
/// final assignedCount = ref.watch(assignedTaskCountProvider);
/// Text('You have $assignedCount assigned tasks');
/// ```
final assignedTaskCountProvider = Provider.autoDispose<int>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.assignedTaskCount;
});

/// Provider for total task count from all tasks
///
/// Returns total count of tasks in all tasks list
///
/// Usage:
/// ```dart
/// final totalCount = ref.watch(totalTaskCountProvider);
/// Text('Total: $totalCount tasks');
/// ```
final totalTaskCountProvider = Provider.autoDispose<int>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.allTasks.itemCount;
});

// ============================================================================
// Derived State Providers - Loading States
// ============================================================================

/// Provider for today tasks loading state
///
/// Returns true if today's tasks are loading
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(isTodayLoadingProvider);
/// if (isLoading) CircularProgressIndicator();
/// ```
final isTodayLoadingProvider = Provider.autoDispose<bool>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.isLoadingToday;
});

/// Provider for overdue tasks loading state
///
/// Returns true if overdue tasks are loading
final isOverdueLoadingProvider = Provider.autoDispose<bool>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.isLoadingOverdue;
});

/// Provider for upcoming tasks loading state
///
/// Returns true if upcoming tasks are loading
final isUpcomingLoadingProvider = Provider.autoDispose<bool>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.isLoadingUpcoming;
});

/// Provider for any loading state
///
/// Returns true if any task operation is loading
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(isAnyTaskLoadingProvider);
/// if (isLoading) LoadingOverlay();
/// ```
final isAnyTaskLoadingProvider = Provider.autoDispose<bool>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.isAnyLoading;
});

/// Provider for operation in progress state
///
/// Returns true if any task operation (create, update, delete) is in progress
///
/// Usage:
/// ```dart
/// final isProcessing = ref.watch(isTaskOperationInProgressProvider);
/// ElevatedButton(
///   onPressed: isProcessing ? null : () => createTask(),
/// );
/// ```
final isTaskOperationInProgressProvider = Provider.autoDispose<bool>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.isAnyOperationInProgress;
});

// ============================================================================
// Derived State Providers - Errors
// ============================================================================

/// Provider for operation error
///
/// Returns error from task operations (create, update, delete)
///
/// Usage:
/// ```dart
/// ref.listen(taskOperationErrorProvider, (previous, next) {
///   if (next != null) {
///     showErrorSnackBar(next.message);
///   }
/// });
/// ```
final taskOperationErrorProvider = Provider.autoDispose((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.operationError;
});

/// Provider for today tasks error
///
/// Returns error from loading today's tasks
final todayTasksErrorProvider = Provider.autoDispose((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.todayError;
});

/// Provider for overdue tasks error
///
/// Returns error from loading overdue tasks
final overdueTasksErrorProvider = Provider.autoDispose((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.overdueError;
});

/// Provider for any error state
///
/// Returns true if any task operation has an error
///
/// Usage:
/// ```dart
/// final hasError = ref.watch(hasAnyTaskErrorProvider);
/// if (hasError) ErrorBanner();
/// ```
final hasAnyTaskErrorProvider = Provider.autoDispose<bool>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.hasAnyError;
});

// ============================================================================
// Derived State Providers - Filters and Sorting
// ============================================================================

/// Provider for current list filter
///
/// Returns ID of currently selected list
///
/// Usage:
/// ```dart
/// final currentListId = ref.watch(currentListFilterProvider);
/// if (currentListId != null) {
///   // Show list-specific UI
/// }
/// ```
final currentListFilterProvider = Provider.autoDispose<String?>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.currentListId;
});

/// Provider for current tag filter
///
/// Returns currently selected tag
final currentTagFilterProvider = Provider.autoDispose<String?>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.currentTag;
});

/// Provider for current priority filter
///
/// Returns currently selected priority
final currentPriorityFilterProvider =
    Provider.autoDispose<TaskPriority?>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.currentPriority;
});

/// Provider for current search query
///
/// Returns current search query string
final currentSearchQueryProvider = Provider.autoDispose<String?>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.currentSearchQuery;
});

/// Provider for current sort option
///
/// Returns current task sort option
///
/// Usage:
/// ```dart
/// final sortOption = ref.watch(currentSortOptionProvider);
/// SortButton(currentOption: sortOption);
/// ```
final currentSortOptionProvider = Provider.autoDispose<TaskSortOption>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.sortOption;
});

/// Provider for sort direction (ascending/descending)
///
/// Returns true if sorting in ascending order
final isSortAscendingProvider = Provider.autoDispose<bool>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.sortAscending;
});

/// Provider for include completed filter
///
/// Returns true if completed tasks should be included in lists
final includeCompletedProvider = Provider.autoDispose<bool>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.includeCompleted;
});

// ============================================================================
// Derived State Providers - Computed Values
// ============================================================================

/// Provider for high priority tasks from today's list
///
/// Returns today's tasks filtered by high/critical priority
///
/// Usage:
/// ```dart
/// final urgentTasks = ref.watch(urgentTodayTasksProvider);
/// UrgentTasksWidget(tasks: urgentTasks);
/// ```
final urgentTodayTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final todayTasks = ref.watch(todayTasksProvider);
  return todayTasks
      .where((task) =>
          task.priority == TaskPriority.high ||
          task.priority == TaskPriority.critical)
      .toList();
});

/// Provider for count of urgent today tasks
///
/// Returns count of high/critical priority tasks due today
final urgentTodayCountProvider = Provider.autoDispose<int>((ref) {
  final urgentTasks = ref.watch(urgentTodayTasksProvider);
  return urgentTasks.length;
});

/// Provider for incomplete tasks (excluding completed)
///
/// Returns all tasks excluding completed ones
///
/// Usage:
/// ```dart
/// final incompleteTasks = ref.watch(incompleteTasksProvider);
/// Text('${incompleteTasks.length} tasks remaining');
/// ```
final incompleteTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.allTasks.items
      .where((task) => task.status != TaskStatus.completed)
      .toList();
});

/// Provider for tasks with no due date
///
/// Returns tasks that don't have a due date set
final tasksWithoutDueDateProvider =
    Provider.autoDispose<List<TaskEntity>>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.allTasks.items.where((task) => task.dueDate == null).toList();
});

/// Provider for tasks due this week
///
/// Returns tasks due within the current week
///
/// Usage:
/// ```dart
/// final thisWeekTasks = ref.watch(tasksThisWeekProvider);
/// WeeklyPlannerWidget(tasks: thisWeekTasks);
/// ```
final tasksThisWeekProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 7));

  final taskState = ref.watch(taskNotifierProvider);
  return taskState.allTasks.items.where((task) {
    if (task.dueDate == null) return false;
    return task.dueDate!.isAfter(startOfWeek) &&
        task.dueDate!.isBefore(endOfWeek);
  }).toList();
});

/// Provider for subtasks of selected task
///
/// Returns subtasks of the currently selected task
///
/// Usage:
/// ```dart
/// final subtasks = ref.watch(selectedTaskSubtasksProvider);
/// SubtasksList(subtasks: subtasks);
/// ```
final selectedTaskSubtasksProvider =
    Provider.autoDispose<List<TaskEntity>>((ref) {
  final selectedTask = ref.watch(selectedTaskProvider);
  if (selectedTask == null) return [];

  final taskState = ref.watch(taskNotifierProvider);
  return taskState.allTasks.items
      .where((task) => task.parentTaskId == selectedTask.id)
      .toList();
});

/// Provider for task completion percentage
///
/// Returns percentage of completed tasks from all tasks
///
/// Usage:
/// ```dart
/// final completionRate = ref.watch(taskCompletionPercentageProvider);
/// ProgressIndicator(value: completionRate / 100);
/// ```
final taskCompletionPercentageProvider = Provider.autoDispose<double>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  final allTasks = taskState.allTasks.items;

  if (allTasks.isEmpty) return 0.0;

  final completedCount =
      allTasks.where((task) => task.status == TaskStatus.completed).length;

  return (completedCount / allTasks.length) * 100;
});

/// Provider for tasks grouped by priority
///
/// Returns map of tasks grouped by their priority level
///
/// Usage:
/// ```dart
/// final groupedTasks = ref.watch(tasksGroupedByPriorityProvider);
/// for (final priority in groupedTasks.keys) {
///   PrioritySection(priority: priority, tasks: groupedTasks[priority]!);
/// }
/// ```
final tasksGroupedByPriorityProvider =
    Provider.autoDispose<Map<TaskPriority, List<TaskEntity>>>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  final tasks = taskState.allTasks.items;

  final grouped = <TaskPriority, List<TaskEntity>>{};

  for (final task in tasks) {
    if (!grouped.containsKey(task.priority)) {
      grouped[task.priority] = [];
    }
    grouped[task.priority]!.add(task);
  }

  return grouped;
});

/// Provider for tasks grouped by status
///
/// Returns map of tasks grouped by their status
final tasksGroupedByStatusProvider =
    Provider.autoDispose<Map<TaskStatus, List<TaskEntity>>>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  final tasks = taskState.allTasks.items;

  final grouped = <TaskStatus, List<TaskEntity>>{};

  for (final task in tasks) {
    if (!grouped.containsKey(task.status)) {
      grouped[task.status] = [];
    }
    grouped[task.status]!.add(task);
  }

  return grouped;
});

/// Provider for checking if refresh is needed
///
/// Returns true if any task list needs refresh (based on 5-minute threshold)
///
/// Usage:
/// ```dart
/// final needsRefresh = ref.watch(tasksNeedRefreshProvider);
/// if (needsRefresh) {
///   ref.read(taskNotifierProvider.notifier).refreshAll(userId);
/// }
/// ```
final tasksNeedRefreshProvider = Provider.autoDispose<bool>((ref) {
  final taskState = ref.watch(taskNotifierProvider);
  return taskState.needsRefreshAll ||
      taskState.needsRefreshToday ||
      taskState.needsRefreshOverdue ||
      taskState.needsRefreshUpcoming;
});
