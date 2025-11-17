import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'goals_state.dart';

/// Goals Notifier
///
/// Manages goals and milestones including:
/// - CRUD operations for goals
/// - Milestone management
/// - Progress tracking
/// - Task linkage
/// - Filtering and statistics
class GoalsNotifier extends StateNotifier<GoalsState> {
  final String _userId;
  final SharedPreferences _prefs;

  GoalsNotifier({
    required String userId,
    required SharedPreferences prefs,
  })  : _userId = userId,
        _prefs = prefs,
        super(const GoalsState()) {
    _loadGoals();
  }

  /// Load goals from local storage
  Future<void> _loadGoals() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final goalsJson = _prefs.getString('goals_$_userId');
      if (goalsJson != null) {
        final List<dynamic> decoded = json.decode(goalsJson);
        final goals = decoded.map((json) => _goalFromJson(json)).toList();

        _updateStatistics(goals);

        state = state.copyWith(
          goals: goals,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load goals: $e',
      );
    }
  }

  /// Save goals to local storage
  Future<void> _saveGoals() async {
    try {
      final goalsJson = json.encode(
        state.goals.map((g) => _goalToJson(g)).toList(),
      );
      await _prefs.setString('goals_$_userId', goalsJson);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save goals: $e');
    }
  }

  /// Create new goal
  Future<void> createGoal(Goal goal) async {
    final updatedGoals = [...state.goals, goal];

    _updateStatistics(updatedGoals);

    state = state.copyWith(goals: updatedGoals);
    await _saveGoals();
  }

  /// Create goal from template
  Future<void> createGoalFromTemplate(GoalTemplate template) async {
    final goal = template.toGoal(
      const Uuid().v4(),
      _userId,
    );
    await createGoal(goal);
  }

  /// Update goal
  Future<void> updateGoal(Goal updatedGoal) async {
    final updatedGoals = state.goals.map((g) {
      return g.id == updatedGoal.id ? updatedGoal : g;
    }).toList();

    _updateStatistics(updatedGoals);

    state = state.copyWith(
      goals: updatedGoals,
      selectedGoal: state.selectedGoal?.id == updatedGoal.id
          ? updatedGoal
          : state.selectedGoal,
    );
    await _saveGoals();
  }

  /// Delete goal
  Future<void> deleteGoal(String goalId) async {
    final updatedGoals = state.goals.where((g) => g.id != goalId).toList();

    _updateStatistics(updatedGoals);

    state = state.copyWith(
      goals: updatedGoals,
      selectedGoal: state.selectedGoal?.id == goalId ? null : state.selectedGoal,
    );
    await _saveGoals();
  }

  /// Toggle goal completion
  Future<void> toggleGoalCompletion(String goalId) async {
    final goal = state.goals.firstWhere((g) => g.id == goalId);
    final updatedGoal = goal.copyWith(
      isCompleted: !goal.isCompleted,
      completedAt: !goal.isCompleted ? DateTime.now() : null,
      progress: !goal.isCompleted ? 100.0 : goal.progress,
    );
    await updateGoal(updatedGoal);
  }

  /// Toggle goal archive
  Future<void> toggleGoalArchive(String goalId) async {
    final goal = state.goals.firstWhere((g) => g.id == goalId);
    final updatedGoal = goal.copyWith(
      isArchived: !goal.isArchived,
    );
    await updateGoal(updatedGoal);
  }

  /// Update goal progress
  Future<void> updateGoalProgress(String goalId, double progress) async {
    final goal = state.goals.firstWhere((g) => g.id == goalId);
    final updatedGoal = goal.copyWith(
      progress: progress.clamp(0.0, 100.0),
      isCompleted: progress >= 100.0,
      completedAt: progress >= 100.0 ? DateTime.now() : null,
    );
    await updateGoal(updatedGoal);
  }

  /// Add milestone to goal
  Future<void> addMilestone(String goalId, Milestone milestone) async {
    final goal = state.goals.firstWhere((g) => g.id == goalId);
    final updatedMilestones = [...goal.milestones, milestone];
    final updatedGoal = goal.copyWith(milestones: updatedMilestones);
    await updateGoal(updatedGoal);
  }

  /// Toggle milestone completion
  Future<void> toggleMilestoneCompletion(
    String goalId,
    String milestoneId,
  ) async {
    final goal = state.goals.firstWhere((g) => g.id == goalId);
    final updatedMilestones = goal.milestones.map((m) {
      if (m.id == milestoneId) {
        return m.copyWith(
          isCompleted: !m.isCompleted,
          completedAt: !m.isCompleted ? DateTime.now() : null,
        );
      }
      return m;
    }).toList();

    // Calculate progress based on milestones
    final completedCount =
        updatedMilestones.where((m) => m.isCompleted).length;
    final progress = updatedMilestones.isEmpty
        ? goal.progress
        : (completedCount / updatedMilestones.length) * 100;

    final updatedGoal = goal.copyWith(
      milestones: updatedMilestones,
      progress: progress,
    );

    await updateGoal(updatedGoal);
  }

  /// Delete milestone
  Future<void> deleteMilestone(String goalId, String milestoneId) async {
    final goal = state.goals.firstWhere((g) => g.id == goalId);
    final updatedMilestones =
        goal.milestones.where((m) => m.id != milestoneId).toList();

    // Recalculate progress
    final completedCount =
        updatedMilestones.where((m) => m.isCompleted).length;
    final progress = updatedMilestones.isEmpty
        ? goal.progress
        : (completedCount / updatedMilestones.length) * 100;

    final updatedGoal = goal.copyWith(
      milestones: updatedMilestones,
      progress: progress,
    );

    await updateGoal(updatedGoal);
  }

  /// Link task to goal
  Future<void> linkTaskToGoal(String goalId, String taskId) async {
    final goal = state.goals.firstWhere((g) => g.id == goalId);
    if (goal.linkedTaskIds.contains(taskId)) return;

    final updatedTaskIds = [...goal.linkedTaskIds, taskId];
    final updatedGoal = goal.copyWith(linkedTaskIds: updatedTaskIds);
    await updateGoal(updatedGoal);
  }

  /// Unlink task from goal
  Future<void> unlinkTaskFromGoal(String goalId, String taskId) async {
    final goal = state.goals.firstWhere((g) => g.id == goalId);
    final updatedTaskIds =
        goal.linkedTaskIds.where((id) => id != taskId).toList();
    final updatedGoal = goal.copyWith(linkedTaskIds: updatedTaskIds);
    await updateGoal(updatedGoal);
  }

  /// Select goal for detail view
  void selectGoal(Goal? goal) {
    state = state.copyWith(selectedGoal: goal);
  }

  /// Change filter
  void changeFilter(GoalFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Filter by category
  void filterByCategory(GoalCategory? category) {
    state = state.copyWith(filterCategory: category);
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(
      filter: GoalFilter.all,
      filterCategory: null,
    );
  }

  /// Update statistics
  void _updateStatistics(List<Goal> goals) {
    final active = goals.where((g) => !g.isCompleted && !g.isArchived).length;
    final completed = goals.where((g) => g.isCompleted).length;
    final totalProgress = goals.isEmpty
        ? 0.0
        : goals.map((g) => g.progress).reduce((a, b) => a + b) / goals.length;

    state = state.copyWith(
      totalGoals: goals.length,
      activeGoals: active,
      completedGoals: completed,
      overallProgress: totalProgress,
    );
  }

  /// Convert Goal to JSON
  Map<String, dynamic> _goalToJson(Goal goal) {
    return {
      'id': goal.id,
      'userId': goal.userId,
      'title': goal.title,
      'description': goal.description,
      'category': goal.category.name,
      'createdAt': goal.createdAt.toIso8601String(),
      'deadline': goal.deadline?.toIso8601String(),
      'linkedTaskIds': goal.linkedTaskIds,
      'milestones': goal.milestones
          .map((m) => {
                'id': m.id,
                'title': m.title,
                'description': m.description,
                'dueDate': m.dueDate?.toIso8601String(),
                'isCompleted': m.isCompleted,
                'completedAt': m.completedAt?.toIso8601String(),
              })
          .toList(),
      'progress': goal.progress,
      'isCompleted': goal.isCompleted,
      'isArchived': goal.isArchived,
      'completedAt': goal.completedAt?.toIso8601String(),
      'isSpecific': goal.isSpecific,
      'isMeasurable': goal.isMeasurable,
      'isAchievable': goal.isAchievable,
      'isRelevant': goal.isRelevant,
      'isTimeBound': goal.isTimeBound,
    };
  }

  /// Convert JSON to Goal
  Goal _goalFromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: GoalCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => GoalCategory.personal,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      linkedTaskIds: List<String>.from(json['linkedTaskIds'] as List? ?? []),
      milestones: (json['milestones'] as List?)
              ?.map((m) => Milestone(
                    id: m['id'] as String,
                    title: m['title'] as String,
                    description: m['description'] as String?,
                    dueDate: m['dueDate'] != null
                        ? DateTime.parse(m['dueDate'] as String)
                        : null,
                    isCompleted: m['isCompleted'] as bool? ?? false,
                    completedAt: m['completedAt'] != null
                        ? DateTime.parse(m['completedAt'] as String)
                        : null,
                  ))
              .toList() ??
          [],
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isSpecific: json['isSpecific'] as bool?,
      isMeasurable: json['isMeasurable'] as bool?,
      isAchievable: json['isAchievable'] as bool?,
      isRelevant: json['isRelevant'] as bool?,
      isTimeBound: json['isTimeBound'] as bool?,
    );
  }
}
