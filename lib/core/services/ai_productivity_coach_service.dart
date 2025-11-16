import '../../domain/entities/productivity_insight.dart';
import '../../domain/entities/task_entity.dart';
import '../utils/logger.dart';

/// AI Productivity Coach Service
///
/// Analyzes user's tasks, patterns, and workload to provide intelligent
/// productivity insights and recommendations.
class AiProductivityCoachService {
  final _logger = Logger();

  // Thresholds and constants
  static const _overloadTaskThreshold = 15;
  static const _busyTaskThreshold = 10;
  static const _highPriorityThreshold = 5;
  static const _hoursPerDayThreshold = 8;
  static const _complexTaskMinLength = 100;
  static const _focusStreakThreshold = 3;

  /// Analyze productivity and generate insights
  Future<ProductivityAnalysis> analyzeProductivity({
    required List<TaskEntity> allTasks,
    List<TaskEntity>? completedTodayTasks,
    List<TaskEntity>? completedThisWeekTasks,
    DateTime? lastCompletedAt,
  }) async {
    try {
      _logger.info('Starting productivity analysis');

      final insights = <ProductivityInsight>[];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Calculate metrics
      final metrics = _calculateMetrics(
        allTasks: allTasks,
        completedTodayTasks: completedTodayTasks ?? [],
        completedThisWeekTasks: completedThisWeekTasks ?? [],
        lastCompletedAt: lastCompletedAt,
      );

      // 1. Workload analysis
      insights.addAll(_analyzeWorkload(metrics, allTasks));

      // 2. Task breakdown suggestions
      insights.addAll(_suggestTaskBreakdowns(allTasks));

      // 3. Optimal timing recommendations
      insights.addAll(_analyzeOptimalTiming(allTasks, metrics));

      // 4. Workflow optimization
      insights.addAll(_analyzeWorkflow(allTasks, metrics));

      // 5. Distraction alerts
      insights.addAll(_analyzeDistractions(metrics));

      // 6. Energy management
      insights.addAll(_analyzeEnergyLevel(metrics));

      // 7. Progress celebration
      insights.addAll(_celebrateProgress(metrics));

      // 8. General productivity tips
      insights.addAll(_generateProductivityTips(allTasks, metrics));

      _logger.info('Analysis complete: ${insights.length} insights generated');

      return ProductivityAnalysis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        insights: insights,
        metrics: metrics,
        analyzedAt: now,
        nextAnalysisAt: now.add(const Duration(hours: 1)),
      );
    } catch (e, stackTrace) {
      _logger.error('Productivity analysis failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Calculate productivity metrics
  ProductivityMetrics _calculateMetrics({
    required List<TaskEntity> allTasks,
    required List<TaskEntity> completedTodayTasks,
    required List<TaskEntity> completedThisWeekTasks,
    DateTime? lastCompletedAt,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));

    // Active tasks (not completed)
    final activeTasks = allTasks.where((t) => !t.isCompleted).toList();

    // Count various task categories
    final overdueCount = activeTasks.where((t) {
      return t.dueDate != null && t.dueDate!.isBefore(today);
    }).length;

    final dueTodayCount = activeTasks.where((t) {
      if (t.dueDate == null) return false;
      final dueDate = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return dueDate == today;
    }).length;

    final dueThisWeekCount = activeTasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.isAfter(today) && t.dueDate!.isBefore(weekStart.add(const Duration(days: 7)));
    }).length;

    final highPriorityCount = activeTasks.where((t) => t.priority >= 3).length;

    // Estimate hours (assuming 30 min default if no estimate)
    final estimatedHoursToday = dueTodayCount * 0.5;
    final estimatedHoursThisWeek = (dueTodayCount + dueThisWeekCount) * 0.5;

    // Completion rates
    final totalTasksToday = completedTodayTasks.length + dueTodayCount;
    final completionRateToday = totalTasksToday > 0
        ? completedTodayTasks.length / totalTasksToday
        : 0.0;

    final totalTasksWeek = completedThisWeekTasks.length + activeTasks.length;
    final completionRateWeek = totalTasksWeek > 0
        ? completedThisWeekTasks.length / totalTasksWeek
        : 0.0;

    // Focus streak (based on completion patterns)
    final currentFocusStreak = completedTodayTasks.length >= _focusStreakThreshold
        ? completedTodayTasks.length
        : 0;

    // Determine workload level
    final workloadLevel = _determineWorkloadLevel(
      activeTasks.length,
      highPriorityCount,
      estimatedHoursToday.toInt(),
    );

    // Determine energy level (based on time of day)
    final energyLevel = _determineEnergyLevel(now);

