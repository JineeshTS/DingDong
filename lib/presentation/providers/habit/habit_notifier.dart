import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/habit_entity.dart';
import '../../../domain/usecases/habit/archive_habit_usecase.dart';
import '../../../domain/usecases/habit/calculate_streak_usecase.dart';
import '../../../domain/usecases/habit/check_in_habit_usecase.dart';
import '../../../domain/usecases/habit/create_habit_usecase.dart';
import '../../../domain/usecases/habit/delete_habit_usecase.dart';
import '../../../domain/usecases/habit/get_habit_statistics_usecase.dart';
import '../../../domain/usecases/habit/get_habits_due_today_usecase.dart';
import '../../../domain/usecases/habit/get_habits_usecase.dart';
import '../../../domain/usecases/habit/undo_check_in_usecase.dart';
import '../../../domain/usecases/habit/update_habit_usecase.dart';
import 'habit_state.dart';

/// StateNotifier for managing habit state
///
/// Handles all habit-related operations including:
/// - CRUD operations (Create, Read, Update, Delete)
/// - Habit check-ins and streak tracking
/// - Habit archiving and soft delete
/// - Habit statistics and analytics
/// - Habit filtering by category and frequency
/// - Habit scheduling (daily, weekly, monthly)
/// - Real-time habit updates
///
/// This notifier integrates with all 10 habit use cases
/// and manages the HabitState throughout the application lifecycle.
class HabitNotifier extends StateNotifier<HabitState> {
  // Use cases
  final CreateHabitUseCase _createHabitUseCase;
  final UpdateHabitUseCase _updateHabitUseCase;
  final DeleteHabitUseCase _deleteHabitUseCase;
  final GetHabitsUseCase _getHabitsUseCase;
  final CheckInHabitUseCase _checkInHabitUseCase;
  final UndoCheckInUseCase _undoCheckInUseCase;
  final CalculateStreakUseCase _calculateStreakUseCase;
  final GetHabitsDueTodayUseCase _getHabitsDueTodayUseCase;
  final GetHabitStatisticsUseCase _getHabitStatisticsUseCase;
  final ArchiveHabitUseCase _archiveHabitUseCase;

  HabitNotifier({
    required CreateHabitUseCase createHabitUseCase,
    required UpdateHabitUseCase updateHabitUseCase,
    required DeleteHabitUseCase deleteHabitUseCase,
    required GetHabitsUseCase getHabitsUseCase,
    required CheckInHabitUseCase checkInHabitUseCase,
    required UndoCheckInUseCase undoCheckInUseCase,
    required CalculateStreakUseCase calculateStreakUseCase,
    required GetHabitsDueTodayUseCase getHabitsDueTodayUseCase,
    required GetHabitStatisticsUseCase getHabitStatisticsUseCase,
    required ArchiveHabitUseCase archiveHabitUseCase,
  })  : _createHabitUseCase = createHabitUseCase,
        _updateHabitUseCase = updateHabitUseCase,
        _deleteHabitUseCase = deleteHabitUseCase,
        _getHabitsUseCase = getHabitsUseCase,
        _checkInHabitUseCase = checkInHabitUseCase,
        _undoCheckInUseCase = undoCheckInUseCase,
        _calculateStreakUseCase = calculateStreakUseCase,
        _getHabitsDueTodayUseCase = getHabitsDueTodayUseCase,
        _getHabitStatisticsUseCase = getHabitStatisticsUseCase,
        _archiveHabitUseCase = archiveHabitUseCase,
        super(const HabitState());

  // ============================================================================
  // CRUD Operations
  // ============================================================================

