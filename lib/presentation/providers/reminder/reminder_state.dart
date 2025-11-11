import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/reminder_entity.dart';
import '../../common/pagination_state.dart';

part 'reminder_state.freezed.dart';

/// Reminder management state for the application
///
/// Manages reminder operations, scheduling, and filtering with support for
/// multiple reminder types (time-based, location-based, context-based).
/// This state is used by [ReminderNotifier] to track all reminder-related operations.
///
/// Features:
/// - Multiple reminder type support (time, location, context)
/// - Due soon queries with time window support
/// - Snooze functionality with duration tracking
/// - Enable/disable management
/// - Pagination support for reminder lists
/// - Real-time reminder updates
/// - Filter and sort capabilities
@freezed
class ReminderState with _$ReminderState {
  const factory ReminderState({
    /// All reminders with pagination
    @Default(PaginationState()) PaginationState<ReminderEntity> allReminders,

    /// Active reminders (enabled and not deleted)
    @Default([]) List<ReminderEntity> activeReminders,

    /// Reminders due soon (within configured time window)
    @Default([]) List<ReminderEntity> remindersDueSoon,

    /// Time-based reminders
    @Default([]) List<ReminderEntity> timeBasedReminders,

    /// Location-based reminders
    @Default([]) List<ReminderEntity> locationBasedReminders,

    /// Context-based reminders
    @Default([]) List<ReminderEntity> contextBasedReminders,

    /// Snoozed reminders with snooze end time
    @Default([]) List<ReminderEntity> snoozedReminders,

    /// Recently triggered reminders
    @Default([]) List<ReminderEntity> triggeredReminders,

    /// Disabled reminders
    @Default([]) List<ReminderEntity> disabledReminders,

    /// Currently selected/viewed reminder
    ReminderEntity? selectedReminder,

    /// Current time window for due soon queries (in minutes)
    @Default(30) int dueWindowMinutes,

    /// Current snooze duration (in minutes)
    @Default(5) int snoozeDurationMinutes,

    /// Current sort option
    @Default(ReminderSortOption.triggerTime) ReminderSortOption sortOption,

    /// Sort in ascending order
    @Default(true) bool sortAscending,

    /// Include disabled reminders in lists
    @Default(false) bool includeDisabled,

    /// Filter by reminder type
    ReminderType? filterByType,

    /// Loading states
    @Default(false) bool isLoadingAll,
    @Default(false) bool isLoadingActive,
    @Default(false) bool isLoadingDueSoon,
    @Default(false) bool isLoadingByType,
    @Default(false) bool isLoadingReminder,

    /// Operation loading states
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,
    @Default(false) bool isDeleting,
    @Default(false) bool isEnabling,
    @Default(false) bool isDisabling,
    @Default(false) bool isSnoozeing,
    @Default(false) bool isMarking,

    /// Error states
    Failure? error,
    Failure? dueSoonError,
    Failure? typeFilterError,
    Failure? operationError,

    /// Last refresh timestamps
    DateTime? lastRefreshAll,
    DateTime? lastRefreshActive,
    DateTime? lastRefreshDueSoon,
    DateTime? lastRefreshByType,
  }) = _ReminderState;

  const ReminderState._();

  /// Check if any reminder list is loading
  bool get isAnyLoading =>
      isLoadingAll ||
      isLoadingActive ||
      isLoadingDueSoon ||
      isLoadingByType ||
      isLoadingReminder ||
      allReminders.isLoading;

  /// Check if any operation is in progress
  bool get isAnyOperationInProgress =>
      isCreating ||
      isUpdating ||
      isDeleting ||
      isEnabling ||
      isDisabling ||
      isSnoozeing ||
      isMarking;

  /// Check if there are any errors
  bool get hasAnyError =>
      error != null ||
      dueSoonError != null ||
      typeFilterError != null ||
      operationError != null;

  /// Get total count of active reminders
  int get activeRemindersCount => activeReminders.length;

  /// Get total count of reminders due soon
  int get dueSoonRemindersCount => remindersDueSoon.length;

  /// Get total count of snoozed reminders
  int get snoozedRemindersCount => snoozedReminders.length;

  /// Get total count of time-based reminders
  int get timeBasedRemindersCount => timeBasedReminders.length;

  /// Get total count of location-based reminders
  int get locationBasedRemindersCount => locationBasedReminders.length;

  /// Get total count of context-based reminders
  int get contextBasedRemindersCount => contextBasedReminders.length;

  /// Check if data needs refresh (based on 5 minute threshold)
  bool needsRefresh(DateTime? lastRefresh) {
    if (lastRefresh == null) return true;
    final now = DateTime.now();
    return now.difference(lastRefresh).inMinutes >= 5;
  }

  /// Check if all reminders need refresh
  bool get needsRefreshAll => needsRefresh(lastRefreshAll);

  /// Check if active reminders need refresh
  bool get needsRefreshActive => needsRefresh(lastRefreshActive);

  /// Check if due soon reminders need refresh
  bool get needsRefreshDueSoon => needsRefresh(lastRefreshDueSoon);

  /// Check if type-filtered reminders need refresh
  bool get needsRefreshByType => needsRefresh(lastRefreshByType);
}

/// Reminder sort options
enum ReminderSortOption {
  triggerTime, // Sort by trigger time
  createdDate, // Sort by creation date
  updatedDate, // Sort by update date
  type, // Sort by reminder type
  enabled, // Sort by enabled status
}
