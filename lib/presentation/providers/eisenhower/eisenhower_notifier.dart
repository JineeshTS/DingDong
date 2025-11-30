import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task/get_tasks_usecase.dart';
import '../../../domain/usecases/task/update_task_usecase.dart';
import 'eisenhower_state.dart';

/// Eisenhower Matrix state notifier
///
/// Manages Eisenhower Matrix state including:
/// - Task categorization by urgency and importance
/// - Auto-categorization logic
/// - Quadrant management
/// - Focus mode
class EisenhowerNotifier extends StateNotifier<EisenhowerState> {
  EisenhowerNotifier({
    required this.getTasksUseCase,
    required this.updateTaskUseCase,
    required this.userId,
  }) : super(EisenhowerState.initial()) {
    // Load tasks for initial view
    loadTasks();
  }

  final GetTasksUseCase getTasksUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final String userId;

  /// Load all tasks and categorize into quadrants
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
          _categorizeTasks(tasks);
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

  /// Categorize tasks into quadrants
  void _categorizeTasks(List<TaskEntity> tasks) {
    var filteredTasks = tasks;

    // Apply filters
    if (state.selectedListId != null) {
      filteredTasks = filteredTasks
          .where((task) => task.categoryId == state.selectedListId)
          .toList();
    }

    if (!state.showCompletedTasks) {
      filteredTasks = filteredTasks
          .where((task) => task.status != TaskStatus.completed)
          .toList();
    }

    // Categorize into quadrants
    final urgentImportant = <TaskEntity>[];
    final notUrgentImportant = <TaskEntity>[];
    final urgentNotImportant = <TaskEntity>[];
    final notUrgentNotImportant = <TaskEntity>[];

    for (final task in filteredTasks) {
      final quadrant = state.autoCategorization
          ? _autoCategorizTask(task)
          : _manualCategorizTask(task);

      switch (quadrant) {
        case MatrixQuadrant.urgentImportant:
          urgentImportant.add(task);
          break;
        case MatrixQuadrant.notUrgentImportant:
          notUrgentImportant.add(task);
          break;
        case MatrixQuadrant.urgentNotImportant:
          urgentNotImportant.add(task);
          break;
        case MatrixQuadrant.notUrgentNotImportant:
          notUrgentNotImportant.add(task);
          break;
      }
    }

    // Sort tasks within each quadrant by priority and due date
    urgentImportant.sort(_compareTasksByPriorityAndDate);
    notUrgentImportant.sort(_compareTasksByPriorityAndDate);
    urgentNotImportant.sort(_compareTasksByPriorityAndDate);
    notUrgentNotImportant.sort(_compareTasksByPriorityAndDate);

    state = state.copyWith(
      urgentImportantTasks: urgentImportant,
      notUrgentImportantTasks: notUrgentImportant,
      urgentNotImportantTasks: urgentNotImportant,
      notUrgentNotImportantTasks: notUrgentNotImportant,
    );
  }

  /// Auto-categorize task based on priority and due date
  MatrixQuadrant _autoCategorizTask(TaskEntity task) {
    final isUrgent = _isTaskUrgent(task);
    final isImportant = _isTaskImportant(task);

    if (isUrgent && isImportant) {
      return MatrixQuadrant.urgentImportant;
    } else if (!isUrgent && isImportant) {
      return MatrixQuadrant.notUrgentImportant;
    } else if (isUrgent && !isImportant) {
      return MatrixQuadrant.urgentNotImportant;
    } else {
      return MatrixQuadrant.notUrgentNotImportant;
    }
  }

  /// Manual categorization (placeholder - would use task metadata)
  MatrixQuadrant _manualCategorizTask(TaskEntity task) {
    // In a real implementation, this would check task metadata
    // For now, fall back to auto-categorization
    return _autoCategorizTask(task);
  }

  /// Check if task is urgent
  bool _isTaskUrgent(TaskEntity task) {
    if (task.dueDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    // Overdue tasks are urgent
    if (dueDate.isBefore(today)) return true;

    // Due today is urgent
    if (dueDate.isAtSameMomentAs(today)) return true;

    // Due within 3 days is urgent
    final daysUntilDue = dueDate.difference(today).inDays;
    return daysUntilDue <= 3;
  }

  /// Check if task is important
  bool _isTaskImportant(TaskEntity task) {
    // High or critical priority tasks are important
    if (task.priority == TaskPriority.high ||
        task.priority == TaskPriority.critical) {
      return true;
    }

    // Tasks with tags might indicate importance
    // This is a simplified heuristic
    if (task.tags.isNotEmpty) {
      return true;
    }

    // Medium priority with a due date is considered important
    if (task.priority == TaskPriority.medium && task.dueDate != null) {
      return true;
    }

    return false;
  }

  /// Compare tasks by priority and due date
  int _compareTasksByPriorityAndDate(TaskEntity a, TaskEntity b) {
    // First by priority (high to low)
    if (a.priority.index != b.priority.index) {
      return b.priority.index.compareTo(a.priority.index);
    }

    // Then by due date (earliest first)
    if (a.dueDate != null && b.dueDate != null) {
      return a.dueDate!.compareTo(b.dueDate!);
    }
    if (a.dueDate != null) return -1;
    if (b.dueDate != null) return 1;

    return 0;
  }

  /// Move task to a different quadrant
  Future<bool> moveTask(TaskEntity task, MatrixQuadrant toQuadrant) async {
    // In a real implementation, you might update task metadata
    // to store the manual quadrant assignment
    // For now, we'll just refresh the view
    await loadTasks();
    return true;
  }

  /// Set focus mode to a specific quadrant
  void setFocusQuadrant(MatrixQuadrant? quadrant) {
    state = state.copyWith(focusQuadrant: quadrant);
  }

  /// Toggle show completed tasks
  void toggleShowCompletedTasks() {
    state = state.copyWith(showCompletedTasks: !state.showCompletedTasks);
    loadTasks();
  }

  /// Filter by list
  void filterByList(String? listId) {
    state = state.copyWith(selectedListId: listId);
    loadTasks();
  }

  /// Toggle auto-categorization
  void toggleAutoCategorization() {
    state = state.copyWith(autoCategorization: !state.autoCategorization);
    loadTasks();
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      selectedListId: null,
      focusQuadrant: null,
    );
    loadTasks();
  }

  /// Refresh matrix data
  Future<void> refresh() async {
    await loadTasks();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
