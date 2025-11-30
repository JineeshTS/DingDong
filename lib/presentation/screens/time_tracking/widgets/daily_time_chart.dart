import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../providers/time_tracking/time_tracking_state.dart';

/// Daily Time Chart Widget
///
/// Displays a bar chart of time tracked per day
class DailyTimeChart extends StatelessWidget {
  final List<DailyTimeEntry> entries;

  const DailyTimeChart({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxTime = entries
        .map((e) => e.totalTime.inMinutes)
        .reduce((a, b) => a > b ? a : b);

    if (maxTime == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No time tracked in this period',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Chart
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: entries.map((entry) {
                  return _buildBar(context, entry, maxTime);
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  context,
                  color: Theme.of(context).colorScheme.primary,
                  label: 'Total',
                ),
                const SizedBox(width: 16),
                _buildLegendItem(
                  context,
                  color: Colors.green,
                  label: 'Billable',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context, DailyTimeEntry entry, int maxMinutes) {
    final totalMinutes = entry.totalTime.inMinutes;
    final billableMinutes = entry.billableTime.inMinutes;

    final totalHeight = (totalMinutes / maxMinutes * 160).clamp(2.0, 160.0);
    final billableHeight =
        (billableMinutes / maxMinutes * 160).clamp(0.0, totalHeight);

    final dayLabel = DateFormat('E').format(entry.date);
    final dateLabel = DateFormat('d').format(entry.date);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Time label
            if (totalMinutes > 0)
              Text(
                _formatMinutes(totalMinutes),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            const SizedBox(height: 4),

            // Bar
            Container(
              width: double.infinity,
              height: totalHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: billableHeight,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Day label
            Column(
              children: [
                Text(
                  dayLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '${hours}h';
      }
      return '${hours}h${mins}m';
    }
    return '${minutes}m';
  }
}
