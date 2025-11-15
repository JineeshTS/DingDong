import '../../domain/entities/ai_suggestion.dart';
import '../../domain/entities/task_entity.dart';
import '../utils/logger.dart';

/// AI Task Intelligence Service
///
/// Provides intelligent suggestions for task properties using AI/ML algorithms.
/// Analyzes task content, user history, and patterns to suggest:
/// - Priority levels
/// - Due dates
/// - Time estimates
/// - Tags
/// - Related tasks
/// - Optimal scheduling times
class AiTaskIntelligenceService {
  final _logger = Logger();

  // Common task keywords for different categories
  static const _urgentKeywords = [
    'urgent',
    'asap',
    'immediately',
    'critical',
    'emergency',
    'deadline',
    'today',
    'now',
  ];

  static const _importantKeywords = [
    'important',
    'priority',
    'key',
    'essential',
    'crucial',
    'vital',
    'significant',
  ];

  static const _meetingKeywords = [
    'meeting',
    'call',
    'zoom',
    'conference',
    'discussion',
    'sync',
    'standup',
    'review',
  ];

  static const _workKeywords = [
    'work',
    'office',
    'project',
    'client',
    'business',
    'professional',
    'job',
  ];

  static const _personalKeywords = [
    'personal',
    'home',
    'family',
    'self',
    'private',
  ];

