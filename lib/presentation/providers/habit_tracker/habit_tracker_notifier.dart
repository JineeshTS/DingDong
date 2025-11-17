import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/habit_entity.dart';
import '../../../domain/usecases/habit/create_habit_usecase.dart';
import '../../../domain/usecases/habit/update_habit_usecase.dart';
import '../../../domain/usecases/habit/delete_habit_usecase.dart';
import '../../../domain/usecases/habit/archive_habit_usecase.dart';
import '../../../domain/usecases/habit/check_in_habit_usecase.dart';
import '../../../domain/usecases/habit/undo_check_in_usecase.dart';
import '../../../domain/usecases/habit/get_habits_usecase.dart';
import '../../../domain/usecases/habit/get_habits_due_today_usecase.dart';
import '../../../domain/usecases/habit/get_habit_statistics_usecase.dart';
import 'habit_tracker_state.dart';

/// Habit Tracker Notifier
///
/// Manages habit tracking logic including:
/// - CRUD operations for habits
/// - Check-in/undo check-in
/// - Streak calculations
/// - Statistics and analytics
/// - Filtering and views
class HabitTrackerNotifier extends StateNotifier<HabitTrackerState> {
  final CreateHabitUseCase _createHabit;
  final UpdateHabitUseCase _updateHabit;
  final DeleteHabitUseCase _deleteHabit;
  final ArchiveHabitUseCase _archiveHabit;
  final CheckInHabitUseCase _checkInHabit;
  final UndoCheckInUseCase _undoCheckIn;
  final GetHabitsUseCase _getHabits;
  final GetHabitsDueTodayUseCase _getHabitsDueToday;
  final GetHabitStatisticsUseCase _getHabitStatistics;

  final String _userId;

  HabitTrackerNotifier({
    required String userId,
    required CreateHabitUseCase createHabit,
    required UpdateHabitUseCase updateHabit,
    required DeleteHabitUseCase deleteHabit,
    required ArchiveHabitUseCase archiveHabit,
    required CheckInHabitUseCase checkInHabit,
    required UndoCheckInUseCase undoCheckIn,
    required GetHabitsUseCase getHabits,
    required GetHabitsDueTodayUseCase getHabitsDueToday,
    required GetHabitStatisticsUseCase getHabitStatistics,
  })  : _userId = userId,
        _createHabit = createHabit,
        _updateHabit = updateHabit,
        _deleteHabit = deleteHabit,
        _archiveHabit = archiveHabit,
        _checkInHabit = checkInHabit,
        _undoCheckIn = undoCheckIn,
        _getHabits = getHabits,
        _getHabitsDueToday = getHabitsDueToday,
        _getHabitStatistics = getHabitStatistics,
        super(const HabitTrackerState()) {
    loadHabits();
  }

