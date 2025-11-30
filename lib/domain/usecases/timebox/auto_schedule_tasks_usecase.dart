import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/timebox_entity.dart';
import '../../entities/task_entity.dart';
import '../../repositories/timebox_repository.dart';

/// Auto Schedule Tasks Use Case
///
/// Automatically schedules tasks into optimal time slots based on:
/// - Task priority (high priority tasks scheduled during peak hours)
/// - Estimated duration
/// - Category (personal vs professional)
/// - Available time slots
/// - User's energy levels throughout the day
///
/// WBS: 3.7.3.6
class AutoScheduleTasksUseCase {
  final TimeboxRepository _repository;

  const AutoScheduleTasksUseCase(this._repository);

  /// Execute the use case
  Future<Either<Failure, TimeboxEntity>> call(AutoScheduleTasksParams params) async {
    // Validate parameters
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID is required'));
    }

    if (params.tasks.isEmpty) {
      return const Left(ValidationFailure(message: 'No tasks to schedule'));
    }

    return await _repository.autoScheduleTasks(
      userId: params.userId,
      date: params.date,
      tasks: params.tasks,
      settings: params.settings,
    );
  }

  /// Generate auto-schedule locally
  ///
  /// Creates an optimal schedule for tasks without saving to repository.
  /// Useful for previewing schedule before confirming.
  List<TimeboxSlot> generateSchedule({
    required List<TaskEntity> tasks,
    required DateTime date,
    required TimeboxSettings settings,
    List<TimeboxSlot> existingSlots = const [],
  }) {
    final scheduledSlots = <TimeboxSlot>[];

    // Sort tasks by priority and due date
    final sortedTasks = List<TaskEntity>.from(tasks)
      ..sort((a, b) {
        // High priority first
        final priorityCompare = b.priority.index.compareTo(a.priority.index);
        if (priorityCompare != 0) return priorityCompare;

        // Then by due date (earlier first)
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;

        return 0;
      });

    // Get available slots
    final availableSlots = _getAvailableSlots(
      date: date,
      settings: settings,
      existingSlots: existingSlots,
    );

    // Peak hours for high-priority tasks (9 AM - 11 AM typically)
    final peakStartHour = 9;
    final peakEndHour = 11;

    // Schedule each task
    for (final task in sortedTasks) {
      final duration = task.estimatedDuration?.inMinutes ?? settings.defaultSlotDuration;

      // Find best slot based on priority
      final isHighPriority = task.priority == TaskPriority.high ||
                             task.priority == TaskPriority.critical;

      AvailableSlot? bestSlot;

      if (isHighPriority) {
        // Try to schedule during peak hours first
        bestSlot = _findSlotInTimeRange(
          availableSlots: availableSlots,
          duration: duration,
          date: date,
          startHour: peakStartHour,
          endHour: peakEndHour,
        );
      }

      // If no peak slot found or not high priority, find any available slot
      bestSlot ??= _findFirstAvailableSlot(
        availableSlots: availableSlots,
        duration: duration,
      );

      if (bestSlot != null) {
        // Infer category from task
        final category = _inferCategory(task);

        // Create the slot
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
        _updateAvailableSlots(
          availableSlots: availableSlots,
          usedSlot: bestSlot,
          usedDuration: duration + settings.bufferBetweenSlots,
        );
      }
    }

    return scheduledSlots;
  }

  List<AvailableSlot> _getAvailableSlots({
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
    required int startHour,
    required int endHour,
  }) {
    final rangeStart = DateTime(date.year, date.month, date.day, startHour);
    final rangeEnd = DateTime(date.year, date.month, date.day, endHour);

    for (final slot in availableSlots) {
      // Check if slot overlaps with desired time range
      if (slot.endTime.isAfter(rangeStart) && slot.startTime.isBefore(rangeEnd)) {
        // Calculate effective start time within range
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

  void _updateAvailableSlots({
    required List<AvailableSlot> availableSlots,
    required AvailableSlot usedSlot,
    required int usedDuration,
  }) {
    final index = availableSlots.indexWhere(
      (s) => s.startTime == usedSlot.startTime,
    );

    if (index != -1) {
      final newStartTime = usedSlot.startTime.add(Duration(minutes: usedDuration));
      if (newStartTime.isBefore(availableSlots[index].endTime)) {
        availableSlots[index] = AvailableSlot(
          startTime: newStartTime,
          endTime: availableSlots[index].endTime,
        );
      } else {
        availableSlots.removeAt(index);
      }
    }
  }

  TaskCategory _inferCategory(TaskEntity task) {
    // Infer from tags
    final lowerTags = task.tags.map((t) => t.toLowerCase()).toList();

    if (lowerTags.any((t) => t.contains('work') || t.contains('professional') || t.contains('office'))) {
      return TaskCategory.professional;
    }
    if (lowerTags.any((t) => t.contains('health') || t.contains('gym') || t.contains('exercise'))) {
      return TaskCategory.health;
    }
    if (lowerTags.any((t) => t.contains('learn') || t.contains('study') || t.contains('course'))) {
      return TaskCategory.learning;
    }
    if (lowerTags.any((t) => t.contains('errand') || t.contains('shop') || t.contains('buy'))) {
      return TaskCategory.errands;
    }
    if (lowerTags.any((t) => t.contains('social') || t.contains('friend') || t.contains('family'))) {
      return TaskCategory.social;
    }
    if (lowerTags.any((t) => t.contains('personal') || t.contains('home'))) {
      return TaskCategory.personal;
    }

    // Infer from context tags
    for (final context in task.contextTags) {
      if (context.contains('office') || context.contains('computer')) {
        return TaskCategory.professional;
      }
    }

    // Default to personal
    return TaskCategory.personal;
  }
}

/// Parameters for AutoScheduleTasksUseCase
class AutoScheduleTasksParams extends Equatable {
  final String userId;
  final DateTime date;
  final List<TaskEntity> tasks;
  final TimeboxSettings? settings;

  const AutoScheduleTasksParams({
    required this.userId,
    required this.date,
    required this.tasks,
    this.settings,
  });

  @override
  List<Object?> get props => [userId, date, tasks, settings];
}
