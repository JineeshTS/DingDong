import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai_task_intelligence_service.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/ai_suggestion.dart';
import '../../../domain/entities/task_entity.dart';
import 'ai_intelligence_state.dart';

/// AI Task Intelligence Notifier
///
/// Manages AI-powered task suggestions and intelligence
class AiIntelligenceNotifier extends StateNotifier<AiIntelligenceState> {
  final AiTaskIntelligenceService _aiService;
  final _logger = Logger();

  AiIntelligenceNotifier({
    required AiTaskIntelligenceService aiService,
  })  : _aiService = aiService,
        super(const AiIntelligenceState());

  /// Analyze task and generate suggestions
  Future<void> analyzeTask({
    required String title,
    String? description,
    DateTime? dueDate,
    int? priority,
    List<String>? tags,
    List<TaskEntity>? existingTasks,
  }) async {
    // Don't re-analyze the same content
    final content = '$title $description';
    if (content == state.lastAnalyzedContent && state.hasAnalysis) {
      _logger.info('Skipping re-analysis of same content');
      return;
    }

    try {
      _logger.info('Starting AI task analysis');

      state = state.copyWith(
        isAnalyzing: true,
        error: null,
      );

      // Perform analysis
      final analysis = await _aiService.analyzeTask(
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        tags: tags,
        existingTasks: existingTasks,
      );

      _logger.info(
          'AI analysis complete: ${analysis.suggestions.length} suggestions');

      state = state.copyWith(
        isAnalyzing: false,
        currentAnalysis: analysis,
        lastAnalyzedContent: content,
      );
    } catch (e, stackTrace) {
      _logger.error('AI analysis failed', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isAnalyzing: false,
        error: 'Failed to analyze task: ${e.toString()}',
      );
    }
  }

  /// Apply a suggestion
  void applySuggestion(AiSuggestion suggestion) {
    _logger.info('Applying suggestion: ${suggestion.type.displayName}');

    final updatedApplied = Map<SuggestionType, AiSuggestion>.from(
      state.appliedSuggestions,
    );
    updatedApplied[suggestion.type] = suggestion.copyWith(isApplied: true);

    state = state.copyWith(
      appliedSuggestions: updatedApplied,
    );
  }

  /// Dismiss a suggestion
  void dismissSuggestion(String suggestionId) {
    _logger.info('Dismissing suggestion: $suggestionId');

    final updated = [...state.dismissedSuggestionIds, suggestionId];

    state = state.copyWith(
      dismissedSuggestionIds: updated,
    );
  }

  /// Undo applied suggestion
  void undoAppliedSuggestion(SuggestionType type) {
    _logger.info('Undoing applied suggestion: ${type.displayName}');

    final updatedApplied = Map<SuggestionType, AiSuggestion>.from(
      state.appliedSuggestions,
    );
    updatedApplied.remove(type);

    state = state.copyWith(
      appliedSuggestions: updatedApplied,
    );
  }

  /// Apply all high confidence suggestions
  void applyAllHighConfidence() {
    _logger.info('Applying all high confidence suggestions');

    final updatedApplied = Map<SuggestionType, AiSuggestion>.from(
      state.appliedSuggestions,
    );

    for (final suggestion in state.highConfidenceSuggestions) {
      updatedApplied[suggestion.type] = suggestion.copyWith(isApplied: true);
    }

    state = state.copyWith(
      appliedSuggestions: updatedApplied,
    );
  }

  /// Get applied suggestion value for a type
  dynamic getAppliedValue(SuggestionType type) {
    return state.appliedSuggestions[type]?.value;
  }

  /// Check if suggestion type is applied
  bool isSuggestionApplied(SuggestionType type) {
    return state.appliedSuggestions.containsKey(type);
  }

  /// Clear all suggestions and reset
  void clear() {
    state = const AiIntelligenceState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
