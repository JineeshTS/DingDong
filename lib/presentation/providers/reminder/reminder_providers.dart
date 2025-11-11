import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/reminder_entity.dart';
import '../../../domain/usecases/reminder/create_reminder_usecase.dart';
import '../../../domain/usecases/reminder/update_reminder_usecase.dart';
import '../../../domain/usecases/reminder/delete_reminder_usecase.dart';
import '../../../domain/usecases/reminder/get_reminders_due_soon_usecase.dart';
import '../../../domain/usecases/reminder/enable_reminder_usecase.dart';
import '../../../domain/usecases/reminder/disable_reminder_usecase.dart';
import '../../../domain/usecases/reminder/snooze_reminder_usecase.dart';
import '../../../domain/usecases/reminder/mark_reminder_triggered_usecase.dart';
import 'reminder_notifier.dart';
import 'reminder_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================
// These providers expose individual use cases from the DI container.
// They are auto-disposed when no longer needed for optimal memory management.

/// Provider for CreateReminderUseCase
///
/// Handles creation of new reminders with support for:
/// - Time-based reminders with trigger times
/// - Location-based reminders with geofencing
/// - Context-based reminders (app open, WiFi, etc.)
final createReminderProvider = Provider.autoDispose<CreateReminderUseCase>(
  (ref) => sl<CreateReminderUseCase>(),
);

/// Provider for UpdateReminderUseCase
///
/// Handles reminder updates
final updateReminderProvider = Provider.autoDispose<UpdateReminderUseCase>(
  (ref) => sl<UpdateReminderUseCase>(),
);

/// Provider for DeleteReminderUseCase
///
/// Handles reminder deletion
final deleteReminderProvider = Provider.autoDispose<DeleteReminderUseCase>(
  (ref) => sl<DeleteReminderUseCase>(),
);

/// Provider for GetRemindersDueSoonUseCase
///
/// Retrieves reminders that will trigger within a time window
final getRemindersDueSoonProvider =
    Provider.autoDispose<GetRemindersDueSoonUseCase>(
  (ref) => sl<GetRemindersDueSoonUseCase>(),
);

/// Provider for EnableReminderUseCase
///
/// Enables a reminder for triggering
final enableReminderProvider = Provider.autoDispose<EnableReminderUseCase>(
  (ref) => sl<EnableReminderUseCase>(),
);

/// Provider for DisableReminderUseCase
///
/// Disables a reminder so it won't trigger
final disableReminderProvider = Provider.autoDispose<DisableReminderUseCase>(
  (ref) => sl<DisableReminderUseCase>(),
);

/// Provider for SnoozeReminderUseCase
///
/// Temporarily disables and reschedules a reminder
final snoozeReminderProvider = Provider.autoDispose<SnoozeReminderUseCase>(
  (ref) => sl<SnoozeReminderUseCase>(),
);

/// Provider for MarkReminderTriggeredUseCase
///
/// Updates reminder trigger tracking
final markReminderTriggeredProvider =
    Provider.autoDispose<MarkReminderTriggeredUseCase>(
  (ref) => sl<MarkReminderTriggeredUseCase>(),
);

// ============================================================================
// Reminder State Notifier Provider
// ============================================================================

/// Main reminder state notifier provider
///
/// This is the primary provider for reminder state management.
/// It should NOT be auto-disposed as we want to maintain reminder
/// state throughout the app lifecycle.
///
/// Usage:
/// ```dart
/// // In a ConsumerWidget
/// final reminderState = ref.watch(reminderNotifierProvider);
/// final reminderNotifier = ref.read(reminderNotifierProvider.notifier);
///
/// // Get reminders due soon
/// ref.listen(reminderNotifierProvider, (previous, next) {
///   if (next.remindersDueSoon.isNotEmpty) {
///     // Handle due soon reminders update
///   }
/// });
///
/// // Perform reminder actions
/// await reminderNotifier.createReminder(newReminder);
/// await reminderNotifier.enableReminder(reminderId);
/// ```
final reminderNotifierProvider = StateNotifierProvider<ReminderNotifier, ReminderState>(
  (ref) {
    return ReminderNotifier(
      createReminderUseCase: ref.read(createReminderProvider),
      updateReminderUseCase: ref.read(updateReminderProvider),
      deleteReminderUseCase: ref.read(deleteReminderProvider),
      getRemindersDueSoonUseCase: ref.read(getRemindersDueSoonProvider),
      enableReminderUseCase: ref.read(enableReminderProvider),
      disableReminderUseCase: ref.read(disableReminderProvider),
      snoozeReminderUseCase: ref.read(snoozeReminderProvider),
      markReminderTriggeredUseCase: ref.read(markReminderTriggeredProvider),
    );
  },
);

