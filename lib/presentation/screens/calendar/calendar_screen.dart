import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/design_system.dart';
import '../../providers/calendar/calendar.dart';
import 'widgets/month_view_calendar.dart';
import 'widgets/week_view_calendar.dart';
import 'widgets/day_view_calendar.dart';

/// Calendar screen with month, week, and day views
///
/// Displays tasks in a calendar format with ability to:
/// - Switch between month/week/day views
/// - Navigate through dates
/// - View tasks on specific dates
/// - Filter tasks by list, tags, priority
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final viewDateRange = ref.watch(viewDateRangeProvider);
    final viewMode = ref.watch(calendarViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(viewDateRange),
        actions: [
          // View mode selector
          PopupMenuButton<CalendarViewMode>(
            icon: const Icon(Icons.view_module),
            onSelected: (mode) {
              ref.read(calendarNotifierProvider.notifier).setViewMode(mode);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarViewMode.month,
                child: Text('Month View'),
              ),
              const PopupMenuItem(
                value: CalendarViewMode.week,
                child: Text('Week View'),
              ),
              const PopupMenuItem(
                value: CalendarViewMode.day,
                child: Text('Day View'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation bar
          _buildNavigationBar(),

          // Calendar content based on view mode
          Expanded(
            child: calendarState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : calendarState.error != null
                    ? _buildError(calendarState.error!)
                    : _buildCalendarContent(viewMode),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(calendarNotifierProvider.notifier).goToToday();
        },
        child: const Icon(Icons.today),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200,
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(calendarNotifierProvider.notifier).goToPrevious();
            },
          ),
          TextButton(
            onPressed: () {
              ref.read(calendarNotifierProvider.notifier).goToToday();
            },
            child: const Text('Today'),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(calendarNotifierProvider.notifier).goToNext();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent(CalendarViewMode viewMode) {
    switch (viewMode) {
      case CalendarViewMode.month:
        return _buildMonthView();
      case CalendarViewMode.week:
        return _buildWeekView();
      case CalendarViewMode.day:
        return _buildDayView();
    }
  }

  Widget _buildMonthView() {
    return const MonthViewCalendar();
  }

  Widget _buildWeekView() {
    return const WeekViewCalendar();
  }

  Widget _buildDayView() {
    return const DayViewCalendar();
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            'Error loading calendar',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.error,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            error,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceMD,
          ElevatedButton(
            onPressed: () {
              ref.read(calendarNotifierProvider.notifier).refresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
