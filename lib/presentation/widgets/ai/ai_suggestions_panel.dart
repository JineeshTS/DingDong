import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/design_system.dart';
import '../../../domain/entities/ai_suggestion.dart';
import '../../providers/ai/ai_intelligence_providers.dart';
import '../common/widgets.dart';

/// AI Suggestions Panel
///
/// Displays AI-generated suggestions for task properties
class AiSuggestionsPanel extends ConsumerWidget {
  const AiSuggestionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAnalyzing = ref.watch(isAnalyzingProvider);
    final hasSuggestions = ref.watch(hasSuggestionsProvider);
    final activeSuggestions = ref.watch(activeSuggestionsProvider);

    if (isAnalyzing) {
      return _buildLoading();
    }

    if (!hasSuggestions) {
      return const SizedBox.shrink();
    }

    return AppCard(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, activeSuggestions.length),
          AppSpacing.verticalSpaceSM,
          ...activeSuggestions.map((suggestion) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xs),
              child: _SuggestionItem(suggestion: suggestion),
            );
          }),
        ],
      ),
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
            'Analyzing task with AI...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, int count) {
    final hasHighConfidence = ref.watch(hasHighConfidenceSuggestionsProvider);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: AppSpacing.borderRadiusSM,
          ),
          child: const Icon(
            Icons.lightbulb,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        AppSpacing.horizontalSpaceSM,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Suggestions',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              Text(
                '$count ${count == 1 ? 'suggestion' : 'suggestions'} available',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
        if (hasHighConfidence)
          AppButton(
            onPressed: () {
              ref.read(aiIntelligenceNotifierProvider.notifier).applyAllHighConfidence();
            },
            variant: AppButtonVariant.text,
            size: AppButtonSize.small,
            child: const Text('Apply All'),
          ),
      ],
    );
  }
}

/// Individual suggestion item
class _SuggestionItem extends ConsumerWidget {
  final AiSuggestion suggestion;

  const _SuggestionItem({required this.suggestion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: _getConfidenceColor().withOpacity(0.05),
        borderRadius: AppSpacing.borderRadiusSM,
        border: Border.all(
          color: _getConfidenceColor().withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              color: _getConfidenceColor().withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusXS,
            ),
            child: Text(
              suggestion.type.icon,
              style: const TextStyle(fontSize: 16),
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
                    Text(
                      suggestion.type.displayName,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                    AppSpacing.horizontalSpaceXXS,
                    _ConfidenceBadge(confidence: suggestion.confidence),
                  ],
                ),
                AppSpacing.verticalSpaceXXS,
                Text(
                  _formatValue(suggestion.value),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: AppTypography.medium,
                  ),
                ),
                if (suggestion.reasoning.isNotEmpty) ...[
                  AppSpacing.verticalSpaceXXS,
                  Text(
                    suggestion.reasoning,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          AppSpacing.horizontalSpaceXS,
          Column(
            children: [
              AppIconButton(
                icon: Icons.check,
                onPressed: () {
                  ref.read(aiIntelligenceNotifierProvider.notifier).applySuggestion(suggestion);
                },
                iconSize: 18,
                tooltip: 'Apply',
              ),
              AppIconButton(
                icon: Icons.close,
                onPressed: () {
                  ref.read(aiIntelligenceNotifierProvider.notifier).dismissSuggestion(suggestion.id);
                },
                iconSize: 18,
                tooltip: 'Dismiss',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor() {
    if (suggestion.isHighConfidence) return AppColors.success;
    if (suggestion.isMediumConfidence) return AppColors.warning;
    return AppColors.gray500;
  }

  String _formatValue(dynamic value) {
    if (value is int) {
      if (suggestion.type == SuggestionType.priority) {
        return _getPriorityText(value);
      } else if (suggestion.type == SuggestionType.timeEstimate) {
        return '$value minutes';
      }
      return value.toString();
    } else if (value is DateTime) {
      return _formatDate(value);
    } else if (value is String) {
      return value;
    } else if (value is List) {
      return value.join(', ');
    }
    return value.toString();
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Low Priority';
      case 2:
        return 'Medium Priority';
      case 3:
        return 'High Priority';
      case 4:
        return 'Critical Priority';
      default:
        return 'No Priority';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) return 'Today';
    if (taskDate == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (taskDate == today.add(const Duration(days: 2))) return 'In 2 days';

    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Confidence badge
class _ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).round();
    final color = _getColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
        vertical: AppSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusXS,
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        '$percentage%',
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: AppTypography.semiBold,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getColor() {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.5) return AppColors.warning;
    return AppColors.gray500;
  }
}

/// AI Insights Card
///
/// Shows additional AI insights like complexity, optimal time, etc.
class AiInsightsCard extends ConsumerWidget {
  const AiInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAnalysis = ref.watch(hasAnalysisProvider);

    if (!hasAnalysis) {
      return const SizedBox.shrink();
    }

    final complexityLevel = ref.watch(complexityLevelProvider);
    final estimatedDuration = ref.watch(estimatedDurationProvider);
    final optimalTime = ref.watch(optimalScheduleTimeProvider);

    return AppCard(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, size: 20, color: AppColors.primary),
              AppSpacing.horizontalSpaceXS,
              Text(
                'AI Insights',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,

          // Complexity
          _InsightRow(
            icon: Icons.speed,
            label: 'Complexity',
            value: '${complexityLevel.emoji} ${complexityLevel.displayName}',
          ),

          // Estimated duration
          if (estimatedDuration != null) ...[
            AppSpacing.verticalSpaceXS,
            _InsightRow(
              icon: Icons.timer,
              label: 'Estimated Time',
              value: _formatDuration(estimatedDuration),
            ),
          ],

          // Optimal time
          if (optimalTime != null) ...[
            AppSpacing.verticalSpaceXS,
            _InsightRow(
              icon: Icons.schedule,
              label: 'Best Time',
              value: _formatTime(optimalTime),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else {
      final hours = minutes / 60;
      return '${hours.toStringAsFixed(1)} hours';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }
}

/// Insight row
class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gray600),
        AppSpacing.horizontalSpaceXS,
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.gray600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: AppTypography.medium,
          ),
        ),
      ],
    );
  }
}
