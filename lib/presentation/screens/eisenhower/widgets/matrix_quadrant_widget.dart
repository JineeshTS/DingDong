import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/design_system.dart';
import '../../../../domain/entities/task_entity.dart';
import '../../../providers/eisenhower/eisenhower.dart';
import 'matrix_task_card.dart';

/// Matrix quadrant widget
///
/// Displays one quadrant of the Eisenhower Matrix with:
/// - Quadrant header with title and count
/// - List of tasks
/// - Color-coded styling
/// - Tap to focus mode
class MatrixQuadrantWidget extends ConsumerWidget {
  const MatrixQuadrantWidget({
    super.key,
    required this.quadrant,
    this.onTap,
  });

  final MatrixQuadrant quadrant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksInQuadrantProvider(quadrant));
    final taskCount = tasks.length;
    final incompleteCount = tasks.where((t) => !t.isCompleted).length;

    final colors = _getQuadrantColors();

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(
          color: colors.borderColor,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quadrant header
          _buildHeader(
            colors,
            taskCount,
            incompleteCount,
          ),

          // Divider
          Container(
            height: 1,
            color: colors.borderColor,
          ),

          // Task list
          Expanded(
            child: tasks.isEmpty
                ? _buildEmptyState(colors)
                : _buildTaskList(tasks, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    _QuadrantColors colors,
    int taskCount,
    int incompleteCount,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusMD),
          topRight: Radius.circular(AppSpacing.radiusMD),
        ),
        child: Padding(
          padding: AppSpacing.paddingSM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Title
                  Expanded(
                    child: Text(
                      quadrant.title,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: AppTypography.bold,
                        color: colors.titleColor,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Task count badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.badgeColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                    ),
                    child: Text(
                      '$incompleteCount/$taskCount',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: AppTypography.bold,
                        color: colors.titleColor,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2),

              // Subtitle
              Text(
                quadrant.subtitle,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.subtitleColor,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskEntity> tasks, _QuadrantColors colors) {
    return ListView.builder(
      padding: AppSpacing.paddingSM,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return MatrixTaskCard(task: tasks[index]);
      },
    );
  }

  Widget _buildEmptyState(_QuadrantColors colors) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 32,
              color: colors.subtitleColor.withOpacity(0.5),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'No tasks',
              style: AppTypography.bodySmall.copyWith(
                color: colors.subtitleColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _QuadrantColors _getQuadrantColors() {
    switch (quadrant) {
      case MatrixQuadrant.urgentImportant:
        return _QuadrantColors(
          backgroundColor: AppColors.error.withOpacity(0.05),
          borderColor: AppColors.error.withOpacity(0.3),
          titleColor: AppColors.error.withOpacity(0.9),
          subtitleColor: AppColors.error.withOpacity(0.7),
          badgeColor: AppColors.error.withOpacity(0.15),
        );

      case MatrixQuadrant.notUrgentImportant:
        return _QuadrantColors(
          backgroundColor: AppColors.primary.withOpacity(0.05),
          borderColor: AppColors.primary.withOpacity(0.3),
          titleColor: AppColors.primary.withOpacity(0.9),
          subtitleColor: AppColors.primary.withOpacity(0.7),
          badgeColor: AppColors.primary.withOpacity(0.15),
        );

      case MatrixQuadrant.urgentNotImportant:
        return _QuadrantColors(
          backgroundColor: AppColors.warning.withOpacity(0.05),
          borderColor: AppColors.warning.withOpacity(0.3),
          titleColor: AppColors.warning.withOpacity(0.9),
          subtitleColor: AppColors.warning.withOpacity(0.7),
          badgeColor: AppColors.warning.withOpacity(0.15),
        );

      case MatrixQuadrant.notUrgentNotImportant:
        return _QuadrantColors(
          backgroundColor: AppColors.gray100,
          borderColor: AppColors.gray300,
          titleColor: AppColors.gray700,
          subtitleColor: AppColors.gray600,
          badgeColor: AppColors.gray200,
        );
    }
  }
}

/// Quadrant colors helper class
class _QuadrantColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color badgeColor;

  _QuadrantColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.badgeColor,
  });
}
