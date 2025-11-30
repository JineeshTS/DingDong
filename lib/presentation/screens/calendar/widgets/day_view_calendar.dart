import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/design_system.dart';
import '../../../domain/entities/task_entity.dart';
import '../../common/widgets/widgets.dart';
import '../../providers/calendar/calendar.dart';
import '../../providers/task_provider.dart';

/// Day view calendar widget
///
/// Displays tasks for a single day with:
/// - Task list with full details
/// - Task completion toggle
/// - Priority indicators
/// - Due time (if available)
/// - Tap to view detail
class DayViewCalendar extends ConsumerWidget {
  const DayViewCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasks = ref.watch(tasksForDateProvider(selectedDate));
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final pendingCount = tasks.length - completedCount;

    return Column(
      children: [
        // Date header with statistics
        _buildDateHeader(
          ref,
          selectedDate,
          tasks.length,
          completedCount,
          pendingCount,
        ),

        // Task list
        Expanded(
          child: tasks.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: AppSpacing.pagePadding,
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) =>
                      AppSpacing.verticalSpaceXS,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(ref, context, tasks[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(
    WidgetRef ref,
    DateTime date,
    int total,
    int completed,
    int pending,
  ) {
    final isToday = ref.watch(isTodayProvider(date));

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: isToday ? AppColors.primary : AppColors.gray600,
                size: AppSpacing.iconSM,
              ),
              AppSpacing.horizontalSpaceSM,
              Text(
                _formatDate(date),
                style: AppTypography.titleLarge.copyWith(
                  color: isToday ? AppColors.primary : AppColors.gray900,
                  fontWeight: AppTypography.bold,
                ),
              ),
              if (isToday) ...[
                AppSpacing.horizontalSpaceXS,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
                  ),
                  child: Text(
                    'Today',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            children: [
              _buildStatChip(
                'Total',
                total.toString(),
                AppColors.gray600,
              ),
              AppSpacing.horizontalSpaceXS,
              _buildStatChip(
                'Pending',
                pending.toString(),
                AppColors.warning,
              ),
              AppSpacing.horizontalSpaceXS,
              _buildStatChip(
                'Done',
                completed.toString(),
                AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontSize: 11,
            ),
          ),
          AppSpacing.horizontalSpaceXXS,
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: AppTypography.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(WidgetRef ref, BuildContext context, TaskEntity task) {
    return AppCard(
      onTap: () {
        context.push('/home/task/${task.id}');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Checkbox(
            value: task.isCompleted,
            onChanged: (_) async {
              if (task.isCompleted) {
                await ref
                    .read(taskNotifierProvider.notifier)
                    .uncompleteTask(task.id);
              } else {
                await ref
                    .read(taskNotifierProvider.notifier)
                    .completeTask(task.id);
              }
              // Refresh calendar
              ref.read(calendarNotifierProvider.notifier).refresh();
            },
            activeColor: AppColors.primary,
          ),
          AppSpacing.horizontalSpaceSM,

          // Task content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  task.title,
                  style: task.isCompleted
                      ? AppTypography.strikethrough(AppTypography.bodyLarge)
                          .copyWith(color: AppColors.gray500)
                      : AppTypography.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Description
                if (task.description != null) ...[
                  AppSpacing.verticalSpaceXXS,
                  Text(
                    task.description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Tags and priority
                if (task.tags.isNotEmpty || task.priority.index > 0) ...[
                  AppSpacing.verticalSpaceXS,
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xxs,
                    children: [
                      // Priority
                      if (task.priority.index > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.getPriorityColor(task.priority.index)
                                .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusXS),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag,
                                size: 10,
                                color: AppColors.getPriorityColor(
                                    task.priority.index),
                              ),
                              AppSpacing.horizontalSpaceXXS,
                              Text(
                                _getPriorityText(task.priority),
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.getPriorityColor(
                                      task.priority.index),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Tags
                      ...task.tags.take(3).map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusXS),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Priority indicator bar
          if (task.priority.index > 2)
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.getPriorityColor(task.priority.index),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.gray600,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            'Tap the + button to add a new task',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
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

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.critical:
        return 'Critical';
      default:
        return '';
    }
  }
}
