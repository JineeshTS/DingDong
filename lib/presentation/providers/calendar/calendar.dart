/// Calendar providers module
///
/// Exports all calendar-related providers, state, and notifiers.
///
/// This module provides calendar view functionality including:
/// - Month, week, and day views
/// - Calendar navigation (previous, next, today)
/// - Task integration with calendar dates
/// - Filtering by list, tags, and priority
/// - Date-based task queries
///
/// ## Usage
///
/// ```dart
/// import 'package:dingdong/presentation/providers/calendar/calendar.dart';
///
/// class CalendarScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Watch calendar state
///     final calendarState = ref.watch(calendarNotifierProvider);
///     final viewMode = ref.watch(calendarViewModeProvider);
///
///     // Get notifier for actions
///     final calendarNotifier = ref.read(calendarNotifierProvider.notifier);
///
///     return Column(
///       children: [
///         // Navigate calendar
///         IconButton(
///           onPressed: () => calendarNotifier.goToPrevious(),
///           icon: Icon(Icons.chevron_left),
///         ),
///         Text(ref.watch(viewDateRangeProvider)),
///         IconButton(
///           onPressed: () => calendarNotifier.goToNext(),
///           icon: Icon(Icons.chevron_right),
///         ),
///
///         // Show tasks for selected date
///         Consumer(
///           builder: (context, ref, child) {
///             final tasks = ref.watch(
///               tasksForDateProvider(calendarState.selectedDate),
///             );
///             return TaskList(tasks: tasks);
///           },
///         ),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## Available Providers
///
/// ### State Provider
/// - `calendarNotifierProvider` - Main calendar state and notifier
///
/// ### View State Providers
/// - `calendarViewModeProvider` - Current view mode (month/week/day)
/// - `selectedDateProvider` - Currently selected date
/// - `currentMonthProvider` - Current month being displayed
/// - `visibleDatesProvider` - All dates visible in current view
/// - `viewDateRangeProvider` - Formatted date range string
///
/// ### Task Providers
/// - `calendarTasksProvider` - All tasks in current view
/// - `tasksForDateProvider` - Tasks for a specific date (family)
/// - `taskCountForDateProvider` - Task count for a date (family)
/// - `hasTasksOnDateProvider` - Check if date has tasks (family)
/// - `hasOverdueTasksOnDateProvider` - Check if date has overdue tasks (family)
///
/// ### Loading & Error Providers
/// - `isCalendarLoadingProvider` - Calendar loading state
/// - `calendarErrorProvider` - Calendar error message
///
/// ### Settings Providers
/// - `weekStartDayProvider` - Week start day (0=Sunday, 1=Monday)
/// - `showCompletedTasksProvider` - Show completed tasks setting
/// - `activeFiltersCountProvider` - Count of active filters
///
/// ### Date Check Providers
/// - `isTodayProvider` - Check if date is today (family)
/// - `isSelectedProvider` - Check if date is selected (family)
/// - `isDateInCurrentMonthProvider` - Check if date is in current month (family)
///
/// ### Formatting Providers
/// - `calendarMonthNameProvider` - Current month name
/// - `calendarYearProvider` - Current year
///
/// ### Statistics Providers
/// - `tasksCountInViewProvider` - Total tasks count in view
/// - `completedTasksCountInViewProvider` - Completed tasks count
/// - `pendingTasksCountInViewProvider` - Pending tasks count
/// - `overdueTasksCountInViewProvider` - Overdue tasks count
///
export 'calendar_notifier.dart';
export 'calendar_providers.dart';
export 'calendar_state.dart';
