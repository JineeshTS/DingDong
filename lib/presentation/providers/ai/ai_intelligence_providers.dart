import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai_task_intelligence_service.dart';
import '../../../domain/entities/ai_suggestion.dart';
import 'ai_intelligence_notifier.dart';
import 'ai_intelligence_state.dart';

/// AI Task Intelligence Service Provider
final aiIntelligenceServiceProvider = Provider<AiTaskIntelligenceService>((ref) {
  return AiTaskIntelligenceService();
});

/// AI Intelligence State Notifier Provider
final aiIntelligenceNotifierProvider =
    StateNotifierProvider<AiIntelligenceNotifier, AiIntelligenceState>((ref) {
  return AiIntelligenceNotifier(
    aiService: ref.watch(aiIntelligenceServiceProvider),
  );
});

/// Current analysis provider
final currentAnalysisProvider = Provider<TaskIntelligenceAnalysis?>((ref) {
  return ref.watch(aiIntelligenceNotifierProvider.select((s) => s.currentAnalysis));
});

/// Is analyzing provider
final isAnalyzingProvider = Provider<bool>((ref) {
  return ref.watch(aiIntelligenceNotifierProvider.select((s) => s.isAnalyzing));
});

/// Has analysis provider
final hasAnalysisProvider = Provider<bool>((ref) {
  return ref.watch(aiIntelligenceNotifierProvider.select((s) => s.hasAnalysis));
});

/// Has suggestions provider
final hasSuggestionsProvider = Provider<bool>((ref) {
  return ref.watch(aiIntelligenceNotifierProvider.select((s) => s.hasSuggestions));
});

/// Active suggestions provider
final activeSuggestionsProvider = Provider<List<AiSuggestion>>((ref) {
  return ref.watch(aiIntelligenceNotifierProvider.select((s) => s.activeSuggestions));
});

/// High confidence suggestions provider
final highConfidenceSuggestionsProvider = Provider<List<AiSuggestion>>((ref) {
  return ref.watch(
      aiIntelligenceNotifierProvider.select((s) => s.highConfidenceSuggestions));
});

/// Has high confidence suggestions provider
final hasHighConfidenceSuggestionsProvider = Provider<bool>((ref) {
  return ref.watch(
      aiIntelligenceNotifierProvider.select((s) => s.hasHighConfidenceSuggestions));
});

/// Active suggestion count provider
final activeSuggestionCountProvider = Provider<int>((ref) {
  return ref.watch(
      aiIntelligenceNotifierProvider.select((s) => s.activeSuggestionCount));
});

/// Applied suggestions provider
final appliedSuggestionsProvider =
    Provider<Map<SuggestionType, AiSuggestion>>((ref) {
  return ref.watch(
      aiIntelligenceNotifierProvider.select((s) => s.appliedSuggestions));
});

/// Related task IDs provider
final relatedTaskIdsProvider = Provider<List<String>>((ref) {
  return ref.watch(aiIntelligenceNotifierProvider.select((s) => s.relatedTaskIds));
});

/// Optimal schedule time provider
final optimalScheduleTimeProvider = Provider<DateTime?>((ref) {
  return ref
      .watch(aiIntelligenceNotifierProvider.select((s) => s.optimalScheduleTime));
});

/// Estimated duration provider
final estimatedDurationProvider = Provider<int?>((ref) {
  return ref
      .watch(aiIntelligenceNotifierProvider.select((s) => s.estimatedDuration));
});

/// Complexity score provider
final complexityScoreProvider = Provider<int>((ref) {
  return ref.watch(aiIntelligenceNotifierProvider.select((s) => s.complexityScore));
});

/// AI error provider
final aiIntelligenceErrorProvider = Provider<String?>((ref) {
  return ref.watch(aiIntelligenceNotifierProvider.select((s) => s.error));
});

/// Is suggestion applied provider (family)
final isSuggestionAppliedProvider =
    Provider.family<bool, SuggestionType>((ref, type) {
  final appliedSuggestions = ref.watch(appliedSuggestionsProvider);
  return appliedSuggestions.containsKey(type);
});

/// Applied suggestion value provider (family)
final appliedSuggestionValueProvider =
    Provider.family<dynamic, SuggestionType>((ref, type) {
  final appliedSuggestions = ref.watch(appliedSuggestionsProvider);
  return appliedSuggestions[type]?.value;
});

/// Suggestion by type provider (family)
final suggestionByTypeProvider =
    Provider.family<AiSuggestion?, SuggestionType>((ref, type) {
  final suggestions = ref.watch(activeSuggestionsProvider);
  try {
    return suggestions.firstWhere((s) => s.type == type);
  } catch (e) {
    return null;
  }
});

/// Complexity level enum
enum ComplexityLevel {
  veryLow,
  low,
  medium,
  high,
  veryHigh,
}

/// Extension for complexity level
extension ComplexityLevelX on ComplexityLevel {
  String get displayName {
    switch (this) {
      case ComplexityLevel.veryLow:
        return 'Very Low';
      case ComplexityLevel.low:
        return 'Low';
      case ComplexityLevel.medium:
        return 'Medium';
      case ComplexityLevel.high:
        return 'High';
      case ComplexityLevel.veryHigh:
        return 'Very High';
    }
  }

  String get emoji {
    switch (this) {
      case ComplexityLevel.veryLow:
        return '😊';
      case ComplexityLevel.low:
        return '🙂';
      case ComplexityLevel.medium:
        return '😐';
      case ComplexityLevel.high:
        return '😰';
      case ComplexityLevel.veryHigh:
        return '😱';
    }
  }
}

/// Complexity level provider
final complexityLevelProvider = Provider<ComplexityLevel>((ref) {
  final score = ref.watch(complexityScoreProvider);

  if (score <= 2) return ComplexityLevel.veryLow;
  if (score <= 4) return ComplexityLevel.low;
  if (score <= 6) return ComplexityLevel.medium;
  if (score <= 8) return ComplexityLevel.high;
  return ComplexityLevel.veryHigh;
});
