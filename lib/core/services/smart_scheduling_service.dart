import '../../domain/entities/productivity_insight.dart';
import '../../domain/entities/smart_schedule.dart';
import '../../domain/entities/task_entity.dart';
import '../utils/logger.dart';

/// Smart Scheduling Service
///
/// AI-powered scheduling service that finds optimal time slots for tasks
/// based on energy levels, calendar availability, deadlines, and user preferences.
class SmartSchedulingService {
  final _logger = Logger();

  // Default scheduling criteria
  static const _defaultWorkStartHour = 9;
  static const _defaultWorkEndHour = 17;
  static const _defaultBufferMinutes = 15;
  static const _defaultFocusBlockMinutes = 90;
  static const _defaultMaxTasksPerDay = 10;

  /// Auto-schedule tasks with AI optimization
  Future<SmartScheduleResult> autoScheduleTasks({
    required List<TaskEntity> tasks,
    SchedulingCriteria? criteria,
    SchedulePreferences? preferences,
    List<TimeBlock>? existingCalendarBlocks,
  }) async {
    try {
      _logger.info('Starting smart scheduling for ${tasks.length} tasks');

      final schedulingCriteria = criteria ?? const SchedulingCriteria();
      final prefs = preferences ?? const SchedulePreferences();

      // Filter schedulable tasks (not completed, no existing schedule)
      final schedulableTasks = tasks
          .where((t) =>
              !t.isCompleted && t.scheduledStartTime == null)
          .toList();

      if (schedulableTasks.isEmpty) {
        _logger.info('No tasks to schedule');
        return _emptyResult(schedulingCriteria);
      }

      // Sort tasks by priority and deadline
      final sortedTasks = _sortTasksByPriority(schedulableTasks);

      // Initialize result containers
      final scheduledTasks = <ScheduledTask>[];
      final conflicts = <ScheduleConflict>[];

      // Track occupied time blocks
      final occupiedBlocks = <TimeBlock>[
        ...(existingCalendarBlocks ?? []),
      ];

      // Get scheduling window
      final startDate = schedulingCriteria.startDate ??
          DateTime.now();
      final endDate = schedulingCriteria.endDate ??
          startDate.add(const Duration(days: 7));

      // Schedule each task
      for (final task in sortedTasks) {
        final result = await _scheduleTask(
          task: task,
          criteria: schedulingCriteria,
          preferences: prefs,
          occupiedBlocks: occupiedBlocks,
          startDate: startDate,
          endDate: endDate,
        );

        if (result != null) {
          scheduledTasks.add(result);

          if (!result.hasConflict) {
            // Add to occupied blocks
            occupiedBlocks.add(TimeBlock(
              startTime: result.suggestedStartTime,
              endTime: result.suggestedEndTime,
              type: TimeBlockType.scheduled,
              taskIds: [task.id],
            ));

            // Add buffer time if enabled
            if (schedulingCriteria.includeBufferTime) {
              occupiedBlocks.add(TimeBlock(
                startTime: result.suggestedEndTime,
                endTime: result.suggestedEndTime
                    .add(Duration(minutes: schedulingCriteria.bufferMinutes)),
                type: TimeBlockType.buffer,
              ));
            }
          }
        } else {
          // Could not schedule
          conflicts.add(ScheduleConflict(
            taskId: task.id,
            taskTitle: task.title,
            type: ConflictType.noAvailableSlots,
            description: 'No suitable time slots found for this task',
          ));
        }
      }

      // Calculate metrics
      final metrics = _calculateMetrics(
        totalTasks: schedulableTasks.length,
        scheduled: scheduledTasks,
        conflicts: conflicts,
        criteria: schedulingCriteria,
      );

      _logger.info(
          'Scheduling complete: ${scheduledTasks.length}/${schedulableTasks.length} tasks scheduled');

      return SmartScheduleResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        scheduledTasks: scheduledTasks,
        conflicts: conflicts,
        metrics: metrics,
        scheduledAt: DateTime.now(),
        criteria: schedulingCriteria,
        scheduleStartDate: startDate,
        scheduleEndDate: endDate,
      );
    } catch (e, stackTrace) {
      _logger.error('Smart scheduling failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Schedule a single task
  Future<ScheduledTask?> _scheduleTask({
    required TaskEntity task,
    required SchedulingCriteria criteria,
    required SchedulePreferences preferences,
    required List<TimeBlock> occupiedBlocks,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Estimate task duration
    final duration = _estimateTaskDuration(task);

    // Get task priority level
    final isHighPriority = task.priority >= 3;
    final isLowPriority = task.priority <= 1;

    // Determine energy requirement
    final requiresHighEnergy = isHighPriority || _isComplexTask(task);

    // Calculate days until deadline
    int? daysUntilDeadline;
    if (task.dueDate != null) {
      daysUntilDeadline = task.dueDate!.difference(DateTime.now()).inDays;
    }

    // Find similar tasks for batching
    List<String>? batchTags;
    if (criteria.batchSimilarTasks && task.tags.isNotEmpty) {
      batchTags = task.tags;
    }

    // Try to find optimal slot
    DateTime? optimalStart;
    SchedulingReason? reason;
    double confidence = 0.7;

    // Strategy 1: Peak energy time for high priority/complex tasks
    if (requiresHighEnergy && criteria.respectEnergyLevels) {
      optimalStart = _findPeakEnergySlot(
        duration: duration,
        occupiedBlocks: occupiedBlocks,
        preferences: preferences,
        startDate: startDate,
        endDate: endDate,
        criteria: criteria,
      );

      if (optimalStart != null) {
        reason = SchedulingReason.peakEnergy;
        confidence = 0.9;
      }
    }

    // Strategy 2: Low energy time for simple tasks
    if (optimalStart == null && isLowPriority) {
      optimalStart = _findLowEnergySlot(
        duration: duration,
        occupiedBlocks: occupiedBlocks,
        preferences: preferences,
        startDate: startDate,
        endDate: endDate,
        criteria: criteria,
      );

      if (optimalStart != null) {
        reason = SchedulingReason.lowEnergy;
        confidence = 0.85;
      }
    }

    // Strategy 3: Before deadline with buffer
    if (optimalStart == null &&
        daysUntilDeadline != null &&
        daysUntilDeadline <= 3) {
      optimalStart = _findSlotBeforeDeadline(
        task: task,
        duration: duration,
        occupiedBlocks: occupiedBlocks,
        preferences: preferences,
        criteria: criteria,
      );

      if (optimalStart != null) {
        reason = SchedulingReason.beforeDeadline;
        confidence = 0.95;
      }
    }

    // Strategy 4: Batch with similar tasks
    if (optimalStart == null && batchTags != null) {
      optimalStart = _findBatchingSlot(
        duration: duration,
        tags: batchTags,
        occupiedBlocks: occupiedBlocks,
        preferences: preferences,
        startDate: startDate,
        endDate: endDate,
        criteria: criteria,
      );

      if (optimalStart != null) {
        reason = SchedulingReason.batchedSimilarTasks;
        confidence = 0.8;
      }
    }

    // Strategy 5: Focus block for complex tasks
    if (optimalStart == null &&
        _isComplexTask(task) &&
        criteria.respectFocusBlocks) {
      optimalStart = _findFocusBlockSlot(
        duration: duration,
        occupiedBlocks: occupiedBlocks,
        preferences: preferences,
        startDate: startDate,
        endDate: endDate,
        criteria: criteria,
      );

      if (optimalStart != null) {
        reason = SchedulingReason.focusBlock;
        confidence = 0.88;
      }
    }

    // Strategy 6: First available slot
    if (optimalStart == null) {
      optimalStart = _findFirstAvailableSlot(
        duration: duration,
        occupiedBlocks: occupiedBlocks,
        preferences: preferences,
        startDate: startDate,
        endDate: endDate,
        criteria: criteria,
      );

      if (optimalStart != null) {
        reason = SchedulingReason.calendarAvailability;
        confidence = 0.7;
      }
    }

    // If no slot found, return null
    if (optimalStart == null || reason == null) {
      return null;
    }

    final optimalEnd = optimalStart.add(Duration(minutes: duration));

    return ScheduledTask(
      taskId: task.id,
      taskTitle: task.title,
      suggestedStartTime: optimalStart,
      suggestedEndTime: optimalEnd,
      estimatedDuration: duration,
      confidence: confidence,
      reason: reason,
    );
  }

  /// Find peak energy time slot
  DateTime? _findPeakEnergySlot({
    required int duration,
    required List<TimeBlock> occupiedBlocks,
    required SchedulePreferences preferences,
    required DateTime startDate,
    required DateTime endDate,
    required SchedulingCriteria criteria,
  }) {
    // Peak hours: typically 9 AM - 11 AM
    final peakStart = preferences.peakStartHour;
    final peakEnd = preferences.peakEndHour;

    return _findSlotInTimeRange(
      duration: duration,
      occupiedBlocks: occupiedBlocks,
      startDate: startDate,
      endDate: endDate,
      hourStart: peakStart,
      hourEnd: peakEnd,
      preferences: preferences,
      criteria: criteria,
    );
  }

  /// Find low energy time slot
  DateTime? _findLowEnergySlot({
    required int duration,
    required List<TimeBlock> occupiedBlocks,
    required SchedulePreferences preferences,
    required DateTime startDate,
    required DateTime endDate,
    required SchedulingCriteria criteria,
  }) {
    // Low energy: early morning (before 9) or late afternoon (after 4 PM)
    // Try late afternoon first
    DateTime? slot = _findSlotInTimeRange(
      duration: duration,
      occupiedBlocks: occupiedBlocks,
      startDate: startDate,
      endDate: endDate,
      hourStart: 16,
      hourEnd: preferences.preferredEndHour,
      preferences: preferences,
      criteria: criteria,
    );

    // If not found, try early morning
    slot ??= _findSlotInTimeRange(
      duration: duration,
      occupiedBlocks: occupiedBlocks,
      startDate: startDate,
      endDate: endDate,
      hourStart: preferences.preferredStartHour,
      hourEnd: 9,
      preferences: preferences,
      criteria: criteria,
    );

    return slot;
  }

  /// Find slot before deadline
  DateTime? _findSlotBeforeDeadline({
    required TaskEntity task,
    required int duration,
    required List<TimeBlock> occupiedBlocks,
    required SchedulePreferences preferences,
    required SchedulingCriteria criteria,
  }) {
    if (task.dueDate == null) return null;

    // Schedule at least 1 day before deadline
    final deadline = task.dueDate!.subtract(const Duration(days: 1));
    final now = DateTime.now();

    if (deadline.isBefore(now)) return null;

    return _findFirstAvailableSlot(
      duration: duration,
      occupiedBlocks: occupiedBlocks,
      preferences: preferences,
      startDate: now,
      endDate: deadline,
      criteria: criteria,
    );
  }

  /// Find batching slot (near similar tasks)
  DateTime? _findBatchingSlot({
    required int duration,
    required List<String> tags,
    required List<TimeBlock> occupiedBlocks,
    required SchedulePreferences preferences,
    required DateTime startDate,
    required DateTime endDate,
    required SchedulingCriteria criteria,
  }) {
    // For now, just find available slot
    // In a real implementation, we would look for slots near similar tasks
    return _findFirstAvailableSlot(
      duration: duration,
      occupiedBlocks: occupiedBlocks,
      preferences: preferences,
      startDate: startDate,
      endDate: endDate,
      criteria: criteria,
    );
  }

  /// Find focus block slot
  DateTime? _findFocusBlockSlot({
    required int duration,
    required List<TimeBlock> occupiedBlocks,
    required SchedulePreferences preferences,
    required DateTime startDate,
    required DateTime endDate,
    required SchedulingCriteria criteria,
  }) {
    // Try preferred focus hours
    for (final hour in preferences.preferredFocusHours) {
      final slot = _findSlotInTimeRange(
        duration: duration,
        occupiedBlocks: occupiedBlocks,
        startDate: startDate,
        endDate: endDate,
        hourStart: hour,
        hourEnd: hour + 2,
        preferences: preferences,
        criteria: criteria,
      );

      if (slot != null) return slot;
    }

    return null;
  }

  /// Find first available slot
  DateTime? _findFirstAvailableSlot({
    required int duration,
    required List<TimeBlock> occupiedBlocks,
    required SchedulePreferences preferences,
    required DateTime startDate,
    required DateTime endDate,
    required SchedulingCriteria criteria,
  }) {
    return _findSlotInTimeRange(
      duration: duration,
      occupiedBlocks: occupiedBlocks,
      startDate: startDate,
      endDate: endDate,
      hourStart: criteria.workDayStartHour,
      hourEnd: criteria.workDayEndHour,
      preferences: preferences,
      criteria: criteria,
    );
  }

  /// Find slot in specific time range
  DateTime? _findSlotInTimeRange({
    required int duration,
    required List<TimeBlock> occupiedBlocks,
    required DateTime startDate,
    required DateTime endDate,
    required int hourStart,
    required int hourEnd,
    required SchedulePreferences preferences,
    required SchedulingCriteria criteria,
  }) {
    var currentDate = startDate;

    while (currentDate.isBefore(endDate)) {
      // Skip non-work days
      if (!preferences.isWorkDay(currentDate)) {
        currentDate = currentDate.add(const Duration(days: 1));
        continue;
      }

      // Try each 30-minute slot in the time range
      for (var hour = hourStart; hour < hourEnd; hour++) {
        for (var minute in [0, 30]) {
          final slotStart = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            hour,
            minute,
          );

          final slotEnd = slotStart.add(Duration(minutes: duration));

          // Check if slot end is still within the day's work hours
          if (slotEnd.hour >= hourEnd) continue;

          // Check if slot is available
          if (_isSlotAvailable(slotStart, slotEnd, occupiedBlocks)) {
            return slotStart;
          }
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return null;
  }

  /// Check if time slot is available
  bool _isSlotAvailable(
    DateTime start,
    DateTime end,
    List<TimeBlock> occupiedBlocks,
  ) {
    for (final block in occupiedBlocks) {
      // Check for overlap
      if (start.isBefore(block.endTime) && end.isAfter(block.startTime)) {
        return false;
      }
    }
    return true;
  }

  /// Estimate task duration in minutes
  int _estimateTaskDuration(TaskEntity task) {
    // If task has subtasks, estimate based on count
    if (task.subtasks.isNotEmpty) {
      return task.subtasks.length * 15; // 15 min per subtask
    }

    // Estimate based on priority and description
    final descLength = task.description?.length ?? 0;

    if (task.priority >= 4) {
      return 120; // 2 hours for critical tasks
    } else if (task.priority == 3) {
      return 90; // 1.5 hours for high priority
    } else if (descLength > 200) {
      return 90; // 1.5 hours for complex tasks
    } else if (descLength > 100) {
      return 60; // 1 hour for moderate tasks
    } else {
      return 30; // 30 min for simple tasks
    }
  }

  /// Check if task is complex
  bool _isComplexTask(TaskEntity task) {
    return task.priority >= 3 ||
        (task.description?.length ?? 0) > 100 ||
        task.subtasks.length > 3;
  }

  /// Sort tasks by priority and deadline
  List<TaskEntity> _sortTasksByPriority(List<TaskEntity> tasks) {
    final sorted = List<TaskEntity>.from(tasks);

    sorted.sort((a, b) {
      // First, compare by priority (higher first)
      final priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;

      // Then by deadline (sooner first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }

      return 0;
    });

    return sorted;
  }

  /// Calculate scheduling metrics
  SchedulingMetrics _calculateMetrics({
    required int totalTasks,
    required List<ScheduledTask> scheduled,
    required List<ScheduleConflict> conflicts,
    required SchedulingCriteria criteria,
  }) {
    final successful = scheduled.where((t) => !t.hasConflict).length;
    final totalMinutes =
        scheduled.fold<int>(0, (sum, t) => sum + t.estimatedDuration);
    final bufferMinutes = successful * criteria.bufferMinutes;
    final avgConfidence = scheduled.isEmpty
        ? 0.0
        : scheduled.fold<double>(0, (sum, t) => sum + t.confidence) /
            scheduled.length;

    final focusBlocks = scheduled
        .where((t) => t.reason == SchedulingReason.focusBlock)
        .length;

    final batchGroups = scheduled
        .where((t) => t.reason == SchedulingReason.batchedSimilarTasks)
        .length;

    return SchedulingMetrics(
      totalTasksToSchedule: totalTasks,
      successfullyScheduled: successful,
      conflictCount: conflicts.length,
      tasksRequiringManualScheduling: totalTasks - successful,
      averageConfidence: avgConfidence,
      totalScheduledMinutes: totalMinutes,
      totalBufferMinutes: bufferMinutes,
      focusBlocksCreated: focusBlocks,
      batchedTaskGroups: batchGroups,
    );
  }

  /// Create empty result
  SmartScheduleResult _emptyResult(SchedulingCriteria criteria) {
    return SmartScheduleResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scheduledTasks: [],
      conflicts: [],
      metrics: const SchedulingMetrics(),
      scheduledAt: DateTime.now(),
      criteria: criteria,
    );
  }
}
