import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/reminder_entity.dart';
import '../../../domain/usecases/reminder/create_reminder_usecase.dart';
import '../../../domain/usecases/reminder/update_reminder_usecase.dart';
import '../../../domain/usecases/reminder/delete_reminder_usecase.dart';
import '../../../domain/usecases/reminder/get_reminders_due_soon_usecase.dart';
import '../../../domain/usecases/reminder/enable_reminder_usecase.dart';
import '../../../domain/usecases/reminder/disable_reminder_usecase.dart';
import '../../../domain/usecases/reminder/snooze_reminder_usecase.dart';
import '../../../domain/usecases/reminder/mark_reminder_triggered_usecase.dart';
import 'reminder_state.dart';

/// StateNotifier for managing reminder state
///
/// Handles all reminder-related operations including:
/// - CRUD operations (Create, Read, Update, Delete)
/// - Multi-type reminder support (time, location, context)
/// - Enable/disable management
/// - Snooze functionality
/// - Due soon queries
/// - Triggered tracking
/// - Real-time reminder updates
///
/// This notifier integrates with all 8 reminder use cases
/// and manages the ReminderState throughout the application lifecycle.
class ReminderNotifier extends StateNotifier<ReminderState> {
  // Use cases
  final CreateReminderUseCase _createReminderUseCase;
  final UpdateReminderUseCase _updateReminderUseCase;
  final DeleteReminderUseCase _deleteReminderUseCase;
  final GetRemindersDueSoonUseCase _getRemindersDueSoonUseCase;
  final EnableReminderUseCase _enableReminderUseCase;
  final DisableReminderUseCase _disableReminderUseCase;
  final SnoozeReminderUseCase _snoozeReminderUseCase;
  final MarkReminderTriggeredUseCase _markReminderTriggeredUseCase;

  ReminderNotifier({
    required CreateReminderUseCase createReminderUseCase,
    required UpdateReminderUseCase updateReminderUseCase,
    required DeleteReminderUseCase deleteReminderUseCase,
    required GetRemindersDueSoonUseCase getRemindersDueSoonUseCase,
    required EnableReminderUseCase enableReminderUseCase,
    required DisableReminderUseCase disableReminderUseCase,
    required SnoozeReminderUseCase snoozeReminderUseCase,
    required MarkReminderTriggeredUseCase markReminderTriggeredUseCase,
  })  : _createReminderUseCase = createReminderUseCase,
        _updateReminderUseCase = updateReminderUseCase,
        _deleteReminderUseCase = deleteReminderUseCase,
        _getRemindersDueSoonUseCase = getRemindersDueSoonUseCase,
        _enableReminderUseCase = enableReminderUseCase,
        _disableReminderUseCase = disableReminderUseCase,
        _snoozeReminderUseCase = snoozeReminderUseCase,
        _markReminderTriggeredUseCase = markReminderTriggeredUseCase,
        super(const ReminderState());

  // ============================================================================
  // CRUD Operations
  // ============================================================================

