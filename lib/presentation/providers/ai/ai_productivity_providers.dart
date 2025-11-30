import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai_productivity_coach_service.dart';
import '../../../domain/entities/productivity_insight.dart';
import 'ai_productivity_notifier.dart';
import 'ai_productivity_state.dart';

/// AI Productivity Coach Service Provider
final aiProductivityCoachServiceProvider =
    Provider<AiProductivityCoachService>((ref) {
  return AiProductivityCoachService();
});

/// AI Productivity State Notifier Provider
final aiProductivityNotifierProvider =
    StateNotifierProvider<AiProductivityNotifier, AiProductivityState>((ref) {
  return AiProductivityNotifier(
    coachService: ref.watch(aiProductivityCoachServiceProvider),
  );
});

/// Current analysis provider
final currentProductivityAnalysisProvider =
    Provider<ProductivityAnalysis?>((ref) {
  return ref.watch(
      aiProductivityNotifierProvider.select((s) => s.currentAnalysis));
});

/// Is analyzing provider
final isAnalyzingProductivityProvider = Provider<bool>((ref) {
  return ref.watch(aiProductivityNotifierProvider.select((s) => s.isAnalyzing));
});

/// Has analysis provider
final hasProductivityAnalysisProvider = Provider<bool>((ref) {
  return ref.watch(aiProductivityNotifierProvider.select((s) => s.hasAnalysis));
});

/// Has insights provider
final hasProductivityInsightsProvider = Provider<bool>((ref) {
  return ref.watch(aiProductivityNotifierProvider.select((s) => s.hasInsights));
});

/// Active insights provider
final activeProductivityInsightsProvider =
    Provider<List<ProductivityInsight>>((ref) {
  return ref
      .watch(aiProductivityNotifierProvider.select((s) => s.activeInsights));
});

/// High priority insights provider
final highPriorityProductivityInsightsProvider =
    Provider<List<ProductivityInsight>>((ref) {
  return ref.watch(
      aiProductivityNotifierProvider.select((s) => s.highPriorityInsights));
});

/// Has high priority insights provider
final hasHighPriorityInsightsProvider = Provider<bool>((ref) {
  return ref.watch(aiProductivityNotifierProvider
      .select((s) => s.hasHighPriorityInsights));
});

/// Active insight count provider
final activeInsightCountProvider = Provider<int>((ref) {
  return ref
      .watch(aiProductivityNotifierProvider.select((s) => s.activeInsightCount));
});

/// Productivity metrics provider
final productivityMetricsProvider = Provider<ProductivityMetrics?>((ref) {
  return ref.watch(aiProductivityNotifierProvider.select((s) => s.metrics));
});

/// Workload level provider
final workloadLevelProvider = Provider<WorkloadLevel>((ref) {
  final metrics = ref.watch(productivityMetricsProvider);
  return metrics?.workloadLevel ?? WorkloadLevel.balanced;
});

/// Energy level provider
final energyLevelProvider = Provider<EnergyLevel>((ref) {
  final metrics = ref.watch(productivityMetricsProvider);
  return metrics?.currentEnergyLevel ?? EnergyLevel.medium;
});

/// Overdue tasks count provider
final overdueTasksCountProvider = Provider<int>((ref) {
  final metrics = ref.watch(productivityMetricsProvider);
  return metrics?.overdueTasksCount ?? 0;
});

/// Due today count provider
final dueTodayCountProvider = Provider<int>((ref) {
  final metrics = ref.watch(productivityMetricsProvider);
  return metrics?.dueTodayCount ?? 0;
});

/// Completed today count provider
final completedTodayCountProvider = Provider<int>((ref) {
  final metrics = ref.watch(productivityMetricsProvider);
  return metrics?.completedToday ?? 0;
});

/// Completion rate today provider
final completionRateTodayProvider = Provider<double>((ref) {
  final metrics = ref.watch(productivityMetricsProvider);
  return metrics?.completionRateToday ?? 0.0;
});

/// Focus streak provider
final focusStreakProvider = Provider<int>((ref) {
  final metrics = ref.watch(productivityMetricsProvider);
  return metrics?.currentFocusStreak ?? 0;
});

/// Is overloaded provider
final isOverloadedProvider = Provider<bool>((ref) {
  final metrics = ref.watch(productivityMetricsProvider);
  return metrics?.isOverloaded ?? false;
});

/// Has good momentum provider
final hasGoodMomentumProvider = Provider<bool>((ref) {
  final metrics = ref.watch(productivityMetricsProvider);
  return metrics?.hasGoodMomentum ?? false;
});

/// Should take break provider
final shouldTakeBreakProvider = Provider<bool>((ref) {
  final metrics = ref.watch(productivityMetricsProvider);
  return metrics?.shouldTakeBreak ?? false;
});

/// Productivity error provider
final productivityErrorProvider = Provider<String?>((ref) {
  return ref.watch(aiProductivityNotifierProvider.select((s) => s.error));
});

/// Auto-refresh enabled provider
final autoRefreshEnabledProvider = Provider<bool>((ref) {
  return ref
      .watch(aiProductivityNotifierProvider.select((s) => s.autoRefreshEnabled));
});

/// Should refresh provider
final shouldRefreshProvider = Provider<bool>((ref) {
  return ref.watch(aiProductivityNotifierProvider.select((s) => s.shouldRefresh));
});

/// Last analyzed at provider
final lastAnalyzedAtProvider = Provider<DateTime?>((ref) {
  return ref
      .watch(aiProductivityNotifierProvider.select((s) => s.lastAnalyzedAt));
});

/// Insights by type provider (family)
final insightsByTypeProvider =
    Provider.family<List<ProductivityInsight>, InsightType>((ref, type) {
  final state = ref.watch(aiProductivityNotifierProvider);
  return state.getInsightsByType(type);
});

/// Has insights of type provider (family)
final hasInsightsOfTypeProvider = Provider.family<bool, InsightType>((ref, type) {
  final insights = ref.watch(insightsByTypeProvider(type));
  return insights.isNotEmpty;
});
