import 'package:flutter/material.dart';

/// Focus Stats Card Widget
///
/// Displays focus session statistics in a card format
class FocusStatsCard extends StatelessWidget {
  final int completedPomodoros;
  final int totalSessionsToday;
  final Duration totalFocusTimeToday;
  final int currentStreak;
  final int pomodorosUntilLongBreak;

  const FocusStatsCard({
    super.key,
    required this.completedPomodoros,
    required this.totalSessionsToday,
    required this.totalFocusTimeToday,
    required this.currentStreak,
    required this.pomodorosUntilLongBreak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.check_circle_rounded,
                    label: 'Completed',
                    value: '$completedPomodoros',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.timer_rounded,
                    label: 'Focus Time',
                    value: _formatDuration(totalFocusTimeToday),
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Streak',
                    value: '$currentStreak days',
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.coffee_rounded,
                    label: 'Until Break',
                    value: '$pomodorosUntilLongBreak',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

/// Compact Focus Stats Widget
///
/// A more compact version for displaying in app bar or smaller spaces
class CompactFocusStats extends StatelessWidget {
  final int completedPomodoros;
  final int pomodorosUntilLongBreak;

  const CompactFocusStats({
    super.key,
    required this.completedPomodoros,
    required this.pomodorosUntilLongBreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Completed pomodoros indicator
        _buildPomodoroIndicator(context, completedPomodoros),
        const SizedBox(width: 8),
        // Text summary
        Text(
          '$completedPomodoros / ${completedPomodoros + pomodorosUntilLongBreak}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildPomodoroIndicator(BuildContext context, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            index < count
                ? Icons.circle
                : Icons.circle_outlined,
            size: 12,
            color: index < count
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
