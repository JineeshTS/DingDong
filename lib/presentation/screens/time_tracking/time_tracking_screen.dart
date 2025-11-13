import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/time_tracking/time_tracking_providers.dart';
import '../../providers/time_tracking/time_tracking_state.dart';
import 'widgets/time_stats_card.dart';
import 'widgets/task_time_list.dart';
import 'widgets/daily_time_chart.dart';
import 'widgets/period_selector.dart';

/// Time Tracking Screen
///
/// Main screen for time tracking featuring:
/// - Time tracking statistics
/// - Daily time breakdown chart
/// - Time by task breakdown
/// - Estimates vs actuals comparison
/// - Period filtering
/// - Export capabilities
class TimeTrackingScreen extends ConsumerWidget {
  const TimeTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timeTrackingNotifierProvider);
    final notifier = ref.read(timeTrackingNotifierProvider.notifier);

    // Show error snackbar if there's an error
    ref.listen<String?>(timeTrackingErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracking'),
        actions: [
          // Filter button
          IconButton(
            icon: Badge(
              isLabelVisible: ref.watch(hasActiveFiltersProvider),
              child: const Icon(Icons.filter_list_rounded),
            ),
            onPressed: () => _showFiltersDialog(context, ref),
          ),
          // Export button
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _showExportDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await notifier.loadTimeData();
          },
          child: state.isLoading && state.sessions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Period Selector
                      PeriodSelector(
                        currentPeriod: state.period,
                        onPeriodSelected: (period) {
                          notifier.changePeriod(period);
                        },
                        onCustomRangeTap: () =>
                            _showCustomRangePicker(context, notifier),
                      ),

                      const SizedBox(height: 16),

                      // Time Stats Card
                      TimeStatsCard(
                        totalTime: state.formattedTotalTime,
                        billableTime: state.formattedBillableTime,
                        billablePercentage: state.billablePercentage,
                        averageDailyTime: state.formattedAverageDailyTime,
                        totalSessions: state.totalSessions,
                        averageQuality: state.averageSessionQuality,
                      ),

                      const SizedBox(height: 16),

                      // Daily Time Chart
                      DailyTimeChart(
                        entries: state.dailyEntries,
                      ),

                      const SizedBox(height: 16),

                      // Task Time Breakdown
                      TaskTimeList(
                        comparisons: state.taskComparisons,
                        onTaskTap: () {
                          // TODO: Navigate to task detail
                        },
                      ),

                      const SizedBox(height: 16),

                      // Estimation Accuracy Section
                      if (state.taskComparisons
                          .where((c) => c.estimatedTime != null)
                          .isNotEmpty) ...[
                        _buildEstimationAccuracyCard(context, ref),
                        const SizedBox(height: 16),
                      ],

                      // Tips
                      _buildTipsCard(context),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildEstimationAccuracyCard(BuildContext context, WidgetRef ref) {
    final overEstimate = ref.watch(overEstimateTasksProvider);
    final underEstimate = ref.watch(underEstimateTasksProvider);
    final onTrack = ref.watch(onTrackTasksProvider);
    final total = overEstimate.length + underEstimate.length + onTrack.length;

    if (total == 0) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimation Accuracy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAccuracyItem(
                    context,
                    icon: Icons.check_circle_rounded,
                    label: 'On Track',
                    count: onTrack.length,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildAccuracyItem(
                    context,
                    icon: Icons.arrow_upward_rounded,
                    label: 'Over',
                    count: overEstimate.length,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildAccuracyItem(
                    context,
                    icon: Icons.arrow_downward_rounded,
                    label: 'Under',
                    count: underEstimate.length,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: onTrack.length / total,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              '${((onTrack.length / total) * 100).toStringAsFixed(0)}% of tasks estimated accurately',
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
    );
  }

  Widget _buildAccuracyItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }

  Widget _buildTipsCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tip: Start focus sessions on your tasks to automatically track time. '
                'Add estimates to see how accurate your planning is!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filters'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Billable hours only'),
                value: ref.read(activeFiltersProvider)['showOnlyBillable']
                    as bool,
                onChanged: (value) {
                  ref
                      .read(timeTrackingNotifierProvider.notifier)
                      .toggleBillableFilter();
                },
              ),
              const Divider(),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (ref.watch(hasActiveFiltersProvider))
                ListTile(
                  leading: const Icon(Icons.clear_all_rounded),
                  title: const Text('Clear all filters'),
                  onTap: () {
                    ref
                        .read(timeTrackingNotifierProvider.notifier)
                        .clearFilters();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Time Data'),
        content: const Text(
          'Export functionality will be available in a future update. '
          'You\'ll be able to export your time tracking data as CSV or PDF.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCustomRangePicker(
    BuildContext context,
    TimeTrackingNotifier notifier,
  ) async {
    final now = DateTime.now();
    final initialRange = DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: initialRange,
    );

    if (picked != null) {
      notifier.setCustomRange(picked.start, picked.end);
    }
  }
}
