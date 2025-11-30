import 'package:freezed_annotation/freezed_annotation.dart';

import 'productivity_insight.dart';
import 'task_entity.dart';

part 'smart_schedule.freezed.dart';
part 'smart_schedule.g.dart';

/// Smart Schedule Result
///
/// Contains the AI-generated schedule with optimal time slots for tasks
@freezed
class SmartScheduleResult with _$SmartScheduleResult {
  const factory SmartScheduleResult({
    required String id,
    required List<ScheduledTask> scheduledTasks,
    required List<ScheduleConflict> conflicts,
    required SchedulingMetrics metrics,
    required DateTime scheduledAt,
    required SchedulingCriteria criteria,
    DateTime? scheduleStartDate,
    DateTime? scheduleEndDate,
  }) = _SmartScheduleResult;

  factory SmartScheduleResult.fromJson(Map<String, dynamic> json) =>
      _$SmartScheduleResultFromJson(json);

  const SmartScheduleResult._();

  /// Has conflicts
  bool get hasConflicts => conflicts.isNotEmpty;

  /// Number of tasks scheduled
  int get scheduledCount => scheduledTasks.length;

  /// Number of conflicts
  int get conflictCount => conflicts.length;

  /// Successfully scheduled tasks (no conflicts)
  List<ScheduledTask> get successfullyScheduled =>
      scheduledTasks.where((t) => !t.hasConflict).toList();

  /// Tasks with conflicts
  List<ScheduledTask> get tasksWithConflicts =>
      scheduledTasks.where((t) => t.hasConflict).toList();
}

/// Scheduled Task
///
/// A task with an AI-assigned time slot
@freezed
class ScheduledTask with _$ScheduledTask {
  const factory ScheduledTask({
    required String taskId,
    required String taskTitle,
    required DateTime suggestedStartTime,
    required DateTime suggestedEndTime,
    required int estimatedDuration, // in minutes
    required double confidence,
    required SchedulingReason reason,
    String? conflictReason,
    @Default(false) bool hasConflict,
    @Default(false) bool isAccepted,
    @Default(false) bool isRejected,
  }) = _ScheduledTask;

  factory ScheduledTask.fromJson(Map<String, dynamic> json) =>
      _$ScheduledTaskFromJson(json);

  const ScheduledTask._();

  /// Duration in hours
  double get durationHours => estimatedDuration / 60.0;

  /// Is high confidence
  bool get isHighConfidence => confidence >= 0.8;

  /// Is pending (not accepted or rejected)
  bool get isPending => !isAccepted && !isRejected;

