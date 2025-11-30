import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/design_system.dart';
import '../../../domain/entities/task_entity.dart';
import '../../providers/calendar/calendar.dart';

/// Week view calendar widget
///
/// Displays a week calendar with:
/// - 7 days in columns
/// - Tasks listed under each day
/// - Scrollable task lists
/// - Visual indicators
class WeekViewCalendar extends ConsumerWidget {
  const WeekViewCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final visibleDates = calendarState.visibleDates;

    return Column(
      children: [
        // Week day headers with dates
        _buildWeekHeaders(ref, visibleDates),
        AppSpacing.verticalSpaceXS,

        // Week content with tasks
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: visibleDates.map((date) {
              return Expanded(
                child: _buildDayColumn(ref, date),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekHeaders(WidgetRef ref, List<DateTime> dates) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: dates.map((date) {
          final isToday = ref.watch(isTodayProvider(date));
          final isSelected = ref.watch(isSelectedProvider(date));
          final taskCount = ref.watch(taskCountForDateProvider(date));

          return Expanded(
            child: InkWell(
              onTap: () {
                ref.read(calendarNotifierProvider.notifier).selectDate(date);
              },
              child: Container(
                padding: AppSpacing.paddingXS,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isToday
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: AppSpacing.borderRadiusXS,
                  border: isToday && !isSelected
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      _getWeekDayName(date.weekday),
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : isToday
                                ? AppColors.primary
                                : AppColors.gray600,
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                    AppSpacing.verticalSpaceXXS,
                    Text(
                      '${date.day}',
                      style: AppTypography.titleMedium.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : isToday
                                ? AppColors.primary
                                : AppColors.gray900,
                        fontWeight: isToday || isSelected
                            ? AppTypography.bold
                            : AppTypography.regular,
                      ),
                    ),
                    if (taskCount > 0) ...[
                      AppSpacing.verticalSpaceXXS,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.white.withOpacity(0.3)
                              : AppColors.primary.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXS),
                        ),
                        child: Text(
                          '$taskCount',
                          style: AppTypography.labelSmall.copyWith(
                            color:
                                isSelected ? AppColors.white : AppColors.primary,
                            fontSize: 10,
                            fontWeight: AppTypography.semiBold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayColumn(WidgetRef ref, DateTime date) {
    final tasks = ref.watch(tasksForDateProvider(date));
    final isToday = ref.watch(isTodayProvider(date));

    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: AppColors.gray200,
            width: 0.5,
          ),
        ),
        color: isToday ? AppColors.primary.withOpacity(0.02) : Colors.transparent,
      ),
      child: tasks.isEmpty
          ? Center(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Text(
                  'No tasks',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: AppSpacing.paddingSM,
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return _buildTaskCard(tasks[index]);
              },
            ),
    );
  }

  Widget _buildTaskCard(TaskEntity task) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: AppSpacing.paddingXS,
      decoration: BoxDecoration(
        color: task.isCompleted
            ? AppColors.gray100
            : AppColors.primary.withOpacity(0.05),
        borderRadius: AppSpacing.borderRadiusXS,
        border: Border.all(
          color: task.isCompleted ? AppColors.gray300 : AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: AppTypography.labelMedium.copyWith(
              color: task.isCompleted ? AppColors.gray500 : AppColors.gray900,
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (task.priority.index > 0) ...[
            AppSpacing.verticalSpaceXXS,
            Row(
              children: [
                Icon(
                  Icons.flag,
                  size: 10,
                  color: AppColors.getPriorityColor(task.priority.index),
                ),
                AppSpacing.horizontalSpaceXXS,
                Text(
                  _getPriorityText(task.priority),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.getPriorityColor(task.priority.index),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getWeekDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Med';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.critical:
        return 'Crit';
      default:
        return '';
    }
  }
}
