import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/design_system.dart';
import '../../../domain/entities/productivity_insight.dart';
import '../../providers/ai/ai_productivity_providers.dart';
import '../common/widgets.dart';

/// Productivity Insights Panel
///
/// Displays AI-generated productivity insights and recommendations
class ProductivityInsightsPanel extends ConsumerWidget {
  const ProductivityInsightsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAnalyzing = ref.watch(isAnalyzingProductivityProvider);
    final hasInsights = ref.watch(hasProductivityInsightsProvider);
    final activeInsights = ref.watch(activeProductivityInsightsProvider);
    final metrics = ref.watch(productivityMetricsProvider);

    if (isAnalyzing) {
      return _buildLoading();
    }

    if (!hasInsights && metrics == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Metrics Dashboard
        if (metrics != null) ...[
          _ProductivityMetricsDashboard(metrics: metrics),
          AppSpacing.verticalSpaceSM,
        ],

        // Insights
        if (hasInsights)
          AppCard(
            margin: EdgeInsets.all(AppSpacing.md),
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, activeInsights.length),
                AppSpacing.verticalSpaceSM,
                ...activeInsights.map((insight) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xs),
                    child: _InsightItem(insight: insight),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLoading() {
    return AppCard(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          AppSpacing.horizontalSpaceSM,
          Text(
            'Analyzing your productivity...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, int count) {
    final hasHighPriority = ref.watch(hasHighPriorityInsightsProvider);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: AppSpacing.borderRadiusSM,
          ),
          child: const Icon(
            Icons.psychology,
            size: 20,
            color: AppColors.secondary,
          ),
        ),
        AppSpacing.horizontalSpaceSM,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productivity Insights',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              Text(
                '$count ${count == 1 ? 'insight' : 'insights'} for you',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
        if (hasHighPriority)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusXS,
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Text(
              'Action Needed',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.error,
                fontWeight: AppTypography.semiBold,
              ),
            ),
          ),
      ],
    );
  }
}

/// Productivity Metrics Dashboard
class _ProductivityMetricsDashboard extends StatelessWidget {
  final ProductivityMetrics metrics;

  const _ProductivityMetricsDashboard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dashboard, size: 20, color: AppColors.primary),
              AppSpacing.horizontalSpaceXS,
              Text(
                'Your Productivity',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,

          // Workload Level
          _MetricRow(
            icon: Icons.work_outline,
            label: 'Workload',
            value: '${metrics.workloadLevel.emoji} ${metrics.workloadLevel.displayName}',
            subtitle: metrics.workloadLevel.description,
            color: _getWorkloadColor(metrics.workloadLevel),
          ),
          AppSpacing.verticalSpaceXS,

          // Energy Level
          _MetricRow(
            icon: Icons.bolt,
            label: 'Energy Level',
            value: '${metrics.currentEnergyLevel.emoji} ${metrics.currentEnergyLevel.displayName}',
            subtitle: metrics.currentEnergyLevel.recommendation,
            color: AppColors.warning,
          ),
          AppSpacing.verticalSpaceXS,

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Completed Today',
                  value: metrics.completedToday.toString(),
                  color: AppColors.success,
                ),
              ),
              AppSpacing.horizontalSpaceXS,
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Focus Streak',
                  value: metrics.currentFocusStreak.toString(),
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getWorkloadColor(WorkloadLevel level) {
    switch (level) {
      case WorkloadLevel.light:
        return AppColors.success;
      case WorkloadLevel.balanced:
        return AppColors.primary;
      case WorkloadLevel.busy:
        return AppColors.warning;
      case WorkloadLevel.overloaded:
        return AppColors.error;
    }
  }
}

/// Metric Row
class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
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
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          AppSpacing.horizontalSpaceXS,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: AppTypography.semiBold,
                    color: color,
                  ),
                ),
                if (subtitle != null) ...[
                  AppSpacing.verticalSpaceXXS,
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat Card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
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
        children: [
          Icon(icon, size: 24, color: color),
          AppSpacing.verticalSpaceXXS,
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: AppTypography.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Individual Insight Item
class _InsightItem extends ConsumerWidget {
  final ProductivityInsight insight;

  const _InsightItem({required this.insight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: _getPriorityColor().withOpacity(0.05),
        borderRadius: AppSpacing.borderRadiusSM,
        border: Border.all(
          color: _getPriorityColor().withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: _getPriorityColor().withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusXS,
                ),
                child: Text(
                  insight.type.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              AppSpacing.horizontalSpaceSM,

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            insight.title,
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: AppTypography.semiBold,
                            ),
                          ),
                        ),
                        _PriorityBadge(priority: insight.priority),
                      ],
                    ),
                    AppSpacing.verticalSpaceXXS,
                    Text(
                      insight.message,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.gray700,
                      ),
                    ),
                  ],
                ),
              ),

              // Dismiss button
              AppSpacing.horizontalSpaceXS,
              AppIconButton(
                icon: Icons.close,
                onPressed: () {
                  ref
                      .read(aiProductivityNotifierProvider.notifier)
                      .dismissInsight(insight.id);
                },
                iconSize: 18,
                tooltip: 'Dismiss',
              ),
            ],
          ),

          // Action button
          if (insight.isActionable) ...[
            AppSpacing.verticalSpaceSM,
            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: () {
                  // Mark as actioned
                  ref
                      .read(aiProductivityNotifierProvider.notifier)
                      .markInsightActioned(insight.id);

                  // Navigate to action route
                  if (insight.actionRoute != null) {
                    context.push(
                      insight.actionRoute!,
                      extra: insight.actionData,
                    );
                  }
                },
                variant: AppButtonVariant.outlined,
                size: AppButtonSize.small,
                child: Text(insight.actionLabel ?? 'Take Action'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (insight.priority) {
      case InsightPriority.high:
        return AppColors.error;
      case InsightPriority.medium:
        return AppColors.warning;
      case InsightPriority.low:
        return AppColors.primary;
    }
  }
}

/// Priority Badge
class _PriorityBadge extends StatelessWidget {
  final InsightPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
        vertical: AppSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusXS,
        border: Border.all(color: _getColor().withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        _getLabel(),
        style: AppTypography.labelSmall.copyWith(
          color: _getColor(),
          fontWeight: AppTypography.semiBold,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (priority) {
      case InsightPriority.high:
        return AppColors.error;
      case InsightPriority.medium:
        return AppColors.warning;
      case InsightPriority.low:
        return AppColors.gray600;
    }
  }

  String _getLabel() {
    switch (priority) {
      case InsightPriority.high:
        return 'HIGH';
      case InsightPriority.medium:
        return 'MED';
      case InsightPriority.low:
        return 'LOW';
    }
  }
}

/// Productivity Coach Button
///
/// Floating action button to trigger productivity analysis
class ProductivityCoachButton extends ConsumerWidget {
  final VoidCallback? onPressed;

  const ProductivityCoachButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInsights = ref.watch(hasProductivityInsightsProvider);
    final hasHighPriority = ref.watch(hasHighPriorityInsightsProvider);

    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(
        Icons.psychology,
        color: hasHighPriority ? AppColors.error : AppColors.white,
      ),
      label: Text(
        hasInsights ? 'View Insights' : 'Get Insights',
        style: TextStyle(
          color: hasHighPriority ? AppColors.error : AppColors.white,
        ),
      ),
      backgroundColor: hasHighPriority
          ? AppColors.error.withOpacity(0.1)
          : AppColors.primary,
    );
  }
}
