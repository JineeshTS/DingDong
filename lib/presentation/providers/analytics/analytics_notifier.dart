import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task/get_tasks_usecase.dart';
import 'analytics_state.dart';

/// Analytics state notifier
///
/// Calculates and manages analytics statistics from task data
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier({
    required this.getTasksUseCase,
    required this.userId,
  }) : super(AnalyticsState.initial()) {
    // Load analytics on init
    loadAnalytics();
  }

  final GetTasksUseCase getTasksUseCase;
  final String userId;

  /// Load and calculate analytics
  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await getTasksUseCase.call(
        GetTasksParams(userId: userId),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (tasks) {
          final stats = _calculateStats(tasks);
          final dailyCounts = _calculateDailyCounts(tasks);

          state = state.copyWith(
            stats: stats,
            dailyTaskCounts: dailyCounts,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Calculate analytics statistics
  AnalyticsStats _calculateStats(List<TaskEntity> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    final yearStart = DateTime(now.year, 1, 1);

    // Filter based on period
    final filteredTasks = _filterTasksByPeriod(tasks);

    // Basic counts
    final totalTasks = filteredTasks.length;
    final completedTasks = filteredTasks.where((t) => t.isCompleted).length;
    final incompleteTasks = totalTasks - completedTasks;

    // Overdue tasks
    final overdueTasks = filteredTasks.where((t) {
      if (t.isCompleted || t.dueDate == null) return false;
      final dueDate = DateTime(
        t.dueDate!.year,
        t.dueDate!.month,
        t.dueDate!.day,
      );
      return dueDate.isBefore(today);
    }).length;

    // Today's tasks
    final todayTasks = filteredTasks.where((t) {
      if (t.dueDate == null) return false;
      final dueDate = DateTime(
        t.dueDate!.year,
        t.dueDate!.month,
        t.dueDate!.day,
      );
      return dueDate.isAtSameMomentAs(today);
    }).length;

    // Completion rate
    final completionRate =
        totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    // Priority distribution
    final criticalTasks =
        filteredTasks.where((t) => t.priority == TaskPriority.critical).length;
    final highPriorityTasks =
        filteredTasks.where((t) => t.priority == TaskPriority.high).length;
    final mediumPriorityTasks =
        filteredTasks.where((t) => t.priority == TaskPriority.medium).length;
    final lowPriorityTasks =
        filteredTasks.where((t) => t.priority == TaskPriority.low).length;

    // Time-based completions (all tasks, not filtered)
    final tasksCompletedToday = tasks.where((t) {
      if (!t.isCompleted || t.updatedAt == null) return false;
      final completedDate = DateTime(
        t.updatedAt!.year,
        t.updatedAt!.month,
        t.updatedAt!.day,
      );
      return completedDate.isAtSameMomentAs(today);
    }).length;

    final tasksCompletedThisWeek = tasks.where((t) {
      if (!t.isCompleted || t.updatedAt == null) return false;
      return t.updatedAt!.isAfter(weekStart);
    }).length;

    final tasksCompletedThisMonth = tasks.where((t) {
      if (!t.isCompleted || t.updatedAt == null) return false;
      return t.updatedAt!.isAfter(monthStart);
    }).length;

    final tasksCompletedThisYear = tasks.where((t) {
      if (!t.isCompleted || t.updatedAt == null) return false;
      return t.updatedAt!.isAfter(yearStart);
    }).length;

    // Streaks
    final streaks = _calculateStreaks(tasks);

    // Average completion time
    final avgCompletionTime = _calculateAvgCompletionTime(tasks);

    // Most productive day
    final mostProductiveDay = _calculateMostProductiveDay(tasks);

    // Tags and lists
    final totalTags = tasks
        .expand((t) => t.tags)
        .toSet()
        .length;
    final totalLists = tasks
        .map((t) => t.categoryId)
        .where((id) => id != null)
        .toSet()
        .length;

    return AnalyticsStats(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      incompleteTasks: incompleteTasks,
      overdueTasks: overdueTasks,
      todayTasks: todayTasks,
      completionRate: completionRate,
      criticalTasks: criticalTasks,
      highPriorityTasks: highPriorityTasks,
      mediumPriorityTasks: mediumPriorityTasks,
      lowPriorityTasks: lowPriorityTasks,
      tasksCompletedToday: tasksCompletedToday,
      tasksCompletedThisWeek: tasksCompletedThisWeek,
      tasksCompletedThisMonth: tasksCompletedThisMonth,
      tasksCompletedThisYear: tasksCompletedThisYear,
      currentStreak: streaks['current'] ?? 0,
      longestStreak: streaks['longest'] ?? 0,
      avgCompletionTime: avgCompletionTime,
      mostProductiveDay: mostProductiveDay,
      totalTags: totalTags,
      totalLists: totalLists,
    );
  }

  /// Filter tasks by current period
  List<TaskEntity> _filterTasksByPeriod(List<TaskEntity> tasks) {
    final now = DateTime.now();

    switch (state.period) {
      case AnalyticsPeriod.today:
        final today = DateTime(now.year, now.month, now.day);
        return tasks.where((t) {
          if (t.createdAt == null) return false;
          final createdDate = DateTime(
            t.createdAt!.year,
            t.createdAt!.month,
            t.createdAt!.day,
          );
          return createdDate.isAtSameMomentAs(today);
        }).toList();

      case AnalyticsPeriod.week:
        final weekStart =
            now.subtract(Duration(days: now.weekday - 1, hours: now.hour));
        return tasks.where((t) {
          if (t.createdAt == null) return true;
          return t.createdAt!.isAfter(weekStart);
        }).toList();

      case AnalyticsPeriod.month:
        final monthStart = DateTime(now.year, now.month, 1);
        return tasks.where((t) {
          if (t.createdAt == null) return true;
          return t.createdAt!.isAfter(monthStart);
        }).toList();

      case AnalyticsPeriod.year:
        final yearStart = DateTime(now.year, 1, 1);
        return tasks.where((t) {
          if (t.createdAt == null) return true;
          return t.createdAt!.isAfter(yearStart);
        }).toList();

      case AnalyticsPeriod.allTime:
        return tasks;
    }
  }

  /// Calculate daily task counts for chart
  List<DailyTaskCount> _calculateDailyCounts(List<TaskEntity> tasks) {
    final now = DateTime.now();
    final counts = <DateTime, DailyTaskCount>{};

    // Get date range based on period
    int days;
    switch (state.period) {
      case AnalyticsPeriod.today:
        days = 1;
        break;
      case AnalyticsPeriod.week:
        days = 7;
        break;
      case AnalyticsPeriod.month:
        days = 30;
        break;
      case AnalyticsPeriod.year:
        days = 365;
        break;
      case AnalyticsPeriod.allTime:
        days = 30; // Show last 30 days for all time
        break;
    }

    // Initialize counts
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: days - 1 - i));
      final dateKey = DateTime(date.year, date.month, date.day);
      counts[dateKey] = DailyTaskCount(date: dateKey);
    }

    // Count tasks by date
    for (final task in tasks) {
      // Count created
      if (task.createdAt != null) {
        final createdDate = DateTime(
          task.createdAt!.year,
          task.createdAt!.month,
          task.createdAt!.day,
        );
        if (counts.containsKey(createdDate)) {
          final existing = counts[createdDate]!;
          counts[createdDate] = DailyTaskCount(
            date: createdDate,
            count: existing.count + 1,
            completed: existing.completed,
            created: existing.created + 1,
          );
        }
      }

      // Count completed
      if (task.isCompleted && task.updatedAt != null) {
        final completedDate = DateTime(
          task.updatedAt!.year,
          task.updatedAt!.month,
          task.updatedAt!.day,
        );
        if (counts.containsKey(completedDate)) {
          final existing = counts[completedDate]!;
          counts[completedDate] = DailyTaskCount(
            date: completedDate,
            count: existing.count,
            completed: existing.completed + 1,
            created: existing.created,
          );
        }
      }
    }

    return counts.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Calculate completion streaks
  Map<String, int> _calculateStreaks(List<TaskEntity> tasks) {
    final completedByDate = <DateTime, int>{};

    // Group completed tasks by date
    for (final task in tasks) {
      if (task.isCompleted && task.updatedAt != null) {
        final date = DateTime(
          task.updatedAt!.year,
          task.updatedAt!.month,
          task.updatedAt!.day,
        );
        completedByDate[date] = (completedByDate[date] ?? 0) + 1;
      }
    }

    // Calculate current streak
    int currentStreak = 0;
    final now = DateTime.now();
    var checkDate = DateTime(now.year, now.month, now.day);

    while (completedByDate.containsKey(checkDate) &&
        completedByDate[checkDate]! > 0) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    final sortedDates = completedByDate.keys.toList()..sort();

    for (int i = 0; i < sortedDates.length; i++) {
      if (completedByDate[sortedDates[i]]! > 0) {
        tempStreak++;
        if (i > 0) {
          final daysDiff =
              sortedDates[i].difference(sortedDates[i - 1]).inDays;
          if (daysDiff > 1) {
            longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
            tempStreak = 1;
          }
        }
      }
    }
    longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;

    return {
      'current': currentStreak,
      'longest': longestStreak,
    };
  }

  /// Calculate average completion time
  double _calculateAvgCompletionTime(List<TaskEntity> tasks) {
    final completedTasks = tasks.where((t) =>
        t.isCompleted && t.createdAt != null && t.updatedAt != null);

    if (completedTasks.isEmpty) return 0.0;

    double totalDays = 0;
    for (final task in completedTasks) {
      final duration = task.updatedAt!.difference(task.createdAt!);
      totalDays += duration.inDays;
    }

    return totalDays / completedTasks.length;
  }

  /// Calculate most productive day of week
  String _calculateMostProductiveDay(List<TaskEntity> tasks) {
    final dayCount = <int, int>{};

    for (final task in tasks) {
      if (task.isCompleted && task.updatedAt != null) {
        final day = task.updatedAt!.weekday;
        dayCount[day] = (dayCount[day] ?? 0) + 1;
      }
    }

    if (dayCount.isEmpty) return 'Monday';

    final mostProductiveDay = dayCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[mostProductiveDay - 1];
  }

  /// Change analytics period
  void setPeriod(AnalyticsPeriod period) {
    state = state.copyWith(period: period);
    loadAnalytics();
  }

  /// Refresh analytics
  Future<void> refresh() async {
    await loadAnalytics();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
