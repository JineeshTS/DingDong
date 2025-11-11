import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
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
import 'habit_notifier.dart';
import 'habit_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================
// These providers expose individual use cases from the DI container.
// They are auto-disposed when no longer needed for optimal memory management.

/// Provider for CreateHabitUseCase
///
/// Handles habit creation with frequency settings (daily/weekly/monthly/custom)
final createHabitProvider = Provider.autoDispose<CreateHabitUseCase>(
  (ref) => sl<CreateHabitUseCase>(),
);

/// Provider for UpdateHabitUseCase
///
/// Handles habit updates
final updateHabitProvider = Provider.autoDispose<UpdateHabitUseCase>(
  (ref) => sl<UpdateHabitUseCase>(),
);

/// Provider for DeleteHabitUseCase
///
/// Handles habit deletion (soft delete)
final deleteHabitProvider = Provider.autoDispose<DeleteHabitUseCase>(
  (ref) => sl<DeleteHabitUseCase>(),
);

/// Provider for GetHabitsUseCase
///
/// Retrieves habits with optional category filter
final getHabitsProvider = Provider.autoDispose<GetHabitsUseCase>(
  (ref) => sl<GetHabitsUseCase>(),
);

/// Provider for CheckInHabitUseCase
///
/// Marks a habit as done for a specific date
final checkInHabitProvider = Provider.autoDispose<CheckInHabitUseCase>(
  (ref) => sl<CheckInHabitUseCase>(),
);

/// Provider for UndoCheckInUseCase
///
/// Removes a check-in for a habit
final undoCheckInProvider = Provider.autoDispose<UndoCheckInUseCase>(
  (ref) => sl<UndoCheckInUseCase>(),
);

/// Provider for CalculateStreakUseCase
///
/// Calculates current and longest streaks for a habit
final calculateStreakProvider = Provider.autoDispose<CalculateStreakUseCase>(
  (ref) => sl<CalculateStreakUseCase>(),
);

/// Provider for GetHabitsDueTodayUseCase
///
/// Retrieves habits that are due today based on frequency
final getHabitsDueTodayProvider = Provider.autoDispose<GetHabitsDueTodayUseCase>(
  (ref) => sl<GetHabitsDueTodayUseCase>(),
);

/// Provider for GetHabitStatisticsUseCase
///
/// Retrieves comprehensive statistics for a habit
final getHabitStatisticsProvider = Provider.autoDispose<GetHabitStatisticsUseCase>(
  (ref) => sl<GetHabitStatisticsUseCase>(),
);

/// Provider for ArchiveHabitUseCase
///
/// Archives a habit (removes from active list)
final archiveHabitProvider = Provider.autoDispose<ArchiveHabitUseCase>(
  (ref) => sl<ArchiveHabitUseCase>(),
);

// ============================================================================
// Habit State Notifier Provider
// ============================================================================

/// Main habit state notifier provider
///
/// This is the primary provider for habit state management.
/// It should NOT be auto-disposed as we want to maintain habit
/// state throughout the app lifecycle.
///
/// Usage:
/// ```dart
/// // In a ConsumerWidget
/// final habitState = ref.watch(habitNotifierProvider);
/// final habitNotifier = ref.read(habitNotifierProvider.notifier);
///
/// // Get habits
/// await habitNotifier.getHabits(userId: userId);
///
/// // Check in a habit
/// await habitNotifier.checkInHabit(habitId: habitId);
///
/// // Create a new habit
/// await habitNotifier.createHabit(newHabit);
/// ```
final habitNotifierProvider = StateNotifierProvider<HabitNotifier, HabitState>(
  (ref) {
    return HabitNotifier(
      createHabitUseCase: ref.read(createHabitProvider),
      updateHabitUseCase: ref.read(updateHabitProvider),
      deleteHabitUseCase: ref.read(deleteHabitProvider),
      getHabitsUseCase: ref.read(getHabitsProvider),
      checkInHabitUseCase: ref.read(checkInHabitProvider),
      undoCheckInUseCase: ref.read(undoCheckInProvider),
      calculateStreakUseCase: ref.read(calculateStreakProvider),
      getHabitsDueTodayUseCase: ref.read(getHabitsDueTodayProvider),
      getHabitStatisticsUseCase: ref.read(getHabitStatisticsProvider),
      archiveHabitUseCase: ref.read(archiveHabitProvider),
    );
  },
);