// ============================================================================
// Derived State Providers - Reminder Lists
// ============================================================================

/// Provider that exposes all reminders
///
/// Returns paginated list of all reminders
///
/// Usage:
/// ```dart
/// final allReminders = ref.watch(allRemindersProvider);
/// ListView.builder(
///   itemCount: allReminders.itemCount,
///   itemBuilder: (context, index) => ReminderTile(reminder: allReminders.items[index]),
/// );
/// ```
final allRemindersProvider = Provider.autoDispose((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.allReminders;
});

/// Provider that exposes active reminders
///
/// Returns list of enabled reminders that can trigger
///
/// Usage:
/// ```dart
/// final activeReminders = ref.watch(activeRemindersProvider);
/// Text('${activeReminders.length} active reminders');
/// ```
final activeRemindersProvider = Provider.autoDispose<List<ReminderEntity>>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.activeReminders;
});

/// Provider that exposes reminders due soon
///
/// Returns reminders that will trigger within the time window
///
/// Usage:
/// ```dart
/// final dueReminders = ref.watch(remindersDueSoonProvider);
/// DueSoonRemindersWidget(reminders: dueReminders);
/// ```
final remindersDueSoonProvider = Provider.autoDispose<List<ReminderEntity>>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.remindersDueSoon;
});

/// Provider that exposes time-based reminders
///
/// Returns reminders with specific trigger times
///
/// Usage:
/// ```dart
/// final timeReminders = ref.watch(timeBasedRemindersProvider);
/// TimeBasedRemindersView(reminders: timeReminders);
/// ```
final timeBasedRemindersProvider = Provider.autoDispose<List<ReminderEntity>>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.timeBasedReminders;
});

/// Provider that exposes location-based reminders
///
/// Returns reminders with geofencing triggers
///
/// Usage:
/// ```dart
/// final locationReminders = ref.watch(locationBasedRemindersProvider);
/// LocationRemindersView(reminders: locationReminders);
/// ```
final locationBasedRemindersProvider = Provider.autoDispose<List<ReminderEntity>>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.locationBasedReminders;
});

/// Provider that exposes context-based reminders
///
/// Returns reminders with context triggers (app open, WiFi, etc.)
final contextBasedRemindersProvider = Provider.autoDispose<List<ReminderEntity>>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.contextBasedReminders;
});

/// Provider that exposes snoozed reminders
///
/// Returns reminders that are currently snoozed
///
/// Usage:
/// ```dart
/// final snoozed = ref.watch(snoozedRemindersProvider);
/// SnoozedRemindersView(reminders: snoozed);
/// ```
final snoozedRemindersProvider = Provider.autoDispose<List<ReminderEntity>>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.snoozedReminders;
});

/// Provider that exposes recently triggered reminders
///
/// Returns reminders that have been triggered recently
final triggeredRemindersProvider = Provider.autoDispose<List<ReminderEntity>>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.triggeredReminders;
});

/// Provider that exposes disabled reminders
///
/// Returns reminders that are currently disabled
final disabledRemindersProvider = Provider.autoDispose<List<ReminderEntity>>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.disabledReminders;
});

/// Provider that exposes selected reminder
///
/// Returns currently selected/viewed reminder
///
/// Usage:
/// ```dart
/// final selectedReminder = ref.watch(selectedReminderProvider);
/// if (selectedReminder != null) {
///   ReminderDetailView(reminder: selectedReminder);
/// }
/// ```
final selectedReminderProvider = Provider.autoDispose<ReminderEntity?>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.selectedReminder;
});

// ============================================================================
// Derived State Providers - Counts and Statistics
// ============================================================================

/// Provider for active reminders count
///
/// Returns count of enabled reminders
///
/// Usage:
/// ```dart
/// final activeCount = ref.watch(activeRemindersCountProvider);
/// Badge(label: '$activeCount');
/// ```
final activeRemindersCountProvider = Provider.autoDispose<int>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.activeRemindersCount;
});

/// Provider for due soon reminders count
///
/// Returns count of reminders due soon
final dueSoonRemindersCountProvider = Provider.autoDispose<int>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.dueSoonRemindersCount;
});

