import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/design_system.dart';
import '../../providers/calendar/calendar.dart';

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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month,
            size: 64,
            color: AppColors.gray400,
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            'Month View',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            'Calendar month view coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            'Foundation complete with:',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            '✓ Calendar state management\n'
            '✓ Date navigation logic\n'
            '✓ Task integration providers\n'
            '✓ Filter support',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_week,
            size: 64,
            color: AppColors.gray400,
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            'Week View',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            'Calendar week view coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayView() {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasks = ref.watch(tasksForDateProvider(selectedDate));

    return Column(
      children: [
        Container(
          padding: AppSpacing.paddingMD,
          color: AppColors.gray50,
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalSpaceSM,
              Text(
                'Tasks for ${_formatDate(selectedDate)}',
                style: AppTypography.titleMedium,
              ),
              const Spacer(),
              Text(
                '${tasks.length} tasks',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 64,
                        color: AppColors.gray400,
                      ),
                      AppSpacing.verticalSpaceMD,
                      Text(
                        'No tasks for this day',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: AppSpacing.pagePadding,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: task.description != null
                          ? Text(task.description!)
                          : null,
                      trailing: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) {
                          // TODO: Toggle task completion
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
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

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
