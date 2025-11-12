import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task/get_tasks_usecase.dart';
import '../../../domain/usecases/task/update_task_usecase.dart';
import 'kanban_state.dart';

/// Kanban board state notifier
///
/// Manages Kanban board state including:
/// - Column management
/// - Task organization by status
/// - Drag-and-drop operations
/// - WIP limit enforcement
/// - Filtering and grouping
class KanbanNotifier extends StateNotifier<KanbanState> {
  KanbanNotifier({
    required this.getTasksUseCase,
    required this.updateTaskUseCase,
    required this.userId,
  }) : super(KanbanState.initial()) {
    // Load tasks for initial view
    loadTasks();
  }

  final GetTasksUseCase getTasksUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final String userId;

  /// Load all tasks and organize into columns
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

  /// Organize tasks into columns based on status
  void _organizeTasks(List<TaskEntity> tasks) {
    var filteredTasks = tasks;

    // Apply filters
    if (state.selectedListId != null) {
      filteredTasks = filteredTasks
          .where((task) => task.categoryId == state.selectedListId)
          .toList();
    }

    if (state.selectedTags.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) {
        return state.selectedTags.any((tag) => task.tags.contains(tag));
      }).toList();
    }

    if (state.selectedPriority != null) {
      filteredTasks = filteredTasks
          .where((task) => task.priority == state.selectedPriority)
          .toList();
    }

    if (!state.showCompletedTasks) {
      filteredTasks = filteredTasks
          .where((task) => task.status != TaskStatus.completed)
          .toList();
    }

    // Organize into columns
    final updatedColumns = state.columns.map((column) {
      final columnTasks = filteredTasks
          .where((task) => task.status == column.status)
          .toList()
        ..sort((a, b) {
          // Sort by priority (high to low), then by due date
          if (a.priority.index != b.priority.index) {
            return b.priority.index.compareTo(a.priority.index);
          }
          if (a.dueDate != null && b.dueDate != null) {
            return a.dueDate!.compareTo(b.dueDate!);
          }
          if (a.dueDate != null) return -1;
          if (b.dueDate != null) return 1;
          return 0;
        });

      return column.copyWith(tasks: columnTasks);
    }).toList();

    state = state.copyWith(columns: updatedColumns);
  }

  /// Move task to a different column (update status)
  Future<bool> moveTask(
    TaskEntity task,
    String fromColumnId,
    String toColumnId,
  ) async {
    final toColumn = state.getColumn(toColumnId);
    if (toColumn == null) return false;

    // Check WIP limit
    if (toColumn.isAtWipLimit && toColumn.wipLimit != null) {
      state = state.copyWith(
        error:
            'Cannot move task: "${toColumn.name}" has reached WIP limit of ${toColumn.wipLimit}',
      );
      return false;
    }

    // Update task status
    final updatedTask = task.copyWith(status: toColumn.status);

    final result = await updateTaskUseCase.call(
      UpdateTaskParams(
        userId: userId,
        taskId: task.id,
        title: updatedTask.title,
        description: updatedTask.description,
        status: updatedTask.status,
        priority: updatedTask.priority,
        dueDate: updatedTask.dueDate,
        tags: updatedTask.tags,
        categoryId: updatedTask.categoryId,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (success) {
        // Refresh tasks
        loadTasks();
        return true;
      },
    );
  }

  /// Reorder task within same column
  void reorderTaskInColumn(
    String columnId,
    int oldIndex,
    int newIndex,
  ) {
    final columnIndex = state.columns.indexWhere((c) => c.id == columnId);
    if (columnIndex == -1) return;

    final column = state.columns[columnIndex];
    final tasks = List<TaskEntity>.from(column.tasks);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);

    final updatedColumn = column.copyWith(tasks: tasks);
    final updatedColumns = List<KanbanColumn>.from(state.columns);
    updatedColumns[columnIndex] = updatedColumn;

    state = state.copyWith(columns: updatedColumns);
  }

  /// Change view mode
  void setViewMode(KanbanViewMode mode) {
    state = state.copyWith(viewMode: mode);
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

  /// Filter by tags
  void filterByTags(List<String> tags) {
    state = state.copyWith(selectedTags: tags);
    loadTasks();
  }

  /// Filter by priority
  void filterByPriority(TaskPriority? priority) {
    state = state.copyWith(selectedPriority: priority);
    loadTasks();
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      selectedListId: null,
      selectedTags: [],
      selectedPriority: null,
    );
    loadTasks();
  }

  /// Set WIP limit for a column
  void setWipLimit(String columnId, int? limit) {
    final columnIndex = state.columns.indexWhere((c) => c.id == columnId);
    if (columnIndex == -1) return;

    final column = state.columns[columnIndex];
    final updatedColumn = column.copyWith(wipLimit: limit);
    final updatedColumns = List<KanbanColumn>.from(state.columns);
    updatedColumns[columnIndex] = updatedColumn;

    state = state.copyWith(columns: updatedColumns);
  }

  /// Toggle column visibility
  void toggleColumnVisibility(String columnId) {
    final columnIndex = state.columns.indexWhere((c) => c.id == columnId);
    if (columnIndex == -1) return;

    final column = state.columns[columnIndex];
    final updatedColumn = column.copyWith(isVisible: !column.isVisible);
    final updatedColumns = List<KanbanColumn>.from(state.columns);
    updatedColumns[columnIndex] = updatedColumn;

    state = state.copyWith(columns: updatedColumns);
  }

  /// Toggle column collapsed state
  void toggleColumnCollapsed(String columnId) {
    final columnIndex = state.columns.indexWhere((c) => c.id == columnId);
    if (columnIndex == -1) return;

    final column = state.columns[columnIndex];
    final updatedColumn = column.copyWith(isCollapsed: !column.isCollapsed);
    final updatedColumns = List<KanbanColumn>.from(state.columns);
    updatedColumns[columnIndex] = updatedColumn;

    state = state.copyWith(columns: updatedColumns);
  }

  /// Refresh board data
  Future<void> refresh() async {
    await loadTasks();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
