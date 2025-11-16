import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/smart_scheduling_service.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/smart_schedule.dart';
import '../../../domain/entities/task_entity.dart';
import 'smart_schedule_state.dart';

/// Smart Schedule Notifier
///
/// Manages smart scheduling state and operations
class SmartScheduleNotifier extends StateNotifier<SmartScheduleState> {
  final SmartSchedulingService _schedulingService;
  final _logger = Logger();

  SmartScheduleNotifier({
    required SmartSchedulingService schedulingService,
  })  : _schedulingService = schedulingService,
        super(const SmartScheduleState());

  /// Schedule tasks automatically
  Future<void> scheduleTasks({
    required List<TaskEntity> tasks,
    SchedulingCriteria? criteria,
    SchedulePreferences? preferences,
    List<TimeBlock>? calendarBlocks,
  }) async {
    try {
      _logger.info('Scheduling ${tasks.length} tasks');

      state = state.copyWith(
        isScheduling: true,
        error: null,
      );

      // Use existing preferences if not provided
      final prefs = preferences ?? state.preferences;

      // Perform scheduling
      final result = await _schedulingService.autoScheduleTasks(
        tasks: tasks,
        criteria: criteria,
        preferences: prefs,
        existingCalendarBlocks: calendarBlocks ?? state.calendarBlocks,
      );

      _logger.info(
          'Scheduling complete: ${result.scheduledCount} tasks scheduled');

      state = state.copyWith(
        isScheduling: false,
        currentSchedule: result,
        lastCriteria: criteria,
        preferences: prefs,
        lastScheduledAt: DateTime.now(),
        calendarBlocks: calendarBlocks ?? state.calendarBlocks,
      );
    } catch (e, stackTrace) {
      _logger.error('Task scheduling failed', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isScheduling: false,
        error: 'Failed to schedule tasks: ${e.toString()}',
      );
    }
  }

  /// Accept a scheduled task
  void acceptTask(String taskId) {
    _logger.info('Accepting scheduled task: $taskId');

    final updated = [...state.acceptedTaskIds, taskId];

    // Remove from rejected if it was there
    final rejectedUpdated = state.rejectedTaskIds
        .where((id) => id != taskId)
        .toList();

    state = state.copyWith(
      acceptedTaskIds: updated,
      rejectedTaskIds: rejectedUpdated,
    );
  }

  /// Reject a scheduled task
  void rejectTask(String taskId) {
    _logger.info('Rejecting scheduled task: $taskId');

    final updated = [...state.rejectedTaskIds, taskId];

    // Remove from accepted if it was there
    final acceptedUpdated = state.acceptedTaskIds
        .where((id) => id != taskId)
        .toList();

    state = state.copyWith(
      rejectedTaskIds: updated,
      acceptedTaskIds: acceptedUpdated,
    );
  }

  /// Accept all scheduled tasks
  void acceptAllTasks() {
    _logger.info('Accepting all scheduled tasks');

    final allTaskIds =
        state.scheduledTasks.map((t) => t.taskId).toList();

    state = state.copyWith(
      acceptedTaskIds: allTaskIds,
      rejectedTaskIds: [],
    );
  }

  /// Reset acceptance/rejection
  void resetTaskDecisions() {
    _logger.info('Resetting task acceptance decisions');

    state = state.copyWith(
      acceptedTaskIds: [],
      rejectedTaskIds: [],
    );
  }

  /// Update scheduling preferences
  void updatePreferences(SchedulePreferences preferences) {
    _logger.info('Updating scheduling preferences');

    state = state.copyWith(
      preferences: preferences,
    );
  }

  /// Add calendar blocks
  void addCalendarBlocks(List<TimeBlock> blocks) {
    _logger.info('Adding ${blocks.length} calendar blocks');

    final updated = [...state.calendarBlocks, ...blocks];

    state = state.copyWith(
      calendarBlocks: updated,
    );
  }

  /// Clear calendar blocks
  void clearCalendarBlocks() {
    _logger.info('Clearing calendar blocks');

    state = state.copyWith(
      calendarBlocks: [],
    );
  }

  /// Clear current schedule
  void clearSchedule() {
    _logger.info('Clearing current schedule');

    state = state.copyWith(
      currentSchedule: null,
      acceptedTaskIds: [],
      rejectedTaskIds: [],
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset all
  void reset() {
    state = const SmartScheduleState();
  }
}
