import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/focus_session_entity.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/repositories/focus_session_repository.dart';
import '../../../domain/repositories/task_repository.dart';
import 'time_tracking_state.dart';

/// Time Tracking Notifier
///
/// Manages time tracking data from focus sessions including:
/// - Loading sessions for selected period
/// - Calculating time by task and list
/// - Generating daily breakdowns
/// - Comparing estimates vs actuals
/// - Filtering and statistics
class TimeTrackingNotifier extends StateNotifier<TimeTrackingState> {
  final FocusSessionRepository _sessionRepository;
  final TaskRepository _taskRepository;
  final String _userId;

  TimeTrackingNotifier({
    required String userId,
    required FocusSessionRepository sessionRepository,
    required TaskRepository taskRepository,
  })  : _userId = userId,
        _sessionRepository = sessionRepository,
        _taskRepository = taskRepository,
        super(const TimeTrackingState()) {
    loadTimeData();
  }

  /// Load time tracking data for current period
  Future<void> loadTimeData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get date range
      final range = state.dateRange;

      // Load completed focus sessions for the period
      final sessionsResult = await _sessionRepository.getFocusSessionsByDateRange(
        _userId,
        startDate: range.start,
        endDate: range.end,
      );

      await sessionsResult.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: _getErrorMessage(failure),
          );
        },
        (sessions) async {
          // Filter only completed sessions
          final completedSessions = sessions
              .where((s) => s.status == FocusSessionStatus.completed)
              .toList();

          // Apply filters
          var filteredSessions = completedSessions;

          if (state.showOnlyBillable) {
            // TODO: Add billable flag to tasks/sessions
            // For now, assume all focus sessions are billable
          }

          if (state.filterByListId != null) {
            filteredSessions = filteredSessions
                .where((s) => s.listId == state.filterByListId)
                .toList();
          }

          if (state.filterByTaskId != null) {
            filteredSessions = filteredSessions
                .where((s) => s.taskId == state.filterByTaskId)
                .toList();
          }

          // Calculate statistics
          final stats = _calculateStatistics(filteredSessions);

          // Calculate time by task
          final timeByTask = _calculateTimeByTask(filteredSessions);
          final sessionCountByTask = _calculateSessionCountByTask(filteredSessions);

          // Calculate time by list
          final timeByList = _calculateTimeByList(filteredSessions);

          // Generate daily entries
          final dailyEntries = _generateDailyEntries(filteredSessions, range);

          // Load task comparisons (estimates vs actuals)
          final taskComparisons = await _generateTaskComparisons(
            filteredSessions,
            timeByTask,
            sessionCountByTask,
          );

          state = state.copyWith(
            sessions: filteredSessions,
            timeByTask: timeByTask,
            sessionCountByTask: sessionCountByTask,
            timeByList: timeByList,
            dailyEntries: dailyEntries,
            totalTrackedTime: stats['totalTime'] as Duration,
            totalBillableTime: stats['billableTime'] as Duration,
            averageDailyTime: stats['averageDaily'] as Duration,
            totalSessions: stats['sessionCount'] as int,
            averageSessionQuality: stats['avgQuality'] as double,
            taskComparisons: taskComparisons,
            isLoading: false,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Calculate statistics from sessions
  Map<String, dynamic> _calculateStatistics(List<FocusSessionEntity> sessions) {
    Duration totalTime = Duration.zero;
    Duration billableTime = Duration.zero;
    double totalQuality = 0.0;

    for (final session in sessions) {
      if (session.actualDuration != null) {
        totalTime += session.actualDuration!;
        // Assume all focus sessions are billable for now
        if (session.type == FocusSessionType.pomodoro ||
            session.type == FocusSessionType.custom) {
          billableTime += session.actualDuration!;
        }
      }
      totalQuality += session.focusQuality;
    }

    // Calculate average daily time
    final range = state.dateRange;
    final dayCount = range.end.difference(range.start).inDays;
    final averageDaily = dayCount > 0
        ? Duration(seconds: totalTime.inSeconds ~/ dayCount)
        : Duration.zero;

    final avgQuality = sessions.isNotEmpty ? totalQuality / sessions.length : 0.0;

    return {
      'totalTime': totalTime,
      'billableTime': billableTime,
      'averageDaily': averageDaily,
      'sessionCount': sessions.length,
      'avgQuality': avgQuality,
    };
  }

  /// Calculate time spent per task
  Map<String, Duration> _calculateTimeByTask(List<FocusSessionEntity> sessions) {
    final Map<String, Duration> timeByTask = {};

    for (final session in sessions) {
      if (session.taskId != null && session.actualDuration != null) {
        timeByTask[session.taskId!] = (timeByTask[session.taskId!] ?? Duration.zero) +
            session.actualDuration!;
      }
    }

    return timeByTask;
  }

  /// Calculate session count per task
  Map<String, int> _calculateSessionCountByTask(List<FocusSessionEntity> sessions) {
    final Map<String, int> countByTask = {};

    for (final session in sessions) {
      if (session.taskId != null) {
        countByTask[session.taskId!] = (countByTask[session.taskId!] ?? 0) + 1;
      }
    }

    return countByTask;
  }

  /// Calculate time spent per list/project
  Map<String, Duration> _calculateTimeByList(List<FocusSessionEntity> sessions) {
    final Map<String, Duration> timeByList = {};

    for (final session in sessions) {
      if (session.listId != null && session.actualDuration != null) {
        timeByList[session.listId!] = (timeByList[session.listId!] ?? Duration.zero) +
            session.actualDuration!;
      }
    }

    return timeByList;
  }

  /// Generate daily time entries
  List<DailyTimeEntry> _generateDailyEntries(
    List<FocusSessionEntity> sessions,
    DateTimeRange range,
  ) {
    final Map<DateTime, DailyTimeEntry> dailyMap = {};

    // Initialize all days in range
    for (var date = range.start;
        date.isBefore(range.end);
        date = date.add(const Duration(days: 1))) {
      final dayKey = DateTime(date.year, date.month, date.day);
      dailyMap[dayKey] = DailyTimeEntry(date: dayKey);
    }

    // Aggregate sessions by day
    for (final session in sessions) {
      final dayKey = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (dailyMap.containsKey(dayKey)) {
        final existing = dailyMap[dayKey]!;
        final actualDuration = session.actualDuration ?? Duration.zero;

        Duration billableTime = existing.billableTime;
        if (session.type == FocusSessionType.pomodoro ||
            session.type == FocusSessionType.custom) {
          billableTime += actualDuration;
        }

        final taskIds = Set<String>.from(existing.taskIds);
        if (session.taskId != null) {
          taskIds.add(session.taskId!);
        }

        dailyMap[dayKey] = DailyTimeEntry(
          date: dayKey,
          totalTime: existing.totalTime + actualDuration,
          billableTime: billableTime,
          sessionCount: existing.sessionCount + 1,
          taskIds: taskIds.toList(),
        );
      }
    }

    return dailyMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Generate task comparisons (estimates vs actuals)
  Future<List<TaskTimeComparison>> _generateTaskComparisons(
    List<FocusSessionEntity> sessions,
    Map<String, Duration> timeByTask,
    Map<String, int> sessionCountByTask,
  ) async {
    final List<TaskTimeComparison> comparisons = [];

    // Get unique task IDs
    final taskIds = timeByTask.keys.toSet();

    // Load tasks and create comparisons
    for (final taskId in taskIds) {
      final taskResult = await _taskRepository.getTaskById(taskId);

      await taskResult.fold(
        (failure) {
          // Skip tasks that can't be loaded
        },
        (task) {
          if (task != null) {
            // Calculate average quality for this task
            final taskSessions = sessions.where((s) => s.taskId == taskId);
            final avgQuality = taskSessions.isEmpty
                ? 0.0
                : taskSessions.map((s) => s.focusQuality).reduce((a, b) => a + b) /
                    taskSessions.length;

            comparisons.add(TaskTimeComparison(
              taskId: taskId,
              taskTitle: task.title,
              estimatedTime: task.estimatedDuration,
              actualTime: timeByTask[taskId] ?? Duration.zero,
              sessionCount: sessionCountByTask[taskId] ?? 0,
              averageQuality: avgQuality,
            ));
          }
        },
      );
    }

    // Sort by actual time (descending)
    comparisons.sort((a, b) => b.actualTime.compareTo(a.actualTime));

    return comparisons;
  }

  /// Change time period
  void changePeriod(TimePeriod period) {
    state = state.copyWith(period: period);
    loadTimeData();
  }

  /// Set custom date range
  void setCustomRange(DateTime start, DateTime end) {
    state = state.copyWith(
      period: TimePeriod.custom,
      customStartDate: start,
      customEndDate: end,
    );
    loadTimeData();
  }

  /// Toggle billable filter
  void toggleBillableFilter() {
    state = state.copyWith(showOnlyBillable: !state.showOnlyBillable);
    loadTimeData();
  }

  /// Filter by list
  void filterByList(String? listId) {
    state = state.copyWith(filterByListId: listId);
    loadTimeData();
  }

  /// Filter by task
  void filterByTask(String? taskId) {
    state = state.copyWith(filterByTaskId: taskId);
    loadTimeData();
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      showOnlyBillable: false,
      filterByListId: null,
      filterByTaskId: null,
    );
    loadTimeData();
  }

  /// Get error message from failure
  String _getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else if (failure is CacheFailure) {
      return 'Failed to load cached data.';
    } else {
      return 'An error occurred while loading time tracking data.';
    }
  }
}
