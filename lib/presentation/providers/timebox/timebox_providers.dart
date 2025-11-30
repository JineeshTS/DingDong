import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/services/timebox_service.dart';
import '../../../domain/entities/timebox_entity.dart';
import '../../../domain/usecases/timebox/timebox.dart';
import 'timebox_notifier.dart';
import 'timebox_state.dart';

/// Timebox Providers
///
/// Riverpod providers for the timebox (daily agenda) feature.
///
/// WBS: 3.7.6.3

// ============================================================
// USE CASE PROVIDERS
// ============================================================

final getDailyTimeboxProvider = Provider.autoDispose(
  (ref) => getIt<GetDailyTimeboxUseCase>(),
);

final createTimeboxSlotProvider = Provider.autoDispose(
  (ref) => getIt<CreateTimeboxSlotUseCase>(),
);

final updateTimeboxSlotProvider = Provider.autoDispose(
  (ref) => getIt<UpdateTimeboxSlotUseCase>(),
);

final deleteTimeboxSlotProvider = Provider.autoDispose(
  (ref) => getIt<DeleteTimeboxSlotUseCase>(),
);

final detectTimeConflictsProvider = Provider.autoDispose(
  (ref) => getIt<DetectTimeConflictsUseCase>(),
);

final autoScheduleTasksProvider = Provider.autoDispose(
  (ref) => getIt<AutoScheduleTasksUseCase>(),
);

final rescheduleSlotProvider = Provider.autoDispose(
  (ref) => getIt<RescheduleSlotUseCase>(),
);

final completeTimeboxSlotProvider = Provider.autoDispose(
  (ref) => getIt<CompleteTimeboxSlotUseCase>(),
);

final skipTimeboxSlotProvider = Provider.autoDispose(
  (ref) => getIt<SkipTimeboxSlotUseCase>(),
);

// ============================================================
// SERVICE PROVIDER
// ============================================================

final timeboxServiceProvider = Provider<TimeboxService>(
  (ref) => TimeboxService.instance,
);

// ============================================================
// STATE NOTIFIER PROVIDER
// ============================================================

/// Main timebox state provider
final timeboxNotifierProvider = StateNotifierProvider<TimeboxNotifier, TimeboxState>(
  (ref) => TimeboxNotifier(
    getDailyTimebox: ref.watch(getDailyTimeboxProvider),
    createSlot: ref.watch(createTimeboxSlotProvider),
    updateSlot: ref.watch(updateTimeboxSlotProvider),
    deleteSlot: ref.watch(deleteTimeboxSlotProvider),
    detectConflicts: ref.watch(detectTimeConflictsProvider),
    autoScheduleTasks: ref.watch(autoScheduleTasksProvider),
    rescheduleSlot: ref.watch(rescheduleSlotProvider),
    completeSlot: ref.watch(completeTimeboxSlotProvider),
    skipSlot: ref.watch(skipTimeboxSlotProvider),
    timeboxService: ref.watch(timeboxServiceProvider),
  ),
);

// ============================================================
// DERIVED PROVIDERS (WBS: 3.7.6.4)
// ============================================================

/// Current timebox entity
final currentTimeboxProvider = Provider<TimeboxEntity?>((ref) {
  return ref.watch(timeboxNotifierProvider).timeboxOrNull;
});

/// All slots in the current timebox
final timeboxSlotsProvider = Provider<List<TimeboxSlot>>((ref) {
  return ref.watch(timeboxNotifierProvider).slots;
});

/// All conflicts in the current timebox
final timeboxConflictsProvider = Provider<List<TimeConflict>>((ref) {
  return ref.watch(timeboxNotifierProvider).conflicts;
});

/// Current timebox summary
final timeboxSummaryProvider = Provider<TimeboxSummary?>((ref) {
  return ref.watch(timeboxNotifierProvider).summary;
});

/// Current timebox settings
final timeboxSettingsProvider = Provider<TimeboxSettings?>((ref) {
  return ref.watch(timeboxNotifierProvider).settings;
});

/// Check if timebox is loading
final isTimeboxLoadingProvider = Provider<bool>((ref) {
  return ref.watch(timeboxNotifierProvider).isLoading;
});

/// Check if timebox has errors
final hasTimeboxErrorProvider = Provider<bool>((ref) {
  return ref.watch(timeboxNotifierProvider).hasError;
});

