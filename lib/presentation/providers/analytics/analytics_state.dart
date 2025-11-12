import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_state.freezed.dart';

/// Time period for analytics
enum AnalyticsPeriod {
  /// Today's stats
  today,

  /// This week's stats
  week,

  /// This month's stats
  month,

  /// This year's stats
  year,

  /// All time stats
  allTime,
}

/// Analytics statistics
@freezed
class AnalyticsStats with _$AnalyticsStats {
  const factory AnalyticsStats({
    // Task statistics
    @Default(0) int totalTasks,
    @Default(0) int completedTasks,
    @Default(0) int incompleteTasks,
    @Default(0) int overdueTasks,
    @Default(0) int todayTasks,

    // Completion rate
    @Default(0.0) double completionRate,

    // Priority distribution
    @Default(0) int criticalTasks,
    @Default(0) int highPriorityTasks,
    @Default(0) int mediumPriorityTasks,
    @Default(0) int lowPriorityTasks,

    // Time-based
    @Default(0) int tasksCompletedToday,
    @Default(0) int tasksCompletedThisWeek,
    @Default(0) int tasksCompletedThisMonth,
    @Default(0) int tasksCompletedThisYear,

    // Streaks
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,

    // Average completion time (in days)
    @Default(0.0) double avgCompletionTime,

    // Most productive day
    @Default('Monday') String mostProductiveDay,

    // Total tags used
    @Default(0) int totalTags,

    // Total lists
    @Default(0) int totalLists,
  }) = _AnalyticsStats;

  const AnalyticsStats._();

  /// Get incomplete percentage
  double get incompletePercentage =>
      totalTasks > 0 ? (incompleteTasks / totalTasks) * 100 : 0;

  /// Get overdue percentage
  double get overduePercentage =>
      totalTasks > 0 ? (overdueTasks / totalTasks) * 100 : 0;
}

/// Daily task count for chart
@freezed
class DailyTaskCount with _$DailyTaskCount {
  const factory DailyTaskCount({
    required DateTime date,
    @Default(0) int count,
    @Default(0) int completed,
    @Default(0) int created,
  }) = _DailyTaskCount;
}

/// Analytics state
@freezed
class AnalyticsState with _$AnalyticsState {
  const factory AnalyticsState({
    /// Current analytics period
    @Default(AnalyticsPeriod.week) AnalyticsPeriod period,

    /// Analytics statistics
    @Default(null) AnalyticsStats? stats,

    /// Daily task counts for chart
    @Default([]) List<DailyTaskCount> dailyTaskCounts,

    /// Loading state
    @Default(false) bool isLoading,

    /// Error message
    @Default(null) String? error,
  }) = _AnalyticsState;

  const AnalyticsState._();

  /// Check if stats are available
  bool get hasStats => stats != null;

  /// Get period label
  String get periodLabel {
    switch (period) {
      case AnalyticsPeriod.today:
        return 'Today';
      case AnalyticsPeriod.week:
        return 'This Week';
      case AnalyticsPeriod.month:
        return 'This Month';
      case AnalyticsPeriod.year:
        return 'This Year';
      case AnalyticsPeriod.allTime:
        return 'All Time';
    }
  }

  /// Factory for initial state
  factory AnalyticsState.initial() => const AnalyticsState();
}