// ============================================================================
// Derived State Providers - Habit Lists
// ============================================================================

/// Provider that exposes active habits
///
/// Returns list of non-archived, non-deleted habits
///
/// Usage:
/// ```dart
/// final activeHabits = ref.watch(activeHabitsProvider);
/// ListView.builder(
///   itemCount: activeHabits.length,
///   itemBuilder: (context, index) => HabitTile(habit: activeHabits[index]),
/// );
/// ```
final activeHabitsProvider = Provider<List<HabitEntity>>((ref) {
  return ref.watch(habitNotifierProvider).activeHabits;
});

/// Provider that exposes archived habits
///
/// Returns list of archived habits
final archivedHabitsProvider = Provider<List<HabitEntity>>((ref) {
  return ref.watch(habitNotifierProvider).archivedHabits;
});

/// Provider that exposes all habits (active and archived)
final allHabitsProvider = Provider<List<HabitEntity>>((ref) {
  return ref.watch(habitNotifierProvider).allHabits;
});

/// Provider that exposes habits due today
///
/// Returns habits that are scheduled for today based on their frequency
final habitsDueTodayProvider = Provider<List<HabitEntity>>((ref) {
  return ref.watch(habitNotifierProvider).habitsDueToday;
});

/// Provider that exposes habits grouped by category
///
/// Usage:
/// ```dart
/// final habitsByCategory = ref.watch(habitsByCategoryProvider);
/// habitsByCategory.forEach((category, habits) {
///   print('${category.name}: ${habits.length} habits');
/// });
/// ```
final habitsByCategoryProvider = Provider<Map<HabitCategory, List<HabitEntity>>>((ref) {
  return ref.watch(habitNotifierProvider).habitsByCategory;
});

/// Provider that exposes search results
final habitSearchResultsProvider = Provider<List<HabitEntity>>((ref) {
  return ref.watch(habitNotifierProvider).searchResults;
});

/// Provider that exposes the selected habit
final selectedHabitProvider = Provider<HabitEntity?>((ref) {
  return ref.watch(habitNotifierProvider).selectedHabit;
});

// ============================================================================
// Derived State Providers - Habit Statistics
// ============================================================================

/// Provider that exposes habit streaks
///
/// Returns map of habitId -> currentStreak
final habitStreaksProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(habitNotifierProvider).habitStreaks;
});

/// Provider that exposes habit statistics
///
/// Returns map of habitId -> statistics map
final habitStatisticsProvider = Provider<Map<String, Map<String, dynamic>>>((ref) {
  return ref.watch(habitNotifierProvider).habitStatistics;
});

/// Provider that exposes statistics for a specific habit
///
/// Parameters: habitId
///
/// Usage:
/// ```dart
/// final stats = ref.watch(habitStatisticsByIdProvider('habit-123'));
/// if (stats != null) {
///   print('Completion rate: ${stats['completionRate']}%');
///   print('Current streak: ${stats['currentStreak']} days');
/// }
/// ```
final habitStatisticsByIdProvider =
    Provider.family<Map<String, dynamic>?, String>((ref, habitId) {
  final stats = ref.watch(habitStatisticsProvider);
  return stats[habitId];
});

/// Provider that exposes current streak for a specific habit
final habitStreakByIdProvider = Provider.family<int, String>((ref, habitId) {
  final streaks = ref.watch(habitStreaksProvider);
  return streaks[habitId] ?? 0;
});

// ============================================================================
// Derived State Providers - Habit Counts
// ============================================================================

/// Provider that exposes count of active habits
final activeHabitCountProvider = Provider<int>((ref) {
  return ref.watch(habitNotifierProvider).activeHabitCount;
});

/// Provider that exposes count of archived habits
final archivedHabitCountProvider = Provider<int>((ref) {
  return ref.watch(habitNotifierProvider).archivedHabitCount;
});

/// Provider that exposes count of total habits
final totalHabitCountProvider = Provider<int>((ref) {
  return ref.watch(habitNotifierProvider).totalHabitCount;
});

