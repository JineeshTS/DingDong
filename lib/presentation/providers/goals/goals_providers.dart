import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'goals_notifier.dart';
import 'goals_state.dart';

// ====================
// Shared Preferences Provider
// ====================

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

// ====================
// State Notifier Provider
// ====================

/// Goals Notifier Provider
///
/// Main provider for goals state management
final goalsNotifierProvider =
    StateNotifierProvider<GoalsNotifier, GoalsState>(
  (ref) {
    // TODO: Get actual user ID from auth provider
    const userId = 'user_123';

    return GoalsNotifier(
      userId: userId,
      prefs: ref.watch(sharedPreferencesProvider),
    );
  },
);

// ====================
// Derived State Providers
// ====================

/// Goals Provider
final goalsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.goals;
});

/// Filtered Goals Provider
final filteredGoalsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.filteredGoals;
});

/// Active Goals Provider
final activeGoalsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.activeGoalsList;
});

/// Completed Goals Provider
final completedGoalsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.completedGoalsList;
});

/// Archived Goals Provider
final archivedGoalsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.archivedGoalsList;
});

/// Selected Goal Provider
final selectedGoalProvider = Provider.autoDispose((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.selectedGoal;
});

/// Current Filter Provider
final currentGoalFilterProvider = Provider.autoDispose<GoalFilter>((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.filter;
});

/// Filter Category Provider
final filterGoalCategoryProvider = Provider.autoDispose((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.filterCategory;
});

/// Total Goals Provider
final totalGoalsProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.totalGoals;
});

/// Active Goals Count Provider
final activeGoalsCountProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.activeGoals;
});

/// Completed Goals Count Provider
final completedGoalsCountProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.completedGoals;
});

/// Overall Progress Provider
final overallProgressProvider = Provider.autoDispose<double>((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.overallProgress;
});

/// Completion Rate Provider
final goalsCompletionRateProvider = Provider.autoDispose<double>((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.completionRate;
});

/// Is Loading Provider
final goalsLoadingProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.isLoading;
});

/// Error Provider
final goalsErrorProvider = Provider.autoDispose<String?>((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.error;
});

/// Goals By Category Provider
final goalsByCategoryProvider =
    Provider.autoDispose.family((ref, GoalCategory category) {
  final state = ref.watch(goalsNotifierProvider);
  return state.getGoalsByCategory(category);
});

/// Has Active Filters Provider
final hasActiveGoalFiltersProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(goalsNotifierProvider);
  return state.filter != GoalFilter.all || state.filterCategory != null;
});

/// Goals With Deadlines Provider
final goalsWithDeadlinesProvider = Provider.autoDispose((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.where((g) => g.deadline != null && !g.isCompleted).toList()
    ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
});

/// Overdue Goals Provider
final overdueGoalsProvider = Provider.autoDispose((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.where((g) => g.isOverdue).toList();
});

/// SMART Goals Provider
final smartGoalsProvider = Provider.autoDispose((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.where((g) => g.isSmart).toList();
});
