import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/design_system.dart';
import '../../../../domain/entities/task_entity.dart';
import '../../../providers/task_provider.dart';

/// Matrix task card widget
///
/// Compact task card optimized for Eisenhower Matrix display with:
/// - Minimal design for 2×2 grid
/// - Priority indicator
/// - Due date badge
/// - Quick complete checkbox
class MatrixTaskCard extends ConsumerWidget {
  const MatrixTaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  final TaskEntity task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        side: BorderSide(
          color: AppColors.gray200,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.push('/home/task/${task.id}'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              SizedBox(
                width: 18,
                height: 18,
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

              AppSpacing.horizontalSpaceXS,

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      task.title,
                      style: task.isCompleted
                          ? AppTypography.strikethrough(AppTypography.bodySmall)
                              .copyWith(
                              color: AppColors.gray500,
                              fontSize: 13,
                            )
                          : AppTypography.bodySmall.copyWith(
                              fontWeight: AppTypography.medium,
                              fontSize: 13,
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Due date and priority
                    if (task.dueDate != null || task.priority.index > 0) ...{
                      SizedBox(height: 4),
                      Row(
                        children: [
                          // Due date
                          if (task.dueDate != null) ...{
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getDueDateColor().withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusXS),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.event,
                                    size: 10,
                                    color: _getDueDateColor(),
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    _formatDueDate(task.dueDate!),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: _getDueDateColor(),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 4),
                          },

                          // Priority
                          if (task.priority.index > 0)
                            Icon(
                              Icons.flag,
                              size: 12,
                              color: AppColors.getPriorityColor(
                                  task.priority.index),
                            ),
                        ],
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
      return 'Tmr';
    } else if (dueDate.isBefore(today)) {
      final diff = today.difference(dueDate).inDays;
      return '-${diff}d';
    } else {
      final diff = dueDate.difference(today).inDays;
      return '+${diff}d';
    }
  }
}