/// Provider that exposes count of habits due today
final habitsDueTodayCountProvider = Provider<int>((ref) {
  return ref.watch(habitNotifierProvider).habitsDueTodayCount;
});

/// Provider that exposes count of completed today habits
final completedTodayCountProvider = Provider<int>((ref) {
  final state = ref.watch(habitNotifierProvider);
  return state.getCompletedTodayHabits().length;
});

/// Provider that exposes count of incomplete today habits
final incompleteTodayCountProvider = Provider<int>((ref) {
  final state = ref.watch(habitNotifierProvider);
  return state.getIncompleteTodayHabits().length;
});

// ============================================================================
// Derived State Providers - Habit Filters
// ============================================================================

/// Provider that exposes current category filter
final currentCategoryFilterProvider = Provider<HabitCategory?>((ref) {
  return ref.watch(habitNotifierProvider).currentCategoryFilter;
});

/// Provider that exposes current frequency filter
final currentFrequencyFilterProvider = Provider<HabitFrequency?>((ref) {
  return ref.watch(habitNotifierProvider).currentFrequencyFilter;
});

/// Provider that exposes current search query
final currentSearchQueryProvider = Provider<String?>((ref) {
  return ref.watch(habitNotifierProvider).currentSearchQuery;
});

/// Provider that exposes habits filtered by category
///
/// Parameters: category
final habitsByCategoryFilterProvider =
    Provider.family<List<HabitEntity>, HabitCategory>((ref, category) {
  final habits = ref.watch(activeHabitsProvider);
  return habits.where((h) => h.category == category).toList();
});

/// Provider that exposes habits filtered by frequency
///
/// Parameters: frequency
final habitsByFrequencyProvider =
    Provider.family<List<HabitEntity>, HabitFrequency>((ref, frequency) {
  final habits = ref.watch(activeHabitsProvider);
  return habits.where((h) => h.frequency == frequency).toList();
});

// ============================================================================
// Derived State Providers - Loading States
// ============================================================================

/// Provider that exposes loading state for all habits
final isLoadingAllProvider = Provider<bool>((ref) {
  return ref.watch(habitNotifierProvider).isLoadingAll;
});

/// Provider that exposes loading state for today's habits
final isLoadingTodayProvider = Provider<bool>((ref) {
  return ref.watch(habitNotifierProvider).isLoadingToday;
});

/// Provider that exposes loading state for statistics
final isLoadingStatisticsProvider = Provider<bool>((ref) {
  return ref.watch(habitNotifierProvider).isLoadingStatistics;
});

/// Provider that indicates if any habit list is loading
final isAnyHabitLoadingProvider = Provider<bool>((ref) {
  return ref.watch(habitNotifierProvider).isAnyLoading;
});

/// Provider that indicates if any habit operation is in progress
final isAnyHabitOperationInProgressProvider = Provider<bool>((ref) {
  return ref.watch(habitNotifierProvider).isAnyOperationInProgress;
});

/// Provider that exposes creating state
final isCreatingHabitProvider = Provider<bool>((ref) {
  return ref.watch(habitNotifierProvider).isCreating;
});

/// Provider that exposes updating state
final isUpdatingHabitProvider = Provider<bool>((ref) {
  return ref.watch(habitNotifierProvider).isUpdating;
});

/// Provider that exposes checking in state
final isCheckingInHabitProvider = Provider<bool>((ref) {
  return ref.watch(habitNotifierProvider).isCheckingIn;
});

// ============================================================================
// Derived State Providers - Error States
// ============================================================================

/// Provider that exposes operation errors
final habitOperationErrorProvider = Provider<String?>((ref) {
  final error = ref.watch(habitNotifierProvider).operationError;
  return error?.message;
});

/// Provider that exposes today habits errors
final habitTodayErrorProvider = Provider<String?>((ref) {
  final error = ref.watch(habitNotifierProvider).todayError;
  return error?.message;
});

/// Provider that exposes statistics errors
final habitStatisticsErrorProvider = Provider<String?>((ref) {
  final error = ref.watch(habitNotifierProvider).statisticsError;
  return error?.message;
});

