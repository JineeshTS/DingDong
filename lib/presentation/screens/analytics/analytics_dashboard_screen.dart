import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/design_system.dart';
import '../../providers/analytics/analytics.dart';
import 'widgets/simple_bar_chart.dart';
import 'widgets/stat_card.dart';

/// Analytics Dashboard screen
///
/// Displays comprehensive task and productivity analytics:
/// - Task completion statistics
/// - Completion rate and streaks
/// - Priority distribution
/// - Productivity trends
/// - Charts and visualizations
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh on init
    Future.microtask(() {
      ref.read(analyticsNotifierProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsNotifierProvider);
    final stats = ref.watch(analyticsStatsProvider);
    final dailyCounts = ref.watch(dailyTaskCountsProvider);
    final periodLabel = ref.watch(analyticsPeriodLabelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          // Period selector
          PopupMenuButton<AnalyticsPeriod>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  periodLabel,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: AppColors.primary),
              ],
            ),
            onSelected: (period) {
              ref.read(analyticsNotifierProvider.notifier).setPeriod(period);
            },
            itemBuilder: (context) => AnalyticsPeriod.values
                .map((period) => PopupMenuItem(
                      value: period,
                      child: Text(_getPeriodLabel(period)),
                    ))
                .toList(),
          ),

          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(analyticsNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(analyticsNotifierProvider.notifier).refresh();
        },
        child: analyticsState.isLoading && stats == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message
                    if (analyticsState.error != null) ...{
                      _buildErrorBanner(analyticsState.error!),
                      AppSpacing.verticalSpaceMD,
                    },

                    if (stats != null) ...[
                      // Header
                      _buildHeader(periodLabel),

                      AppSpacing.verticalSpaceMD,

                      // Key metrics grid
                      _buildKeyMetrics(stats),

                      AppSpacing.verticalSpaceXL,

                      // Completion trend chart
                      _buildTrendSection(dailyCounts),

                      AppSpacing.verticalSpaceXL,

                      // Streaks section
                      _buildStreaksSection(stats),

                      AppSpacing.verticalSpaceXL,

                      // Priority distribution
                      _buildPrioritySection(stats),

                      AppSpacing.verticalSpaceXL,

                      // Additional insights
                      _buildInsightsSection(stats),

                      AppSpacing.verticalSpaceXXL,
                    ] else
                      _buildEmptyState(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(String periodLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Productivity',
          style: AppTypography.headlineLarge.copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          periodLabel,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetrics(AnalyticsStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          label: 'Total Tasks',
          value: stats.totalTasks.toString(),
          icon: Icons.task_alt,
          color: AppColors.primary,
        ),
        StatCard(
          label: 'Completed',
          value: stats.completedTasks.toString(),
          icon: Icons.check_circle,
          color: AppColors.success,
        ),
        StatCard(
          label: 'In Progress',
          value: stats.incompleteTasks.toString(),
          icon: Icons.pending_actions,
          color: AppColors.warning,
        ),
        StatCard(
          label: 'Completion Rate',
          value: '${stats.completionRate.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildTrendSection(List<DailyTaskCount> dailyCounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completion Trend',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        AppSpacing.verticalSpaceSM,
        Card(
          elevation: 2,
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: SimpleBarChart(
              data: dailyCounts,
              height: 180,
              showLabels: dailyCounts.length <= 7,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreaksSection(AnalyticsStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Streaks',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        AppSpacing.verticalSpaceSM,
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Current Streak',
                value: '${stats.currentStreak}',
                icon: Icons.local_fire_department,
                color: AppColors.error,
                subtitle: '${stats.currentStreak} day${stats.currentStreak != 1 ? 's' : ''}',
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: StatCard(
                label: 'Longest Streak',
                value: '${stats.longestStreak}',
                icon: Icons.star,
                color: AppColors.warning,
                subtitle: '${stats.longestStreak} day${stats.longestStreak != 1 ? 's' : ''}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrioritySection(AnalyticsStats stats) {
    final total = stats.criticalTasks +
        stats.highPriorityTasks +
        stats.mediumPriorityTasks +
        stats.lowPriorityTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority Distribution',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        AppSpacing.verticalSpaceSM,
        Card(
          elevation: 2,
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Column(
              children: [
                _buildPriorityBar(
                  'Critical',
                  stats.criticalTasks,
                  total,
                  AppColors.error,
                ),
                AppSpacing.verticalSpaceSM,
                _buildPriorityBar(
                  'High',
                  stats.highPriorityTasks,
                  total,
                  AppColors.warning,
                ),
                AppSpacing.verticalSpaceSM,
                _buildPriorityBar(
                  'Medium',
                  stats.mediumPriorityTasks,
                  total,
                  AppColors.info,
                ),
                AppSpacing.verticalSpaceSM,
                _buildPriorityBar(
                  'Low',
                  stats.lowPriorityTasks,
                  total,
                  AppColors.gray500,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: AppTypography.semiBold,
              ),
            ),
            Text(
              count.toString(),
              style: AppTypography.bodyMedium.copyWith(
                color: color,
                fontWeight: AppTypography.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(AnalyticsStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        AppSpacing.verticalSpaceSM,
        Card(
          elevation: 2,
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Column(
              children: [
                _buildInsightItem(
                  Icons.calendar_today,
                  'Most Productive Day',
                  stats.mostProductiveDay,
                  AppColors.primary,
                ),
                Divider(height: AppSpacing.lg),
                _buildInsightItem(
                  Icons.timer,
                  'Avg. Completion Time',
                  '${stats.avgCompletionTime.toStringAsFixed(1)} days',
                  AppColors.info,
                ),
                Divider(height: AppSpacing.lg),
                _buildInsightItem(
                  Icons.label,
                  'Total Tags Used',
                  stats.totalTags.toString(),
                  AppColors.success,
                ),
                Divider(height: AppSpacing.lg),
                _buildInsightItem(
                  Icons.folder,
                  'Total Lists',
                  stats.totalLists.toString(),
                  AppColors.warning,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        AppSpacing.horizontalSpaceSM,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              Text(
                value,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          AppSpacing.horizontalSpaceSM,
          Expanded(
            child: Text(
              error,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.error),
            onPressed: () {
              ref.read(analyticsNotifierProvider.notifier).clearError();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 80,
              color: AppColors.gray400,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              'No Data Yet',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              'Complete some tasks to see your analytics',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodLabel(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.today:
        return 'Today';
      case AnalyticsPeriod.week:
        return 'This Week';
      case AnalyticsPeriod.month:
        return 'This Month';
      case AnalyticsPeriod.year:
        return 'This Year';
      case AnalyticsPeriod.allTime:
        return 'All Time';
    }
  }
}
