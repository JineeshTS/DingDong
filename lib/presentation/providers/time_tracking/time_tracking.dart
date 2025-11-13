/// Time Tracking State Management
///
/// This module provides comprehensive time tracking functionality including:
/// - Time tracking from focus sessions
/// - Time spent per task and project
/// - Daily time breakdowns
/// - Estimates vs actuals comparison
/// - Billable hours tracking
/// - Period-based filtering (day, week, month)
/// - Time tracking reports and analytics
///
/// Key Components:
/// - [TimeTrackingState]: Immutable state with time data
/// - [TimeTrackingNotifier]: Business logic for time tracking
/// - [timeTrackingNotifierProvider]: Main provider for time tracking state
/// - 25+ derived providers for granular UI access
///
/// Usage:
/// ```dart
/// // Watch total tracked time
/// final totalTime = ref.watch(formattedTotalTimeProvider);
///
/// // Change time period
/// ref.read(timeTrackingNotifierProvider.notifier).changePeriod(TimePeriod.thisWeek);
///
/// // Get task comparisons
/// final comparisons = ref.watch(taskComparisonsProvider);
/// ```
library time_tracking;

export 'time_tracking_state.dart';
export 'time_tracking_notifier.dart';
export 'time_tracking_providers.dart';
