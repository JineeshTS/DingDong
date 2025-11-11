/// Task providers module
///
/// Exports all task-related providers, state, and notifiers.
///
/// This module provides comprehensive task management functionality including:
/// - Task CRUD operations (Create, Read, Update, Delete)
/// - Task completion and status management
/// - Batch operations (complete/delete multiple tasks)
/// - Task filtering (by list, tag, priority, date, status)
/// - Task search with advanced filters
/// - Task assignment and collaboration
/// - Subtask management
/// - Task archiving
/// - Pagination support for large task lists
/// - Real-time task updates
/// - Derived providers for common queries
///
/// ## Architecture
///
/// The task providers follow the Clean Architecture pattern:
/// - **State**: Immutable state managed by Freezed (`TaskState`)
/// - **Notifier**: Business logic and state updates (`TaskNotifier`)
/// - **Providers**: Dependency injection and state access
/// - **Use Cases**: Domain layer operations (26 task use cases)
///
/// ## Usage
///
/// ```dart
/// import 'package:dingdong/presentation/providers/task/task.dart';
///
/// class TaskListScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Watch today's tasks
///     final todayTasks = ref.watch(todayTasksProvider);
///     final isLoading = ref.watch(isTodayLoadingProvider);
///
///     // Get notifier for actions
///     final taskNotifier = ref.read(taskNotifierProvider.notifier);
///
///     return Column(
///       children: [
///         if (isLoading)
///           CircularProgressIndicator()
///         else
///           ListView.builder(
///             itemCount: todayTasks.length,
///             itemBuilder: (context, index) {
///               final task = todayTasks[index];
///               return TaskTile(
///                 task: task,
///                 onComplete: () => taskNotifier.completeTask(task.id),
///                 onDelete: () => taskNotifier.deleteTask(task.id),
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
/// - `taskNotifierProvider` - Main task state and notifier
///
/// ### Task List Providers
/// - `todayTasksProvider` - Tasks due today
/// - `overdueTasksProvider` - Overdue tasks
/// - `upcomingTasksProvider` - Tasks due within 7 days
/// - `completedTasksProvider` - Completed tasks (paginated)
/// - `currentListTasksProvider` - Tasks for current list (paginated)
/// - `assignedTasksProvider` - Tasks assigned to user
/// - `searchResultsProvider` - Search results (paginated)
/// - `selectedTaskProvider` - Currently selected task
///
/// ### Count Providers
/// - `todayTaskCountProvider` - Count of today's tasks
/// - `overdueTaskCountProvider` - Count of overdue tasks
/// - `upcomingTaskCountProvider` - Count of upcoming tasks
/// - `assignedTaskCountProvider` - Count of assigned tasks
/// - `totalTaskCountProvider` - Total task count
/// - `urgentTodayCountProvider` - Count of urgent tasks today
///
/// ### Loading State Providers
/// - `isTodayLoadingProvider` - Today tasks loading state
/// - `isOverdueLoadingProvider` - Overdue tasks loading state
/// - `isUpcomingLoadingProvider` - Upcoming tasks loading state
/// - `isAnyTaskLoadingProvider` - Any task list loading
/// - `isTaskOperationInProgressProvider` - Task operation in progress
///
/// ### Error Providers
/// - `taskOperationErrorProvider` - Operation errors
/// - `todayTasksErrorProvider` - Today tasks errors
/// - `overdueTasksErrorProvider` - Overdue tasks errors
/// - `hasAnyTaskErrorProvider` - Any error state
///
/// ### Filter Providers
/// - `currentListFilterProvider` - Current list filter
/// - `currentTagFilterProvider` - Current tag filter
/// - `currentPriorityFilterProvider` - Current priority filter
/// - `currentSearchQueryProvider` - Current search query
/// - `currentSortOptionProvider` - Current sort option
/// - `isSortAscendingProvider` - Sort direction
/// - `includeCompletedProvider` - Include completed tasks
///
/// ### Computed Providers
/// - `urgentTodayTasksProvider` - High priority tasks today
/// - `incompleteTasksProvider` - All incomplete tasks
/// - `tasksWithoutDueDateProvider` - Tasks without due date
/// - `tasksThisWeekProvider` - Tasks due this week
/// - `selectedTaskSubtasksProvider` - Subtasks of selected task
/// - `taskCompletionPercentageProvider` - Completion percentage
/// - `tasksGroupedByPriorityProvider` - Tasks grouped by priority
/// - `tasksGroupedByStatusProvider` - Tasks grouped by status
/// - `tasksNeedRefreshProvider` - Refresh needed indicator
///
/// ### Use Case Providers (26 total)
/// - `createTaskProvider` - Create task use case
/// - `updateTaskProvider` - Update task use case
/// - `deleteTaskProvider` - Delete task use case
/// - `getTaskProvider` - Get task by ID use case
/// - `completeTaskProvider` - Complete task use case
/// - `uncompleteTaskProvider` - Uncomplete task use case
/// - `getTasksDueTodayProvider` - Get today's tasks use case
/// - `getOverdueTasksProvider` - Get overdue tasks use case
/// - `getUpcomingTasksProvider` - Get upcoming tasks use case
/// - `getCompletedTasksProvider` - Get completed tasks use case
/// - `getTasksByListProvider` - Get tasks by list use case
/// - `getTasksByPriorityProvider` - Get tasks by priority use case
/// - `getTasksByTagProvider` - Get tasks by tag use case
/// - `getAssignedTasksProvider` - Get assigned tasks use case
/// - `getTasksByDateRangeProvider` - Get tasks by date range use case
/// - `searchTasksProvider` - Search tasks use case
/// - `batchCompleteTasksProvider` - Batch complete use case
/// - `batchDeleteTasksProvider` - Batch delete use case
/// - `duplicateTaskProvider` - Duplicate task use case
/// - `moveTaskProvider` - Move task use case
/// - `assignTaskProvider` - Assign task use case
/// - `unassignTaskProvider` - Unassign task use case
/// - `archiveTaskProvider` - Archive task use case
/// - `unarchiveTaskProvider` - Unarchive task use case
/// - `addSubtaskProvider` - Add subtask use case
/// - `removeSubtaskProvider` - Remove subtask use case
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
/// 4. **Performance**
///    - Use specific providers instead of watching entire state
///    - Leverage auto-dispose providers for temporary data
///    - Implement proper list keys for efficient rebuilds
///
/// 5. **Offline Support**
///    - Check refresh timestamps
///    - Implement pull-to-refresh
///    - Handle network failures gracefully
///
export 'task_notifier.dart';
export 'task_providers.dart';
export 'task_state.dart';
