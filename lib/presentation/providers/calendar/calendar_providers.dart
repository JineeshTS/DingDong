import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/usecases/task/get_tasks_by_date_range_usecase.dart';
import '../auth_provider.dart';
import 'calendar_notifier.dart';
import 'calendar_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================

/// Provider for GetTasksByDateRangeUseCase
final getTasksByDateRangeProvider =
    Provider.autoDispose<GetTasksByDateRangeUseCase>(
  (ref) => sl<GetTasksByDateRangeUseCase>(),
);

// ============================================================================
// Calendar State Notifier Provider
// ============================================================================

/// Main calendar state notifier provider
///
/// Manages calendar view state including navigation, task loading, and filtering.
///
/// Usage:
/// ```dart
/// final calendarState = ref.watch(calendarNotifierProvider);
/// final calendarNotifier = ref.read(calendarNotifierProvider.notifier);
///
/// // Navigate calendar
/// calendarNotifier.goToNext();
/// calendarNotifier.goToToday();
///
/// // Change view mode
/// calendarNotifier.setViewMode(CalendarViewMode.week);
///
/// // Get tasks for date
/// final tasks = calendarNotifier.getTasksForDate(DateTime.now());
/// ```
final calendarNotifierProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.when(
    data: (user) => user?.id ?? '',
    loading: () => '',
    error: (_, __) => '',
  );

  return CalendarNotifier(
    getTasksByDateRangeUseCase: ref.read(getTasksByDateRangeProvider),
    userId: userId ?? '',
  );
});

// ============================================================================
// Derived State Providers
// ============================================================================

/// Provider for current calendar view mode
final calendarViewModeProvider = Provider.autoDispose<CalendarViewMode>((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.viewMode;
});

/// Provider for selected date
final selectedDateProvider = Provider.autoDispose<DateTime>((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.selectedDate;
});

/// Provider for current month
final currentMonthProvider = Provider.autoDispose<DateTime>((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.currentMonth;
});

/// Provider for visible tasks in calendar
final calendarTasksProvider = Provider.autoDispose((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.visibleTasks;
});

/// Provider for calendar loading state
final isCalendarLoadingProvider = Provider.autoDispose<bool>((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.isLoading;
});

/// Provider for calendar error
final calendarErrorProvider = Provider.autoDispose<String?>((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.error;
});

/// Provider for visible dates in current view
final visibleDatesProvider = Provider.autoDispose<List<DateTime>>((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.visibleDates;
});

/// Provider for formatted view date range
final viewDateRangeProvider = Provider.autoDispose<String>((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.viewDateRange;
});

/// Provider for week start day
final weekStartDayProvider = Provider.autoDispose<int>((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.weekStartDay;
});

/// Provider for show completed tasks setting
final showCompletedTasksProvider = Provider.autoDispose<bool>((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.showCompletedTasks;
});

/// Provider for active filters count
final activeFiltersCountProvider = Provider.autoDispose<int>((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  int count = 0;

  if (calendarState.selectedListId != null) count++;
  if (calendarState.selectedTags.isNotEmpty) count++;
  if (calendarState.selectedPriority != null) count++;

  return count;
});

/// Provider for checking if a specific date has tasks
final hasTasksOnDateProvider =
    Provider.autoDispose.family<bool, DateTime>((ref, date) {
  final calendarNotifier = ref.watch(calendarNotifierProvider.notifier);
  return calendarNotifier.hasTasksOnDate(date);
});

/// Provider for getting task count for a specific date
final taskCountForDateProvider =
    Provider.autoDispose.family<int, DateTime>((ref, date) {
  final calendarNotifier = ref.watch(calendarNotifierProvider.notifier);
  return calendarNotifier.getTaskCountForDate(date);
});

/// Provider for checking if a date has overdue tasks
final hasOverdueTasksOnDateProvider =
    Provider.autoDispose.family<bool, DateTime>((ref, date) {
  final calendarNotifier = ref.watch(calendarNotifierProvider.notifier);
  return calendarNotifier.hasOverdueTasksOnDate(date);
});

/// Provider for getting tasks for a specific date
final tasksForDateProvider =
    Provider.autoDispose.family((ref, DateTime date) {
  final calendarNotifier = ref.watch(calendarNotifierProvider.notifier);
  return calendarNotifier.getTasksForDate(date);
});

/// Provider for checking if date is today
final isTodayProvider = Provider.autoDispose.family<bool, DateTime>((ref, date) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.isToday(date);
});

/// Provider for checking if date is selected
final isSelectedProvider =
    Provider.autoDispose.family<bool, DateTime>((ref, date) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.isSelected(date);
});

/// Provider for checking if date is in current month
final isDateInCurrentMonthProvider =
    Provider.autoDispose.family<bool, DateTime>((ref, date) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.isDateInCurrentMonth(date);
});

/// Provider for calendar month name
final calendarMonthNameProvider = Provider.autoDispose<String>((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.monthName;
});

/// Provider for calendar year
final calendarYearProvider = Provider.autoDispose<String>((ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  return calendarState.year;
});

// ============================================================================
// Computed Providers
// ============================================================================

/// Provider for tasks count in current view
final tasksCountInViewProvider = Provider.autoDispose<int>((ref) {
  final tasks = ref.watch(calendarTasksProvider);
  return tasks.length;
});

/// Provider for completed tasks count in current view
final completedTasksCountInViewProvider = Provider.autoDispose<int>((ref) {
  final tasks = ref.watch(calendarTasksProvider);
  return tasks.where((task) => task.status == TaskStatus.completed).length;
});

/// Provider for pending tasks count in current view
final pendingTasksCountInViewProvider = Provider.autoDispose<int>((ref) {
  final tasks = ref.watch(calendarTasksProvider);
  return tasks.where((task) => task.status != TaskStatus.completed).length;
});

/// Provider for overdue tasks count in current view
final overdueTasksCountInViewProvider = Provider.autoDispose<int>((ref) {
  final tasks = ref.watch(calendarTasksProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return tasks.where((task) {
    if (task.status == TaskStatus.completed) return false;
    if (task.dueDate == null) return false;
    final taskDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );
    return taskDate.isBefore(today);
  }).length;
});
