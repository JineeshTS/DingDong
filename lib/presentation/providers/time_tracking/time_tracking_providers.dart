import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories_providers.dart';
import 'time_tracking_notifier.dart';
import 'time_tracking_state.dart';

// ====================
// State Notifier Provider
// ====================

/// Time Tracking Notifier Provider
///
/// Main provider for time tracking state management
final timeTrackingNotifierProvider =
    StateNotifierProvider<TimeTrackingNotifier, TimeTrackingState>(
  (ref) {
    // TODO: Get actual user ID from auth provider
    const userId = 'user_123';

    return TimeTrackingNotifier(
      userId: userId,
      sessionRepository: ref.watch(focusSessionRepositoryProvider),
      taskRepository: ref.watch(taskRepositoryProvider),
    );
  },
);

// ====================
// Derived State Providers
// ====================

/// Sessions Provider
final timeTrackingSessionsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.sessions;
});

/// Current Period Provider
final currentTimePeriodProvider = Provider.autoDispose<TimePeriod>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.period;
});

/// Period Label Provider
final periodLabelProvider = Provider.autoDispose<String>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.periodLabel;
});

/// Total Tracked Time Provider
final totalTrackedTimeProvider = Provider.autoDispose<Duration>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.totalTrackedTime;
});

/// Formatted Total Time Provider
final formattedTotalTimeProvider = Provider.autoDispose<String>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.formattedTotalTime;
});

/// Total Billable Time Provider
final totalBillableTimeProvider = Provider.autoDispose<Duration>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.totalBillableTime;
});

/// Formatted Billable Time Provider
final formattedBillableTimeProvider = Provider.autoDispose<String>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.formattedBillableTime;
});

/// Billable Percentage Provider
final billablePercentageProvider = Provider.autoDispose<double>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.billablePercentage;
});

/// Average Daily Time Provider
final averageDailyTimeProvider = Provider.autoDispose<Duration>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.averageDailyTime;
});

/// Formatted Average Daily Time Provider
final formattedAverageDailyTimeProvider = Provider.autoDispose<String>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.formattedAverageDailyTime;
});

/// Total Sessions Provider
final totalSessionsProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.totalSessions;
});

/// Average Session Quality Provider
final averageSessionQualityProvider = Provider.autoDispose<double>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.averageSessionQuality;
});

/// Time By Task Provider
final timeByTaskProvider = Provider.autoDispose((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.timeByTask;
});

/// Session Count By Task Provider
final sessionCountByTaskProvider = Provider.autoDispose((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.sessionCountByTask;
});

/// Time By List Provider
final timeByListProvider = Provider.autoDispose((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.timeByList;
});

/// Daily Entries Provider
final dailyEntriesProvider = Provider.autoDispose((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.dailyEntries;
});

/// Task Comparisons Provider
final taskComparisonsProvider = Provider.autoDispose((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.taskComparisons;
});

/// Over Estimate Tasks Provider
final overEstimateTasksProvider = Provider.autoDispose((ref) {
  final comparisons = ref.watch(taskComparisonsProvider);
  return comparisons.where((c) => c.isOverEstimate).toList();
});

/// Under Estimate Tasks Provider
final underEstimateTasksProvider = Provider.autoDispose((ref) {
  final comparisons = ref.watch(taskComparisonsProvider);
  return comparisons.where((c) => c.isUnderEstimate).toList();
});

/// On Track Tasks Provider
final onTrackTasksProvider = Provider.autoDispose((ref) {
  final comparisons = ref.watch(taskComparisonsProvider);
  return comparisons.where((c) => c.isOnTrack).toList();
});

/// Is Loading Provider
final timeTrackingLoadingProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.isLoading;
});

/// Error Provider
final timeTrackingErrorProvider = Provider.autoDispose<String?>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.error;
});

/// Active Filters Provider
final activeFiltersProvider = Provider.autoDispose((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return {
    'showOnlyBillable': state.showOnlyBillable,
    'filterByListId': state.filterByListId,
    'filterByTaskId': state.filterByTaskId,
  };
});

/// Has Active Filters Provider
final hasActiveFiltersProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.showOnlyBillable ||
      state.filterByListId != null ||
      state.filterByTaskId != null;
});

/// Date Range Provider
final dateRangeProvider = Provider.autoDispose((ref) {
  final state = ref.watch(timeTrackingNotifierProvider);
  return state.dateRange;
});
