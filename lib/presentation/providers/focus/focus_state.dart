import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/task_entity.dart';

part 'focus_state.freezed.dart';

/// Focus view mode
enum FocusViewMode {
  /// Timeline view with time blocks
  timeline,

  /// Simple list view
  list,
}

/// Time of day
enum TimeOfDay {
  /// Morning (6am - 12pm)
  morning,

  /// Afternoon (12pm - 6pm)
  afternoon,

  /// Evening (6pm - 12am)
  evening,

  /// Night (12am - 6am)
  night,
}

/// Focus/Today state
@freezed
class FocusState with _$FocusState {
  const factory FocusState({
    /// Tasks for today
    @Default([]) List<TaskEntity> todayTasks,

    /// Overdue tasks
    @Default([]) List<TaskEntity> overdueTasks,

    /// Completed tasks today
    @Default([]) List<TaskEntity> completedTasks,

    /// Current view mode
    @Default(FocusViewMode.timeline) FocusViewMode viewMode,

    /// Show completed tasks
    @Default(false) bool showCompletedTasks,

    /// Current time of day
    @Default(TimeOfDay.morning) TimeOfDay currentTimeOfDay,

    /// Next suggested task
    @Default(null) TaskEntity? nextSuggestedTask,

    /// Show morning planning prompt
    @Default(false) bool showMorningPrompt,

    /// Show evening review prompt
    @Default(false) bool showEveningPrompt,

    /// Loading state
    @Default(false) bool isLoading,

    /// Error message
    @Default(null) String? error,
  }) = _FocusState;

  const FocusState._();

  /// Get total tasks for today (including overdue)
  int get totalTasksCount => todayTasks.length + overdueTasks.length;

  /// Get incomplete tasks count
  int get incompleteTasksCount =>
      todayTasks.where((t) => !t.isCompleted).length +
      overdueTasks.where((t) => !t.isCompleted).length;

  /// Get completed tasks count today
  int get completedTasksCount => completedTasks.length;

  /// Get completion percentage
  double get completionPercentage {
    if (totalTasksCount == 0) return 0;
    return (completedTasksCount / totalTasksCount) * 100;
  }

  /// Get all incomplete tasks (overdue + today)
  List<TaskEntity> get allIncompleteTasks {
    final tasks = <TaskEntity>[
      ...overdueTasks.where((t) => !t.isCompleted),
      ...todayTasks.where((t) => !t.isCompleted),
    ];

    // Sort by priority and time
    tasks.sort((a, b) {
      // Overdue tasks first
      final aOverdue = a.dueDate != null &&
          a.dueDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)));
      final bOverdue = b.dueDate != null &&
          b.dueDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)));

      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;

      // Then by priority
      if (a.priority.index != b.priority.index) {
        return b.priority.index.compareTo(a.priority.index);
      }

      // Then by due time if available
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }

      return 0;
    });

    return tasks;
  }

  /// Get tasks for a specific time of day
  List<TaskEntity> getTasksForTimeOfDay(TimeOfDay timeOfDay) {
    return todayTasks.where((task) {
      if (task.dueDate == null) return false;

      final hour = task.dueDate!.hour;

      switch (timeOfDay) {
        case TimeOfDay.morning:
          return hour >= 6 && hour < 12;
        case TimeOfDay.afternoon:
          return hour >= 12 && hour < 18;
        case TimeOfDay.evening:
          return hour >= 18 && hour < 24;
        case TimeOfDay.night:
          return hour >= 0 && hour < 6;
      }
    }).toList();
  }

  /// Check if it's time for morning planning
  bool get isMorningPlanningTime {
    final now = DateTime.now();
    return now.hour >= 6 && now.hour < 10 && incompleteTasksCount > 0;
  }

  /// Check if it's time for evening review
  bool get isEveningReviewTime {
    final now = DateTime.now();
    return now.hour >= 18 && now.hour < 22;
  }

  /// Get greeting based on time of day
  String get greeting {
    final now = DateTime.now();
    if (now.hour >= 5 && now.hour < 12) return 'Good Morning';
    if (now.hour >= 12 && now.hour < 17) return 'Good Afternoon';
    if (now.hour >= 17 && now.hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  /// Factory for initial state
  factory FocusState.initial() {
    final now = DateTime.now();
    TimeOfDay currentTime;

    if (now.hour >= 6 && now.hour < 12) {
      currentTime = TimeOfDay.morning;
    } else if (now.hour >= 12 && now.hour < 18) {
      currentTime = TimeOfDay.afternoon;
    } else if (now.hour >= 18 && now.hour < 24) {
      currentTime = TimeOfDay.evening;
    } else {
      currentTime = TimeOfDay.night;
    }

    return FocusState(currentTimeOfDay: currentTime);
  }
}
