import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/design_system.dart';
import '../../../../domain/entities/task_entity.dart';
import '../../../providers/task_provider.dart';

/// Kanban card widget
///
/// Displays a task as a card in the Kanban board with:
/// - Task title and description
/// - Priority indicator
/// - Due date
/// - Tags
/// - Subtask count
/// - Drag handle
class KanbanCardWidget extends ConsumerWidget {
  const KanbanCardWidget({
    super.key,
    required this.task,
    this.onTap,
  });

  final TaskEntity task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        side: BorderSide(
          color: _getPriorityBorderColor(),
          width: task.priority.index > 2 ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.push('/home/task/${task.id}'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Title + Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Icon(
                    Icons.drag_indicator,
                    size: 16,
                    color: AppColors.gray400,
                  ),
                  AppSpacing.horizontalSpaceXS,

                  // Title
                  Expanded(
                    child: Text(
                      task.title,
                      style: task.isCompleted
                          ? AppTypography.strikethrough(AppTypography.bodyMedium)
                              .copyWith(color: AppColors.gray500)
                          : AppTypography.bodyMedium.copyWith(
                              fontWeight: AppTypography.semiBold,
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  AppSpacing.horizontalSpaceXS,

                  // Checkbox
                  SizedBox(
                    width: 20,
                    height: 20,
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
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),

              // Description
              if (task.description != null && task.description!.isNotEmpty) ...{
                AppSpacing.verticalSpaceXS,
                Text(
                  task.description!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              },

              // Due date
              if (task.dueDate != null) ...{
                AppSpacing.verticalSpaceXS,
                Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 14,
                      color: _getDueDateColor(),
                    ),
                    AppSpacing.horizontalSpaceXXS,
                    Text(
                      _formatDueDate(task.dueDate!),
                      style: AppTypography.labelSmall.copyWith(
                        color: _getDueDateColor(),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              },

              // Tags & metadata
              if (task.tags.isNotEmpty || task.priority.index > 0) ...{
                AppSpacing.verticalSpaceXS,
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    // Priority indicator
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
                              color:
                                  AppColors.getPriorityColor(task.priority.index),
                            ),
                            AppSpacing.horizontalSpaceXXS,
                            Text(
                              _getPriorityText(task.priority),
                              style: AppTypography.labelSmall.copyWith(
                                color:
                                    AppColors.getPriorityColor(task.priority.index),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Tags (max 2)
                    ...task.tags.take(2).map((tag) {
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

                    // More tags indicator
                    if (task.tags.length > 2)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXS),
                        ),
                        child: Text(
                          '+${task.tags.length - 2}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.gray600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              },
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityBorderColor() {
    if (task.priority.index > 2) {
      return AppColors.getPriorityColor(task.priority.index);
    }
    return AppColors.gray200;
  }

  Color _getDueDateColor() {
    if (task.dueDate == null) return AppColors.gray600;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    if (task.isCompleted) return AppColors.gray600;

    if (dueDate.isBefore(today)) {
      return AppColors.error;
    } else if (dueDate.isAtSameMomentAs(today)) {
      return AppColors.warning;
    } else if (dueDate.difference(today).inDays <= 3) {
      return AppColors.primary;
    }

    return AppColors.gray600;
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDate = DateTime(date.year, date.month, date.day);

    if (dueDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dueDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else if (dueDate.isBefore(today)) {
      final diff = today.difference(dueDate).inDays;
      return '$diff day${diff > 1 ? 's' : ''} ago';
    } else {
      final months = [
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
      return '${months[date.month - 1]} ${date.day}';
    }
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
