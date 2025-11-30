import 'package:flutter/material.dart';

/// Time Stats Card Widget
///
/// Displays time tracking statistics in a card format
class TimeStatsCard extends StatelessWidget {
  final String totalTime;
  final String billableTime;
  final double billablePercentage;
  final String averageDailyTime;
  final int totalSessions;
  final double averageQuality;

  const TimeStatsCard({
    super.key,
    required this.totalTime,
    required this.billableTime,
    required this.billablePercentage,
    required this.averageDailyTime,
    required this.totalSessions,
    required this.averageQuality,
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
              'Time Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Total and Billable Time
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.access_time_rounded,
                    label: 'Total Time',
                    value: totalTime,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.attach_money_rounded,
                    label: 'Billable',
                    value: billableTime,
                    subtitle: '${billablePercentage.toStringAsFixed(0)}%',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Average Daily and Sessions
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'Daily Avg',
                    value: averageDailyTime,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.timer_rounded,
                    label: 'Sessions',
                    value: '$totalSessions',
                    subtitle: '${averageQuality.toStringAsFixed(0)}% quality',
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
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
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
              size: 18,
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
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ),
        ],
      ],
    );
  }
}