  /// Time slot display
  String get timeSlotDisplay {
    final start = _formatTime(suggestedStartTime);
    final end = _formatTime(suggestedEndTime);
    return '$start - $end';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

/// Scheduling Reason
///
/// Why this time slot was chosen
enum SchedulingReason {
  peakEnergy,
  lowEnergy,
  calendarAvailability,
  batchedSimilarTasks,
  beforeDeadline,
  focusBlock,
  bufferTime,
  userPreference,
}

/// Extension for SchedulingReason
extension SchedulingReasonX on SchedulingReason {
  String get displayName {
    switch (this) {
      case SchedulingReason.peakEnergy:
        return 'Peak Energy Time';
      case SchedulingReason.lowEnergy:
        return 'Low Energy Task';
      case SchedulingReason.calendarAvailability:
        return 'Calendar Available';
      case SchedulingReason.batchedSimilarTasks:
        return 'Batched with Similar Tasks';
      case SchedulingReason.beforeDeadline:
        return 'Before Deadline';
      case SchedulingReason.focusBlock:
        return 'Focus Time Block';
      case SchedulingReason.bufferTime:
        return 'Buffer Time Included';
      case SchedulingReason.userPreference:
        return 'Your Preference';
    }
  }

  String get description {
    switch (this) {
      case SchedulingReason.peakEnergy:
        return 'Scheduled during your peak productivity hours';
      case SchedulingReason.lowEnergy:
        return 'Simple task scheduled for low energy period';
      case SchedulingReason.calendarAvailability:
        return 'Time slot is free on your calendar';
      case SchedulingReason.batchedSimilarTasks:
        return 'Grouped with similar tasks for efficiency';
      case SchedulingReason.beforeDeadline:
        return 'Scheduled to meet deadline with buffer';
      case SchedulingReason.focusBlock:
        return 'Protected focus time for deep work';
      case SchedulingReason.bufferTime:
        return 'Includes buffer for transitions';
      case SchedulingReason.userPreference:
        return 'Matches your work preferences';
    }
  }

  String get icon {
    switch (this) {
      case SchedulingReason.peakEnergy:
        return '⚡';
      case SchedulingReason.lowEnergy:
        return '😌';
      case SchedulingReason.calendarAvailability:
        return '📅';
      case SchedulingReason.batchedSimilarTasks:
        return '📦';
      case SchedulingReason.beforeDeadline:
        return '⏰';
      case SchedulingReason.focusBlock:
        return '🎯';
      case SchedulingReason.bufferTime:
        return '⏸️';
      case SchedulingReason.userPreference:
        return '⭐';
    }
  }
}

/// Schedule Conflict
///
/// Represents a scheduling conflict
@freezed
class ScheduleConflict with _$ScheduleConflict {
  const factory ScheduleConflict({
    required String taskId,
    required String taskTitle,
    required ConflictType type,
    required String description,
    DateTime? conflictingTimeStart,
    DateTime? conflictingTimeEnd,
    String? conflictingEventTitle,
  }) = _ScheduleConflict;

  factory ScheduleConflict.fromJson(Map<String, dynamic> json) =>
      _$ScheduleConflictFromJson(json);
}

/// Conflict Type
enum ConflictType {
  calendarOverlap,
  insufficientTime,
  tooLate,
  noAvailableSlots,
  energyMismatch,
}

/// Extension for ConflictType
extension ConflictTypeX on ConflictType {
  String get displayName {
    switch (this) {
      case ConflictType.calendarOverlap:
        return 'Calendar Conflict';
      case ConflictType.insufficientTime:
        return 'Not Enough Time';
      case ConflictType.tooLate:
        return 'Too Close to Deadline';
      case ConflictType.noAvailableSlots:
        return 'No Available Slots';
      case ConflictType.energyMismatch:
        return 'Energy Level Mismatch';
    }
  }
}

/// Scheduling Criteria
///
/// Criteria and preferences for scheduling
@freezed
class SchedulingCriteria with _$SchedulingCriteria {
  const factory SchedulingCriteria({
    // Time range
    DateTime? startDate,
    DateTime? endDate,

    // Work hours
    @Default(9) int workDayStartHour,
    @Default(17) int workDayEndHour,

    // Preferences
    @Default(true) bool respectEnergyLevels,
    @Default(true) bool avoidCalendarConflicts,
    @Default(true) bool batchSimilarTasks,
    @Default(true) bool includeBufferTime,
    @Default(true) bool respectFocusBlocks,

    // Buffer time (in minutes)
    @Default(15) int bufferMinutes,

    // Focus block duration (in minutes)
    @Default(90) int focusBlockDuration,

    // Maximum tasks per day
    @Default(10) int maxTasksPerDay,

    // Break time after focus blocks (in minutes)
    @Default(15) int breakAfterFocusMinutes,

    // Priority thresholds
    @Default(true) bool prioritizeHighPriority,
    @Default(true) bool prioritizeNearDeadlines,
  }) = _SchedulingCriteria;

  factory SchedulingCriteria.fromJson(Map<String, dynamic> json) =>
      _$SchedulingCriteriaFromJson(json);

  const SchedulingCriteria._();

  /// Work day duration in hours
  int get workDayHours => workDayEndHour - workDayStartHour;

  /// Available minutes per day
  int get availableMinutesPerDay => workDayHours * 60;
}

/// Scheduling Metrics
///
/// Metrics about the scheduling operation
@freezed
class SchedulingMetrics with _$SchedulingMetrics {
  const factory SchedulingMetrics({
    @Default(0) int totalTasksToSchedule,
    @Default(0) int successfullyScheduled,
    @Default(0) int conflictCount,
    @Default(0) int tasksRequiringManualScheduling,
    @Default(0.0) double averageConfidence,
    @Default(0) int totalScheduledMinutes,
    @Default(0) int totalBufferMinutes,
    @Default(0) int focusBlocksCreated,
    @Default(0) int batchedTaskGroups,
  }) = _SchedulingMetrics;

  factory SchedulingMetrics.fromJson(Map<String, dynamic> json) =>
      _$SchedulingMetricsFromJson(json);

  const SchedulingMetrics._();

  /// Success rate (0-1)
  double get successRate {
    if (totalTasksToSchedule == 0) return 0.0;
    return successfullyScheduled / totalTasksToSchedule;
  }

  /// Success rate percentage
  int get successRatePercentage => (successRate * 100).round();

  /// Total scheduled hours
  double get totalScheduledHours => totalScheduledMinutes / 60.0;

  /// Has high success rate
  bool get hasHighSuccessRate => successRate >= 0.8;
}

/// Time Block
///
/// Represents a time block in the schedule
@freezed
class TimeBlock with _$TimeBlock {
  const factory TimeBlock({
    required DateTime startTime,
    required DateTime endTime,
    required TimeBlockType type,
    String? label,
    List<String>? taskIds,
  }) = _TimeBlock;

  factory TimeBlock.fromJson(Map<String, dynamic> json) =>
      _$TimeBlockFromJson(json);

  const TimeBlock._();

  /// Duration in minutes
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  /// Is available for scheduling
  bool get isAvailable => type == TimeBlockType.available;

  /// Is occupied
  bool get isOccupied =>
      type == TimeBlockType.scheduled || type == TimeBlockType.meeting;
}

/// Time Block Type
enum TimeBlockType {
  available,
  scheduled,
  meeting,
  focusBlock,
  breakTime,
  buffer,
}

/// Extension for TimeBlockType
extension TimeBlockTypeX on TimeBlockType {
  String get displayName {
    switch (this) {
      case TimeBlockType.available:
        return 'Available';
      case TimeBlockType.scheduled:
        return 'Scheduled Task';
      case TimeBlockType.meeting:
        return 'Meeting';
      case TimeBlockType.focusBlock:
        return 'Focus Time';
      case TimeBlockType.breakTime:
        return 'Break';
      case TimeBlockType.buffer:
        return 'Buffer Time';
    }
  }
}

/// Schedule Preferences
///
/// User's scheduling preferences
@freezed
class SchedulePreferences with _$SchedulePreferences {
  const factory SchedulePreferences({
    // Peak hours
    @Default(9) int peakStartHour,
    @Default(11) int peakEndHour,

    // Preferred work hours
    @Default(9) int preferredStartHour,
    @Default(17) int preferredEndHour,

    // Break preferences
    @Default(true) bool autoScheduleBreaks,
    @Default(60) int breakAfterMinutes,
    @Default(15) int breakDurationMinutes,

    // Task batching
    @Default(true) bool enableTaskBatching,
    @Default(['work', 'personal', 'email']) List<String> batchableCategories,

    // Focus time
    @Default(true) bool protectFocusTime,
    @Default(90) int focusBlockMinutes,
    @Default([9, 14]) List<int> preferredFocusHours,

    // Buffer time
    @Default(true) bool addBufferBetweenTasks,
    @Default(15) int bufferMinutes,

    // Days
    @Default([1, 2, 3, 4, 5]) List<int> workDays, // 1=Monday, 7=Sunday
  }) = _SchedulePreferences;

  factory SchedulePreferences.fromJson(Map<String, dynamic> json) =>
      _$SchedulePreferencesFromJson(json);

  const SchedulePreferences._();

  /// Is work day
  bool isWorkDay(DateTime date) {
    return workDays.contains(date.weekday);
  }

  /// Is peak hour
  bool isPeakHour(int hour) {
    return hour >= peakStartHour && hour < peakEndHour;
  }

  /// Is within work hours
  bool isWithinWorkHours(int hour) {
    return hour >= preferredStartHour && hour < preferredEndHour;
  }
}
