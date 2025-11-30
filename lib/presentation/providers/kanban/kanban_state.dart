import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/task_entity.dart';

part 'kanban_state.freezed.dart';

/// Kanban board view modes
enum KanbanViewMode {
  /// Standard columns view
  columns,

  /// Swimlanes view (grouped by category/assignee)
  swimlanes,
}

/// Kanban column definition
@freezed
class KanbanColumn with _$KanbanColumn {
  const factory KanbanColumn({
    required String id,
    required String name,
    required TaskStatus status,
    @Default([]) List<TaskEntity> tasks,
    @Default(null) int? wipLimit, // Work In Progress limit
    @Default(0) int order,
    @Default(true) bool isVisible,
    @Default(false) bool isCollapsed,
  }) = _KanbanColumn;

  const KanbanColumn._();

  /// Check if column is at WIP limit
  bool get isAtWipLimit {
    if (wipLimit == null) return false;
    return tasks.length >= wipLimit!;
  }

  /// Get tasks count
  int get taskCount => tasks.length;

  /// Get incomplete tasks count
  int get incompleteCount =>
      tasks.where((t) => t.status != TaskStatus.completed).length;
}

/// Kanban board state
@freezed
class KanbanState with _$KanbanState {
  const factory KanbanState({
    /// Board columns
    @Default([]) List<KanbanColumn> columns,

    /// Current view mode
    @Default(KanbanViewMode.columns) KanbanViewMode viewMode,

    /// Selected list ID (null = all tasks)
    @Default(null) String? selectedListId,

    /// Swimlane grouping (category, assignee, priority)
    @Default('category') String swimlaneGroupBy,

    /// Show completed tasks
    @Default(false) bool showCompletedTasks,

    /// Filter by tags
    @Default([]) List<String> selectedTags,

    /// Filter by priority
    @Default(null) TaskPriority? selectedPriority,

    /// Loading state
    @Default(false) bool isLoading,

    /// Error message
    @Default(null) String? error,
  }) = _KanbanState;

  const KanbanState._();

  /// Get all tasks across all columns
  List<TaskEntity> get allTasks {
    return columns.expand((column) => column.tasks).toList();
  }

  /// Get total tasks count
  int get totalTasksCount => allTasks.length;

  /// Get completed tasks count
  int get completedTasksCount =>
      allTasks.where((t) => t.status == TaskStatus.completed).length;

  /// Get incomplete tasks count
  int get incompleteTasksCount => totalTasksCount - completedTasksCount;

  /// Get tasks for a specific column
  List<TaskEntity> getTasksForColumn(String columnId) {
    final column = columns.firstWhere(
      (c) => c.id == columnId,
      orElse: () => const KanbanColumn(
        id: '',
        name: '',
        status: TaskStatus.todo,
      ),
    );
    return column.tasks;
  }

  /// Get column by ID
  KanbanColumn? getColumn(String columnId) {
    try {
      return columns.firstWhere((c) => c.id == columnId);
    } catch (_) {
      return null;
    }
  }

  /// Check if any column is at WIP limit
  bool get hasWipLimitReached {
    return columns.any((column) => column.isAtWipLimit);
  }

  /// Get visible columns
  List<KanbanColumn> get visibleColumns {
    return columns.where((c) => c.isVisible).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Factory for initial state
  factory KanbanState.initial() {
    return KanbanState(
      columns: [
        const KanbanColumn(
          id: 'todo',
          name: 'To Do',
          status: TaskStatus.todo,
          order: 0,
        ),
        const KanbanColumn(
          id: 'in_progress',
          name: 'In Progress',
          status: TaskStatus.inProgress,
          order: 1,
          wipLimit: 5, // Default WIP limit
        ),
        const KanbanColumn(
          id: 'completed',
          name: 'Completed',
          status: TaskStatus.completed,
          order: 2,
        ),
      ],
    );
  }
}
