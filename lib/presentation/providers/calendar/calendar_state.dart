import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/task_entity.dart';

part 'calendar_state.freezed.dart';

/// Calendar view mode
enum CalendarViewMode {
  month,
  week,
  day,
}

/// Calendar state for managing calendar view
@freezed
class CalendarState with _$CalendarState {
  const factory CalendarState({
    /// Current view mode (month, week, or day)
    @Default(CalendarViewMode.month) CalendarViewMode viewMode,

    /// Currently selected date
    required DateTime selectedDate,

    /// Current month being displayed (for month view)
    required DateTime currentMonth,

    /// Tasks for the current view period
    @Default([]) List<TaskEntity> visibleTasks,

    /// Whether calendar is loading
    @Default(false) bool isLoading,

    /// Error message if loading failed
    String? error,

    /// Week start day (0 = Sunday, 1 = Monday)
    @Default(1) int weekStartDay,

    /// Whether to show completed tasks
    @Default(true) bool showCompletedTasks,

    /// Whether to show tasks without due dates
    @Default(false) bool showTasksWithoutDates,

    /// Selected filter for calendar tasks
    String? selectedListId,

    /// Selected tags filter
    @Default([]) List<String> selectedTags,

    /// Selected priority filter
    TaskPriority? selectedPriority,
  }) = _CalendarState;

  const CalendarState._();

  /// Initial state with today's date
  factory CalendarState.initial() {
    final now = DateTime.now();
    return CalendarState(
      selectedDate: DateTime(now.year, now.month, now.day),
      currentMonth: DateTime(now.year, now.month, 1),
    );
  }

  /// Get start of the current week
  DateTime get weekStart {
    final daysSinceWeekStart = (selectedDate.weekday - weekStartDay) % 7;
    return selectedDate.subtract(Duration(days: daysSinceWeekStart));
  }

  /// Get end of the current week
  DateTime get weekEnd {
    return weekStart.add(const Duration(days: 6));
  }

  /// Get start of the current month
  DateTime get monthStart {
    return DateTime(currentMonth.year, currentMonth.month, 1);
  }

  /// Get end of the current month
  DateTime get monthEnd {
    return DateTime(currentMonth.year, currentMonth.month + 1, 0);
  }

  /// Get calendar grid start (includes days from previous month)
  DateTime get calendarGridStart {
    final firstDayOfMonth = monthStart;
    final daysSinceWeekStart = (firstDayOfMonth.weekday - weekStartDay) % 7;
    return firstDayOfMonth.subtract(Duration(days: daysSinceWeekStart));
  }

  /// Get calendar grid end (includes days from next month)
  DateTime get calendarGridEnd {
    final lastDayOfMonth = monthEnd;
    final daysUntilWeekEnd = (6 - (lastDayOfMonth.weekday - weekStartDay)) % 7;
    return lastDayOfMonth.add(Duration(days: daysUntilWeekEnd));
  }

  /// Get tasks for a specific date
  List<TaskEntity> getTasksForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);

    return visibleTasks.where((task) {
      if (task.dueDate == null) return false;
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      return taskDate == targetDate;
    }).toList();
  }

  /// Get task count for a specific date
  int getTaskCountForDate(DateTime date) {
    return getTasksForDate(date).length;
  }

  /// Check if a date has any tasks
  bool hasTasksOnDate(DateTime date) {
    return getTaskCountForDate(date) > 0;
  }

  /// Check if a date has overdue tasks
  bool hasOverdueTasksOnDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (!targetDate.isBefore(today)) return false;

    return getTasksForDate(date).any(
      (task) => task.status != TaskStatus.completed,
    );
  }

  /// Get all dates in the current view
  List<DateTime> get visibleDates {
    switch (viewMode) {
      case CalendarViewMode.month:
        return _getMonthDates();
      case CalendarViewMode.week:
        return _getWeekDates();
      case CalendarViewMode.day:
        return [selectedDate];
    }
  }

  List<DateTime> _getMonthDates() {
    final dates = <DateTime>[];
    var current = calendarGridStart;
    final end = calendarGridEnd;

    while (current.isBefore(end) || current == end) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  List<DateTime> _getWeekDates() {
    final dates = <DateTime>[];
    var current = weekStart;
    final end = weekEnd;

    for (int i = 0; i <= 6; i++) {
      dates.add(current.add(Duration(days: i)));
    }

    return dates;
  }

  /// Check if date is in current month
  bool isDateInCurrentMonth(DateTime date) {
    return date.month == currentMonth.month &&
        date.year == currentMonth.year;
  }

  /// Check if date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is selected
  bool isSelected(DateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }

  /// Get week number in year
  int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).floor() + 1;
  }

  /// Get formatted month name
  String get monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[currentMonth.month - 1];
  }

  /// Get formatted year
  String get year {
    return currentMonth.year.toString();
  }

  /// Get formatted date range for current view
  String get viewDateRange {
    switch (viewMode) {
      case CalendarViewMode.month:
        return '$monthName $year';
      case CalendarViewMode.week:
        final startMonth = weekStart.month;
        final endMonth = weekEnd.month;
        if (startMonth == endMonth) {
          return '${_getMonthName(startMonth)} ${weekStart.day}-${weekEnd.day}, ${weekStart.year}';
        } else {
          return '${_getMonthName(startMonth)} ${weekStart.day} - ${_getMonthName(endMonth)} ${weekEnd.day}, ${weekStart.year}';
        }
      case CalendarViewMode.day:
        return '${_getMonthName(selectedDate.month)} ${selectedDate.day}, ${selectedDate.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