  /// Create a new reminder
  ///
  /// Parameters:
  /// - [reminder]: Reminder entity to create
  ///
  /// Supports:
  /// - Time-based reminders with future trigger times
  /// - Location-based reminders with geofencing
  /// - Context-based reminders (app open, WiFi, etc.)
  /// - Multiple types per task (max 10)
  Future<void> createReminder(ReminderEntity reminder) async {
    state = state.copyWith(isCreating: true, operationError: null);

    final result = await _createReminderUseCase(reminder: reminder);

    result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          operationError: failure,
        );
      },
      (createdReminder) {
        // Add to relevant lists
        state = state.copyWith(
          isCreating: false,
          allReminders: state.allReminders.prependItem(createdReminder),
          operationError: null,
        );

        // Add to type-specific lists
        if (createdReminder.isEnabled) {
          state = state.copyWith(
            activeReminders: [createdReminder, ...state.activeReminders],
          );
        }

        _categorizeReminder(createdReminder);
      },
    );
  }

  /// Update an existing reminder
  ///
  /// Parameters:
  /// - [reminder]: Updated reminder entity
  ///
  /// Updates trigger times, locations, context, and other properties
  Future<void> updateReminder(ReminderEntity reminder) async {
    state = state.copyWith(isUpdating: true, operationError: null);

    final result = await _updateReminderUseCase(reminder: reminder);

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          operationError: failure,
        );
      },
      (updatedReminder) {
        // Update in all lists
        state = state.copyWith(
          isUpdating: false,
          allReminders: state.allReminders.updateItem(
            (r) => r.id == updatedReminder.id,
            (_) => updatedReminder,
          ),
          activeReminders: state.activeReminders
              .map((r) => r.id == updatedReminder.id ? updatedReminder : r)
              .toList(),
          timeBasedReminders: state.timeBasedReminders
              .map((r) => r.id == updatedReminder.id ? updatedReminder : r)
              .toList(),
          locationBasedReminders: state.locationBasedReminders
              .map((r) => r.id == updatedReminder.id ? updatedReminder : r)
              .toList(),
          contextBasedReminders: state.contextBasedReminders
              .map((r) => r.id == updatedReminder.id ? updatedReminder : r)
              .toList(),
          snoozedReminders: state.snoozedReminders
              .map((r) => r.id == updatedReminder.id ? updatedReminder : r)
              .toList(),
          triggeredReminders: state.triggeredReminders
              .map((r) => r.id == updatedReminder.id ? updatedReminder : r)
              .toList(),
          selectedReminder: state.selectedReminder?.id == updatedReminder.id
              ? updatedReminder
              : state.selectedReminder,
          operationError: null,
        );
      },
    );
  }

  /// Delete a reminder
  ///
  /// Parameters:
  /// - [reminderId]: ID of reminder to delete
  ///
  /// Removes the reminder from all lists
  Future<void> deleteReminder(String reminderId) async {
    state = state.copyWith(isDeleting: true, operationError: null);

    final result = await _deleteReminderUseCase(reminderId: reminderId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          operationError: failure,
        );
      },
      (_) {
        // Remove from all lists
        state = state.copyWith(
          isDeleting: false,
          allReminders: state.allReminders.removeItem((r) => r.id == reminderId),
          activeReminders:
              state.activeReminders.where((r) => r.id != reminderId).toList(),
          remindersDueSoon: state.remindersDueSoon
              .where((r) => r.id != reminderId)
              .toList(),
          timeBasedReminders: state.timeBasedReminders
              .where((r) => r.id != reminderId)
              .toList(),
          locationBasedReminders: state.locationBasedReminders
              .where((r) => r.id != reminderId)
              .toList(),
          contextBasedReminders: state.contextBasedReminders
              .where((r) => r.id != reminderId)
              .toList(),
          snoozedReminders:
              state.snoozedReminders.where((r) => r.id != reminderId).toList(),
          triggeredReminders: state.triggeredReminders
              .where((r) => r.id != reminderId)
              .toList(),
          disabledReminders:
              state.disabledReminders.where((r) => r.id != reminderId).toList(),
          selectedReminder: state.selectedReminder?.id == reminderId
              ? null
              : state.selectedReminder,
          operationError: null,
        );
      },
    );
  }

  // ============================================================================
  // Due Soon Queries
  // ============================================================================

  /// Get reminders due soon
  ///
  /// Parameters:
  /// - [userId]: ID of current user
  /// - [timeWindowMinutes]: Time window in minutes (default from state)
  /// - [forceRefresh]: Force refresh even if cached data is fresh
  ///
  /// Returns reminders that will trigger within the specified time window
  Future<void> getRemindersDueSoon(
    String userId, {
    int? timeWindowMinutes,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && !state.needsRefreshDueSoon) {
      return;
    }

    state = state.copyWith(
      isLoadingDueSoon: true,
      dueSoonError: null,
      dueWindowMinutes: timeWindowMinutes ?? state.dueWindowMinutes,
    );

    final result = await _getRemindersDueSoonUseCase(
      userId: userId,
      timeWindowMinutes: timeWindowMinutes ?? state.dueWindowMinutes,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingDueSoon: false,
          dueSoonError: failure,
        );
      },
      (reminders) {
        state = state.copyWith(
          isLoadingDueSoon: false,
          remindersDueSoon: reminders,
          lastRefreshDueSoon: DateTime.now(),
          dueSoonError: null,
        );
      },
    );
  }

  /// Set the time window for due soon queries
  ///
  /// Parameters:
  /// - [minutes]: Time window in minutes
  void setDueWindowMinutes(int minutes) {
    state = state.copyWith(dueWindowMinutes: minutes);
  }

  // ============================================================================
  // Enable/Disable Operations
  // ============================================================================

  /// Enable a reminder
  ///
  /// Parameters:
  /// - [reminderId]: ID of reminder to enable
  ///
  /// Activates the reminder for triggering
  Future<void> enableReminder(String reminderId) async {
    state = state.copyWith(isEnabling: true, operationError: null);

    final result = await _enableReminderUseCase(reminderId: reminderId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isEnabling: false,
          operationError: failure,
        );
      },
      (enabledReminder) {
        // Update in all lists
        state = state.copyWith(
          isEnabling: false,
          allReminders: state.allReminders.updateItem(
            (r) => r.id == reminderId,
            (_) => enabledReminder,
          ),
          activeReminders: [enabledReminder, ...state.activeReminders],
          disabledReminders:
              state.disabledReminders.where((r) => r.id != reminderId).toList(),
          operationError: null,
        );

        // Re-categorize the reminder
        _categorizeReminder(enabledReminder);
      },
    );
  }

  /// Disable a reminder
  ///
  /// Parameters:
  /// - [reminderId]: ID of reminder to disable
  ///
  /// Deactivates the reminder so it won't trigger
  Future<void> disableReminder(String reminderId) async {
    state = state.copyWith(isDisabling: true, operationError: null);

    final result = await _disableReminderUseCase(reminderId: reminderId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isDisabling: false,
          operationError: failure,
        );
      },
      (disabledReminder) {
        // Update in all lists
        state = state.copyWith(
          isDisabling: false,
          allReminders: state.allReminders.updateItem(
            (r) => r.id == reminderId,
            (_) => disabledReminder,
          ),
          activeReminders:
              state.activeReminders.where((r) => r.id != reminderId).toList(),
          disabledReminders: [disabledReminder, ...state.disabledReminders],
          operationError: null,
        );
      },
    );
  }

  // ============================================================================
  // Snooze Operations
  // ============================================================================

  /// Snooze a reminder for a specified duration
  ///
  /// Parameters:
  /// - [reminderId]: ID of reminder to snooze
  /// - [durationMinutes]: Duration to snooze in minutes (default from state)
  ///
  /// Temporarily disables the reminder and reschedules it
  Future<void> snoozeReminder(
    String reminderId, {
    int? durationMinutes,
  }) async {
    state = state.copyWith(isSnoozeing: true, operationError: null);

    final duration = durationMinutes ?? state.snoozeDurationMinutes;

    final result = await _snoozeReminderUseCase(
      reminderId: reminderId,
      durationMinutes: duration,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isSnoozeing: false,
          operationError: failure,
        );
      },
      (snoozedReminder) {
        // Update in all lists
        state = state.copyWith(
          isSnoozeing: false,
          allReminders: state.allReminders.updateItem(
            (r) => r.id == reminderId,
            (_) => snoozedReminder,
          ),
          activeReminders: state.activeReminders
              .where((r) => r.id != reminderId)
              .toList(),
          snoozedReminders: [snoozedReminder, ...state.snoozedReminders],
          remindersDueSoon: state.remindersDueSoon
              .where((r) => r.id != reminderId)
              .toList(),
          operationError: null,
        );
      },
    );
  }

  /// Set the default snooze duration
  ///
  /// Parameters:
  /// - [minutes]: Default snooze duration in minutes
  void setSnoozeDurationMinutes(int minutes) {
    state = state.copyWith(snoozeDurationMinutes: minutes);
  }

  // ============================================================================
  // Triggered Operations
  // ============================================================================

  /// Mark a reminder as triggered
  ///
  /// Parameters:
  /// - [reminderId]: ID of reminder that was triggered
  ///
  /// Updates last trigger time and trigger count
  Future<void> markReminderTriggered(String reminderId) async {
    state = state.copyWith(isMarking: true, operationError: null);

    final result = await _markReminderTriggeredUseCase(
      reminderId: reminderId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isMarking: false,
          operationError: failure,
        );
      },
      (triggeredReminder) {
        // Update in all lists
        state = state.copyWith(
          isMarking: false,
          allReminders: state.allReminders.updateItem(
            (r) => r.id == reminderId,
            (_) => triggeredReminder,
          ),
          triggeredReminders: [triggeredReminder, ...state.triggeredReminders],
          operationError: null,
        );
      },
    );
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Set selected reminder
  void selectReminder(ReminderEntity? reminder) {
    state = state.copyWith(selectedReminder: reminder);
  }

  /// Set reminder type filter
  void setTypeFilter(ReminderType? type) {
    state = state.copyWith(filterByType: type);
  }

  /// Set sort option
  void setSortOption(ReminderSortOption option, {bool ascending = true}) {
    state = state.copyWith(
      sortOption: option,
      sortAscending: ascending,
    );
  }

  /// Toggle include disabled reminders
  void toggleIncludeDisabled() {
    state = state.copyWith(
      includeDisabled: !state.includeDisabled,
    );
  }

  /// Clear all errors
  void clearErrors() {
    state = state.copyWith(
      error: null,
      dueSoonError: null,
      typeFilterError: null,
      operationError: null,
    );
  }

  /// Clear operation error
  void clearOperationError() {
    state = state.copyWith(operationError: null);
  }

  /// Refresh all reminder lists
  Future<void> refreshAll(String userId) async {
    await getRemindersDueSoon(
      userId,
      forceRefresh: true,
    );
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  /// Categorize a reminder into its type-specific list
  void _categorizeReminder(ReminderEntity reminder) {
    switch (reminder.type) {
      case ReminderType.timeBased:
        state = state.copyWith(
          timeBasedReminders: [reminder, ...state.timeBasedReminders],
        );
        break;

      case ReminderType.locationBased:
        state = state.copyWith(
          locationBasedReminders: [reminder, ...state.locationBasedReminders],
        );
        break;

      case ReminderType.contextBased:
        state = state.copyWith(
          contextBasedReminders: [reminder, ...state.contextBasedReminders],
        );
        break;
    }
  }
}
