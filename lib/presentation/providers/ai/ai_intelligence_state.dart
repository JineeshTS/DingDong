import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/ai_suggestion.dart';

part 'ai_intelligence_state.freezed.dart';

/// AI Task Intelligence State
@freezed
class AiIntelligenceState with _$AiIntelligenceState {
  const factory AiIntelligenceState({
    // Current analysis
    TaskIntelligenceAnalysis? currentAnalysis,

    // Loading state
    @Default(false) bool isAnalyzing,

    // Applied suggestions (by type)
    @Default({}) Map<SuggestionType, AiSuggestion> appliedSuggestions,

    // Dismissed suggestions
    @Default([]) List<String> dismissedSuggestionIds,

    // Error
    String? error,

    // Last analyzed task content
    String? lastAnalyzedContent,
  }) = _AiIntelligenceState;

  const AiIntelligenceState._();

  /// Has analysis results
  bool get hasAnalysis => currentAnalysis != null;

  /// Has suggestions
  bool get hasSuggestions => currentAnalysis?.hasSuggestions ?? false;

  /// Active suggestions (not applied or dismissed)
  List<AiSuggestion> get activeSuggestions {
    if (currentAnalysis == null) return [];

    return currentAnalysis!.suggestions.where((suggestion) {
      // Filter out applied suggestions
      if (appliedSuggestions.containsKey(suggestion.type)) {
        return false;
      }
      // Filter out dismissed suggestions
      if (dismissedSuggestionIds.contains(suggestion.id)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// High confidence suggestions
  List<AiSuggestion> get highConfidenceSuggestions {
    return activeSuggestions.where((s) => s.isHighConfidence).toList();
  }

  /// Has high confidence suggestions
  bool get hasHighConfidenceSuggestions => highConfidenceSuggestions.isNotEmpty;

  /// Number of active suggestions
  int get activeSuggestionCount => activeSuggestions.length;

  /// Has error
  bool get hasError => error != null;

  /// Has related tasks
  bool get hasRelatedTasks => currentAnalysis?.hasRelatedTasks ?? false;

  /// Related task IDs
  List<String> get relatedTaskIds => currentAnalysis?.relatedTaskIds ?? [];

  /// Optimal schedule time
  DateTime? get optimalScheduleTime => currentAnalysis?.optimalScheduleTime;

  /// Estimated duration
  int? get estimatedDuration => currentAnalysis?.estimatedDuration;

  /// Complexity score
  int get complexityScore => currentAnalysis?.complexityScore ?? 5;
}