  /// Create a new habit with frequency settings
  ///
  /// Parameters:
  /// - [habit]: Habit entity to create with frequency (daily/weekly/monthly/custom)
  ///
  /// Updates the relevant habit lists after creation
  Future<void> createHabit(HabitEntity habit) async {
    state = state.copyWith(isCreating: true, operationError: null);

    final result = await _createHabitUseCase(habit);

    result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          operationError: failure,
        );
      },
      (createdHabit) {
        // Add to all habits
        state = state.copyWith(
          isCreating: false,
          allHabits: [createdHabit, ...state.allHabits],
          operationError: null,
        );

        // Add to active habits if not archived
        if (!createdHabit.isArchived) {
          state = state.copyWith(
            activeHabits: [createdHabit, ...state.activeHabits],
          );
        }

        // Add to category map
        _addToCategory(createdHabit);

        // Refresh relevant lists
        _refreshRelevantLists();
      },
    );
  }

  /// Update an existing habit
  ///
  /// Parameters:
  /// - [habit]: Updated habit entity
  ///
  /// Updates the habit in all relevant lists
  Future<void> updateHabit(HabitEntity habit) async {
    state = state.copyWith(isUpdating: true, operationError: null);

    final result = await _updateHabitUseCase(habit);

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          operationError: failure,
        );
      },
      (updatedHabit) {
        // Update in all lists
        state = state.copyWith(
          isUpdating: false,
          allHabits: state.allHabits
              .map((h) => h.id == updatedHabit.id ? updatedHabit : h)
              .toList(),
          activeHabits: state.activeHabits
              .map((h) => h.id == updatedHabit.id ? updatedHabit : h)
              .toList(),
          archivedHabits: state.archivedHabits
              .map((h) => h.id == updatedHabit.id ? updatedHabit : h)
              .toList(),
          habitsDueToday: state.habitsDueToday
              .map((h) => h.id == updatedHabit.id ? updatedHabit : h)
              .toList(),
          selectedHabit:
              state.selectedHabit?.id == updatedHabit.id ? updatedHabit : state.selectedHabit,
          operationError: null,
        );

        // Update category map
        _updateCategoryMap();

        // Refresh relevant lists
        _refreshRelevantLists();
      },
    );
  }

  /// Delete a habit (soft delete)
  ///
  /// Parameters:
  /// - [habitId]: ID of habit to delete
  ///
  /// Removes the habit from active lists (soft delete)
  Future<void> deleteHabit(String habitId) async {
    state = state.copyWith(isDeleting: true, operationError: null);

    final result = await _deleteHabitUseCase(habitId);

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
          allHabits: state.allHabits.where((h) => h.id != habitId).toList(),
          activeHabits: state.activeHabits.where((h) => h.id != habitId).toList(),
          habitsDueToday:
              state.habitsDueToday.where((h) => h.id != habitId).toList(),
          selectedHabit: state.selectedHabit?.id == habitId ? null : state.selectedHabit,
          operationError: null,
        );

        // Update category map
        _updateCategoryMap();
      },
    );
  }

  /// Get all habits with optional category filter
  ///
  /// Parameters:
  /// - [userId]: ID of the user
  /// - [category]: Optional category filter
  /// - [includeArchived]: Whether to include archived habits
  ///
  /// Loads habits and updates state
  Future<void> getHabits({
    required String userId,
    HabitCategory? category,
    bool includeArchived = false,
  }) async {
    state = state.copyWith(isLoadingAll: true, error: null);

    final result = await _getHabitsUseCase(
      userId: userId,
      category: category,
      includeArchived: includeArchived,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingAll: false,
          error: failure,
        );
      },
      (habits) {
        final activeHabits = habits.where((h) => !h.isArchived && !h.isDeleted).toList();
        final archivedHabits = habits.where((h) => h.isArchived && !h.isDeleted).toList();

        state = state.copyWith(
          isLoadingAll: false,
          allHabits: habits,
          activeHabits: activeHabits,
          archivedHabits: archivedHabits,
          error: null,
          lastRefreshAll: DateTime.now(),
        );

        // Build category map
        _updateCategoryMap();

        // Load streaks for all habits
        _loadStreaks(activeHabits);
      },
    );
  }

  // ============================================================================
  // Check-in Operations
  // ============================================================================

  /// Check in a habit for today (mark as done)
  ///
  /// Parameters:
  /// - [habitId]: ID of habit to check in
  /// - [date]: Optional date for the check-in (defaults to today)
  /// - [note]: Optional note about the check-in
  /// - [count]: Number of times completed (default: 1)
  ///
  /// Updates streak and statistics
  Future<void> checkInHabit({
    required String habitId,
    DateTime? date,
    String? note,
    int count = 1,
  }) async {
    state = state.copyWith(isCheckingIn: true, operationError: null);

    final result = await _checkInHabitUseCase(
      habitId: habitId,
      date: date,
      note: note,
      count: count,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isCheckingIn: false,
          operationError: failure,
        );
      },
      (updatedHabit) {
        // Update in all lists
        state = state.copyWith(
          isCheckingIn: false,
          allHabits: state.allHabits
              .map((h) => h.id == updatedHabit.id ? updatedHabit : h)
              .toList(),
          activeHabits: state.activeHabits
              .map((h) => h.id == updatedHabit.id ? updatedHabit : h)
              .toList(),
          habitsDueToday: state.habitsDueToday
              .map((h) => h.id == updatedHabit.id ? updatedHabit : h)
              .toList(),
          selectedHabit:
              state.selectedHabit?.id == updatedHabit.id ? updatedHabit : state.selectedHabit,
          operationError: null,
        );

        // Update streak
        _calculateAndUpdateStreak(habitId);
      },
    );
  }

  /// Undo a check-in for a habit
  ///
  /// Parameters:
  /// - [habitId]: ID of habit to undo check-in
  /// - [date]: Optional date of the check-in to undo (defaults to today)
  ///
  /// Removes the check-in and recalculates streak
  Future<void> undoCheckIn({
    required String habitId,
    DateTime? date,
  }) async {
    state = state.copyWith(isUndoingCheckIn: true, operationError: null);

    final result = await _undoCheckInUseCase(
      habitId: habitId,
      date: date,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isUndoingCheckIn: false,
          operationError: failure,
        );
      },
      (updatedHabit) {
        // Update in all lists
        state = state.copyWith(
          isUndoingCheckIn: false,
          allHabits: state.allHabits
              .map((h) => h.id == updatedHabit.id ? updatedHabit : h)
              .toList(),
          activeHabits: state.activeHabits
              .map((h) => h.id == updatedHabit.id ? updatedHabit : h)
              .toList(),
          habitsDueToday: state.habitsDueToday
              .map((h) => h.id == updatedHabit.id ? updatedHabit : h)
              .toList(),
          selectedHabit:
              state.selectedHabit?.id == updatedHabit.id ? updatedHabit : state.selectedHabit,
          operationError: null,
        );

        // Update streak
        _calculateAndUpdateStreak(habitId);
      },
    );
  }

  // ============================================================================
  // Streak Operations
  // ============================================================================

  /// Calculate current streak for a habit
  ///
  /// Parameters:
  /// - [habitId]: ID of habit to calculate streak for
  ///
  /// Updates the habit streaks map
  Future<void> calculateStreak(String habitId) async {
    final result = await _calculateStreakUseCase(habitId);

    result.fold(
      (failure) {
        // Silently handle errors for streak calculation
      },
      (streak) {
        state = state.copyWith(
          habitStreaks: {
            ...state.habitStreaks,
            habitId: streak,
          },
        );
      },
    );
  }

  // ============================================================================
  // Habit Query Operations
  // ============================================================================

  /// Load habits due today
  ///
  /// Fetches habits that are due based on their frequency
  Future<void> loadHabitsDueToday({required String userId}) async {
    state = state.copyWith(isLoadingToday: true, todayError: null);

    final result = await _getHabitsDueTodayUseCase(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingToday: false,
          todayError: failure,
        );
      },
      (habits) {
        state = state.copyWith(
          isLoadingToday: false,
          habitsDueToday: habits,
          todayError: null,
          lastRefreshToday: DateTime.now(),
        );

        // Load streaks for today's habits
        _loadStreaks(habits);
      },
    );
  }

  /// Load statistics for a specific habit
  ///
  /// Parameters:
  /// - [habitId]: ID of habit to get statistics for
  /// - [startDate]: Optional start date for statistics period
  /// - [endDate]: Optional end date for statistics period
  ///
  /// Updates the habit statistics map
  Future<void> loadHabitStatistics({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoadingStatistics: true, statisticsError: null);

    final result = await _getHabitStatisticsUseCase(
      habitId: habitId,
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingStatistics: false,
          statisticsError: failure,
        );
      },
      (statistics) {
        state = state.copyWith(
          isLoadingStatistics: false,
          habitStatistics: {
            ...state.habitStatistics,
            habitId: statistics,
          },
          statisticsError: null,
          lastRefreshStatistics: DateTime.now(),
        );
      },
    );
  }

  // ============================================================================
  // Archiving Operations
  // ============================================================================

  /// Archive a habit
  ///
  /// Parameters:
  /// - [habitId]: ID of habit to archive
  ///
  /// Moves habit from active to archived
  Future<void> archiveHabit(String habitId) async {
    state = state.copyWith(isArchiving: true, operationError: null);

    final result = await _archiveHabitUseCase(habitId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isArchiving: false,
          operationError: failure,
        );
      },
      (archivedHabit) {
        // Remove from active, add to archived
        state = state.copyWith(
          isArchiving: false,
          allHabits: state.allHabits
              .map((h) => h.id == habitId ? archivedHabit : h)
              .toList(),
          activeHabits: state.activeHabits.where((h) => h.id != habitId).toList(),
          archivedHabits: [archivedHabit, ...state.archivedHabits],
          habitsDueToday:
              state.habitsDueToday.where((h) => h.id != habitId).toList(),
          selectedHabit:
              state.selectedHabit?.id == habitId ? null : state.selectedHabit,
          operationError: null,
        );

        // Update category map
        _updateCategoryMap();
      },
    );
  }

  // ============================================================================
  // Filter and Search Operations
  // ============================================================================

  /// Filter habits by category
  ///
  /// Parameters:
  /// - [category]: Category to filter by
  ///
  /// Updates the current category filter
  void filterByCategory(HabitCategory? category) {
    state = state.copyWith(currentCategoryFilter: category);
  }

  /// Filter habits by frequency
  ///
  /// Parameters:
  /// - [frequency]: Frequency to filter by
  ///
  /// Updates the current frequency filter
  void filterByFrequency(HabitFrequency? frequency) {
    state = state.copyWith(currentFrequencyFilter: frequency);
  }

  /// Search habits by query
  ///
  /// Parameters:
  /// - [query]: Search query
  ///
  /// Updates search results
  void searchHabits(String query) {
    state = state.copyWith(currentSearchQuery: query);

    if (query.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    final results = state.activeHabits
        .where((h) =>
            h.name.toLowerCase().contains(query.toLowerCase()) ||
            (h.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();

    state = state.copyWith(searchResults: results);
  }

  // ============================================================================
  // Selection Operations
  // ============================================================================

  /// Select a habit to view details
  ///
  /// Parameters:
  /// - [habit]: Habit to select
  ///
  /// Sets the selected habit and loads its statistics
  void selectHabit(HabitEntity habit) {
    state = state.copyWith(selectedHabit: habit);
    loadHabitStatistics(habitId: habit.id);
  }

  /// Clear the selected habit
  void clearSelectedHabit() {
    state = state.copyWith(selectedHabit: null);
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  /// Add a habit to the category map
  void _addToCategory(HabitEntity habit) {
    final habitsByCategory = Map<HabitCategory, List<HabitEntity>>.from(state.habitsByCategory);
    final habitsInCategory = habitsByCategory[habit.category] ?? [];
    habitsByCategory[habit.category] = [habit, ...habitsInCategory];
    state = state.copyWith(habitsByCategory: habitsByCategory);
  }

  /// Update the category map based on all habits
  void _updateCategoryMap() {
    final habitsByCategory = <HabitCategory, List<HabitEntity>>{};

    for (final habit in state.activeHabits) {
      if (habitsByCategory.containsKey(habit.category)) {
        habitsByCategory[habit.category]!.add(habit);
      } else {
        habitsByCategory[habit.category] = [habit];
      }
    }

    state = state.copyWith(habitsByCategory: habitsByCategory);
  }

  /// Load streaks for a list of habits
  void _loadStreaks(List<HabitEntity> habits) {
    for (final habit in habits) {
      _calculateAndUpdateStreak(habit.id);
    }
  }

  /// Calculate and update streak for a habit
  void _calculateAndUpdateStreak(String habitId) async {
    final result = await _calculateStreakUseCase(habitId);
    result.fold(
      (_) {
        // Silently handle errors
      },
      (streak) {
        state = state.copyWith(
          habitStreaks: {
            ...state.habitStreaks,
            habitId: streak,
          },
        );
      },
    );
  }

  /// Refresh relevant lists based on current filters
  void _refreshRelevantLists() {
    // This is called after operations to ensure UI stays in sync
    // In a real app, you might implement smart refresh logic here
  }

  /// Clear all errors
  void clearErrors() {
    state = state.copyWith(
      error: null,
      todayError: null,
      categoryError: null,
      statisticsError: null,
      operationError: null,
    );
  }
}