  /// Analyze a task and generate intelligent suggestions
  Future<TaskIntelligenceAnalysis> analyzeTask({
    required String title,
    String? description,
    DateTime? dueDate,
    int? priority,
    List<String>? tags,
    List<TaskEntity>? existingTasks,
  }) async {
    try {
      _logger.info('Analyzing task: $title');

      final suggestions = <AiSuggestion>[];
      final relatedTaskIds = <String>[];

      // Combine title and description for analysis
      final content = '$title ${description ?? ''}'.toLowerCase();

      // 1. Priority suggestion
      if (priority == null || priority == 0) {
        final prioritySuggestion = _suggestPriority(content, dueDate);
        if (prioritySuggestion != null) {
          suggestions.add(prioritySuggestion);
        }
      }

      // 2. Due date suggestion
      if (dueDate == null) {
        final dueDateSuggestion = _suggestDueDate(content);
        if (dueDateSuggestion != null) {
          suggestions.add(dueDateSuggestion);
        }
      }

      // 3. Tag suggestions
      final tagSuggestions = _suggestTags(content, tags ?? []);
      suggestions.addAll(tagSuggestions);

      // 4. Time estimate suggestion
      final timeEstimate = _estimateTime(content);
      if (timeEstimate != null) {
        suggestions.add(timeEstimate);
      }

      // 5. Related tasks
      if (existingTasks != null && existingTasks.isNotEmpty) {
        relatedTaskIds.addAll(_findRelatedTasks(content, existingTasks));
      }

      // 6. Optimal schedule time
      final scheduleTime = _suggestOptimalTime(content, dueDate);

      // 7. Complexity score
      final complexity = _calculateComplexity(content, description);

      _logger.info('Analysis complete: ${suggestions.length} suggestions generated');

      return TaskIntelligenceAnalysis(
        suggestions: suggestions,
        relatedTaskIds: relatedTaskIds,
        optimalScheduleTime: scheduleTime,
        estimatedDuration: timeEstimate?.value as int?,
        complexityScore: complexity,
        analyzedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      _logger.error('Task analysis failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Suggest priority based on content and due date
  AiSuggestion? _suggestPriority(String content, DateTime? dueDate) {
    int suggestedPriority = 2; // Default to medium
    double confidence = 0.6;
    String reasoning = 'Based on task content analysis';

    // Check for urgent keywords
    final hasUrgentKeywords = _urgentKeywords.any((kw) => content.contains(kw));
    if (hasUrgentKeywords) {
      suggestedPriority = 4;
      confidence = 0.9;
      reasoning = 'Contains urgent keywords like "${_urgentKeywords.firstWhere((kw) => content.contains(kw))}"';
    }
    // Check for important keywords
    else if (_importantKeywords.any((kw) => content.contains(kw))) {
      suggestedPriority = 3;
      confidence = 0.85;
      reasoning = 'Contains important keywords';
    }
    // Check due date proximity
    else if (dueDate != null) {
      final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
      if (daysUntilDue <= 1) {
        suggestedPriority = 4;
        confidence = 0.95;
        reasoning = 'Due very soon (within 1 day)';
      } else if (daysUntilDue <= 3) {
        suggestedPriority = 3;
        confidence = 0.8;
        reasoning = 'Due soon (within 3 days)';
      } else if (daysUntilDue <= 7) {
        suggestedPriority = 2;
        confidence = 0.7;
        reasoning = 'Due this week';
      }
    }

    return AiSuggestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SuggestionType.priority,
      value: suggestedPriority,
      confidence: confidence,
      reasoning: reasoning,
      createdAt: DateTime.now(),
    );
  }

  /// Suggest due date based on content
  AiSuggestion? _suggestDueDate(String content) {
    DateTime? suggestedDate;
    double confidence = 0.6;
    String reasoning = 'No specific date mentioned';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check for explicit date keywords
    if (content.contains('today')) {
      suggestedDate = today;
      confidence = 0.95;
      reasoning = 'Task mentions "today"';
    } else if (content.contains('tomorrow')) {
      suggestedDate = today.add(const Duration(days: 1));
      confidence = 0.95;
      reasoning = 'Task mentions "tomorrow"';
    } else if (content.contains('this week') || content.contains('week')) {
      suggestedDate = today.add(Duration(days: 7 - now.weekday));
      confidence = 0.8;
      reasoning = 'Task mentions "this week"';
    } else if (content.contains('next week')) {
      suggestedDate = today.add(Duration(days: 7 + (7 - now.weekday)));
      confidence = 0.8;
      reasoning = 'Task mentions "next week"';
    } else if (content.contains('month')) {
      suggestedDate = DateTime(now.year, now.month + 1, 1);
      confidence = 0.7;
      reasoning = 'Task mentions "month"';
    } else if (_urgentKeywords.any((kw) => content.contains(kw))) {
      suggestedDate = today;
      confidence = 0.85;
      reasoning = 'Task contains urgent keywords';
    }

    if (suggestedDate == null) {
      return null;
    }

    return AiSuggestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SuggestionType.dueDate,
      value: suggestedDate,
      confidence: confidence,
      reasoning: reasoning,
      createdAt: DateTime.now(),
    );
  }

  /// Suggest tags based on content
  List<AiSuggestion> _suggestTags(String content, List<String> existingTags) {
    final suggestions = <AiSuggestion>[];
    final suggestedTags = <String>{};

    // Detect common categories
    if (_workKeywords.any((kw) => content.contains(kw)) &&
        !existingTags.contains('work')) {
      suggestedTags.add('work');
    }

    if (_personalKeywords.any((kw) => content.contains(kw)) &&
        !existingTags.contains('personal')) {
      suggestedTags.add('personal');
    }

    if (_meetingKeywords.any((kw) => content.contains(kw)) &&
        !existingTags.contains('meeting')) {
      suggestedTags.add('meeting');
    }

    // Shopping related
    if (content.contains('buy') ||
        content.contains('purchase') ||
        content.contains('shop')) {
      if (!existingTags.contains('shopping')) {
        suggestedTags.add('shopping');
      }
    }

    // Health related
    if (content.contains('doctor') ||
        content.contains('gym') ||
        content.contains('exercise') ||
        content.contains('health')) {
      if (!existingTags.contains('health')) {
        suggestedTags.add('health');
      }
    }

    // Finance related
    if (content.contains('pay') ||
        content.contains('bill') ||
        content.contains('invoice') ||
        content.contains('bank')) {
      if (!existingTags.contains('finance')) {
        suggestedTags.add('finance');
      }
    }

    // Create suggestions for each tag
    for (final tag in suggestedTags) {
      suggestions.add(
        AiSuggestion(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: SuggestionType.tags,
          value: tag,
          confidence: 0.75,
          reasoning: 'Task content suggests "$tag" category',
          createdAt: DateTime.now(),
        ),
      );
    }

    return suggestions;
  }

  /// Estimate time required for task
  AiSuggestion? _estimateTime(String content) {
    int estimatedMinutes = 30; // Default
    double confidence = 0.6;
    String reasoning = 'Estimated based on task complexity';

    // Check for explicit time mentions
    if (content.contains('quick') || content.contains('5 min')) {
      estimatedMinutes = 15;
      confidence = 0.8;
      reasoning = 'Task mentions quick/short duration';
    } else if (content.contains('hour') || content.contains('1h')) {
      estimatedMinutes = 60;
      confidence = 0.85;
      reasoning = 'Task mentions hour duration';
    } else if (_meetingKeywords.any((kw) => content.contains(kw))) {
      estimatedMinutes = 30;
      confidence = 0.75;
      reasoning = 'Meetings typically take 30-60 minutes';
    } else if (content.contains('call')) {
      estimatedMinutes = 15;
      confidence = 0.7;
      reasoning = 'Calls typically take 15-30 minutes';
    } else if (content.contains('review') || content.contains('read')) {
      estimatedMinutes = 45;
      confidence = 0.7;
      reasoning = 'Review tasks typically take 30-60 minutes';
    } else if (content.contains('write') || content.contains('create')) {
      estimatedMinutes = 90;
      confidence = 0.65;
      reasoning = 'Creative tasks typically take 1-2 hours';
    }

    return AiSuggestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SuggestionType.timeEstimate,
      value: estimatedMinutes,
      confidence: confidence,
      reasoning: reasoning,
      createdAt: DateTime.now(),
    );
  }

  /// Find related tasks based on similarity
  List<String> _findRelatedTasks(String content, List<TaskEntity> existingTasks) {
    final relatedIds = <String>[];
    final contentWords = _extractKeywords(content);

    for (final task in existingTasks) {
      if (task.isCompleted) continue;

      final taskContent = '${task.title} ${task.description ?? ''}'.toLowerCase();
      final taskWords = _extractKeywords(taskContent);

      // Calculate similarity (simple word overlap)
      final commonWords = contentWords.intersection(taskWords);
      final similarity = commonWords.length / contentWords.length;

      if (similarity > 0.3) {
        // 30% similarity threshold
        relatedIds.add(task.id);
      }

      // Limit to 5 related tasks
      if (relatedIds.length >= 5) break;
    }

    return relatedIds;
  }

  /// Suggest optimal time to work on task
  DateTime? _suggestOptimalTime(String content, DateTime? dueDate) {
    final now = DateTime.now();

    // Morning tasks (8 AM)
    if (content.contains('email') ||
        content.contains('plan') ||
        content.contains('review')) {
      return DateTime(now.year, now.month, now.day, 8, 0);
    }

    // Afternoon tasks (2 PM)
    if (_meetingKeywords.any((kw) => content.contains(kw))) {
      return DateTime(now.year, now.month, now.day, 14, 0);
    }

    // Evening tasks (6 PM)
    if (content.contains('exercise') ||
        content.contains('gym') ||
        content.contains('workout')) {
      return DateTime(now.year, now.month, now.day, 18, 0);
    }

    // If due date exists, suggest 2 days before
    if (dueDate != null) {
      final suggestedDate = dueDate.subtract(const Duration(days: 2));
      if (suggestedDate.isAfter(now)) {
        return DateTime(suggestedDate.year, suggestedDate.month,
            suggestedDate.day, 10, 0);
      }
    }

    return null;
  }

  /// Calculate task complexity
  int _calculateComplexity(String content, String? description) {
    int complexity = 5; // Base complexity

    // Long tasks are more complex
    final totalLength = content.length + (description?.length ?? 0);
    if (totalLength > 500) {
      complexity += 2;
    } else if (totalLength > 200) {
      complexity += 1;
    }

    // Multiple steps indicate complexity
    if (content.contains('and') && content.split('and').length > 2) {
      complexity += 1;
    }

    // Certain keywords indicate complexity
    if (content.contains('complex') ||
        content.contains('difficult') ||
        content.contains('challenge')) {
      complexity += 2;
    }

    if (content.contains('research') ||
        content.contains('analyze') ||
        content.contains('investigate')) {
      complexity += 1;
    }

    return complexity.clamp(1, 10);
  }

  /// Extract keywords from text
  Set<String> _extractKeywords(String text) {
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3) // Filter short words
        .toSet();

    // Remove common stop words
    const stopWords = {
      'that',
      'this',
      'with',
      'from',
      'have',
      'will',
      'would',
      'should',
      'could',
      'been',
      'their',
      'there',
      'these',
      'those',
    };

    return words.difference(stopWords);
  }
}
