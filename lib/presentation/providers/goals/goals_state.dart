import 'package:freezed_annotation/freezed_annotation.dart';

part 'goals_state.freezed.dart';

/// Goals State
///
/// Manages goals and milestones including:
/// - Goals with progress tracking
/// - Milestones for projects
/// - Task linkage to goals
/// - SMART goals framework
@freezed
class GoalsState with _$GoalsState {
  const factory GoalsState({
    // Goals list
    @Default([]) List<Goal> goals,
    @Default([]) List<Milestone> milestones,

    // Selected goal for detail view
    Goal? selectedGoal,

    // Filters
    @Default(GoalFilter.all) GoalFilter filter,
    GoalCategory? filterCategory,

    // Statistics
    @Default(0) int totalGoals,
    @Default(0) int completedGoals,
    @Default(0) int activeGoals,
    @Default(0.0) double overallProgress,

    // UI state
    @Default(false) bool isLoading,
    String? error,
  }) = _GoalsState;

  const GoalsState._();

  /// Get active goals
  List<Goal> get activeGoalsList {
    return goals.where((g) => !g.isCompleted && !g.isArchived).toList();
  }

  /// Get completed goals
  List<Goal> get completedGoalsList {
    return goals.where((g) => g.isCompleted).toList();
  }

  /// Get archived goals
  List<Goal> get archivedGoalsList {
    return goals.where((g) => g.isArchived).toList();
  }

  /// Get goals by category
  List<Goal> getGoalsByCategory(GoalCategory category) {
    return goals.where((g) => g.category == category).toList();
  }

  /// Get filtered goals
  List<Goal> get filteredGoals {
    var filtered = goals;

    // Apply filter
    switch (filter) {
      case GoalFilter.all:
        filtered = goals;
        break;
      case GoalFilter.active:
        filtered = activeGoalsList;
        break;
      case GoalFilter.completed:
        filtered = completedGoalsList;
        break;
      case GoalFilter.archived:
        filtered = archivedGoalsList;
        break;
    }

    // Apply category filter
    if (filterCategory != null) {
      filtered = filtered.where((g) => g.category == filterCategory).toList();
    }

    return filtered;
  }

  /// Calculate overall completion rate
  double get completionRate {
    if (goals.isEmpty) return 0.0;
    final completed = completedGoalsList.length;
    return (completed / goals.length) * 100;
  }
}

/// Goal
@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String userId,
    required String title,
    String? description,
    required GoalCategory category,
    required DateTime createdAt,
    DateTime? deadline,
    @Default([]) List<String> linkedTaskIds,
    @Default([]) List<Milestone> milestones,
    @Default(0.0) double progress,
    @Default(false) bool isCompleted,
    @Default(false) bool isArchived,
    DateTime? completedAt,

    // SMART framework fields
    bool? isSpecific,
    bool? isMeasurable,
    bool? isAchievable,
    bool? isRelevant,
    bool? isTimeBound,
  }) = _Goal;

  const Goal._();

  /// Check if goal is overdue
  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return DateTime.now().isAfter(deadline!);
  }

  /// Get days until deadline
  int? get daysUntilDeadline {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  /// Get SMART score (0-5)
  int get smartScore {
    int score = 0;
    if (isSpecific == true) score++;
    if (isMeasurable == true) score++;
    if (isAchievable == true) score++;
    if (isRelevant == true) score++;
    if (isTimeBound == true) score++;
    return score;
  }

  /// Check if goal is SMART
  bool get isSmart => smartScore == 5;
}

/// Milestone
@freezed
class Milestone with _$Milestone {
  const factory Milestone({
    required String id,
    required String title,
    String? description,
    DateTime? dueDate,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
  }) = _Milestone;

  const Milestone._();

  /// Check if milestone is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }
}

/// Goal Category
enum GoalCategory {
  personal,
  career,
  health,
  financial,
  education,
  relationships,
  hobby,
  travel,
  custom,
}

