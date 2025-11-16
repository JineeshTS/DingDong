import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/design_system.dart';
import '../../../domain/entities/smart_schedule.dart';
import '../../providers/ai/smart_schedule_providers.dart';
import '../common/widgets.dart';

/// Smart Schedule View
///
/// Displays AI-generated schedule with optimal time slots for tasks
class SmartScheduleView extends ConsumerWidget {
  const SmartScheduleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScheduling = ref.watch(isSchedulingProvider);
    final hasSchedule = ref.watch(hasScheduleProvider);
    final pendingTasks = ref.watch(pendingScheduledTasksProvider);
    final metrics = ref.watch(schedulingMetricsProvider);

    if (isScheduling) {
      return _buildLoading();
    }

    if (!hasSchedule) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Dashboard
          if (metrics != null) ...[
            _SchedulingMetricsDashboard(metrics: metrics),
            AppSpacing.verticalSpaceMD,
          ],

          // Pending tasks section
          if (pendingTasks.isNotEmpty) ...[
            _buildSectionHeader('Review Schedule', pendingTasks.length),
            AppSpacing.verticalSpaceSM,
            ...pendingTasks.map((task) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ScheduledTaskCard(task: task),
                )),
            AppSpacing.verticalSpaceMD,
          ],

          // Conflicts section
          _ConflictsSection(),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          AppSpacing.verticalSpaceMD,
          Text(
            'Finding optimal time slots...',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.gray600,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            'Analyzing energy levels, deadlines, and calendar availability',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 80,
              color: AppColors.gray400,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'No Schedule Yet',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: AppTypography.semiBold,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              'AI will find the perfect time slots for your tasks based on energy levels, deadlines, and availability.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: AppTypography.semiBold,
          ),
        ),
        AppSpacing.horizontalSpaceXS,
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: AppSpacing.borderRadiusXS,
          ),
          child: Text(
            count.toString(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: AppTypography.semiBold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Scheduling Metrics Dashboard
class _SchedulingMetricsDashboard extends StatelessWidget {
  final SchedulingMetrics metrics;

  const _SchedulingMetricsDashboard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph, size: 20, color: AppColors.primary),
              AppSpacing.horizontalSpaceXS,
              Text(
                'Scheduling Results',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMD,

          // Success rate
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.check_circle,
                  label: 'Success Rate',
                  value: '${metrics.successRatePercentage}%',
                  color: metrics.hasHighSuccessRate
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
              AppSpacing.horizontalSpaceXS,
              Expanded(
                child: _MetricCard(
                  icon: Icons.schedule,
                  label: 'Scheduled',
                  value: '${metrics.successfullyScheduled}/${metrics.totalTasksToSchedule}',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceXS,

          // Time and focus blocks
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.timer,
                  label: 'Total Time',
                  value: '${metrics.totalScheduledHours.toStringAsFixed(1)}h',
                  color: AppColors.info,
                ),
              ),
              AppSpacing.horizontalSpaceXS,
              Expanded(
                child: _MetricCard(
                  icon: Icons.workspaces,
                  label: 'Focus Blocks',
                  value: metrics.focusBlocksCreated.toString(),
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Metric Card
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: AppSpacing.borderRadiusSM,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          AppSpacing.verticalSpaceXS,
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: AppTypography.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Scheduled Task Card
class _ScheduledTaskCard extends ConsumerWidget {
  final ScheduledTask task;

  const _ScheduledTaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task title and confidence
          Row(
            children: [
              Expanded(
                child: Text(
                  task.taskTitle,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
              ),
              _ConfidenceBadge(confidence: task.confidence),
            ],
          ),
          AppSpacing.verticalSpaceSM,

          // Time slot
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: AppSpacing.borderRadiusSM,
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 20, color: AppColors.primary),
                AppSpacing.horizontalSpaceSM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(task.suggestedStartTime),
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                      Text(
                        task.timeSlotDisplay,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${task.estimatedDuration} min',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpaceSM,

          // Reason
          Row(
            children: [
              Text(
                task.reason.icon,
                style: const TextStyle(fontSize: 16),
              ),
              AppSpacing.horizontalSpaceXS,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.reason.displayName,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                    Text(
                      task.reason.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMD,

          // Actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: () {
                    ref
                        .read(smartScheduleNotifierProvider.notifier)
                        .rejectTask(task.taskId);
                  },
                  variant: AppButtonVariant.outlined,
                  size: AppButtonSize.small,
                  child: const Text('Reject'),
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: AppButton(
                  onPressed: () {
                    ref
                        .read(smartScheduleNotifierProvider.notifier)
                        .acceptTask(task.taskId);
                  },
                  size: AppButtonSize.small,
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEE, MMM d').format(date);
    }
  }
}

/// Confidence Badge
class _ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).round();
    final color = _getColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusXS,
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$percentage%',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: AppTypography.semiBold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (confidence >= 0.8) {
      return AppColors.success;
    } else if (confidence >= 0.6) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  IconData _getIcon() {
    if (confidence >= 0.8) {
      return Icons.check_circle;
    } else if (confidence >= 0.6) {
      return Icons.info;
    } else {
      return Icons.warning;
    }
  }
}

/// Conflicts Section
class _ConflictsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasConflicts = ref.watch(hasScheduleConflictsProvider);
    final conflicts = ref.watch(scheduleConflictsProvider);

    if (!hasConflicts) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning, size: 20, color: AppColors.warning),
            AppSpacing.horizontalSpaceXS,
            Text(
              'Scheduling Conflicts',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: AppTypography.semiBold,
              ),
            ),
            AppSpacing.horizontalSpaceXS,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: AppSpacing.borderRadiusXS,
              ),
              child: Text(
                conflicts.length.toString(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.warning,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceSM,
        ...conflicts.map((conflict) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ConflictCard(conflict: conflict),
            )),
      ],
    );
  }
}

/// Conflict Card
class _ConflictCard extends StatelessWidget {
  final ScheduleConflict conflict;

  const _ConflictCard({required this.conflict});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.05),
        borderRadius: AppSpacing.borderRadiusSM,
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.warning),
          AppSpacing.horizontalSpaceSM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conflict.taskTitle,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
                AppSpacing.verticalSpaceXXS,
                Text(
                  conflict.type.displayName,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
                AppSpacing.verticalSpaceXXS,
                Text(
                  conflict.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Smart Schedule Button
///
/// Floating action button to trigger smart scheduling
class SmartScheduleButton extends ConsumerWidget {
  final VoidCallback? onPressed;

  const SmartScheduleButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingScheduledCountProvider);

    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.auto_awesome, color: AppColors.white),
      label: Text(
        pendingCount > 0 ? 'Review ($pendingCount)' : 'Auto-Schedule',
        style: const TextStyle(color: AppColors.white),
      ),
      backgroundColor: AppColors.secondary,
    );
  }
}
