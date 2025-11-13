import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/habit/create_habit_usecase.dart';
import '../../../domain/usecases/habit/update_habit_usecase.dart';
import '../../../domain/usecases/habit/delete_habit_usecase.dart';
import '../../../domain/usecases/habit/archive_habit_usecase.dart';
import '../../../domain/usecases/habit/check_in_habit_usecase.dart';
import '../../../domain/usecases/habit/undo_check_in_usecase.dart';
import '../../../domain/usecases/habit/get_habits_usecase.dart';
import '../../../domain/usecases/habit/get_habits_due_today_usecase.dart';
import '../../../domain/usecases/habit/get_habit_statistics_usecase.dart';
import '../../repositories_providers.dart';
import 'habit_tracker_notifier.dart';
import 'habit_tracker_state.dart';

// ====================
// Use Case Providers
// ====================

final createHabitUseCaseProvider = Provider<CreateHabitUseCase>(
  (ref) => CreateHabitUseCase(ref.watch(habitRepositoryProvider)),
);

final updateHabitUseCaseProvider = Provider<UpdateHabitUseCase>(
  (ref) => UpdateHabitUseCase(ref.watch(habitRepositoryProvider)),
);

final deleteHabitUseCaseProvider = Provider<DeleteHabitUseCase>(
  (ref) => DeleteHabitUseCase(ref.watch(habitRepositoryProvider)),
);

final archiveHabitUseCaseProvider = Provider<ArchiveHabitUseCase>(
  (ref) => ArchiveHabitUseCase(ref.watch(habitRepositoryProvider)),
);

final checkInHabitUseCaseProvider = Provider<CheckInHabitUseCase>(
  (ref) => CheckInHabitUseCase(ref.watch(habitRepositoryProvider)),
);

final undoCheckInUseCaseProvider = Provider<UndoCheckInUseCase>(
  (ref) => UndoCheckInUseCase(ref.watch(habitRepositoryProvider)),
);

final getHabitsUseCaseProvider = Provider<GetHabitsUseCase>(
  (ref) => GetHabitsUseCase(ref.watch(habitRepositoryProvider)),
);

final getHabitsDueTodayUseCaseProvider = Provider<GetHabitsDueTodayUseCase>(
  (ref) => GetHabitsDueTodayUseCase(ref.watch(habitRepositoryProvider)),
);

final getHabitStatisticsUseCaseProvider = Provider<GetHabitStatisticsUseCase>(
  (ref) => GetHabitStatisticsUseCase(ref.watch(habitRepositoryProvider)),
);

// ====================
// State Notifier Provider
// ====================

/// Habit Tracker Notifier Provider
///
/// Main provider for habit tracking state management
final habitTrackerNotifierProvider =
    StateNotifierProvider<HabitTrackerNotifier, HabitTrackerState>(
  (ref) {
    // TODO: Get actual user ID from auth provider
    const userId = 'user_123';

    return HabitTrackerNotifier(
      userId: userId,
      createHabit: ref.watch(createHabitUseCaseProvider),
      updateHabit: ref.watch(updateHabitUseCaseProvider),
      deleteHabit: ref.watch(deleteHabitUseCaseProvider),
      archiveHabit: ref.watch(archiveHabitUseCaseProvider),
      checkInHabit: ref.watch(checkInHabitUseCaseProvider),
      undoCheckIn: ref.watch(undoCheckInUseCaseProvider),
      getHabits: ref.watch(getHabitsUseCaseProvider),
      getHabitsDueToday: ref.watch(getHabitsDueTodayUseCaseProvider),
      getHabitStatistics: ref.watch(getHabitStatisticsUseCaseProvider),
    );
  },
);

// ====================
// Derived State Providers
// ====================

/// Habits Provider
final habitsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.habits;
});

/// Active Habits Provider
final activeHabitsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.activeHabits;
});

/// Archived Habits Provider
final archivedHabitsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.archivedHabits;
});

/// Today's Habits Provider
final todayHabitsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.todayHabits;
});

/// Habits Due Today Provider
final habitsDueTodayProvider = Provider.autoDispose((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.habitsDueToday;
});

/// Completed Habits Today Provider
final completedHabitsTodayProvider = Provider.autoDispose((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.completedHabitsToday;
});

/// Pending Habits Today Provider
final pendingHabitsTodayProvider = Provider.autoDispose((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.pendingHabitsToday;
});

/// Habits With Streaks Provider
final habitsWithStreaksProvider = Provider.autoDispose((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.habitsWithStreaks;
});

/// Selected Habit Provider
final selectedHabitProvider = Provider.autoDispose((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.selectedHabit;
});

/// View Mode Provider
final habitViewModeProvider = Provider.autoDispose<HabitViewMode>((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.viewMode;
});

/// Show Archived Provider
final showArchivedProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.showArchived;
});

/// Filter Category Provider
final filterCategoryProvider = Provider.autoDispose((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.filterCategory;
});

/// Total Habits Provider
final totalHabitsProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.totalHabits;
});

/// Completed Today Provider
final completedTodayProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.completedToday;
});

/// Today Completion Rate Provider
final todayCompletionRateProvider = Provider.autoDispose<double>((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.todayCompletionRate;
});

/// Overall Today Completion Rate Provider
final overallTodayCompletionRateProvider = Provider.autoDispose<double>((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.overallTodayCompletionRate;
});

/// Active Streaks Provider
final activeStreaksProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.activeStreaks;
});

/// Longest Streak Provider
final longestStreakProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.longestStreak;
});

/// Is Loading Provider
final habitTrackerLoadingProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.isLoading;
});

/// Is Checking In Provider
final isCheckingInProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.isCheckingIn;
});

/// Error Provider
final habitTrackerErrorProvider = Provider.autoDispose<String?>((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.error;
});

/// Habits By Category Provider
final habitsByCategoryProvider =
    Provider.autoDispose.family((ref, HabitCategory category) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.getHabitsByCategory(category);
});

/// Habits By Frequency Provider
final habitsByFrequencyProvider =
    Provider.autoDispose.family((ref, HabitFrequency frequency) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.getHabitsByFrequency(frequency);
});

/// Has Active Filters Provider
final hasActiveFiltersProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(habitTrackerNotifierProvider);
  return state.filterCategory != null || state.showArchived;
});
