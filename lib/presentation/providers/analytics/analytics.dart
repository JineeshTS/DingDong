/// Analytics providers module
///
/// Exports all Analytics-related providers, state, and notifiers.
///
/// This module provides comprehensive analytics and statistics including:
/// - Task completion statistics
/// - Productivity trends
/// - Priority distribution
/// - Completion streaks
/// - Time-based analytics
/// - Charts and visualizations
///
/// ## Usage
///
/// ```dart
/// import 'package:dingdong/presentation/providers/analytics/analytics.dart';
///
/// class AnalyticsScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Watch Analytics state
///     final analyticsState = ref.watch(analyticsNotifierProvider);
///     final stats = ref.watch(analyticsStatsProvider);
///
///     // Get notifier for actions
///     final analyticsNotifier = ref.read(analyticsNotifierProvider.notifier);
///
///     return Column(
///       children: [
///         // Period selector
///         DropdownButton<AnalyticsPeriod>(
///           value: analyticsState.period,
///           onChanged: (period) {
///             if (period != null) {
///               analyticsNotifier.setPeriod(period);
///             }
///           },
///           items: AnalyticsPeriod.values.map((period) {
///             return DropdownMenuItem(
///               value: period,
///               child: Text(period.name),
///             );
///           }).toList(),
///         ),
///
///         // Statistics
///         if (stats != null) ...[
///           Text('Total Tasks: ${stats.totalTasks}'),
///           Text('Completed: ${stats.completedTasks}'),
///           Text('Completion Rate: ${stats.completionRate.toStringAsFixed(1)}%'),
///           Text('Current Streak: ${stats.currentStreak} days'),
///         ],
///       ],
///     );
///   }
/// }
/// ```
///
/// ## Available Providers
///
/// ### State Provider
/// - `analyticsNotifierProvider` - Main Analytics state and notifier
///
/// ### View State Providers
/// - `analyticsPeriodProvider` - Current analytics period
/// - `analyticsStatsProvider` - Analytics statistics
/// - `dailyTaskCountsProvider` - Daily task counts for charts
/// - `analyticsPeriodLabelProvider` - Period label string
///
/// ### Loading & Error Providers
/// - `isAnalyticsLoadingProvider` - Loading state
/// - `analyticsErrorProvider` - Error message
/// - `hasAnalyticsStatsProvider` - Check if stats are available
///
/// ### Statistics Providers
/// - `totalTasksCountProvider` - Total tasks count
/// - `completedTasksCountProvider` - Completed tasks count
/// - `incompleteTasksCountProvider` - Incomplete tasks count
/// - `completionRateProvider` - Completion rate percentage
/// - `currentStreakProvider` - Current completion streak
/// - `longestStreakProvider` - Longest completion streak
/// - `tasksCompletedTodayProvider` - Tasks completed today
/// - `tasksCompletedThisWeekProvider` - Tasks completed this week
/// - `tasksCompletedThisMonthProvider` - Tasks completed this month
///
export 'analytics_notifier.dart';
export 'analytics_providers.dart';
export 'analytics_state.dart';