    return ProductivityMetrics(
      totalActiveTasks: activeTasks.length,
      overdueTasksCount: overdueCount,
      dueTodayCount: dueTodayCount,
      dueThisWeekCount: dueThisWeekCount,
      highPriorityCount: highPriorityCount,
      estimatedHoursToday: estimatedHoursToday.toInt(),
      estimatedHoursThisWeek: estimatedHoursThisWeek.toInt(),
      completedToday: completedTodayTasks.length,
      completedThisWeek: completedThisWeekTasks.length,
      completionRateToday: completionRateToday,
      completionRateThisWeek: completionRateWeek,
      currentFocusStreak: currentFocusStreak,
      lastCompletedTaskAt: lastCompletedAt,
      workloadLevel: workloadLevel,
      currentEnergyLevel: energyLevel,
    );
  }

  /// Determine workload level
  WorkloadLevel _determineWorkloadLevel(
    int activeTaskCount,
    int highPriorityCount,
    int estimatedHours,
  ) {
    if (activeTaskCount >= _overloadTaskThreshold ||
        highPriorityCount >= _highPriorityThreshold ||
        estimatedHours > _hoursPerDayThreshold) {
      return WorkloadLevel.overloaded;
    } else if (activeTaskCount >= _busyTaskThreshold ||
        highPriorityCount >= 3 ||
        estimatedHours >= 6) {
      return WorkloadLevel.busy;
    } else if (activeTaskCount <= 3) {
      return WorkloadLevel.light;
    } else {
      return WorkloadLevel.balanced;
    }
  }

  /// Determine energy level based on time of day
  EnergyLevel _determineEnergyLevel(DateTime now) {
    final hour = now.hour;

    // Peak hours: 9 AM - 11 AM
    if (hour >= 9 && hour < 11) {
      return EnergyLevel.peak;
    }
    // High energy: 2 PM - 4 PM
    else if (hour >= 14 && hour < 16) {
      return EnergyLevel.high;
    }
    // Low energy: Early morning (5-7 AM) or late evening (8 PM - midnight)
    else if ((hour >= 5 && hour < 7) || (hour >= 20 && hour < 24)) {
      return EnergyLevel.low;
    }
    // Medium otherwise
    else {
      return EnergyLevel.medium;
    }
  }

  /// Analyze workload and generate insights
  List<ProductivityInsight> _analyzeWorkload(
    ProductivityMetrics metrics,
    List<TaskEntity> allTasks,
  ) {
    final insights = <ProductivityInsight>[];

    // Overload warning
    if (metrics.isOverloaded) {
      insights.add(ProductivityInsight(
        id: 'overload_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.overloadWarning,
        title: 'Too Much on Your Plate',
        message: 'You have ${metrics.totalActiveTasks} active tasks with ${metrics.highPriorityCount} high priority. '
            'Consider delegating, deferring, or breaking down some tasks.',
        priority: InsightPriority.high,
        createdAt: DateTime.now(),
        actionLabel: 'Review Tasks',
        actionRoute: '/tasks',
      ));
    }

    // Overdue tasks warning
    if (metrics.overdueTasksCount > 0) {
      insights.add(ProductivityInsight(
        id: 'overdue_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.overloadWarning,
        title: 'Overdue Tasks Need Attention',
        message: 'You have ${metrics.overdueTasksCount} overdue ${metrics.overdueTasksCount == 1 ? 'task' : 'tasks'}. '
            'Reschedule or complete them to stay on track.',
        priority: InsightPriority.high,
        createdAt: DateTime.now(),
        actionLabel: 'View Overdue',
        actionRoute: '/tasks',
        actionData: {'filter': 'overdue'},
      ));
    }

    return insights;
  }

  /// Suggest task breakdowns for complex tasks
  List<ProductivityInsight> _suggestTaskBreakdowns(List<TaskEntity> allTasks) {
    final insights = <ProductivityInsight>[];

    // Find complex tasks (long descriptions, no subtasks)
    final complexTasks = allTasks.where((task) {
      if (task.isCompleted) return false;
      final description = task.description ?? '';
      final hasSubtasks = task.subtasks.isNotEmpty;
      return description.length > _complexTaskMinLength && !hasSubtasks;
    }).take(2); // Limit to 2 suggestions

    for (final task in complexTasks) {
      insights.add(ProductivityInsight(
        id: 'breakdown_${task.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.taskBreakdown,
        title: 'Break Down Complex Task',
        message: '"${task.title}" looks complex. Breaking it into smaller subtasks '
            'can make it more manageable and help you track progress.',
        priority: InsightPriority.medium,
        createdAt: DateTime.now(),
        actionLabel: 'Add Subtasks',
        actionRoute: '/task/${task.id}/edit',
        actionData: {'taskId': task.id},
      ));
    }

    return insights;
  }

  /// Analyze optimal timing
  List<ProductivityInsight> _analyzeOptimalTiming(
    List<TaskEntity> allTasks,
    ProductivityMetrics metrics,
  ) {
    final insights = <ProductivityInsight>[];
    final now = DateTime.now();

    // Suggest working on high-priority tasks during peak energy
    if (metrics.currentEnergyLevel == EnergyLevel.peak &&
        metrics.highPriorityCount > 0) {
      insights.add(ProductivityInsight(
        id: 'peak_time_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.optimalTiming,
        title: 'Peak Productivity Time',
        message: 'You\'re in your peak energy window! Now is the perfect time '
            'to tackle your ${metrics.highPriorityCount} high-priority ${metrics.highPriorityCount == 1 ? 'task' : 'tasks'}.',
        priority: InsightPriority.high,
        createdAt: DateTime.now(),
        actionLabel: 'View High Priority',
        actionRoute: '/tasks',
        actionData: {'filter': 'high-priority'},
      ));
    }

    // Suggest easy tasks during low energy
    if (metrics.currentEnergyLevel == EnergyLevel.low) {
      final lowPriorityCount =
          allTasks.where((t) => !t.isCompleted && t.priority <= 1).length;

      if (lowPriorityCount > 0) {
        insights.add(ProductivityInsight(
          id: 'low_energy_${DateTime.now().millisecondsSinceEpoch}',
          type: InsightType.energyManagement,
          title: 'Low Energy Period',
          message: 'Energy levels are naturally lower now. Perfect time for '
              'simple, routine tasks that don\'t require deep focus.',
          priority: InsightPriority.low,
          createdAt: DateTime.now(),
          actionLabel: 'View Simple Tasks',
          actionRoute: '/tasks',
          actionData: {'filter': 'low-priority'},
        ));
      }
    }

    return insights;
  }

  /// Analyze workflow and suggest optimizations
  List<ProductivityInsight> _analyzeWorkflow(
    List<TaskEntity> allTasks,
    ProductivityMetrics metrics,
  ) {
    final insights = <ProductivityInsight>[];

    // Suggest batching similar tasks
    final tagGroups = <String, int>{};
    for (final task in allTasks.where((t) => !t.isCompleted)) {
      for (final tag in task.tags) {
        tagGroups[tag] = (tagGroups[tag] ?? 0) + 1;
      }
    }

    final largeGroups = tagGroups.entries.where((e) => e.value >= 3).toList();
    if (largeGroups.isNotEmpty) {
      final topGroup = largeGroups.first;
      insights.add(ProductivityInsight(
        id: 'batch_${topGroup.key}_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.workflowOptimization,
        title: 'Batch Similar Tasks',
        message: 'You have ${topGroup.value} "${topGroup.key}" tasks. '
            'Batching similar tasks together can improve focus and efficiency.',
        priority: InsightPriority.medium,
        createdAt: DateTime.now(),
        actionLabel: 'View ${topGroup.key} Tasks',
        actionRoute: '/tasks',
        actionData: {'filter': 'tag:${topGroup.key}'},
      ));
    }

    return insights;
  }

  /// Analyze for distractions
  List<ProductivityInsight> _analyzeDistractions(ProductivityMetrics metrics) {
    final insights = <ProductivityInsight>[];

    // If many tasks but low completion rate, suggest focus time
    if (metrics.totalActiveTasks >= 8 &&
        metrics.completionRateToday < 0.3 &&
        metrics.completedToday < 2) {
      insights.add(ProductivityInsight(
        id: 'focus_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.focusRecommendation,
        title: 'Time to Focus',
        message: 'You have many tasks but haven\'t completed much today. '
            'Try a focused work session: pick one task, eliminate distractions, '
            'and work for 25 minutes.',
        priority: InsightPriority.high,
        createdAt: DateTime.now(),
        actionLabel: 'Start Focus Timer',
        actionRoute: '/focus-timer',
      ));
    }

    return insights;
  }

  /// Analyze energy levels
  List<ProductivityInsight> _analyzeEnergyLevel(ProductivityMetrics metrics) {
    final insights = <ProductivityInsight>[];

    // Suggest break if been working for a while
    if (metrics.shouldTakeBreak) {
      insights.add(ProductivityInsight(
        id: 'break_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.energyManagement,
        title: 'Great Progress! Take a Break',
        message: 'You\'ve completed ${metrics.currentFocusStreak} tasks in a row. '
            'Taking a short break will help you maintain productivity.',
        priority: InsightPriority.medium,
        createdAt: DateTime.now(),
        actionLabel: 'Start Break Timer',
        actionRoute: '/break-timer',
      ));
    }

    return insights;
  }

  /// Celebrate progress
  List<ProductivityInsight> _celebrateProgress(ProductivityMetrics metrics) {
    final insights = <ProductivityInsight>[];

    // Celebrate good completion rate
    if (metrics.completedToday >= 5 && metrics.completionRateToday >= 0.7) {
      insights.add(ProductivityInsight(
        id: 'celebrate_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.progressCelebration,
        title: 'Amazing Productivity!',
        message: 'You\'ve completed ${metrics.completedToday} tasks today with a '
            '${(metrics.completionRateToday * 100).toInt()}% completion rate. Keep up the great work!',
        priority: InsightPriority.low,
        createdAt: DateTime.now(),
      ));
    }
    // Celebrate good streak
    else if (metrics.hasGoodMomentum) {
      insights.add(ProductivityInsight(
        id: 'streak_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.progressCelebration,
        title: 'You\'re on a Roll!',
        message: 'You\'ve completed ${metrics.currentFocusStreak} tasks. '
            'Great momentum!',
        priority: InsightPriority.low,
        createdAt: DateTime.now(),
      ));
    }

    return insights;
  }

  /// Generate general productivity tips
  List<ProductivityInsight> _generateProductivityTips(
    List<TaskEntity> allTasks,
    ProductivityMetrics metrics,
  ) {
    final insights = <ProductivityInsight>[];
    final now = DateTime.now();

    // Only add tips if not overloaded (don't add noise)
    if (metrics.isOverloaded) return insights;

    // Morning planning tip
    if (now.hour >= 7 && now.hour < 9 && metrics.dueTodayCount > 0) {
      insights.add(ProductivityInsight(
        id: 'tip_morning_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.productivityTip,
        title: 'Plan Your Day',
        message: 'Start your day by reviewing your ${metrics.dueTodayCount} tasks '
            'due today. Prioritize the most important ones.',
        priority: InsightPriority.low,
        createdAt: DateTime.now(),
        actionLabel: 'View Today',
        actionRoute: '/tasks',
        actionData: {'filter': 'today'},
      ));
    }

    // End of day review tip
    if (now.hour >= 17 && now.hour < 19) {
      insights.add(ProductivityInsight(
        id: 'tip_review_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.productivityTip,
        title: 'Daily Review',
        message: 'Take 5 minutes to review what you accomplished today and '
            'plan for tomorrow.',
        priority: InsightPriority.low,
        createdAt: DateTime.now(),
      ));
    }

    return insights;
  }

  /// Suggest task breakdown (detailed)
  Future<TaskBreakdownSuggestion?> suggestTaskBreakdown({
    required TaskEntity task,
  }) async {
    try {
      // Only suggest for tasks with substantial descriptions
      if ((task.description?.length ?? 0) < _complexTaskMinLength) {
        return null;
      }

      final description = task.description!.toLowerCase();
      final subtasks = <SubtaskSuggestion>[];

      // Simple pattern matching for common task structures
      // Look for numbered steps, bullet points, or "and" separators
      if (description.contains(RegExp(r'\d+\.'))) {
        // Numbered list detected
        final lines = description.split('\n');
        int order = 1;
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          if (RegExp(r'\d+\.').hasMatch(line)) {
            final cleaned = line.replaceAll(RegExp(r'\d+\.'), '').trim();
            if (cleaned.isNotEmpty) {
              subtasks.add(SubtaskSuggestion(
                title: cleaned,
                suggestedOrder: order++,
                estimatedMinutes: 30,
              ));
            }
          }
        }
      } else if (description.contains(' and ')) {
        // Multiple actions separated by "and"
        final parts = description.split(' and ');
        int order = 1;
        for (final part in parts) {
          final cleaned = part.trim();
          if (cleaned.isNotEmpty && cleaned.length > 5) {
            subtasks.add(SubtaskSuggestion(
              title: cleaned[0].toUpperCase() + cleaned.substring(1),
              suggestedOrder: order++,
              estimatedMinutes: 30,
            ));
          }
        }
      }

      if (subtasks.isEmpty) {
        return null;
      }

      return TaskBreakdownSuggestion(
        taskId: task.id,
        taskTitle: task.title,
        subtasks: subtasks,
        reasoning: 'Task appears to have multiple steps that could be tracked separately',
        confidence: 0.75,
        createdAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      _logger.error('Task breakdown suggestion failed', error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
