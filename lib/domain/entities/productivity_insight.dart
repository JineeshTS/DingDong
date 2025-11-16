import 'package:freezed_annotation/freezed_annotation.dart';

part 'productivity_insight.freezed.dart';
part 'productivity_insight.g.dart';

/// Productivity Insight
///
/// Represents an AI-generated productivity tip or recommendation
@freezed
class ProductivityInsight with _$ProductivityInsight {
  const factory ProductivityInsight({
    required String id,
    required InsightType type,
    required String title,
    required String message,
    required InsightPriority priority,
    required DateTime createdAt,
    String? actionLabel,
    String? actionRoute,
    Map<String, dynamic>? actionData,
    @Default(false) bool isDismissed,
    @Default(false) bool isActionTaken,
  }) = _ProductivityInsight;

  factory ProductivityInsight.fromJson(Map<String, dynamic> json) =>
      _$ProductivityInsightFromJson(json);

  const ProductivityInsight._();

  /// Check if insight is high priority
  bool get isHighPriority => priority == InsightPriority.high;

  /// Check if insight is actionable
  bool get isActionable => actionLabel != null && actionRoute != null;

  /// Check if insight is still active
  bool get isActive => !isDismissed && !isActionTaken;
}

/// Insight Type
enum InsightType {
  /// Task breakdown suggestion
  taskBreakdown,

  /// Workload warning (too many tasks)
  overloadWarning,

  /// Best time to work on task
  optimalTiming,

  /// Workflow optimization
  workflowOptimization,

  /// Distraction alert
  distractionAlert,

  /// Energy management
  energyManagement,

  /// Progress celebration
  progressCelebration,

  /// Productivity tip
  productivityTip,

  /// Focus recommendation
  focusRecommendation,
}

/// Extension for InsightType
extension InsightTypeX on InsightType {
  String get displayName {
    switch (this) {
      case InsightType.taskBreakdown:
        return 'Task Breakdown';
      case InsightType.overloadWarning:
        return 'Workload Alert';
      case InsightType.optimalTiming:
        return 'Optimal Timing';
      case InsightType.workflowOptimization:
        return 'Workflow Tip';
      case InsightType.distractionAlert:
        return 'Focus Alert';
      case InsightType.energyManagement:
        return 'Energy Management';
      case InsightType.progressCelebration:
        return 'Great Progress!';
      case InsightType.productivityTip:
        return 'Productivity Tip';
      case InsightType.focusRecommendation:
        return 'Focus Time';
    }
  }

  String get icon {
    switch (this) {
      case InsightType.taskBreakdown:
        return '🧩';
      case InsightType.overloadWarning:
        return '⚠️';
      case InsightType.optimalTiming:
        return '⏰';
      case InsightType.workflowOptimization:
        return '🎯';
      case InsightType.distractionAlert:
        return '🔕';
      case InsightType.energyManagement:
        return '⚡';
      case InsightType.progressCelebration:
        return '🎉';
      case InsightType.productivityTip:
        return '💡';
      case InsightType.focusRecommendation:
        return '🎯';
    }
  }
}

/// Insight Priority
enum InsightPriority {
  low,
  medium,
  high,
}

/// Productivity Analysis
///
/// Represents a complete productivity analysis with insights and metrics
@freezed
class ProductivityAnalysis with _$ProductivityAnalysis {
  const factory ProductivityAnalysis({
    required String id,
    required List<ProductivityInsight> insights,
    required ProductivityMetrics metrics,
    required DateTime analyzedAt,
    DateTime? nextAnalysisAt,
  }) = _ProductivityAnalysis;

  factory ProductivityAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ProductivityAnalysisFromJson(json);

  const ProductivityAnalysis._();

  /// Active insights (not dismissed or actioned)
  List<ProductivityInsight> get activeInsights =>
      insights.where((i) => i.isActive).toList();

  /// High priority insights
  List<ProductivityInsight> get highPriorityInsights =>
      activeInsights.where((i) => i.isHighPriority).toList();

  /// Has active insights
  bool get hasActiveInsights => activeInsights.isNotEmpty;

  /// Has high priority insights
  bool get hasHighPriorityInsights => highPriorityInsights.isNotEmpty;

  /// Number of active insights
  int get activeInsightCount => activeInsights.length;
}

