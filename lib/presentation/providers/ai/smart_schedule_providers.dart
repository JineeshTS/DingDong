import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/smart_scheduling_service.dart';
import '../../../domain/entities/smart_schedule.dart';
import 'smart_schedule_notifier.dart';
import 'smart_schedule_state.dart';

/// Smart Scheduling Service Provider
final smartSchedulingServiceProvider = Provider<SmartSchedulingService>((ref) {
  return SmartSchedulingService();
});

/// Smart Schedule State Notifier Provider
final smartScheduleNotifierProvider =
    StateNotifierProvider<SmartScheduleNotifier, SmartScheduleState>((ref) {
  return SmartScheduleNotifier(
    schedulingService: ref.watch(smartSchedulingServiceProvider),
  );
});

/// Is scheduling provider
final isSchedulingProvider = Provider<bool>((ref) {
  return ref.watch(smartScheduleNotifierProvider.select((s) => s.isScheduling));
});

/// Has schedule provider
final hasScheduleProvider = Provider<bool>((ref) {
  return ref.watch(smartScheduleNotifierProvider.select((s) => s.hasSchedule));
});

/// Current schedule provider
final currentScheduleProvider = Provider<SmartScheduleResult?>((ref) {
  return ref
      .watch(smartScheduleNotifierProvider.select((s) => s.currentSchedule));
});

/// Scheduled tasks provider
final scheduledTasksProvider = Provider<List<ScheduledTask>>((ref) {
  return ref
      .watch(smartScheduleNotifierProvider.select((s) => s.scheduledTasks));
});

/// Pending tasks provider
final pendingScheduledTasksProvider = Provider<List<ScheduledTask>>((ref) {
  return ref.watch(smartScheduleNotifierProvider.select((s) => s.pendingTasks));
});

/// Accepted tasks provider
final acceptedScheduledTasksProvider = Provider<List<ScheduledTask>>((ref) {
  return ref
      .watch(smartScheduleNotifierProvider.select((s) => s.acceptedTasks));
});

/// Rejected tasks provider
final rejectedScheduledTasksProvider = Provider<List<ScheduledTask>>((ref) {
  return ref
      .watch(smartScheduleNotifierProvider.select((s) => s.rejectedTasks));
});

/// Pending count provider
final pendingScheduledCountProvider = Provider<int>((ref) {
  return ref.watch(smartScheduleNotifierProvider.select((s) => s.pendingCount));
});

/// Accepted count provider
final acceptedScheduledCountProvider = Provider<int>((ref) {
  return ref
      .watch(smartScheduleNotifierProvider.select((s) => s.acceptedCount));
});

/// Has conflicts provider
final hasScheduleConflictsProvider = Provider<bool>((ref) {
  return ref.watch(smartScheduleNotifierProvider.select((s) => s.hasConflicts));
});

/// Conflicts provider
final scheduleConflictsProvider = Provider<List<ScheduleConflict>>((ref) {
  return ref.watch(smartScheduleNotifierProvider.select((s) => s.conflicts));
});

/// Scheduling metrics provider
final schedulingMetricsProvider = Provider<SchedulingMetrics?>((ref) {
  return ref.watch(smartScheduleNotifierProvider.select((s) => s.metrics));
});

/// Success rate provider
final schedulingSuccessRateProvider = Provider<double>((ref) {
  return ref.watch(smartScheduleNotifierProvider.select((s) => s.successRate));
});

/// Scheduling preferences provider
final schedulePreferencesProvider = Provider<SchedulePreferences?>((ref) {
  return ref.watch(smartScheduleNotifierProvider.select((s) => s.preferences));
});

/// Has preferences provider
final hasSchedulePreferencesProvider = Provider<bool>((ref) {
  return ref
      .watch(smartScheduleNotifierProvider.select((s) => s.hasPreferences));
});

/// Calendar blocks provider
final calendarBlocksProvider = Provider<List<TimeBlock>>((ref) {
  return ref
      .watch(smartScheduleNotifierProvider.select((s) => s.calendarBlocks));
});

/// Scheduling error provider
final schedulingErrorProvider = Provider<String?>((ref) {
  return ref.watch(smartScheduleNotifierProvider.select((s) => s.error));
});

/// Has scheduling error provider
final hasSchedulingErrorProvider = Provider<bool>((ref) {
  return ref.watch(smartScheduleNotifierProvider.select((s) => s.hasError));
});

/// Last scheduled at provider
final lastScheduledAtProvider = Provider<DateTime?>((ref) {
  return ref
      .watch(smartScheduleNotifierProvider.select((s) => s.lastScheduledAt));
});

/// Last criteria provider
final lastSchedulingCriteriaProvider = Provider<SchedulingCriteria?>((ref) {
  return ref.watch(smartScheduleNotifierProvider.select((s) => s.lastCriteria));
});

/// Scheduled tasks by date provider (family)
final scheduledTasksByDateProvider =
    Provider.family<List<ScheduledTask>, DateTime>((ref, date) {
  final scheduled = ref.watch(scheduledTasksProvider);
  final targetDate = DateTime(date.year, date.month, date.day);

  return scheduled.where((task) {
    final taskDate = DateTime(
      task.suggestedStartTime.year,
      task.suggestedStartTime.month,
      task.suggestedStartTime.day,
    );
    return taskDate == targetDate;
  }).toList();
});

/// Has tasks on date provider (family)
final hasTasksOnDateProvider = Provider.family<bool, DateTime>((ref, date) {
  final tasks = ref.watch(scheduledTasksByDateProvider(date));
  return tasks.isNotEmpty;
});
