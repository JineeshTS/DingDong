import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/habit_entity.dart';

part 'habit_state.freezed.dart';

/// Habit tracking state for the application
///
/// Manages habit operations, check-ins, streaks, and analytics with comprehensive state tracking.
/// This state is used by [HabitNotifier] to track all habit-related operations.
///
/// Features:
/// - Multiple habit views (all, active, archived)
/// - Habits grouped by category
/// - Habits due today
/// - Habit statistics and streaks
/// - Habit check-in history
/// - Filtering and search capabilities
/// - Real-time habit updates
@freezed
class HabitState with _$HabitState {
  const factory HabitState({
    /// All habits (active and archived)
    @Default([]) List<HabitEntity> allHabits,

    /// Active habits (non-archived, non-deleted)
    @Default([]) List<HabitEntity> activeHabits,

    /// Archived habits
    @Default([]) List<HabitEntity> archivedHabits,

    /// Habits grouped by category
    @Default({}) Map<HabitCategory, List<HabitEntity>> habitsByCategory,

    /// Habits due today (based on frequency)
    @Default([]) List<HabitEntity> habitsDueToday,

    /// Habits grouped by current streak
    @Default({}) Map<String, int> habitStreaks,

    /// Habit statistics (habitId -> statistics map)
    @Default({}) Map<String, Map<String, dynamic>> habitStatistics,

    /// Currently selected/viewed habit
    HabitEntity? selectedHabit,

    /// Current category filter
    HabitCategory? currentCategoryFilter,

    /// Current frequency filter
    HabitFrequency? currentFrequencyFilter,

    /// Search query for habits
    String? currentSearchQuery,

    /// Search results
    @Default([]) List<HabitEntity> searchResults,

    /// Loading states
    @Default(false) bool isLoadingAll,
    @Default(false) bool isLoadingActive,
    @Default(false) bool isLoadingArchived,
    @Default(false) bool isLoadingToday,
    @Default(false) bool isLoadingStatistics,
    @Default(false) bool isLoadingStreaks,
    @Default(false) bool isLoadingHabit,

    /// Operation loading states
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,
    @Default(false) bool isDeleting,
    @Default(false) bool isCheckingIn,
    @Default(false) bool isArchiving,
    @Default(false) bool isUndoingCheckIn,

    /// Error states
    Failure? error,
    Failure? todayError,
    Failure? categoryError,
    Failure? statisticsError,
    Failure? operationError,

    /// Last refresh timestamps
    DateTime? lastRefreshAll,
    DateTime? lastRefreshToday,
    DateTime? lastRefreshActive,
    DateTime? lastRefreshStatistics,
  }) = _HabitState;

  const HabitState._();

  /// Check if any habit list is loading
  bool get isAnyLoading =>
      isLoadingAll ||
      isLoadingActive ||
      isLoadingArchived ||
      isLoadingToday ||
      isLoadingStatistics ||
      isLoadingStreaks ||
      isLoadingHabit;

  /// Check if any operation is in progress
  bool get isAnyOperationInProgress =>
      isCreating ||
      isUpdating ||
      isDeleting ||
      isCheckingIn ||
      isArchiving ||
      isUndoingCheckIn;

  /// Check if there are any errors
  bool get hasAnyError =>
      error != null ||
      todayError != null ||
      categoryError != null ||
      statisticsError != null ||
      operationError != null;

  /// Get total count of active habits
  int get activeHabitCount => activeHabits.length;

  /// Get total count of habits due today
  int get habitsDueTodayCount => habitsDueToday.length;

  /// Get total count of archived habits
  int get archivedHabitCount => archivedHabits.length;

  /// Get total count of all habits
  int get totalHabitCount => allHabits.length;

  /// Check if data needs refresh (based on 5 minute threshold)
  bool needsRefresh(DateTime? lastRefresh) {
    if (lastRefresh == null) return true;
    final now = DateTime.now();
    return now.difference(lastRefresh).inMinutes >= 5;
  }

  /// Check if all habits need refresh
  bool get needsRefreshAll => needsRefresh(lastRefreshAll);

  /// Check if today habits need refresh
  bool get needsRefreshToday => needsRefresh(lastRefreshToday);

  /// Check if active habits need refresh
  bool get needsRefreshActive => needsRefresh(lastRefreshActive);

  /// Check if statistics need refresh
  bool get needsRefreshStatistics => needsRefresh(lastRefreshStatistics);

  /// Get completion percentage for all habits (0-100)
  double getAverageCompletionRate() {
    if (activeHabits.isEmpty) return 0;
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    double totalRate = 0;
    for (final habit in activeHabits) {
      totalRate += habit.getCompletionRate(thirtyDaysAgo, now);
    }
    return totalRate / activeHabits.length;
  }

  /// Get habits with current streak
  List<HabitEntity> getHabitsWithStreak(int minStreak) {
    return activeHabits.where((h) => h.currentStreak >= minStreak).toList();
  }

  /// Get habits completed today
  List<HabitEntity> getCompletedTodayHabits() {
    return habitsDueToday.where((h) => h.isCompletedToday).toList();
  }

  /// Get incomplete habits for today
  List<HabitEntity> getIncompleteTodayHabits() {
    return habitsDueToday.where((h) => !h.isCompletedToday).toList();
  }
}
