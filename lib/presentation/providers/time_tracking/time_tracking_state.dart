import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/focus_session_entity.dart';

part 'time_tracking_state.freezed.dart';

/// Time Tracking State
///
/// Manages time tracking data including:
/// - Time entries from focus sessions
/// - Time spent per task
/// - Time spent per project/list
/// - Time period filtering
/// - Billable vs non-billable hours
@freezed
class TimeTrackingState with _$TimeTrackingState {
  const factory TimeTrackingState({
    // Time entries (from focus sessions)
    @Default([]) List<FocusSessionEntity> sessions,

    // Period filter
    @Default(TimePeriod.thisWeek) TimePeriod period,
    DateTime? customStartDate,
    DateTime? customEndDate,

    // Task time breakdown
    @Default({}) Map<String, Duration> timeByTask,
    @Default({}) Map<String, int> sessionCountByTask,

    // List/Project time breakdown
    @Default({}) Map<String, Duration> timeByList,

    // Daily time tracking
    @Default([]) List<DailyTimeEntry> dailyEntries,

    // Statistics
    @Default(Duration.zero) Duration totalTrackedTime,
    @Default(Duration.zero) Duration totalBillableTime,
    @Default(Duration.zero) Duration averageDailyTime,
    @Default(0) int totalSessions,
    @Default(0.0) double averageSessionQuality,

    // Task estimates comparison
    @Default([]) List<TaskTimeComparison> taskComparisons,

    // UI state
    @Default(false) bool isLoading,
    String? error,

    // Filters
    @Default(false) bool showOnlyBillable,
    String? filterByListId,
    String? filterByTaskId,
  }) = _TimeTrackingState;

  const TimeTrackingState._();

  /// Get date range based on period
  DateTimeRange get dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case TimePeriod.today:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
      case TimePeriod.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: yesterday,
          end: today,
        );
      case TimePeriod.thisWeek:
        final weekStart = today.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(
          start: weekStart,
          end: weekStart.add(const Duration(days: 7)),
        );
      case TimePeriod.lastWeek:
        final thisWeekStart = today.subtract(Duration(days: now.weekday - 1));
        final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
        return DateTimeRange(
          start: lastWeekStart,
          end: thisWeekStart,
        );
      case TimePeriod.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        return DateTimeRange(
          start: monthStart,
          end: nextMonth,
        );
      case TimePeriod.lastMonth:
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final thisMonthStart = DateTime(now.year, now.month, 1);
        return DateTimeRange(
          start: lastMonthStart,
          end: thisMonthStart,
        );
      case TimePeriod.custom:
        if (customStartDate != null && customEndDate != null) {
          return DateTimeRange(
            start: customStartDate!,
            end: customEndDate!,
          );
        }
        // Fallback to this week
        final weekStart = today.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(
          start: weekStart,
          end: weekStart.add(const Duration(days: 7)),
        );
    }
  }

  /// Format total tracked time
  String get formattedTotalTime => _formatDuration(totalTrackedTime);

  /// Format average daily time
  String get formattedAverageDailyTime => _formatDuration(averageDailyTime);

  /// Format total billable time
  String get formattedBillableTime => _formatDuration(totalBillableTime);

  /// Get billable percentage
  double get billablePercentage {
    if (totalTrackedTime.inSeconds == 0) return 0.0;
    return (totalBillableTime.inSeconds / totalTrackedTime.inSeconds) * 100;
  }

  /// Format duration helper
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Get period label
  String get periodLabel {
    switch (period) {
      case TimePeriod.today:
        return 'Today';
      case TimePeriod.yesterday:
        return 'Yesterday';
      case TimePeriod.thisWeek:
        return 'This Week';
      case TimePeriod.lastWeek:
        return 'Last Week';
      case TimePeriod.thisMonth:
        return 'This Month';
      case TimePeriod.lastMonth:
        return 'Last Month';
      case TimePeriod.custom:
        return 'Custom Range';
    }
  }
}

/// Time Period
enum TimePeriod {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  custom,
}

/// Date Time Range
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});
}

/// Daily Time Entry
@freezed
class DailyTimeEntry with _$DailyTimeEntry {
  const factory DailyTimeEntry({
    required DateTime date,
    @Default(Duration.zero) Duration totalTime,
    @Default(Duration.zero) Duration billableTime,
    @Default(0) int sessionCount,
    @Default([]) List<String> taskIds,
  }) = _DailyTimeEntry;
}

/// Task Time Comparison (Estimate vs Actual)
@freezed
class TaskTimeComparison with _$TaskTimeComparison {
  const factory TaskTimeComparison({
    required String taskId,
    required String taskTitle,
    Duration? estimatedTime,
    @Default(Duration.zero) Duration actualTime,
    @Default(0) int sessionCount,
    @Default(0.0) double averageQuality,
  }) = _TaskTimeComparison;

  const TaskTimeComparison._();

  /// Get variance (actual - estimated)
  Duration? get variance {
    if (estimatedTime == null) return null;
    return Duration(
      seconds: actualTime.inSeconds - estimatedTime!.inSeconds,
    );
  }

  /// Get variance percentage
  double? get variancePercentage {
    if (estimatedTime == null || estimatedTime!.inSeconds == 0) return null;
    return ((actualTime.inSeconds - estimatedTime!.inSeconds) /
            estimatedTime!.inSeconds) *
        100;
  }

  /// Check if over estimate
  bool get isOverEstimate {
    if (estimatedTime == null) return false;
    return actualTime > estimatedTime!;
  }

  /// Check if under estimate
  bool get isUnderEstimate {
    if (estimatedTime == null) return false;
    return actualTime < estimatedTime!;
  }

  /// Check if on track (within 10%)
  bool get isOnTrack {
    if (variancePercentage == null) return false;
    return variancePercentage!.abs() <= 10;
  }
}