/// Provider for snoozed reminders count
///
/// Returns count of currently snoozed reminders
final snoozedRemindersCountProvider = Provider.autoDispose<int>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.snoozedRemindersCount;
});

/// Provider for time-based reminders count
///
/// Returns count of time-based reminders
final timeBasedRemindersCountProvider = Provider.autoDispose<int>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.timeBasedRemindersCount;
});

/// Provider for location-based reminders count
///
/// Returns count of location-based reminders
final locationBasedRemindersCountProvider = Provider.autoDispose<int>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.locationBasedRemindersCount;
});

/// Provider for context-based reminders count
///
/// Returns count of context-based reminders
final contextBasedRemindersCountProvider = Provider.autoDispose<int>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.contextBasedRemindersCount;
});

/// Provider for total reminders count
///
/// Returns total count of all reminders
final totalRemindersCountProvider = Provider.autoDispose<int>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.allReminders.itemCount;
});

// ============================================================================
// Derived State Providers - Loading States
// ============================================================================

/// Provider for all reminders loading state
///
/// Returns true if all reminders are loading
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(isLoadingAllRemindersProvider);
/// if (isLoading) CircularProgressIndicator();
/// ```
final isLoadingAllRemindersProvider = Provider.autoDispose<bool>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.isLoadingAll;
});

/// Provider for due soon reminders loading state
///
/// Returns true if due soon reminders are loading
final isLoadingDueSoonProvider = Provider.autoDispose<bool>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.isLoadingDueSoon;
});

/// Provider for any loading state
///
/// Returns true if any reminder operation is loading
final isAnyReminderLoadingProvider = Provider.autoDispose<bool>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.isAnyLoading;
});

/// Provider for operation in progress state
///
/// Returns true if any reminder operation is in progress
///
/// Usage:
/// ```dart
/// final isProcessing = ref.watch(isReminderOperationInProgressProvider);
/// ElevatedButton(
///   onPressed: isProcessing ? null : () => createReminder(),
/// );
/// ```
final isReminderOperationInProgressProvider = Provider.autoDispose<bool>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.isAnyOperationInProgress;
});

// ============================================================================
// Derived State Providers - Errors
// ============================================================================

/// Provider for operation error
///
/// Returns error from reminder operations
///
/// Usage:
/// ```dart
/// ref.listen(reminderOperationErrorProvider, (previous, next) {
///   if (next != null) {
///     showErrorSnackBar(next.message);
///   }
/// });
/// ```
final reminderOperationErrorProvider = Provider.autoDispose((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.operationError;
});

/// Provider for due soon error
///
/// Returns error from loading due soon reminders
final dueSoonErrorProvider = Provider.autoDispose((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.dueSoonError;
});

/// Provider for any error state
///
/// Returns true if any reminder operation has an error
final hasAnyReminderErrorProvider = Provider.autoDispose<bool>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.hasAnyError;
});

// ============================================================================
// Derived State Providers - Filters and Options
// ============================================================================

/// Provider for current type filter
///
/// Returns currently selected reminder type filter
final reminderTypeFilterProvider =
    Provider.autoDispose<ReminderType?>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.filterByType;
});

/// Provider for current sort option
///
/// Returns current reminder sort option
final currentReminderSortOptionProvider =
    Provider.autoDispose<ReminderSortOption>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.sortOption;
});

/// Provider for sort direction (ascending/descending)
///
/// Returns true if sorting in ascending order
final isReminderSortAscendingProvider = Provider.autoDispose<bool>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.sortAscending;
});

/// Provider for include disabled reminders filter
///
/// Returns true if disabled reminders should be included
final includeDisabledRemindersProvider = Provider.autoDispose<bool>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.includeDisabled;
});

/// Provider for current due window setting
///
/// Returns the time window in minutes for due soon queries
final dueSoonWindowProvider = Provider.autoDispose<int>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.dueWindowMinutes;
});

/// Provider for default snooze duration
///
/// Returns the default snooze duration in minutes
final defaultSnoozeDurationProvider = Provider.autoDispose<int>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.snoozeDurationMinutes;
});

// ============================================================================
// Derived State Providers - Computed Values
// ============================================================================

