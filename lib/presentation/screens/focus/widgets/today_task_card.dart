import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/design_system.dart';
import '../../../../domain/entities/task_entity.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/focus/focus.dart';

/// Today task card widget
///
/// Displays a task in the Focus/Today view with:
/// - Quick complete button
/// - Task title and description
/// - Time and priority indicators
/// - Swipe actions
class TodayTaskCard extends ConsumerWidget {
  const TodayTaskCard({
    super.key,
    required this.task,
    this.showTime = true,
    this.isOverdue = false,
  });

  final TaskEntity task;
  final bool showTime;
  final bool isOverdue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        side: BorderSide(
          color: isOverdue ? AppColors.error.withOpacity(0.3) : AppColors.gray200,
          width: isOverdue ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/home/task/${task.id}'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick complete checkbox
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
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
                    // Refresh focus view
                    ref.invalidate(focusNotifierProvider);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),

              AppSpacing.horizontalSpaceSM,

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Time + Priority
                    if (showTime || task.priority.index > 0) ...{
                      Row(
                        children: [
                          // Time
                          if (showTime && task.dueDate != null) ...{
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isOverdue
                                    ? AppColors.error.withOpacity(0.1)
                                    : AppColors.primary.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusXS),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: isOverdue
                                        ? AppColors.error
                                        : AppColors.primary,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    _formatTime(task.dueDate!),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isOverdue
                                          ? AppColors.error
                                          : AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: AppTypography.semiBold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: AppSpacing.xs),
                          },

                          // Priority
                          if (task.priority.index > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag,
                                  size: 14,
                                  color: AppColors.getPriorityColor(
                                      task.priority.index),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  _getPriorityText(task.priority),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.getPriorityColor(
                                        task.priority.index),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),

                          // Overdue badge
                          if (isOverdue) ...{
                            SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusXS),
                              ),
                              child: Text(
                                'OVERDUE',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.white,
                                  fontSize: 9,
                                  fontWeight: AppTypography.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          },
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                    },

                    // Title
                    Text(
                      task.title,
                      style: task.isCompleted
                          ? AppTypography.strikethrough(AppTypography.bodyLarge)
                              .copyWith(color: AppColors.gray500)
                          : AppTypography.bodyLarge.copyWith(
                              fontWeight: AppTypography.semiBold,
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...{
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        task.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gray600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    },

                    // Tags
                    if (task.tags.isNotEmpty) ...{
                      SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: task.tags.take(3).map((tag) {
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
                        }).toList(),
                      ),
                    },
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    if (hour == 0 && minute == 0) {
      return 'All Day';
    }

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');

    return '$displayHour:$displayMinute $period';
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
