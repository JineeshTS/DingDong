import 'package:flutter/material.dart';
import '../../../providers/time_tracking/time_tracking_state.dart';

/// Task Time List Widget
///
/// Displays a list of tasks with time spent and estimate comparisons
class TaskTimeList extends StatelessWidget {
  final List<TaskTimeComparison> comparisons;
  final VoidCallback? onTaskTap;

  const TaskTimeList({
    super.key,
    required this.comparisons,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    if (comparisons.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 48,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No time tracked yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a focus session to track time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Time by Task',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '${comparisons.length} tasks',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comparisons.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final comparison = comparisons[index];
              return TaskTimeItem(
                comparison: comparison,
                onTap: onTaskTap,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Task Time Item Widget
class TaskTimeItem extends StatelessWidget {
  final TaskTimeComparison comparison;
  final VoidCallback? onTap;

  const TaskTimeItem({
    super.key,
    required this.comparison,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasEstimate = comparison.estimatedTime != null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    comparison.taskTitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(comparison.actualTime),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Session count
                Icon(
                  Icons.timer_rounded,
                  size: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${comparison.sessionCount} sessions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
                const SizedBox(width: 16),
                // Quality
                Icon(
                  Icons.psychology_rounded,
                  size: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${comparison.averageQuality.toStringAsFixed(0)}% quality',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ],
            ),

            // Estimate comparison
            if (hasEstimate) ...[
              const SizedBox(height: 8),
              _buildEstimateComparison(context, comparison),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEstimateComparison(
    BuildContext context,
    TaskTimeComparison comparison,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (comparison.isOnTrack) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_rounded;
      statusText = 'On track';
    } else if (comparison.isOverEstimate) {
      statusColor = Colors.orange;
      statusIcon = Icons.arrow_upward_rounded;
      final variance = comparison.variancePercentage!;
      statusText = '+${variance.toStringAsFixed(0)}% over';
    } else {
      statusColor = Colors.blue;
      statusIcon = Icons.arrow_downward_rounded;
      final variance = comparison.variancePercentage!.abs();
      statusText = '${variance.toStringAsFixed(0)}% under';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            'Est: ${_formatDuration(comparison.estimatedTime!)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            '•',
            style: TextStyle(color: statusColor),
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
