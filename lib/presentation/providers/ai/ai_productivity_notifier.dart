import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai_productivity_coach_service.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/productivity_insight.dart';
import '../../../domain/entities/task_entity.dart';
import 'ai_productivity_state.dart';

/// AI Productivity Coach Notifier
///
/// Manages productivity insights and analysis
class AiProductivityNotifier extends StateNotifier<AiProductivityState> {
  final AiProductivityCoachService _coachService;
  final _logger = Logger();

  AiProductivityNotifier({
    required AiProductivityCoachService coachService,
  })  : _coachService = coachService,
        super(const AiProductivityState());

  /// Analyze productivity and generate insights
  Future<void> analyzeProductivity({
    required List<TaskEntity> allTasks,
    List<TaskEntity>? completedTodayTasks,
    List<TaskEntity>? completedThisWeekTasks,
    DateTime? lastCompletedAt,
  }) async {
    try {
      _logger.info('Starting productivity analysis');

      state = state.copyWith(
        isAnalyzing: true,
        error: null,
      );

      // Perform analysis
      final analysis = await _coachService.analyzeProductivity(
        allTasks: allTasks,
        completedTodayTasks: completedTodayTasks,
        completedThisWeekTasks: completedThisWeekTasks,
        lastCompletedAt: lastCompletedAt,
      );

      _logger.info(
          'Productivity analysis complete: ${analysis.insights.length} insights');

      state = state.copyWith(
        isAnalyzing: false,
        currentAnalysis: analysis,
        lastAnalyzedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      _logger.error('Productivity analysis failed',
          error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isAnalyzing: false,
        error: 'Failed to analyze productivity: ${e.toString()}',
      );
    }
  }

  /// Dismiss an insight
  void dismissInsight(String insightId) {
    _logger.info('Dismissing insight: $insightId');

    final updated = [...state.dismissedInsightIds, insightId];

    state = state.copyWith(
      dismissedInsightIds: updated,
    );
  }

  /// Mark insight as actioned
  void markInsightActioned(String insightId) {
    _logger.info('Marking insight as actioned: $insightId');

    final updated = [...state.actionedInsightIds, insightId];

    state = state.copyWith(
      actionedInsightIds: updated,
    );
  }

  /// Undo dismissed insight
  void undoDismissInsight(String insightId) {
    _logger.info('Undoing dismissed insight: $insightId');

    final updated = state.dismissedInsightIds
        .where((id) => id != insightId)
        .toList();

    state = state.copyWith(
      dismissedInsightIds: updated,
    );
  }

  /// Clear dismissed insights
  void clearDismissedInsights() {
    _logger.info('Clearing all dismissed insights');

    state = state.copyWith(
      dismissedInsightIds: [],
    );
  }

  /// Clear actioned insights
  void clearActionedInsights() {
    _logger.info('Clearing all actioned insights');

    state = state.copyWith(
      actionedInsightIds: [],
    );
  }

  /// Toggle auto-refresh
  void toggleAutoRefresh() {
    state = state.copyWith(
      autoRefreshEnabled: !state.autoRefreshEnabled,
    );
  }

  /// Force refresh
  Future<void> refresh({
    required List<TaskEntity> allTasks,
    List<TaskEntity>? completedTodayTasks,
    List<TaskEntity>? completedThisWeekTasks,
    DateTime? lastCompletedAt,
  }) async {
    await analyzeProductivity(
      allTasks: allTasks,
      completedTodayTasks: completedTodayTasks,
      completedThisWeekTasks: completedThisWeekTasks,
      lastCompletedAt: lastCompletedAt,
    );
  }

  /// Get task breakdown suggestion
  Future<TaskBreakdownSuggestion?> getTaskBreakdownSuggestion(
    TaskEntity task,
  ) async {
    try {
      return await _coachService.suggestTaskBreakdown(task: task);
    } catch (e, stackTrace) {
      _logger.error('Failed to get task breakdown suggestion',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Clear all data and reset
  void clear() {
    state = const AiProductivityState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