/// Provider for urgent reminders (due within 5 minutes)
///
/// Returns reminders that are due very soon
///
/// Usage:
/// ```dart
/// final urgentReminders = ref.watch(urgentRemindersProvider);
/// UrgentRemindersWidget(reminders: urgentReminders);
/// ```
final urgentRemindersProvider = Provider.autoDispose<List<ReminderEntity>>((ref) {
  final dueSoon = ref.watch(remindersDueSoonProvider);
  final now = DateTime.now();
  final urgentThreshold = now.add(const Duration(minutes: 5));

  return dueSoon.where((reminder) {
    if (reminder.triggerTime == null) return false;
    return reminder.triggerTime!.isBefore(urgentThreshold);
  }).toList();
});

/// Provider for urgent reminders count
///
/// Returns count of urgently due reminders
final urgentRemindersCountProvider = Provider.autoDispose<int>((ref) {
  final urgentReminders = ref.watch(urgentRemindersProvider);
  return urgentReminders.length;
});

/// Provider for overdue reminders
///
/// Returns reminders that are past their trigger time
///
/// Usage:
/// ```dart
/// final overdueReminders = ref.watch(overdueRemindersProvider);
/// if (overdueReminders.isNotEmpty) {
///   showOverdueWarning();
/// }
/// ```
final overdueRemindersProvider = Provider.autoDispose<List<ReminderEntity>>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.allReminders.items
      .where((reminder) => reminder.isOverdue && reminder.isEnabled)
      .toList();
});

/// Provider for reminders grouped by type
///
/// Returns map of reminders grouped by their type
///
/// Usage:
/// ```dart
/// final groupedReminders = ref.watch(remindersGroupedByTypeProvider);
/// for (final type in groupedReminders.keys) {
///   TypeSection(type: type, reminders: groupedReminders[type]!);
/// }
/// ```
final remindersGroupedByTypeProvider =
    Provider.autoDispose<Map<ReminderType, List<ReminderEntity>>>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  final reminders = reminderState.allReminders.items;

  final grouped = <ReminderType, List<ReminderEntity>>{};

  for (final reminder in reminders) {
    if (!grouped.containsKey(reminder.type)) {
      grouped[reminder.type] = [];
    }
    grouped[reminder.type]!.add(reminder);
  }

  return grouped;
});

/// Provider for checking if refresh is needed
///
/// Returns true if any reminder list needs refresh
///
/// Usage:
/// ```dart
/// final needsRefresh = ref.watch(remindersNeedRefreshProvider);
/// if (needsRefresh) {
///   ref.read(reminderNotifierProvider.notifier).refreshAll(userId);
/// }
/// ```
final remindersNeedRefreshProvider = Provider.autoDispose<bool>((ref) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.needsRefreshAll ||
      reminderState.needsRefreshActive ||
      reminderState.needsRefreshDueSoon;
});

/// Provider for reminders by task
///
/// Returns reminders associated with a specific task
///
/// Usage:
/// ```dart
/// final taskReminders = ref.watch(remindersByTaskProvider(taskId));
/// TaskRemindersWidget(reminders: taskReminders);
/// ```
final remindersByTaskProvider =
    Provider.autoDispose.family<List<ReminderEntity>, String>((ref, taskId) {
  final reminderState = ref.watch(reminderNotifierProvider);
  return reminderState.allReminders.items
      .where((reminder) => reminder.taskId == taskId)
      .toList();
});

/// Provider for reminder trigger info
///
/// Returns detailed information about when a reminder will trigger
///
/// Usage:
/// ```dart
/// final triggerInfo = ref.watch(reminderTriggerInfoProvider(reminderId));
/// TriggerInfoWidget(info: triggerInfo);
/// ```
final reminderTriggerInfoProvider =
    Provider.autoDispose.family<String, String>((ref, reminderId) {
  final reminder = ref.watch(selectedReminderProvider);
  if (reminder == null || reminder.id != reminderId) return '';

  switch (reminder.type) {
    case ReminderType.timeBased:
      if (reminder.triggerTime == null) return '';
      final duration = reminder.triggerTime!.difference(DateTime.now());
      if (duration.isNegative) {
        return 'Overdue by ${duration.abs().inMinutes} minutes';
      }
      return 'In ${duration.inMinutes} minutes';

    case ReminderType.locationBased:
      if (reminder.locationTrigger == null) return '';
      return '${reminder.locationTrigger!.locationName} (${reminder.locationTrigger!.radiusMeters}m)';

    case ReminderType.contextBased:
      if (reminder.contextTrigger == null) return '';
      return 'When ${reminder.contextTrigger!.type.toString().split('.').last}';
  }
});
