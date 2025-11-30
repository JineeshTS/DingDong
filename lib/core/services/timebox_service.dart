import '../../domain/entities/timebox_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../utils/logger.dart';

/// Timebox Service
///
/// Provides core timebox functionality:
/// - Conflict detection algorithm
/// - Auto-scheduling logic
/// - Category inference from tasks/lists
/// - Time slot suggestions
///
/// WBS: 3.7.5
class TimeboxService {
  TimeboxService._();

  static final TimeboxService _instance = TimeboxService._();
  static TimeboxService get instance => _instance;

  final _logger = Logger();

  // ============================================================
  // 3.7.5.1 CONFLICT DETECTION ALGORITHM
  // ============================================================

  /// Detect all conflicts in a list of slots
  List<TimeConflict> detectConflicts({
    required List<TimeboxSlot> slots,
    required TimeboxSettings settings,
  }) {
    final conflicts = <TimeConflict>[];
    final sortedSlots = List<TimeboxSlot>.from(slots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    for (var i = 0; i < sortedSlots.length; i++) {
      final slot1 = sortedSlots[i];

      // Check work hours violation
      final workHoursConflict = _checkWorkHoursViolation(slot1, settings);
      if (workHoursConflict != null) {
        conflicts.add(workHoursConflict);
      }

      // Check for conflicts with subsequent slots
      for (var j = i + 1; j < sortedSlots.length; j++) {
        final slot2 = sortedSlots[j];

        // No need to check further if slot2 starts after slot1 ends + buffer
        if (slot2.startTime.isAfter(
          slot1.endTime.add(Duration(minutes: settings.bufferBetweenSlots)),
        )) {
          break;
        }

        final conflict = _detectConflictBetweenSlots(slot1, slot2, settings);
        if (conflict != null) {
          conflicts.add(conflict);
        }
      }
    }

    return conflicts;
  }

  TimeConflict? _checkWorkHoursViolation(
    TimeboxSlot slot,
    TimeboxSettings settings,
  ) {
    final date = slot.startTime;
    final dayStart = DateTime(
      date.year,
      date.month,
      date.day,
      settings.dayStartHour,
    );
    final dayEnd = DateTime(
      date.year,
      date.month,
      date.day,
      settings.dayEndHour,
    );

    if (slot.startTime.isBefore(dayStart)) {
      return TimeConflict(
        id: 'conflict_${slot.id}_early',
        slot1Id: slot.id,
        slot1Title: slot.taskTitle,
        slot2Id: '',
        slot2Title: 'Work Hours Start',
        overlapStart: slot.startTime,
        overlapEnd: dayStart,
        type: TimeConflictType.exceedsWorkHours,
        severity: TimeConflictSeverity.warning,
      );
    }

    if (slot.endTime.isAfter(dayEnd)) {
      return TimeConflict(
        id: 'conflict_${slot.id}_late',
        slot1Id: slot.id,
        slot1Title: slot.taskTitle,
        slot2Id: '',
        slot2Title: 'Work Hours End',
        overlapStart: dayEnd,
        overlapEnd: slot.endTime,
        type: TimeConflictType.exceedsWorkHours,
        severity: TimeConflictSeverity.warning,
      );
    }

    return null;
  }

  TimeConflict? _detectConflictBetweenSlots(
    TimeboxSlot slot1,
    TimeboxSlot slot2,
    TimeboxSettings settings,
  ) {
    // Check for time overlap
    if (slot1.endTime.isAfter(slot2.startTime)) {
      final overlapStart = slot2.startTime;
      final overlapEnd = slot1.endTime.isBefore(slot2.endTime)
          ? slot1.endTime
          : slot2.endTime;

      // Determine conflict type
      TimeConflictType type;
      TimeConflictSeverity severity;

      if (slot1.startTime == slot2.startTime && slot1.endTime == slot2.endTime) {
        type = TimeConflictType.doubleBooked;
        severity = TimeConflictSeverity.error;
      } else if (slot1.startTime.isBefore(slot2.startTime) &&
          slot1.endTime.isAfter(slot2.endTime)) {
        type = TimeConflictType.completeOverlap;
        severity = TimeConflictSeverity.error;
      } else if (slot2.startTime.isBefore(slot1.startTime) &&
          slot2.endTime.isAfter(slot1.endTime)) {
        type = TimeConflictType.completeOverlap;
        severity = TimeConflictSeverity.error;
      } else {
        type = TimeConflictType.partialOverlap;
        severity = TimeConflictSeverity.error;
      }

      return TimeConflict(
        id: 'conflict_${slot1.id}_${slot2.id}',
        slot1Id: slot1.id,
        slot1Title: slot1.taskTitle,
        slot2Id: slot2.id,
        slot2Title: slot2.taskTitle,
        overlapStart: overlapStart,
        overlapEnd: overlapEnd,
        type: type,
        severity: severity,
      );
    }

    // Check for back-to-back without buffer
    if (settings.bufferBetweenSlots > 0) {
      final gap = slot2.startTime.difference(slot1.endTime).inMinutes;
      if (gap >= 0 && gap < settings.bufferBetweenSlots) {
        return TimeConflict(
          id: 'conflict_${slot1.id}_${slot2.id}_buffer',
          slot1Id: slot1.id,
          slot1Title: slot1.taskTitle,
          slot2Id: slot2.id,
          slot2Title: slot2.taskTitle,
          overlapStart: slot1.endTime,
          overlapEnd: slot2.startTime,
          type: TimeConflictType.backToBack,
          severity: TimeConflictSeverity.info,
        );
      }
    }

    return null;
  }

  // ============================================================
  // 3.7.5.2 AUTO-SCHEDULING LOGIC
  // ============================================================

  /// Auto-schedule tasks into optimal time slots
  List<TimeboxSlot> autoScheduleTasks({
    required List<TaskEntity> tasks,
    required DateTime date,
    required TimeboxSettings settings,
    List<TimeboxSlot> existingSlots = const [],
  }) {
    _logger.info('Auto-scheduling ${tasks.length} tasks for ${date.toIso8601String()}');

    final scheduledSlots = <TimeboxSlot>[];
    final availableSlots = _calculateAvailableSlots(
      date: date,
      settings: settings,
      existingSlots: existingSlots,
    );

    // Sort tasks by scheduling priority
    final sortedTasks = _sortTasksForScheduling(tasks);

    // Peak productivity hours (configurable, default 9-11 AM)
    const peakStartHour = 9;
    const peakEndHour = 11;

    for (final task in sortedTasks) {
      final duration = task.estimatedDuration?.inMinutes ??
          settings.defaultSlotDuration;

      // High priority tasks get scheduled during peak hours
      final isHighPriority = task.priority == TaskPriority.high ||
          task.priority == TaskPriority.critical;

      AvailableSlot? bestSlot;

      if (isHighPriority) {
        bestSlot = _findSlotInTimeRange(
          availableSlots: availableSlots,
          duration: duration,
          date: date,
          preferredStartHour: peakStartHour,
          preferredEndHour: peakEndHour,
        );
      }

      // Fall back to any available slot
      bestSlot ??= _findFirstAvailableSlot(
        availableSlots: availableSlots,
        duration: duration,
      );

      if (bestSlot != null) {
        final category = inferCategory(task);
        final slot = TimeboxSlot(
          id: 'auto_${task.id}_${DateTime.now().millisecondsSinceEpoch}',
          taskId: task.id,
          taskTitle: task.title,
          taskDescription: task.description,
          startTime: bestSlot.startTime,
          endTime: bestSlot.startTime.add(Duration(minutes: duration)),
          category: category,
          priority: task.priority,
          tags: task.tags,
          isRecurring: task.isRecurring,
        );

        scheduledSlots.add(slot);

        // Update available slots
        _consumeAvailableSlot(
          availableSlots: availableSlots,
          usedStart: bestSlot.startTime,
          usedDuration: duration + settings.bufferBetweenSlots,
        );
      } else {
        _logger.warning('No available slot for task: ${task.title}');
      }
    }

    _logger.info('Scheduled ${scheduledSlots.length}/${tasks.length} tasks');
    return scheduledSlots;
  }

  List<TaskEntity> _sortTasksForScheduling(List<TaskEntity> tasks) {
    return List<TaskEntity>.from(tasks)
      ..sort((a, b) {
        // Priority: higher priority first
        final priorityCompare = b.priority.index.compareTo(a.priority.index);
        if (priorityCompare != 0) return priorityCompare;

        // Due date: earlier first
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;

        // Estimated duration: longer tasks first (easier to fit shorter tasks later)
        final durationA = a.estimatedDuration?.inMinutes ?? 30;
        final durationB = b.estimatedDuration?.inMinutes ?? 30;
        return durationB.compareTo(durationA);
      });
  }

  List<AvailableSlot> _calculateAvailableSlots({
    required DateTime date,
    required TimeboxSettings settings,
    required List<TimeboxSlot> existingSlots,
  }) {
    final available = <AvailableSlot>[];

    DateTime currentTime = DateTime(
      date.year,
      date.month,
      date.day,
      settings.dayStartHour,
    );

    final dayEnd = DateTime(
      date.year,
      date.month,
      date.day,
      settings.dayEndHour,
    );

    final sortedExisting = List<TimeboxSlot>.from(existingSlots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    for (final slot in sortedExisting) {
      if (slot.startTime.isAfter(currentTime)) {
        available.add(AvailableSlot(
          startTime: currentTime,
          endTime: slot.startTime,
        ));
      }
      if (slot.endTime.isAfter(currentTime)) {
        currentTime = slot.endTime.add(Duration(minutes: settings.bufferBetweenSlots));
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

  AvailableSlot? _findSlotInTimeRange({
    required List<AvailableSlot> availableSlots,
    required int duration,
    required DateTime date,
    required int preferredStartHour,
    required int preferredEndHour,
  }) {
    final rangeStart = DateTime(date.year, date.month, date.day, preferredStartHour);
    final rangeEnd = DateTime(date.year, date.month, date.day, preferredEndHour);

    for (final slot in availableSlots) {
      if (slot.endTime.isAfter(rangeStart) && slot.startTime.isBefore(rangeEnd)) {
        final effectiveStart = slot.startTime.isBefore(rangeStart)
            ? rangeStart
            : slot.startTime;
        final effectiveEnd = slot.endTime.isAfter(rangeEnd)
            ? rangeEnd
            : slot.endTime;

        if (effectiveEnd.difference(effectiveStart).inMinutes >= duration) {
          return AvailableSlot(startTime: effectiveStart, endTime: effectiveEnd);
        }
      }
    }
    return null;
  }

  AvailableSlot? _findFirstAvailableSlot({
    required List<AvailableSlot> availableSlots,
    required int duration,
  }) {
    for (final slot in availableSlots) {
      if (slot.durationMinutes >= duration) {
        return slot;
      }
    }
    return null;
  }

  void _consumeAvailableSlot({
    required List<AvailableSlot> availableSlots,
    required DateTime usedStart,
    required int usedDuration,
  }) {
    for (var i = 0; i < availableSlots.length; i++) {
      final slot = availableSlots[i];
      if (!slot.startTime.isAfter(usedStart) && slot.endTime.isAfter(usedStart)) {
        final newStart = usedStart.add(Duration(minutes: usedDuration));
        if (newStart.isBefore(slot.endTime)) {
          availableSlots[i] = AvailableSlot(
            startTime: newStart,
            endTime: slot.endTime,
          );
        } else {
          availableSlots.removeAt(i);
        }
        break;
      }
    }
  }

  // ============================================================
  // 3.7.5.3 CATEGORY INFERENCE
  // ============================================================

  /// Infer task category from task properties and list
  TaskCategory inferCategory(TaskEntity task, {String? listName}) {
    final lowerTags = task.tags.map((t) => t.toLowerCase()).toList();
    final lowerTitle = task.title.toLowerCase();
    final lowerListName = listName?.toLowerCase() ?? '';

    // Check tags first (most specific)
    if (_matchesCategory(lowerTags, ['work', 'professional', 'office', 'meeting', 'client', 'project'])) {
      return TaskCategory.professional;
    }
    if (_matchesCategory(lowerTags, ['health', 'gym', 'exercise', 'workout', 'doctor', 'medical', 'fitness'])) {
      return TaskCategory.health;
    }
    if (_matchesCategory(lowerTags, ['learn', 'study', 'course', 'read', 'book', 'education', 'training'])) {
      return TaskCategory.learning;
    }
    if (_matchesCategory(lowerTags, ['errand', 'shop', 'buy', 'grocery', 'store', 'pickup'])) {
      return TaskCategory.errands;
    }
    if (_matchesCategory(lowerTags, ['social', 'friend', 'family', 'party', 'dinner', 'lunch', 'meet'])) {
      return TaskCategory.social;
    }
    if (_matchesCategory(lowerTags, ['personal', 'home', 'clean', 'organize', 'hobby'])) {
      return TaskCategory.personal;
    }

    // Check title
    if (_containsAny(lowerTitle, ['meeting', 'call', 'review', 'report', 'deadline', 'presentation'])) {
      return TaskCategory.professional;
    }
    if (_containsAny(lowerTitle, ['gym', 'run', 'yoga', 'doctor', 'dentist'])) {
      return TaskCategory.health;
    }
    if (_containsAny(lowerTitle, ['buy', 'shop', 'pick up', 'return', 'mail'])) {
      return TaskCategory.errands;
    }

    // Check list name
    if (_containsAny(lowerListName, ['work', 'office', 'professional', 'job'])) {
      return TaskCategory.professional;
    }
    if (_containsAny(lowerListName, ['personal', 'home', 'private'])) {
      return TaskCategory.personal;
    }

    // Check context tags
    for (final context in task.contextTags) {
      final lowerContext = context.toLowerCase();
      if (lowerContext.contains('office') || lowerContext.contains('computer')) {
        return TaskCategory.professional;
      }
      if (lowerContext.contains('home')) {
        return TaskCategory.personal;
      }
    }

    // Default
    return TaskCategory.personal;
  }

  bool _matchesCategory(List<String> tags, List<String> keywords) {
    return tags.any((tag) => keywords.any((kw) => tag.contains(kw)));
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((kw) => text.contains(kw));
  }

  // ============================================================
  // 3.7.5.4 TIME SLOT SUGGESTIONS
  // ============================================================

  /// Suggest best time slot for a task
  AvailableSlot? suggestTimeSlot({
    required TaskEntity task,
    required DateTime date,
    required TimeboxSettings settings,
    required List<TimeboxSlot> existingSlots,
  }) {
    final duration = task.estimatedDuration?.inMinutes ?? settings.defaultSlotDuration;
    final availableSlots = _calculateAvailableSlots(
      date: date,
      settings: settings,
      existingSlots: existingSlots,
    );

    // High priority: suggest peak hours
    if (task.priority == TaskPriority.high || task.priority == TaskPriority.critical) {
      final peakSlot = _findSlotInTimeRange(
        availableSlots: availableSlots,
        duration: duration,
        date: date,
        preferredStartHour: 9,
        preferredEndHour: 11,
      );
      if (peakSlot != null) return peakSlot;
    }

    // Health/exercise: suggest morning or evening
    final category = inferCategory(task);
    if (category == TaskCategory.health) {
      // Try early morning first
      final morningSlot = _findSlotInTimeRange(
        availableSlots: availableSlots,
        duration: duration,
        date: date,
        preferredStartHour: settings.dayStartHour,
        preferredEndHour: 9,
      );
      if (morningSlot != null) return morningSlot;

      // Try evening
      final eveningSlot = _findSlotInTimeRange(
        availableSlots: availableSlots,
        duration: duration,
        date: date,
        preferredStartHour: 17,
        preferredEndHour: settings.dayEndHour,
      );
      if (eveningSlot != null) return eveningSlot;
    }

    // Default: first available
    return _findFirstAvailableSlot(
      availableSlots: availableSlots,
      duration: duration,
    );
  }

  /// Get all available time slots for a date
  List<AvailableSlot> getAvailableSlots({
    required DateTime date,
    required TimeboxSettings settings,
    required List<TimeboxSlot> existingSlots,
  }) {
    return _calculateAvailableSlots(
      date: date,
      settings: settings,
      existingSlots: existingSlots,
    );
  }

  // ============================================================
  // SUMMARY CALCULATION
  // ============================================================

  /// Calculate summary for a timebox
  TimeboxSummary calculateSummary({
    required List<TimeboxSlot> slots,
    required List<TimeConflict> conflicts,
    required TimeboxSettings settings,
  }) {
    final totalTasks = slots.length;
    final completedTasks = slots.where((s) => s.isCompleted).length;
    final personalTasks = slots.where((s) => s.category == TaskCategory.personal).length;
    final professionalTasks = slots.where((s) => s.category == TaskCategory.professional).length;
    final priorityTasks = slots.where((s) => s.isPriority).length;
    final conflictCount = conflicts.where((c) => c.severity == TimeConflictSeverity.error).length;

    final totalScheduledMinutes = slots.fold<int>(
      0,
      (sum, slot) => sum + slot.durationMinutes,
    );

    final availableMinutes = settings.totalDayMinutes;
    final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return TimeboxSummary(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      personalTasks: personalTasks,
      professionalTasks: professionalTasks,
      priorityTasks: priorityTasks,
      conflictCount: conflictCount,
      totalScheduledMinutes: totalScheduledMinutes,
      availableMinutes: availableMinutes,
      completionRate: completionRate,
    );
  }
}