/// Provider that indicates if there are any errors
final hasAnyHabitErrorProvider = Provider<bool>((ref) {
  return ref.watch(habitNotifierProvider).hasAnyError;
});

// ============================================================================
// Derived State Providers - Habit Analytics
// ============================================================================

/// Provider that exposes average completion rate across all habits
///
/// Returns value between 0-100
final averageCompletionRateProvider = Provider<double>((ref) {
  return ref.watch(habitNotifierProvider).getAverageCompletionRate();
});

/// Provider that exposes habits with current streak >= minStreak
///
/// Parameters: minStreak
///
/// Usage:
/// ```dart
/// final longStreakHabits = ref.watch(habitsWithStreakProvider(7));
/// // Shows habits with current streak of 7+ days
/// ```
final habitsWithStreakProvider = Provider.family<List<HabitEntity>, int>((ref, minStreak) {
  return ref.watch(habitNotifierProvider).getHabitsWithStreak(minStreak);
});

/// Provider that exposes completed today habits
final completedTodayHabitsProvider = Provider<List<HabitEntity>>((ref) {
  return ref.watch(habitNotifierProvider).getCompletedTodayHabits();
});

/// Provider that exposes incomplete today habits
final incompleteTodayHabitsProvider = Provider<List<HabitEntity>>((ref) {
  return ref.watch(habitNotifierProvider).getIncompleteTodayHabits();
});

/// Provider that exposes completion percentage for today
///
/// Returns value between 0-100
final todayCompletionPercentageProvider = Provider<double>((ref) {
  final state = ref.watch(habitNotifierProvider);
  final totalToday = state.habitsDueTodayCount;
  if (totalToday == 0) return 0;
  final completedToday = state.getCompletedTodayHabits().length;
  return (completedToday / totalToday) * 100;
});

// ============================================================================
// Derived State Providers - Refresh Needs
// ============================================================================

/// Provider that indicates if all habits need refresh
final needsRefreshAllHabitsProvider = Provider<bool>((ref) {
  return ref.watch(habitNotifierProvider).needsRefreshAll;
});

/// Provider that indicates if today habits need refresh
final needsRefreshTodayHabitsProvider = Provider<bool>((ref) {
  return ref.watch(habitNotifierProvider).needsRefreshToday;
});

/// Provider that indicates if statistics need refresh
final needsRefreshStatisticsProvider = Provider<bool>((ref) {
  return ref.watch(habitNotifierProvider).needsRefreshStatistics;
});

// ============================================================================
// Computed Providers - Complex Queries
// ============================================================================

/// Provider that exposes habits ready to check-in (due today and not completed)
final habitsDueForCheckInProvider = Provider<List<HabitEntity>>((ref) {
  return ref.watch(habitNotifierProvider).getIncompleteTodayHabits();
});

/// Provider that exposes high-priority habits (those with long streaks or due today)
///
/// A habit is considered high-priority if it's due today and not yet completed
final highPriorityHabitsProvider = Provider<List<HabitEntity>>((ref) {
  return ref.watch(habitNotifierProvider).getIncompleteTodayHabits();
});

/// Provider that exposes habit completion trend
///
/// Returns completion rates for the last 7 days if available
final habitCompletionTrendProvider = Provider<List<double>>((ref) {
  final stats = ref.watch(habitStatisticsProvider);
  // This would typically aggregate statistics from multiple habits
  // returning daily completion rates for the past 7 days
  return [];
});

/// Provider that exposes most consistent habits (highest current streaks)
final mostConsistentHabitsProvider = Provider<List<HabitEntity>>((ref) {
  final habits = ref.watch(activeHabitsProvider);
  final sorted = List<HabitEntity>.from(habits)
    ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
  return sorted.take(5).toList();
});

/// Provider that exposes habits at risk (long time since last check-in)
final habitsAtRiskProvider = Provider<List<HabitEntity>>((ref) {
  final habits = ref.watch(activeHabitsProvider);
  final now = DateTime.now();
  return habits.where((h) {
    if (h.lastCheckInDate == null) return true;
    return now.difference(h.lastCheckInDate!).inDays > 1;
  }).toList();
});
