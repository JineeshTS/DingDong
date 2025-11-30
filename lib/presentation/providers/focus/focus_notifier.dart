import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task/get_tasks_usecase.dart';
import 'focus_state.dart';

/// Focus/Today view state notifier
///
/// Manages Focus/Today view state including:
/// - Today's tasks
/// - Overdue tasks
/// - Smart "What's Next" suggestions
/// - Morning/Evening prompts
class FocusNotifier extends StateNotifier<FocusState> {
  FocusNotifier({
    required this.getTasksUseCase,
    required this.userId,
  }) : super(FocusState.initial()) {
    // Load tasks for initial view
    loadTasks();
    _checkForPrompts();
  }

  final GetTasksUseCase getTasksUseCase;
  final String userId;

  /// Load today's tasks and overdue tasks
  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await getTasksUseCase.call(
        GetTasksParams(userId: userId),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (tasks) {
          _organizeTasks(tasks);
          _suggestNextTask();
          state = state.copyWith(isLoading: false);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Organize tasks into today, overdue, and completed
  void _organizeTasks(List<TaskEntity> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final todayTasks = <TaskEntity>[];
    final overdueTasks = <TaskEntity>[];
    final completedTasks = <TaskEntity>[];

    for (final task in tasks) {
      // Skip tasks without due dates (unless completed today)
      if (task.dueDate == null) {
        if (task.isCompleted && task.updatedAt != null) {
          final completedDate = DateTime(
            task.updatedAt!.year,
            task.updatedAt!.month,
            task.updatedAt!.day,
          );
          if (completedDate.isAtSameMomentAs(today)) {
            completedTasks.add(task);
          }
        }
        continue;
      }

      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );

      // Completed tasks today
      if (task.isCompleted && task.updatedAt != null) {
        final completedDate = DateTime(
          task.updatedAt!.year,
          task.updatedAt!.month,
          task.updatedAt!.day,
        );
        if (completedDate.isAtSameMomentAs(today)) {
          completedTasks.add(task);
        }
      }
      // Overdue tasks
      else if (taskDate.isBefore(today) && !task.isCompleted) {
        overdueTasks.add(task);
      }
      // Today's tasks
      else if (taskDate.isAtSameMomentAs(today)) {
        todayTasks.add(task);
      }
    }

    // Sort tasks
    overdueTasks.sort(_compareTasksByPriorityAndTime);
    todayTasks.sort(_compareTasksByPriorityAndTime);
    completedTasks.sort((a, b) {
      if (a.updatedAt != null && b.updatedAt != null) {
        return b.updatedAt!.compareTo(a.updatedAt!);
      }
      return 0;
    });

    state = state.copyWith(
      todayTasks: todayTasks,
      overdueTasks: overdueTasks,
      completedTasks: completedTasks,
    );
  }

  /// Compare tasks by priority and time
  int _compareTasksByPriorityAndTime(TaskEntity a, TaskEntity b) {
    // First by priority (high to low)
    if (a.priority.index != b.priority.index) {
      return b.priority.index.compareTo(a.priority.index);
    }

    // Then by due time if available
    if (a.dueDate != null && b.dueDate != null) {
      return a.dueDate!.compareTo(b.dueDate!);
    }

    return 0;
  }

  /// Suggest next task based on various factors
  void _suggestNextTask() {
    final incompleteTasks = state.allIncompleteTasks;

    if (incompleteTasks.isEmpty) {
      state = state.copyWith(nextSuggestedTask: null);
      return;
    }

    // Prioritize overdue critical/high priority tasks
    final overdueHighPriority = state.overdueTasks.where((t) =>
        !t.isCompleted &&
        (t.priority == TaskPriority.critical ||
            t.priority == TaskPriority.high));

    if (overdueHighPriority.isNotEmpty) {
      state = state.copyWith(nextSuggestedTask: overdueHighPriority.first);
      return;
    }

    // Then any overdue tasks
    final overdueIncomplete =
        state.overdueTasks.where((t) => !t.isCompleted).toList();
    if (overdueIncomplete.isNotEmpty) {
      state = state.copyWith(nextSuggestedTask: overdueIncomplete.first);
      return;
    }

    // Then today's high priority tasks
    final todayHighPriority = state.todayTasks.where((t) =>
        !t.isCompleted &&
        (t.priority == TaskPriority.critical ||
            t.priority == TaskPriority.high));

    if (todayHighPriority.isNotEmpty) {
      state = state.copyWith(nextSuggestedTask: todayHighPriority.first);
      return;
    }

    // Otherwise, first incomplete task
    state = state.copyWith(nextSuggestedTask: incompleteTasks.first);
  }

  /// Check for morning/evening prompts
  void _checkForPrompts() {
    if (state.isMorningPlanningTime) {
      state = state.copyWith(showMorningPrompt: true);
    }

    if (state.isEveningReviewTime && state.completedTasksCount > 0) {
      state = state.copyWith(showEveningPrompt: true);
    }
  }

  /// Toggle view mode
  void toggleViewMode() {
    final newMode = state.viewMode == FocusViewMode.timeline
        ? FocusViewMode.list
        : FocusViewMode.timeline;
    state = state.copyWith(viewMode: newMode);
  }

  /// Toggle show completed tasks
  void toggleShowCompletedTasks() {
    state = state.copyWith(showCompletedTasks: !state.showCompletedTasks);
  }

  /// Dismiss morning prompt
  void dismissMorningPrompt() {
    state = state.copyWith(showMorningPrompt: false);
  }

  /// Dismiss evening prompt
  void dismissEveningPrompt() {
    state = state.copyWith(showEveningPrompt: false);
  }

  /// Refresh focus view data
  Future<void> refresh() async {
    await loadTasks();
    _checkForPrompts();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
