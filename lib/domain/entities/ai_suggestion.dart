/// AI Task Suggestion Entity
///
/// Represents an intelligent suggestion from the AI system
/// for task properties and optimizations.

/// AI suggestion for task properties
class AiSuggestion {
  /// Unique identifier
  final String id;

  /// Type of suggestion
  final SuggestionType type;

  /// Suggested value
  final dynamic value;

  /// Confidence score (0.0 - 1.0)
  final double confidence;

  /// Reasoning/explanation for the suggestion
  final String reasoning;

  /// Is this suggestion applied
  final bool isApplied;

  /// Timestamp when suggestion was created
  final DateTime createdAt;

  const AiSuggestion({
    required this.id,
    required this.type,
    required this.value,
    required this.confidence,
    required this.reasoning,
    this.isApplied = false,
    required this.createdAt,
  });

  /// Copy with method
  AiSuggestion copyWith({
    String? id,
    SuggestionType? type,
    dynamic value,
    double? confidence,
    String? reasoning,
    bool? isApplied,
    DateTime? createdAt,
  }) {
    return AiSuggestion(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      confidence: confidence ?? this.confidence,
      reasoning: reasoning ?? this.reasoning,
      isApplied: isApplied ?? this.isApplied,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// High confidence suggestion
  bool get isHighConfidence => confidence >= 0.8;

  /// Medium confidence suggestion
  bool get isMediumConfidence => confidence >= 0.5 && confidence < 0.8;

  /// Low confidence suggestion
  bool get isLowConfidence => confidence < 0.5;
}

/// Type of AI suggestion
enum SuggestionType {
  /// Priority level suggestion
  priority,

  /// Due date suggestion
  dueDate,

  /// Time estimate suggestion
  timeEstimate,

  /// Tag suggestions
  tags,

  /// Related tasks
  relatedTasks,

  /// Optimal schedule time
  scheduleTime,

  /// Task breakdown suggestions
  subtasks,

  /// Assignee suggestion (for team tasks)
  assignee,

  /// List/project suggestion
  list,
}

/// Extension for suggestion type
extension SuggestionTypeX on SuggestionType {
  /// Display name
  String get displayName {
    switch (this) {
      case SuggestionType.priority:
        return 'Priority';
      case SuggestionType.dueDate:
        return 'Due Date';
      case SuggestionType.timeEstimate:
        return 'Time Estimate';
      case SuggestionType.tags:
        return 'Tags';
      case SuggestionType.relatedTasks:
        return 'Related Tasks';
      case SuggestionType.scheduleTime:
        return 'Best Time';
      case SuggestionType.subtasks:
        return 'Breakdown';
      case SuggestionType.assignee:
        return 'Assignee';
      case SuggestionType.list:
        return 'List';
    }
  }

  /// Icon for suggestion type
  String get icon {
    switch (this) {
      case SuggestionType.priority:
        return '🎯';
      case SuggestionType.dueDate:
        return '📅';
      case SuggestionType.timeEstimate:
        return '⏱️';
      case SuggestionType.tags:
        return '🏷️';
      case SuggestionType.relatedTasks:
        return '🔗';
      case SuggestionType.scheduleTime:
        return '⏰';
      case SuggestionType.subtasks:
        return '📋';
      case SuggestionType.assignee:
        return '👤';
      case SuggestionType.list:
        return '📁';
    }
  }
}

/// Task intelligence analysis result
class TaskIntelligenceAnalysis {
  /// All suggestions for the task
  final List<AiSuggestion> suggestions;

  /// Related tasks found
  final List<String> relatedTaskIds;

  /// Optimal time to work on this task
  final DateTime? optimalScheduleTime;

  /// Estimated duration in minutes
  final int? estimatedDuration;

  /// Complexity score (1-10)
  final int complexityScore;

  /// Analysis timestamp
  final DateTime analyzedAt;

  const TaskIntelligenceAnalysis({
    required this.suggestions,
    this.relatedTaskIds = const [],
    this.optimalScheduleTime,
    this.estimatedDuration,
    required this.complexityScore,
    required this.analyzedAt,
  });

  /// Has suggestions
  bool get hasSuggestions => suggestions.isNotEmpty;

  /// High priority suggestions
  List<AiSuggestion> get highConfidenceSuggestions =>
      suggestions.where((s) => s.isHighConfidence).toList();

  /// Number of suggestions
  int get suggestionCount => suggestions.length;

  /// Has related tasks
  bool get hasRelatedTasks => relatedTaskIds.isNotEmpty;
}