  /// Load all habits
  Future<void> loadHabits() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getHabits(_userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(failure),
        );
      },
      (habits) async {
        // Load today's habits
        final todayResult = await _getHabitsDueToday(_userId);

        await todayResult.fold(
          (failure) {
            state = state.copyWith(
              habits: habits,
              isLoading: false,
            );
          },
          (todayHabits) async {
            // Load statistics
            await _loadStatistics(habits);

            state = state.copyWith(
              habits: habits,
              todayHabits: todayHabits,
              isLoading: false,
              error: null,
            );
          },
        );
      },
    );
  }

  /// Load statistics
  Future<void> _loadStatistics(List<HabitEntity> habits) async {
    final result = await _getHabitStatistics(_userId);

    result.fold(
      (failure) => null,
      (stats) {
        state = state.copyWith(
          totalHabits: stats['totalHabits'] as int? ?? habits.length,
          completedToday: stats['completedToday'] as int? ?? 0,
          todayCompletionRate: stats['completionRate'] as double? ?? 0.0,
          activeStreaks: stats['activeStreaks'] as int? ?? 0,
          longestStreak: stats['longestStreak'] as int? ?? 0,
        );
      },
    );
  }

  /// Create new habit
  Future<void> createHabit(HabitEntity habit) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createHabit(habit);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(failure),
        );
      },
      (createdHabit) {
        final updatedHabits = [...state.habits, createdHabit];
        state = state.copyWith(
          habits: updatedHabits,
          isLoading: false,
        );
        _recalculateStats();
      },
    );
  }

  /// Create habit from template
  Future<void> createHabitFromTemplate(HabitTemplate template) async {
    final habit = template.toHabit(
      const Uuid().v4(),
      _userId,
    );
    await createHabit(habit);
  }

  /// Update habit
  Future<void> updateHabit(HabitEntity habit) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _updateHabit(habit);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(failure),
        );
      },
      (updatedHabit) {
        final updatedHabits = state.habits.map((h) {
          return h.id == updatedHabit.id ? updatedHabit : h;
        }).toList();

        state = state.copyWith(
          habits: updatedHabits,
          selectedHabit: state.selectedHabit?.id == updatedHabit.id
              ? updatedHabit
              : state.selectedHabit,
          isLoading: false,
        );
        _recalculateStats();
      },
    );
  }

  /// Delete habit
  Future<void> deleteHabit(String habitId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _deleteHabit(habitId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(failure),
        );
      },
      (_) {
        final updatedHabits = state.habits.where((h) => h.id != habitId).toList();
        state = state.copyWith(
          habits: updatedHabits,
          selectedHabit:
              state.selectedHabit?.id == habitId ? null : state.selectedHabit,
          isLoading: false,
        );
        _recalculateStats();
      },
    );
  }

  /// Archive/Unarchive habit
  Future<void> toggleArchiveHabit(String habitId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _archiveHabit(habitId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(failure),
        );
      },
      (updatedHabit) {
        final updatedHabits = state.habits.map((h) {
          return h.id == updatedHabit.id ? updatedHabit : h;
        }).toList();

        state = state.copyWith(
          habits: updatedHabits,
          isLoading: false,
        );
        _recalculateStats();
      },
    );
  }

  /// Check in habit
  Future<void> checkInHabit(String habitId, {String? note, int count = 1}) async {
    state = state.copyWith(isCheckingIn: true, error: null);

    final checkIn = HabitCheckIn(
      id: const Uuid().v4(),
      checkInDate: DateTime.now(),
      note: note,
      count: count,
    );

    final result = await _checkInHabit(habitId, checkIn);

    result.fold(
      (failure) {
        state = state.copyWith(
          isCheckingIn: false,
          error: _getErrorMessage(failure),
        );
      },
      (updatedHabit) {
        final updatedHabits = state.habits.map((h) {
          return h.id == updatedHabit.id ? updatedHabit : h;
        }).toList();

        state = state.copyWith(
          habits: updatedHabits,
          selectedHabit: state.selectedHabit?.id == updatedHabit.id
              ? updatedHabit
              : state.selectedHabit,
          isCheckingIn: false,
        );
        _recalculateStats();
      },
    );
  }

  /// Undo check-in
  Future<void> undoCheckInHabit(String habitId, String checkInId) async {
    state = state.copyWith(isCheckingIn: true, error: null);

    final result = await _undoCheckIn(habitId, checkInId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isCheckingIn: false,
          error: _getErrorMessage(failure),
        );
      },
      (updatedHabit) {
        final updatedHabits = state.habits.map((h) {
          return h.id == updatedHabit.id ? updatedHabit : h;
        }).toList();

        state = state.copyWith(
          habits: updatedHabits,
          selectedHabit: state.selectedHabit?.id == updatedHabit.id
              ? updatedHabit
              : state.selectedHabit,
          isCheckingIn: false,
        );
        _recalculateStats();
      },
    );
  }

  /// Select habit for detail view
  void selectHabit(HabitEntity? habit) {
    state = state.copyWith(selectedHabit: habit);
  }

  /// Change view mode
  void changeViewMode(HabitViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// Toggle show archived
  void toggleShowArchived() {
    state = state.copyWith(showArchived: !state.showArchived);
  }

  /// Filter by category
  void filterByCategory(HabitCategory? category) {
    state = state.copyWith(filterCategory: category);
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(
      filterCategory: null,
      showArchived: false,
    );
  }

  /// Recalculate statistics
  void _recalculateStats() {
    final activeHabits = state.habits.where((h) => !h.isArchived).toList();
    final dueToday = state.habitsDueToday;
    final completedToday = dueToday.where((h) => h.isCompletedToday).length;
    final completionRate = dueToday.isEmpty
        ? 0.0
        : (completedToday / dueToday.length) * 100;

    final activeStreaks =
        activeHabits.where((h) => h.currentStreak > 0).length;
    final longestStreak = activeHabits.isEmpty
        ? 0
        : activeHabits
            .map((h) => h.longestStreak)
            .reduce((a, b) => a > b ? a : b);

    state = state.copyWith(
      totalHabits: activeHabits.length,
      completedToday: completedToday,
      todayCompletionRate: completionRate,
      activeStreaks: activeStreaks,
      longestStreak: longestStreak,
    );
  }

  /// Get error message from failure
  String _getErrorMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else if (failure is NotFoundFailure) {
      return 'Habit not found.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }
}
