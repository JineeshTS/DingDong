import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/smart_schedule.dart';

part 'smart_schedule_state.freezed.dart';

/// Smart Schedule State
@freezed
class SmartScheduleState with _$SmartScheduleState {
  const factory SmartScheduleState({
    // Current schedule result
    SmartScheduleResult? currentSchedule,

    // Scheduling preferences
    SchedulePreferences? preferences,

    // Criteria used for last scheduling
    SchedulingCriteria? lastCriteria,

    // Loading state
    @Default(false) bool isScheduling,

    // Accepted task IDs (user accepted the scheduled time)
    @Default([]) List<String> acceptedTaskIds,

    // Rejected task IDs (user rejected the suggested time)
    @Default([]) List<String> rejectedTaskIds,

    // Calendar blocks (from external calendar)
    @Default([]) List<TimeBlock> calendarBlocks,

    // Error
    String? error,

    // Last scheduled time
    DateTime? lastScheduledAt,
  }) = _SmartScheduleState;

  const SmartScheduleState._();

  /// Has schedule
  bool get hasSchedule => currentSchedule != null;

  /// Has conflicts
  bool get hasConflicts => currentSchedule?.hasConflicts ?? false;

  /// Scheduled tasks
  List<ScheduledTask> get scheduledTasks =>
      currentSchedule?.scheduledTasks ?? [];

  /// Pending tasks (not accepted or rejected)
  List<ScheduledTask> get pendingTasks {
    return scheduledTasks.where((task) {
      return !acceptedTaskIds.contains(task.taskId) &&
          !rejectedTaskIds.contains(task.taskId);
    }).toList();
  }

  /// Accepted tasks
  List<ScheduledTask> get acceptedTasks {
    return scheduledTasks
        .where((task) => acceptedTaskIds.contains(task.taskId))
        .toList();
  }

  /// Rejected tasks
  List<ScheduledTask> get rejectedTasks {
    return scheduledTasks
        .where((task) => rejectedTaskIds.contains(task.taskId))
        .toList();
  }

  /// Conflicts
  List<ScheduleConflict> get conflicts =>
      currentSchedule?.conflicts ?? [];

  /// Metrics
  SchedulingMetrics? get metrics => currentSchedule?.metrics;

  /// Has error
  bool get hasError => error != null;

  /// Has preferences
  bool get hasPreferences => preferences != null;

  /// Number of pending tasks
  int get pendingCount => pendingTasks.length;

  /// Number of accepted tasks
  int get acceptedCount => acceptedTasks.length;

  /// Success rate
  double get successRate => metrics?.successRate ?? 0.0;
}
