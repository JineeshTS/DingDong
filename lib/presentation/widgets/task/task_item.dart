import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';
import '../../../domain/entities/task_entity.dart';

/// Task list item widget
class TaskItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onUncomplete;
  final ValueChanged<bool?>? onCheckboxChanged;
  final bool showListName;
  final bool showDueDate;
  final bool showPriority;
  final bool showTags;
  final bool isSelected;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.onUncomplete,
    this.onCheckboxChanged,
    this.showListName = false,
    this.showDueDate = true,
    this.showPriority = true,
    this.showTags = true,
    this.isSelected = false,
  });

  Color _getPriorityColor() {
    return AppColors.getPriorityColor(task.priority.index);
  }

  bool get _isOverdue {
    if (task.isCompleted || task.dueDate == null) return false;
    return task.dueDate!.isBefore(DateTime.now());
  }

  String _formatDueDate() {
    if (task.dueDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    if (dueDate == today) {
      if (task.dueTime != null) {
        final time = DateTime(
          now.year,
          now.month,
          now.day,
          task.dueTime!.inHours,
          task.dueTime!.inMinutes % 60,
        );
        return 'Today, ${DateFormat.jm().format(time)}';
      }
      return 'Today';
    } else if (dueDate == tomorrow) {
      return 'Tomorrow';
    } else if (dueDate.isBefore(today)) {
      final difference = today.difference(dueDate).inDays;
      if (difference == 1) {
        return 'Yesterday';
      }
      return '$difference days overdue';
    } else {
      return DateFormat.MMMd().format(task.dueDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = task.isCompleted
        ? (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusMd,
              )
            : null,
        padding: AppSpacing.listItemPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            _TaskCheckbox(
              isCompleted: task.isCompleted,
              priority: task.priority,
              onChanged: (value) {
                if (value == true) {
                  onComplete?.call();
                } else {
                  onUncomplete?.call();
                }
                onCheckboxChanged?.call(value);
              },
            ),
            const SizedBox(width: AppSpacing.md),

            // Task content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    task.title,
                    style: AppTypography.taskTitle(
                      color: textColor,
                      completed: task.isCompleted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Description (if present)
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      task.description!,
                      style: AppTypography.taskDescription(color: subtitleColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Metadata row
                  if (showDueDate && task.dueDate != null ||
                      showListName ||
                      showTags && task.tags.isNotEmpty ||
                      task.subtasks.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _TaskMetadataRow(
                      task: task,
                      showListName: showListName,
                      showDueDate: showDueDate,
                      showTags: showTags,
                      isOverdue: _isOverdue,
                      formattedDueDate: _formatDueDate(),
                    ),
                  ],
                ],
              ),
            ),

            // Priority indicator
            if (showPriority && task.priority.index > 0)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: _PriorityIndicator(priority: task.priority),
              ),
          ],
        ),
      ),
    );
  }
}

/// Task checkbox widget
class _TaskCheckbox extends StatelessWidget {
  final bool isCompleted;
  final TaskPriority priority;
  final ValueChanged<bool?>? onChanged;

  const _TaskCheckbox({
    required this.isCompleted,
    required this.priority,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = AppColors.getPriorityColor(priority.index);

    return SizedBox(
      width: 24,
      height: 24,
      child: Checkbox(
        value: isCompleted,
        onChanged: onChanged,
        shape: const CircleBorder(),
        side: BorderSide(
          color: isCompleted ? AppColors.success : priorityColor,
          width: 2,
        ),
        activeColor: AppColors.success,
        checkColor: Colors.white,
      ),
    );
  }
}

/// Task metadata row (due date, tags, subtasks count)
class _TaskMetadataRow extends StatelessWidget {
  final TaskEntity task;
  final bool showListName;
  final bool showDueDate;
  final bool showTags;
  final bool isOverdue;
  final String formattedDueDate;

  const _TaskMetadataRow({
    required this.task,
    required this.showListName,
    required this.showDueDate,
    required this.showTags,
    required this.isOverdue,
    required this.formattedDueDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Due date
        if (showDueDate && task.dueDate != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: isOverdue ? AppColors.error : subtitleColor,
              ),
              const SizedBox(width: 4),
              Text(
                formattedDueDate,
                style: AppTypography.taskDueDate(
                  color: subtitleColor,
                  overdue: isOverdue,
                ),
              ),
            ],
          ),

        // Subtasks count
        if (task.subtasks.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.checklist,
                size: 14,
                color: subtitleColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${task.completedSubtaskCount}/${task.subtasks.length}',
                style: AppTypography.labelSmall(color: subtitleColor),
              ),
            ],
          ),

        // Attachments count
        if (task.attachmentIds.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.attach_file,
                size: 14,
                color: subtitleColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${task.attachmentIds.length}',
                style: AppTypography.labelSmall(color: subtitleColor),
              ),
            ],
          ),

        // Comments count
        if (task.commentCount > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 14,
                color: subtitleColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${task.commentCount}',
                style: AppTypography.labelSmall(color: subtitleColor),
              ),
            ],
          ),

        // Tags (show first 2)
        if (showTags && task.tags.isNotEmpty)
          ...task.tags.take(2).map((tag) => _TagChip(
                label: tag,
                color: AppColors.getTagColor(tag.hashCode),
              )),

        // Show +N if more tags
        if (showTags && task.tags.length > 2)
          _TagChip(
            label: '+${task.tags.length - 2}',
            color: Colors.grey,
          ),
      ],
    );
  }
}

/// Priority indicator dot
class _PriorityIndicator extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityIndicator({required this.priority});

  IconData _getIcon() {
    switch (priority) {
      case TaskPriority.low:
        return Icons.flag_outlined;
      case TaskPriority.medium:
        return Icons.flag_outlined;
      case TaskPriority.high:
        return Icons.flag;
      case TaskPriority.critical:
        return Icons.priority_high;
      default:
        return Icons.flag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getPriorityColor(priority.index);

    return Icon(
      _getIcon(),
      size: 18,
      color: color,
    );
  }
}

/// Small tag chip
class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall(color: color),
      ),
    );
  }
}

/// Compact task item for smaller spaces
class CompactTaskItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const CompactTaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = task.isCompleted
        ? (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            _TaskCheckbox(
              isCompleted: task.isCompleted,
              priority: task.priority,
              onChanged: (_) => onComplete?.call(),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                task.title,
                style: AppTypography.bodyMedium(color: textColor).copyWith(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
