import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/productivity_insight.dart';

part 'ai_productivity_state.freezed.dart';

/// AI Productivity Coach State
@freezed
class AiProductivityState with _$AiProductivityState {
  const factory AiProductivityState({
    // Current analysis
    ProductivityAnalysis? currentAnalysis,

    // Loading state
    @Default(false) bool isAnalyzing,

    // Dismissed insights
    @Default([]) List<String> dismissedInsightIds,

    // Actioned insights
    @Default([]) List<String> actionedInsightIds,

    // Error
    String? error,

    // Last analysis time
    DateTime? lastAnalyzedAt,

    // Auto-refresh enabled
    @Default(true) bool autoRefreshEnabled,
  }) = _AiProductivityState;

  const AiProductivityState._();

  /// Has analysis results
  bool get hasAnalysis => currentAnalysis != null;

  /// Has insights
  bool get hasInsights => currentAnalysis?.hasActiveInsights ?? false;

  /// Active insights (not dismissed or actioned)
  List<ProductivityInsight> get activeInsights {
    if (currentAnalysis == null) return [];

    return currentAnalysis!.insights.where((insight) {
      // Filter out dismissed insights
      if (dismissedInsightIds.contains(insight.id)) {
        return false;
      }
      // Filter out actioned insights
      if (actionedInsightIds.contains(insight.id)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// High priority insights
  List<ProductivityInsight> get highPriorityInsights {
    return activeInsights.where((i) => i.isHighPriority).toList();
  }

  /// Has high priority insights
  bool get hasHighPriorityInsights => highPriorityInsights.isNotEmpty;

  /// Number of active insights
  int get activeInsightCount => activeInsights.length;

  /// Get metrics
  ProductivityMetrics? get metrics => currentAnalysis?.metrics;

  /// Has error
  bool get hasError => error != null;

  /// Should refresh (if enabled and past refresh time)
  bool get shouldRefresh {
    if (!autoRefreshEnabled) return false;
    if (currentAnalysis == null) return true;
    if (currentAnalysis!.nextAnalysisAt == null) return false;

    return DateTime.now().isAfter(currentAnalysis!.nextAnalysisAt!);
  }

  /// Get insights by type
  List<ProductivityInsight> getInsightsByType(InsightType type) {
    return activeInsights.where((i) => i.type == type).toList();
  }
}
