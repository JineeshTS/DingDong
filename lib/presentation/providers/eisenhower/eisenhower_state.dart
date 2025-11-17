import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/task_entity.dart';

part 'eisenhower_state.freezed.dart';

/// Eisenhower Matrix quadrant
enum MatrixQuadrant {
  /// Quadrant 1: Urgent & Important (Do First)
  urgentImportant,

  /// Quadrant 2: Not Urgent & Important (Schedule)
  notUrgentImportant,

  /// Quadrant 3: Urgent & Not Important (Delegate)
  urgentNotImportant,

  /// Quadrant 4: Not Urgent & Not Important (Eliminate)
  notUrgentNotImportant,
}

/// Extension for MatrixQuadrant
extension MatrixQuadrantX on MatrixQuadrant {
  /// Get quadrant title
  String get title {
    switch (this) {
      case MatrixQuadrant.urgentImportant:
        return 'Do First';
      case MatrixQuadrant.notUrgentImportant:
        return 'Schedule';
      case MatrixQuadrant.urgentNotImportant:
        return 'Delegate';
      case MatrixQuadrant.notUrgentNotImportant:
        return 'Eliminate';
    }
  }

  /// Get quadrant subtitle
  String get subtitle {
    switch (this) {
      case MatrixQuadrant.urgentImportant:
        return 'Urgent & Important';
      case MatrixQuadrant.notUrgentImportant:
        return 'Not Urgent & Important';
      case MatrixQuadrant.urgentNotImportant:
        return 'Urgent & Not Important';
      case MatrixQuadrant.notUrgentNotImportant:
        return 'Not Urgent & Not Important';
    }
  }

  /// Get quadrant description
  String get description {
    switch (this) {
      case MatrixQuadrant.urgentImportant:
        return 'Tasks that require immediate attention';
      case MatrixQuadrant.notUrgentImportant:
        return 'Tasks for long-term development';
      case MatrixQuadrant.urgentNotImportant:
        return 'Tasks that could be delegated';
      case MatrixQuadrant.notUrgentNotImportant:
        return 'Tasks to minimize or eliminate';
    }
  }

  /// Get quadrant color index
  int get colorIndex {
    switch (this) {
      case MatrixQuadrant.urgentImportant:
        return 0; // Red
      case MatrixQuadrant.notUrgentImportant:
        return 1; // Blue
      case MatrixQuadrant.urgentNotImportant:
        return 2; // Orange
      case MatrixQuadrant.notUrgentNotImportant:
        return 3; // Gray
    }
  }
}

/// Eisenhower Matrix state
@freezed
class EisenhowerState with _$EisenhowerState {
  const factory EisenhowerState({
    /// Tasks in quadrant 1 (Urgent & Important)
    @Default([]) List<TaskEntity> urgentImportantTasks,

    /// Tasks in quadrant 2 (Not Urgent & Important)
    @Default([]) List<TaskEntity> notUrgentImportantTasks,

    /// Tasks in quadrant 3 (Urgent & Not Important)
    @Default([]) List<TaskEntity> urgentNotImportantTasks,

    /// Tasks in quadrant 4 (Not Urgent & Not Important)
    @Default([]) List<TaskEntity> notUrgentNotImportantTasks,

    /// Selected quadrant for focus mode
    @Default(null) MatrixQuadrant? focusQuadrant,

    /// Show completed tasks
    @Default(false) bool showCompletedTasks,

    /// Filter by list
    @Default(null) String? selectedListId,

    /// Auto-categorization enabled
    @Default(true) bool autoCategorization,

    /// Loading state
    @Default(false) bool isLoading,

    /// Error message
    @Default(null) String? error,
  }) = _EisenhowerState;

  const EisenhowerState._();

  /// Get tasks for a specific quadrant
  List<TaskEntity> getTasksForQuadrant(MatrixQuadrant quadrant) {
    switch (quadrant) {
      case MatrixQuadrant.urgentImportant:
        return urgentImportantTasks;
      case MatrixQuadrant.notUrgentImportant:
        return notUrgentImportantTasks;
      case MatrixQuadrant.urgentNotImportant:
        return urgentNotImportantTasks;
      case MatrixQuadrant.notUrgentNotImportant:
        return notUrgentNotImportantTasks;
    }
  }

  /// Get total tasks count
  int get totalTasksCount =>
      urgentImportantTasks.length +
      notUrgentImportantTasks.length +
      urgentNotImportantTasks.length +
      notUrgentNotImportantTasks.length;

  /// Get completed tasks count
  int get completedTasksCount {
    return [
      ...urgentImportantTasks,
      ...notUrgentImportantTasks,
      ...urgentNotImportantTasks,
      ...notUrgentNotImportantTasks,
    ].where((t) => t.isCompleted).length;
  }

  /// Get incomplete tasks count
  int get incompleteTasksCount => totalTasksCount - completedTasksCount;

  /// Check if in focus mode
  bool get isFocusMode => focusQuadrant != null;

  /// Get all tasks
  List<TaskEntity> get allTasks => [
        ...urgentImportantTasks,
        ...notUrgentImportantTasks,
        ...urgentNotImportantTasks,
        ...notUrgentNotImportantTasks,
      ];

  /// Factory for initial state
  factory EisenhowerState.initial() => const EisenhowerState();
}
