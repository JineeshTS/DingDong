import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task/get_tasks_by_date_range_usecase.dart';
import 'calendar_state.dart';

/// Calendar state notifier
///
/// Manages calendar view state including:
/// - View mode (month/week/day)
/// - Selected date and navigation
/// - Task loading for calendar dates
/// - Filtering and display options
class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier({
    required this.getTasksByDateRangeUseCase,
    required this.userId,
  }) : super(CalendarState.initial()) {
    // Load tasks for initial view
    loadTasksForCurrentView();
  }

  final GetTasksByDateRangeUseCase getTasksByDateRangeUseCase;
  final String userId;

  /// Change calendar view mode
  void setViewMode(CalendarViewMode mode) {
    state = state.copyWith(viewMode: mode);
    loadTasksForCurrentView();
  }

  /// Select a date
  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
    );

    // Update current month if date is in a different month
    if (date.month != state.currentMonth.month ||
        date.year != state.currentMonth.year) {
      state = state.copyWith(
        currentMonth: DateTime(date.year, date.month, 1),
      );
      loadTasksForCurrentView();
    }
  }

  /// Navigate to today
  void goToToday() {
    final now = DateTime.now();
    selectDate(now);
  }

  /// Navigate to previous period (month/week/day)
  void goToPrevious() {
    switch (state.viewMode) {
      case CalendarViewMode.month:
        _goToPreviousMonth();
        break;
      case CalendarViewMode.week:
        _goToPreviousWeek();
        break;
      case CalendarViewMode.day:
        _goToPreviousDay();
        break;
    }
  }

  /// Navigate to next period (month/week/day)
  void goToNext() {
    switch (state.viewMode) {
      case CalendarViewMode.month:
        _goToNextMonth();
        break;
      case CalendarViewMode.week:
        _goToNextWeek();
        break;
      case CalendarViewMode.day:
        _goToNextDay();
        break;
    }
  }

  void _goToPreviousMonth() {
    final previousMonth = DateTime(
      state.currentMonth.year,
      state.currentMonth.month - 1,
      1,
    );
    state = state.copyWith(currentMonth: previousMonth);
    loadTasksForCurrentView();
  }

  void _goToNextMonth() {
    final nextMonth = DateTime(
      state.currentMonth.year,
      state.currentMonth.month + 1,
      1,
    );
    state = state.copyWith(currentMonth: nextMonth);
    loadTasksForCurrentView();
  }

  void _goToPreviousWeek() {
    final previousWeek = state.selectedDate.subtract(const Duration(days: 7));
    selectDate(previousWeek);
  }

  void _goToNextWeek() {
    final nextWeek = state.selectedDate.add(const Duration(days: 7));
    selectDate(nextWeek);
  }

  void _goToPreviousDay() {
    final previousDay = state.selectedDate.subtract(const Duration(days: 1));
    selectDate(previousDay);
  }

  void _goToNextDay() {
    final nextDay = state.selectedDate.add(const Duration(days: 1));
    selectDate(nextDay);
  }

  /// Toggle show completed tasks
  void toggleShowCompletedTasks() {
    state = state.copyWith(showCompletedTasks: !state.showCompletedTasks);
    _filterVisibleTasks();
  }

  /// Toggle show tasks without dates
  void toggleShowTasksWithoutDates() {
    state = state.copyWith(
      showTasksWithoutDates: !state.showTasksWithoutDates,
    );
    loadTasksForCurrentView();
  }

  /// Set week start day (0 = Sunday, 1 = Monday)
  void setWeekStartDay(int day) {
    if (day < 0 || day > 6) return;
    state = state.copyWith(weekStartDay: day);
  }

  /// Filter by list
  void filterByList(String? listId) {
    state = state.copyWith(selectedListId: listId);
    _filterVisibleTasks();
  }

  /// Filter by tags
  void filterByTags(List<String> tags) {
    state = state.copyWith(selectedTags: tags);
    _filterVisibleTasks();
  }

  /// Filter by priority
  void filterByPriority(TaskPriority? priority) {
    state = state.copyWith(selectedPriority: priority);
    _filterVisibleTasks();
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      selectedListId: null,
      selectedTags: [],
      selectedPriority: null,
    );
    _filterVisibleTasks();
  }

  /// Load tasks for the current view period
  Future<void> loadTasksForCurrentView() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final dateRange = _getCurrentViewDateRange();
      final result = await getTasksByDateRangeUseCase.call(
        GetTasksByDateRangeParams(
          userId: userId,
          startDate: dateRange.$1,
          endDate: dateRange.$2,
        ),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (tasks) {
          state = state.copyWith(
            visibleTasks: tasks,
            isLoading: false,
          );
          _filterVisibleTasks();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh calendar data
  Future<void> refresh() async {
    await loadTasksForCurrentView();
  }

  /// Get date range for current view
  (DateTime, DateTime) _getCurrentViewDateRange() {
    switch (state.viewMode) {
      case CalendarViewMode.month:
        return (state.calendarGridStart, state.calendarGridEnd);
      case CalendarViewMode.week:
        return (state.weekStart, state.weekEnd);
      case CalendarViewMode.day:
        return (
          state.selectedDate,
          state.selectedDate.add(const Duration(days: 1)),
        );
    }
  }

  /// Apply filters to visible tasks
  void _filterVisibleTasks() {
    var filtered = List<TaskEntity>.from(state.visibleTasks);

    // Filter by completion status
    if (!state.showCompletedTasks) {
      filtered = filtered
          .where((task) => task.status != TaskStatus.completed)
          .toList();
    }

    // Filter by list
    if (state.selectedListId != null) {
      filtered = filtered
          .where((task) => task.categoryId == state.selectedListId)
          .toList();
    }

    // Filter by tags
    if (state.selectedTags.isNotEmpty) {
      filtered = filtered.where((task) {
        return state.selectedTags.any((tag) => task.tags.contains(tag));
      }).toList();
    }

    // Filter by priority
    if (state.selectedPriority != null) {
      filtered = filtered
          .where((task) => task.priority == state.selectedPriority)
          .toList();
    }

    state = state.copyWith(visibleTasks: filtered);
  }

  /// Get tasks for a specific date
  List<TaskEntity> getTasksForDate(DateTime date) {
    return state.getTasksForDate(date);
  }

  /// Get task count for a specific date
  int getTaskCountForDate(DateTime date) {
    return state.getTaskCountForDate(date);
  }

  /// Check if a date has tasks
  bool hasTasksOnDate(DateTime date) {
    return state.hasTasksOnDate(date);
  }

  /// Check if a date has overdue tasks
  bool hasOverdueTasksOnDate(DateTime date) {
    return state.hasOverdueTasksOnDate(date);
  }
}
