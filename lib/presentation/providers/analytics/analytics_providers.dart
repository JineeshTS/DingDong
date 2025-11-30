import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/usecases/task/get_tasks_usecase.dart';
import '../auth_provider.dart';
import 'analytics_notifier.dart';
import 'analytics_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================

/// Provider for GetTasksUseCase
final getTasksForAnalyticsProvider = Provider.autoDispose<GetTasksUseCase>(
  (ref) => sl<GetTasksUseCase>(),
);

// ============================================================================
// Analytics State Notifier Provider
// ============================================================================

/// Main Analytics state notifier provider
///
/// Manages analytics calculations and statistics.
///
/// Usage:
/// ```dart
/// final analyticsState = ref.watch(analyticsNotifierProvider);
/// final analyticsNotifier = ref.read(analyticsNotifierProvider.notifier);
///
/// // Get statistics
/// final stats = analyticsState.stats;
///
/// // Change period
/// analyticsNotifier.setPeriod(AnalyticsPeriod.month);
/// ```
final analyticsNotifierProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.when(
    data: (user) => user?.id ?? '',
    loading: () => '',
    error: (_, __) => '',
  );

  return AnalyticsNotifier(
    getTasksUseCase: ref.read(getTasksForAnalyticsProvider),
    userId: userId ?? '',
  );
});

// ============================================================================
// Derived State Providers
// ============================================================================

/// Provider for current analytics period
final analyticsPeriodProvider = Provider.autoDispose<AnalyticsPeriod>((ref) {
  final analyticsState = ref.watch(analyticsNotifierProvider);
  return analyticsState.period;
});

/// Provider for analytics statistics
final analyticsStatsProvider = Provider.autoDispose<AnalyticsStats?>((ref) {
  final analyticsState = ref.watch(analyticsNotifierProvider);
  return analyticsState.stats;
});

/// Provider for daily task counts
final dailyTaskCountsProvider =
    Provider.autoDispose<List<DailyTaskCount>>((ref) {
  final analyticsState = ref.watch(analyticsNotifierProvider);
  return analyticsState.dailyTaskCounts;
});

/// Provider for loading state
final isAnalyticsLoadingProvider = Provider.autoDispose<bool>((ref) {
  final analyticsState = ref.watch(analyticsNotifierProvider);
  return analyticsState.isLoading;
});

/// Provider for error message
final analyticsErrorProvider = Provider.autoDispose<String?>((ref) {
  final analyticsState = ref.watch(analyticsNotifierProvider);
  return analyticsState.error;
});

/// Provider for has stats
final hasAnalyticsStatsProvider = Provider.autoDispose<bool>((ref) {
  final analyticsState = ref.watch(analyticsNotifierProvider);
  return analyticsState.hasStats;
});

/// Provider for period label
final analyticsPeriodLabelProvider = Provider.autoDispose<String>((ref) {
  final analyticsState = ref.watch(analyticsNotifierProvider);
  return analyticsState.periodLabel;
});

// ============================================================================
// Statistics Providers
// ============================================================================

/// Provider for total tasks count
final totalTasksCountProvider = Provider.autoDispose<int>((ref) {
  final stats = ref.watch(analyticsStatsProvider);
  return stats?.totalTasks ?? 0;
});

/// Provider for completed tasks count
final completedTasksCountProvider = Provider.autoDispose<int>((ref) {
  final stats = ref.watch(analyticsStatsProvider);
  return stats?.completedTasks ?? 0;
});

/// Provider for incomplete tasks count
final incompleteTasksCountProvider = Provider.autoDispose<int>((ref) {
  final stats = ref.watch(analyticsStatsProvider);
  return stats?.incompleteTasks ?? 0;
});

/// Provider for completion rate
final completionRateProvider = Provider.autoDispose<double>((ref) {
  final stats = ref.watch(analyticsStatsProvider);
  return stats?.completionRate ?? 0.0;
});

/// Provider for current streak
final currentStreakProvider = Provider.autoDispose<int>((ref) {
  final stats = ref.watch(analyticsStatsProvider);
  return stats?.currentStreak ?? 0;
});

/// Provider for longest streak
final longestStreakProvider = Provider.autoDispose<int>((ref) {
  final stats = ref.watch(analyticsStatsProvider);
  return stats?.longestStreak ?? 0;
});

/// Provider for tasks completed today
final tasksCompletedTodayProvider = Provider.autoDispose<int>((ref) {
  final stats = ref.watch(analyticsStatsProvider);
  return stats?.tasksCompletedToday ?? 0;
});

/// Provider for tasks completed this week
final tasksCompletedThisWeekProvider = Provider.autoDispose<int>((ref) {
  final stats = ref.watch(analyticsStatsProvider);
  return stats?.tasksCompletedThisWeek ?? 0;
});

/// Provider for tasks completed this month
final tasksCompletedThisMonthProvider = Provider.autoDispose<int>((ref) {
  final stats = ref.watch(analyticsStatsProvider);
  return stats?.tasksCompletedThisMonth ?? 0;
});