/// Goal Filter
enum GoalFilter {
  all,
  active,
  completed,
  archived,
}

/// Goal Template
class GoalTemplate {
  final String title;
  final String? description;
  final GoalCategory category;
  final List<String> milestoneTemplates;

  const GoalTemplate({
    required this.title,
    this.description,
    required this.category,
    this.milestoneTemplates = const [],
  });

  /// Convert template to goal
  Goal toGoal(String id, String userId) {
    final milestones = milestoneTemplates
        .asMap()
        .entries
        .map((e) => Milestone(
              id: '${id}_milestone_${e.key}',
              title: e.value,
            ))
        .toList();

    return Goal(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: category,
      createdAt: DateTime.now(),
      milestones: milestones,
    );
  }
}

/// Predefined Goal Templates
class GoalTemplates {
  // Personal
  static const readBooks = GoalTemplate(
    title: 'Read 12 books this year',
    description: 'Read one book per month',
    category: GoalCategory.personal,
    milestoneTemplates: [
      'Read 3 books (Q1)',
      'Read 6 books (Q2)',
      'Read 9 books (Q3)',
      'Read 12 books (Q4)',
    ],
  );

  static const learnLanguage = GoalTemplate(
    title: 'Learn a new language',
    description: 'Achieve conversational fluency',
    category: GoalCategory.education,
    milestoneTemplates: [
      'Complete beginner course',
      'Practice 30 days in a row',
      'Have first conversation',
      'Pass proficiency test',
    ],
  );

  // Career
  static const getPromotion = GoalTemplate(
    title: 'Get promoted',
    description: 'Advance to next career level',
    category: GoalCategory.career,
    milestoneTemplates: [
      'Complete required training',
      'Lead 2 major projects',
      'Get positive performance review',
      'Submit promotion request',
    ],
  );

  static const launchProject = GoalTemplate(
    title: 'Launch side project',
    description: 'Build and launch a product',
    category: GoalCategory.career,
    milestoneTemplates: [
      'Define MVP features',
      'Build prototype',
      'Get first 10 users',
      'Launch publicly',
    ],
  );

  // Health
  static const loseWeight = GoalTemplate(
    title: 'Lose 10 kg',
    description: 'Achieve healthy weight through diet and exercise',
    category: GoalCategory.health,
    milestoneTemplates: [
      'Lose 2.5 kg (Month 1)',
      'Lose 5 kg (Month 2)',
      'Lose 7.5 kg (Month 3)',
      'Reach target weight',
    ],
  );

  static const runMarathon = GoalTemplate(
    title: 'Run a marathon',
    description: 'Complete a full marathon (42.2 km)',
    category: GoalCategory.health,
    milestoneTemplates: [
      'Run 5K without stopping',
      'Run 10K race',
      'Run half marathon',
      'Complete full marathon',
    ],
  );

  // Financial
  static const saveEmergencyFund = GoalTemplate(
    title: 'Build emergency fund',
    description: 'Save 6 months of expenses',
    category: GoalCategory.financial,
    milestoneTemplates: [
      'Save 1 month expenses',
      'Save 3 months expenses',
      'Save 6 months expenses',
    ],
  );

  static const payOffDebt = GoalTemplate(
    title: 'Pay off debt',
    description: 'Become debt-free',
    category: GoalCategory.financial,
    milestoneTemplates: [
      'Pay 25% of debt',
      'Pay 50% of debt',
      'Pay 75% of debt',
      'Become debt-free',
    ],
  );

  // Get all templates
  static List<GoalTemplate> get allTemplates => [
        readBooks,
        learnLanguage,
        getPromotion,
        launchProject,
        loseWeight,
        runMarathon,
        saveEmergencyFund,
        payOffDebt,
      ];

  // Get templates by category
  static List<GoalTemplate> getByCategory(GoalCategory category) {
    return allTemplates.where((t) => t.category == category).toList();
  }
}
