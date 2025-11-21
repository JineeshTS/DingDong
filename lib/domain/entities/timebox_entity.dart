import 'package:equatable/equatable.dart';
import 'task_entity.dart';

/// Timebox Entity
///
/// Represents a daily agenda with time-slotted tasks organized by category
/// (Personal, Professional, Priority) with time conflict detection.
///
/// Features:
/// - Daily task scheduling with specific time blocks
/// - Personal/Professional/Priority categorization
/// - Time conflict detection and highlighting
/// - Visual daily agenda planning
class TimeboxEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final List<TimeboxSlot> slots;
  final List<TimeConflict> conflicts;
  final TimeboxSummary summary;
  final TimeboxSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TimeboxEntity({
    required this.id,
    required this.userId,
    required this.date,
    this.slots = const [],
    this.conflicts = const [],
    required this.summary,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if there are any conflicts
  bool get hasConflicts => conflicts.isNotEmpty;

  /// Get total scheduled hours
  double get totalScheduledHours {
    return slots.fold(0.0, (sum, slot) => sum + slot.durationMinutes) / 60.0;
  }

  /// Get tasks by category
  List<TimeboxSlot> getSlotsByCategory(TaskCategory category) {
    return slots.where((s) => s.category == category).toList();
  }

  /// Get personal tasks
  List<TimeboxSlot> get personalSlots =>
      getSlotsByCategory(TaskCategory.personal);

  /// Get professional tasks
  List<TimeboxSlot> get professionalSlots =>
      getSlotsByCategory(TaskCategory.professional);

  /// Get priority tasks (high/critical priority regardless of category)
  List<TimeboxSlot> get prioritySlots =>
      slots.where((s) => s.isPriority).toList();

  /// Get available time slots
  List<AvailableSlot> getAvailableSlots() {
    final available = <AvailableSlot>[];
    final sortedSlots = List<TimeboxSlot>.from(slots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    DateTime currentTime = DateTime(
      date.year,
      date.month,
      date.day,
      settings.dayStartHour,
      0,
    );

    final dayEnd = DateTime(
      date.year,
      date.month,
      date.day,
      settings.dayEndHour,
      0,
    );

    for (final slot in sortedSlots) {
      if (slot.startTime.isAfter(currentTime)) {
        available.add(AvailableSlot(
          startTime: currentTime,
          endTime: slot.startTime,
        ));
      }
      if (slot.endTime.isAfter(currentTime)) {
        currentTime = slot.endTime;
      }
    }

    if (currentTime.isBefore(dayEnd)) {
      available.add(AvailableSlot(
        startTime: currentTime,
        endTime: dayEnd,
      ));
    }

    return available;
  }

  /// Copy with method
  TimeboxEntity copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<TimeboxSlot>? slots,
    List<TimeConflict>? conflicts,
    TimeboxSummary? summary,
    TimeboxSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimeboxEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      slots: slots ?? this.slots,
      conflicts: conflicts ?? this.conflicts,
      summary: summary ?? this.summary,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        slots,
        conflicts,
        summary,
        settings,
        createdAt,
        updatedAt,
      ];
}

/// Timebox Slot
///
/// A single time-blocked task in the daily agenda
class TimeboxSlot extends Equatable {
  final String id;
  final String taskId;
  final String taskTitle;
  final String? taskDescription;
  final DateTime startTime;
  final DateTime endTime;
  final TaskCategory category;
  final TaskPriority priority;
  final TimeboxSlotStatus status;
  final String? listId;
  final String? listName;
  final String? listColor;
  final List<String> tags;
  final bool isRecurring;
  final bool isAllDay;
  final String? notes;

  const TimeboxSlot({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    this.taskDescription,
    required this.startTime,
    required this.endTime,
    required this.category,
    this.priority = TaskPriority.none,
    this.status = TimeboxSlotStatus.scheduled,
    this.listId,
    this.listName,
    this.listColor,
    this.tags = const [],
    this.isRecurring = false,
    this.isAllDay = false,
    this.notes,
  });

  /// Duration in minutes
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  /// Duration in hours
  double get durationHours => durationMinutes / 60.0;

  /// Is this a priority task (high or critical)
  bool get isPriority =>
      priority == TaskPriority.high || priority == TaskPriority.critical;

  /// Is this task in progress
  bool get isInProgress => status == TimeboxSlotStatus.inProgress;

  /// Is this task completed
  bool get isCompleted => status == TimeboxSlotStatus.completed;

  /// Is this task overdue (past end time and not completed)
  bool get isOverdue =>
      DateTime.now().isAfter(endTime) && status != TimeboxSlotStatus.completed;

  /// Is this task currently active (within time range)
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return now.isAfter(startTime) &&
        now.isBefore(endTime) &&
        status != TimeboxSlotStatus.completed;
  }

  /// Get time display string
  String get timeDisplay {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Copy with method
  TimeboxSlot copyWith({
    String? id,
    String? taskId,
    String? taskTitle,
    String? taskDescription,
    DateTime? startTime,
    DateTime? endTime,
    TaskCategory? category,
    TaskPriority? priority,
    TimeboxSlotStatus? status,
    String? listId,
    String? listName,
    String? listColor,
    List<String>? tags,
    bool? isRecurring,
    bool? isAllDay,
    String? notes,
  }) {
    return TimeboxSlot(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      taskDescription: taskDescription ?? this.taskDescription,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      listId: listId ?? this.listId,
      listName: listName ?? this.listName,
      listColor: listColor ?? this.listColor,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      isAllDay: isAllDay ?? this.isAllDay,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        taskTitle,
        taskDescription,
        startTime,
        endTime,
        category,
        priority,
        status,
        listId,
        listName,
        listColor,
        tags,
        isRecurring,
        isAllDay,
        notes,
      ];
}

/// Task Category
///
/// Categories for organizing tasks in the timebox
enum TaskCategory {
  personal,
  professional,
  health,
  learning,
  errands,
  social,
  other,
}

/// Extension for TaskCategory
extension TaskCategoryX on TaskCategory {
  String get displayName {
    switch (this) {
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.professional:
        return 'Professional';
      case TaskCategory.health:
        return 'Health & Fitness';
      case TaskCategory.learning:
        return 'Learning';
      case TaskCategory.errands:
        return 'Errands';
      case TaskCategory.social:
        return 'Social';
      case TaskCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case TaskCategory.personal:
        return '🏠';
      case TaskCategory.professional:
        return '💼';
      case TaskCategory.health:
        return '💪';
      case TaskCategory.learning:
        return '📚';
      case TaskCategory.errands:
        return '🛒';
      case TaskCategory.social:
        return '👥';
      case TaskCategory.other:
        return '📌';
    }
  }

  String get color {
    switch (this) {
      case TaskCategory.personal:
        return '#4CAF50'; // Green
      case TaskCategory.professional:
        return '#2196F3'; // Blue
      case TaskCategory.health:
        return '#FF5722'; // Deep Orange
      case TaskCategory.learning:
        return '#9C27B0'; // Purple
      case TaskCategory.errands:
        return '#FF9800'; // Orange
      case TaskCategory.social:
        return '#E91E63'; // Pink
      case TaskCategory.other:
        return '#607D8B'; // Blue Grey
    }
  }
}

/// Timebox Slot Status
enum TimeboxSlotStatus {
  scheduled,
  inProgress,
  completed,
  skipped,
  rescheduled,
}

/// Extension for TimeboxSlotStatus
extension TimeboxSlotStatusX on TimeboxSlotStatus {
  String get displayName {
    switch (this) {
      case TimeboxSlotStatus.scheduled:
        return 'Scheduled';
      case TimeboxSlotStatus.inProgress:
        return 'In Progress';
      case TimeboxSlotStatus.completed:
        return 'Completed';
      case TimeboxSlotStatus.skipped:
        return 'Skipped';
      case TimeboxSlotStatus.rescheduled:
        return 'Rescheduled';
    }
  }
}

/// Time Conflict
///
/// Represents a scheduling conflict between tasks
class TimeConflict extends Equatable {
  final String id;
  final String slot1Id;
  final String slot1Title;
  final String slot2Id;
  final String slot2Title;
  final DateTime overlapStart;
  final DateTime overlapEnd;
  final TimeConflictType type;
  final TimeConflictSeverity severity;
  final String? resolution;

  const TimeConflict({
    required this.id,
    required this.slot1Id,
    required this.slot1Title,
    required this.slot2Id,
    required this.slot2Title,
    required this.overlapStart,
    required this.overlapEnd,
    required this.type,
    this.severity = TimeConflictSeverity.warning,
    this.resolution,
  });

  /// Duration of overlap in minutes
  int get overlapMinutes => overlapEnd.difference(overlapStart).inMinutes;

  /// Is this a complete overlap
  bool get isCompleteOverlap => type == TimeConflictType.completeOverlap;

  /// Get overlap time display
  String get overlapDisplay {
    return '${_formatTime(overlapStart)} - ${_formatTime(overlapEnd)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  @override
  List<Object?> get props => [
        id,
        slot1Id,
        slot1Title,
        slot2Id,
        slot2Title,
        overlapStart,
        overlapEnd,
        type,
        severity,
        resolution,
      ];
}

/// Time Conflict Type
enum TimeConflictType {
  partialOverlap,
  completeOverlap,
  backToBack, // No buffer between tasks
  exceedsWorkHours,
  doubleBooked,
}

/// Extension for TimeConflictType
extension TimeConflictTypeX on TimeConflictType {
  String get displayName {
    switch (this) {
      case TimeConflictType.partialOverlap:
        return 'Partial Overlap';
      case TimeConflictType.completeOverlap:
        return 'Complete Overlap';
      case TimeConflictType.backToBack:
        return 'No Buffer Time';
      case TimeConflictType.exceedsWorkHours:
        return 'Outside Work Hours';
      case TimeConflictType.doubleBooked:
        return 'Double Booked';
    }
  }

  String get description {
    switch (this) {
      case TimeConflictType.partialOverlap:
        return 'These tasks partially overlap in time';
      case TimeConflictType.completeOverlap:
        return 'One task completely overlaps with another';
      case TimeConflictType.backToBack:
        return 'No buffer time between tasks';
      case TimeConflictType.exceedsWorkHours:
        return 'Task extends beyond work hours';
      case TimeConflictType.doubleBooked:
        return 'Multiple tasks at the same time';
    }
  }
}

/// Time Conflict Severity
enum TimeConflictSeverity {
  info, // Minor, informational
  warning, // Should address but not critical
  error, // Must resolve before proceeding
}

/// Extension for TimeConflictSeverity
extension TimeConflictSeverityX on TimeConflictSeverity {
  String get color {
    switch (this) {
      case TimeConflictSeverity.info:
        return '#2196F3'; // Blue
      case TimeConflictSeverity.warning:
        return '#FF9800'; // Orange
      case TimeConflictSeverity.error:
        return '#F44336'; // Red
    }
  }
}

/// Timebox Summary
///
/// Summary statistics for the daily timebox
class TimeboxSummary extends Equatable {
  final int totalTasks;
  final int completedTasks;
  final int personalTasks;
  final int professionalTasks;
  final int priorityTasks;
  final int conflictCount;
  final int totalScheduledMinutes;
  final int availableMinutes;
  final double completionRate;

  const TimeboxSummary({
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.personalTasks = 0,
    this.professionalTasks = 0,
    this.priorityTasks = 0,
    this.conflictCount = 0,
    this.totalScheduledMinutes = 0,
    this.availableMinutes = 0,
    this.completionRate = 0.0,
  });

  /// Pending tasks count
  int get pendingTasks => totalTasks - completedTasks;

  /// Total scheduled hours
  double get totalScheduledHours => totalScheduledMinutes / 60.0;

  /// Available hours
  double get availableHours => availableMinutes / 60.0;

  /// Utilization rate (scheduled / available)
  double get utilizationRate {
    if (availableMinutes == 0) return 0.0;
    return totalScheduledMinutes / availableMinutes;
  }

  /// Has conflicts
  bool get hasConflicts => conflictCount > 0;

  /// Copy with method
  TimeboxSummary copyWith({
    int? totalTasks,
    int? completedTasks,
    int? personalTasks,
    int? professionalTasks,
    int? priorityTasks,
    int? conflictCount,
    int? totalScheduledMinutes,
    int? availableMinutes,
    double? completionRate,
  }) {
    return TimeboxSummary(
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      personalTasks: personalTasks ?? this.personalTasks,
      professionalTasks: professionalTasks ?? this.professionalTasks,
      priorityTasks: priorityTasks ?? this.priorityTasks,
      conflictCount: conflictCount ?? this.conflictCount,
      totalScheduledMinutes:
          totalScheduledMinutes ?? this.totalScheduledMinutes,
      availableMinutes: availableMinutes ?? this.availableMinutes,
      completionRate: completionRate ?? this.completionRate,
    );
  }

  @override
  List<Object?> get props => [
        totalTasks,
        completedTasks,
        personalTasks,
        professionalTasks,
        priorityTasks,
        conflictCount,
        totalScheduledMinutes,
        availableMinutes,
        completionRate,
      ];
}

/// Timebox Settings
///
/// User preferences for timebox configuration
class TimeboxSettings extends Equatable {
  final int dayStartHour;
  final int dayEndHour;
  final int defaultSlotDuration; // in minutes
  final int bufferBetweenSlots; // in minutes
  final bool showCompletedTasks;
  final bool highlightConflicts;
  final bool highlightPriorityTasks;
  final bool autoScheduleBreaks;
  final int breakDuration; // in minutes
  final int breakAfterMinutes; // schedule break after X minutes of work
  final List<TaskCategory> visibleCategories;
  final TimeboxViewMode viewMode;

  const TimeboxSettings({
    this.dayStartHour = 8,
    this.dayEndHour = 18,
    this.defaultSlotDuration = 30,
    this.bufferBetweenSlots = 5,
    this.showCompletedTasks = true,
    this.highlightConflicts = true,
    this.highlightPriorityTasks = true,
    this.autoScheduleBreaks = true,
    this.breakDuration = 15,
    this.breakAfterMinutes = 90,
    this.visibleCategories = const [
      TaskCategory.personal,
      TaskCategory.professional,
      TaskCategory.health,
      TaskCategory.learning,
      TaskCategory.errands,
      TaskCategory.social,
      TaskCategory.other,
    ],
    this.viewMode = TimeboxViewMode.timeline,
  });

  /// Total available minutes in a day
  int get totalDayMinutes => (dayEndHour - dayStartHour) * 60;

  /// Total available hours
  double get totalDayHours => totalDayMinutes / 60.0;

  /// Copy with method
  TimeboxSettings copyWith({
    int? dayStartHour,
    int? dayEndHour,
    int? defaultSlotDuration,
    int? bufferBetweenSlots,
    bool? showCompletedTasks,
    bool? highlightConflicts,
    bool? highlightPriorityTasks,
    bool? autoScheduleBreaks,
    int? breakDuration,
    int? breakAfterMinutes,
    List<TaskCategory>? visibleCategories,
    TimeboxViewMode? viewMode,
  }) {
    return TimeboxSettings(
      dayStartHour: dayStartHour ?? this.dayStartHour,
      dayEndHour: dayEndHour ?? this.dayEndHour,
      defaultSlotDuration: defaultSlotDuration ?? this.defaultSlotDuration,
      bufferBetweenSlots: bufferBetweenSlots ?? this.bufferBetweenSlots,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
      highlightConflicts: highlightConflicts ?? this.highlightConflicts,
      highlightPriorityTasks:
          highlightPriorityTasks ?? this.highlightPriorityTasks,
      autoScheduleBreaks: autoScheduleBreaks ?? this.autoScheduleBreaks,
      breakDuration: breakDuration ?? this.breakDuration,
      breakAfterMinutes: breakAfterMinutes ?? this.breakAfterMinutes,
      visibleCategories: visibleCategories ?? this.visibleCategories,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  List<Object?> get props => [
        dayStartHour,
        dayEndHour,
        defaultSlotDuration,
        bufferBetweenSlots,
        showCompletedTasks,
        highlightConflicts,
        highlightPriorityTasks,
        autoScheduleBreaks,
        breakDuration,
        breakAfterMinutes,
        visibleCategories,
        viewMode,
      ];
}

/// Timebox View Mode
enum TimeboxViewMode {
  timeline, // Vertical timeline view
  calendar, // Calendar day view
  list, // Simple list view
  kanban, // Kanban by time blocks
}

/// Extension for TimeboxViewMode
extension TimeboxViewModeX on TimeboxViewMode {
  String get displayName {
    switch (this) {
      case TimeboxViewMode.timeline:
        return 'Timeline';
      case TimeboxViewMode.calendar:
        return 'Calendar';
      case TimeboxViewMode.list:
        return 'List';
      case TimeboxViewMode.kanban:
        return 'Kanban';
    }
  }
}

/// Available Slot
///
/// Represents an available time slot for scheduling
class AvailableSlot extends Equatable {
  final DateTime startTime;
  final DateTime endTime;

  const AvailableSlot({
    required this.startTime,
    required this.endTime,
  });

  /// Duration in minutes
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  /// Can fit a task of given duration
  bool canFit(int taskDurationMinutes) {
    return durationMinutes >= taskDurationMinutes;
  }

  @override
  List<Object?> get props => [startTime, endTime];
}