/// Check if there are conflicts
final hasTimeboxConflictsProvider = Provider<bool>((ref) {
  return ref.watch(timeboxNotifierProvider).hasConflicts;
});

// ============================================================
// CATEGORY-SPECIFIC PROVIDERS
// ============================================================

/// Personal slots
final personalSlotsProvider = Provider<List<TimeboxSlot>>((ref) {
  return ref.watch(timeboxNotifierProvider).personalSlots;
});

/// Professional slots
final professionalSlotsProvider = Provider<List<TimeboxSlot>>((ref) {
  return ref.watch(timeboxNotifierProvider).professionalSlots;
});

/// Priority slots (high/critical priority)
final prioritySlotsProvider = Provider<List<TimeboxSlot>>((ref) {
  return ref.watch(timeboxNotifierProvider).prioritySlots;
});

/// Health category slots
final healthSlotsProvider = Provider<List<TimeboxSlot>>((ref) {
  return ref.watch(timeboxNotifierProvider)
      .slots
      .where((s) => s.category == TaskCategory.health)
      .toList();
});

/// Learning category slots
final learningSlotsProvider = Provider<List<TimeboxSlot>>((ref) {
  return ref.watch(timeboxNotifierProvider)
      .slots
      .where((s) => s.category == TaskCategory.learning)
      .toList();
});

// ============================================================
// STATUS-SPECIFIC PROVIDERS
// ============================================================

/// Currently active slot
final currentSlotProvider = Provider<TimeboxSlot?>((ref) {
  return ref.watch(timeboxNotifierProvider).currentSlot;
});

/// Upcoming slots (not started)
final upcomingSlotsProvider = Provider<List<TimeboxSlot>>((ref) {
  return ref.watch(timeboxNotifierProvider).upcomingSlots;
});

/// Completed slots
final completedSlotsProvider = Provider<List<TimeboxSlot>>((ref) {
  return ref.watch(timeboxNotifierProvider).completedSlots;
});

/// Overdue slots
final overdueSlotsProvider = Provider<List<TimeboxSlot>>((ref) {
  return ref.watch(timeboxNotifierProvider).overdueSlots;
});

// ============================================================
// STATISTICS PROVIDERS
// ============================================================

/// Total tasks count
final totalTasksCountProvider = Provider<int>((ref) {
  return ref.watch(timeboxSummaryProvider)?.totalTasks ?? 0;
});

/// Completed tasks count
final completedTasksCountProvider = Provider<int>((ref) {
  return ref.watch(timeboxSummaryProvider)?.completedTasks ?? 0;
});

/// Completion rate (0.0 - 1.0)
final completionRateProvider = Provider<double>((ref) {
  return ref.watch(timeboxSummaryProvider)?.completionRate ?? 0.0;
});

/// Conflict count
final conflictCountProvider = Provider<int>((ref) {
  return ref.watch(timeboxSummaryProvider)?.conflictCount ?? 0;
});

/// Total scheduled hours
final totalScheduledHoursProvider = Provider<double>((ref) {
  return ref.watch(timeboxSummaryProvider)?.totalScheduledHours ?? 0.0;
});

/// Available hours
final availableHoursProvider = Provider<double>((ref) {
  return ref.watch(timeboxSummaryProvider)?.availableHours ?? 0.0;
});

/// Utilization rate (scheduled / available)
final utilizationRateProvider = Provider<double>((ref) {
  return ref.watch(timeboxSummaryProvider)?.utilizationRate ?? 0.0;
});

// ============================================================
// FAMILY PROVIDERS (Parameterized)
// ============================================================

/// Get slot by ID
final slotByIdProvider = Provider.family<TimeboxSlot?, String>((ref, slotId) {
  final slots = ref.watch(timeboxSlotsProvider);
  try {
    return slots.firstWhere((s) => s.id == slotId);
  } catch (_) {
    return null;
  }
});

/// Get slots by category
final slotsByCategoryProvider = Provider.family<List<TimeboxSlot>, TaskCategory>((ref, category) {
  return ref.watch(timeboxSlotsProvider)
      .where((s) => s.category == category)
      .toList();
});

/// Get conflicts for a specific slot
final conflictsForSlotProvider = Provider.family<List<TimeConflict>, String>((ref, slotId) {
  return ref.watch(timeboxConflictsProvider)
      .where((c) => c.slot1Id == slotId || c.slot2Id == slotId)
      .toList();
});