/// Productivity Metrics
///
/// Metrics about user's current productivity state
@freezed
class ProductivityMetrics with _$ProductivityMetrics {
  const factory ProductivityMetrics({
    // Workload metrics
    @Default(0) int totalActiveTasks,
    @Default(0) int overdueTasksCount,
    @Default(0) int dueTodayCount,
    @Default(0) int dueThisWeekCount,
    @Default(0) int highPriorityCount,
    @Default(0) int estimatedHoursToday,
    @Default(0) int estimatedHoursThisWeek,

    // Completion metrics
    @Default(0) int completedToday,
    @Default(0) int completedThisWeek,
    @Default(0.0) double completionRateToday,
    @Default(0.0) double completionRateThisWeek,

    // Focus metrics
    @Default(0) int longestFocusStreak,
    @Default(0) int currentFocusStreak,
    DateTime? lastCompletedTaskAt,

    // Workload level
    @Default(WorkloadLevel.balanced) WorkloadLevel workloadLevel,

    // Energy level (based on time of day and patterns)
    @Default(EnergyLevel.medium) EnergyLevel currentEnergyLevel,
  }) = _ProductivityMetrics;

  factory ProductivityMetrics.fromJson(Map<String, dynamic> json) =>
      _$ProductivityMetricsFromJson(json);

  const ProductivityMetrics._();

  /// Check if user is overloaded
  bool get isOverloaded => workloadLevel == WorkloadLevel.overloaded;

  /// Check if user has good momentum
  bool get hasGoodMomentum => currentFocusStreak >= 3;

  /// Check if user should take a break
  bool get shouldTakeBreak {
    if (lastCompletedTaskAt == null) return false;
    final hoursSinceLastTask =
        DateTime.now().difference(lastCompletedTaskAt!).inHours;
    return currentFocusStreak >= 5 && hoursSinceLastTask < 2;
  }
}

/// Workload Level
enum WorkloadLevel {
  light,
  balanced,
  busy,
  overloaded,
}

/// Extension for WorkloadLevel
extension WorkloadLevelX on WorkloadLevel {
  String get displayName {
    switch (this) {
      case WorkloadLevel.light:
        return 'Light';
      case WorkloadLevel.balanced:
        return 'Balanced';
      case WorkloadLevel.busy:
        return 'Busy';
      case WorkloadLevel.overloaded:
        return 'Overloaded';
    }
  }

  String get emoji {
    switch (this) {
      case WorkloadLevel.light:
        return '😌';
      case WorkloadLevel.balanced:
        return '👍';
      case WorkloadLevel.busy:
        return '😅';
      case WorkloadLevel.overloaded:
        return '🔥';
    }
  }

  String get description {
    switch (this) {
      case WorkloadLevel.light:
        return 'You have a comfortable workload';
      case WorkloadLevel.balanced:
        return 'Your workload is well balanced';
      case WorkloadLevel.busy:
        return 'You have a lot on your plate';
      case WorkloadLevel.overloaded:
        return 'You may be taking on too much';
    }
  }
}

/// Energy Level
enum EnergyLevel {
  low,
  medium,
  high,
  peak,
}

/// Extension for EnergyLevel
extension EnergyLevelX on EnergyLevel {
  String get displayName {
    switch (this) {
      case EnergyLevel.low:
        return 'Low Energy';
      case EnergyLevel.medium:
        return 'Medium Energy';
      case EnergyLevel.high:
        return 'High Energy';
      case EnergyLevel.peak:
        return 'Peak Energy';
    }
  }

  String get emoji {
    switch (this) {
      case EnergyLevel.low:
        return '😴';
      case EnergyLevel.medium:
        return '🙂';
      case EnergyLevel.high:
        return '💪';
      case EnergyLevel.peak:
        return '🚀';
    }
  }

  String get recommendation {
    switch (this) {
      case EnergyLevel.low:
        return 'Good time for simple, routine tasks';
      case EnergyLevel.medium:
        return 'Handle moderate complexity tasks';
      case EnergyLevel.high:
        return 'Tackle challenging tasks now';
      case EnergyLevel.peak:
        return 'Perfect time for your most important work';
    }
  }
}

/// Task Breakdown Suggestion
///
/// Suggests how to break down a complex task
@freezed
class TaskBreakdownSuggestion with _$TaskBreakdownSuggestion {
  const factory TaskBreakdownSuggestion({
    required String taskId,
    required String taskTitle,
    required List<SubtaskSuggestion> subtasks,
    required String reasoning,
    required double confidence,
    required DateTime createdAt,
  }) = _TaskBreakdownSuggestion;

  factory TaskBreakdownSuggestion.fromJson(Map<String, dynamic> json) =>
      _$TaskBreakdownSuggestionFromJson(json);
}

/// Subtask Suggestion
@freezed
class SubtaskSuggestion with _$SubtaskSuggestion {
  const factory SubtaskSuggestion({
    required String title,
    String? description,
    int? estimatedMinutes,
    int? suggestedOrder,
  }) = _SubtaskSuggestion;

  factory SubtaskSuggestion.fromJson(Map<String, dynamic> json) =>
      _$SubtaskSuggestionFromJson(json);
}
