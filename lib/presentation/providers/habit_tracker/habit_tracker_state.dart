import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/habit_entity.dart';

part 'habit_tracker_state.freezed.dart';

/// Habit Tracker State
///
/// Manages habit tracking data including:
/// - List of habits
/// - Check-ins and streaks
/// - Statistics and completion rates
/// - Filters and views
@freezed
class HabitTrackerState with _$HabitTrackerState {
  const factory HabitTrackerState({
    // Habits list
    @Default([]) List<HabitEntity> habits,
    @Default([]) List<HabitEntity> todayHabits,

    // Selected habit for detail view
    HabitEntity? selectedHabit,

    // View mode
    @Default(HabitViewMode.list) HabitViewMode viewMode,

    // Filters
    @Default(false) bool showArchived,
    HabitCategory? filterCategory,

    // Statistics
    @Default(0) int totalHabits,
    @Default(0) int completedToday,
    @Default(0) int totalCompletedToday,
    @Default(0.0) double todayCompletionRate,
    @Default(0) int activeStreaks,
    @Default(0) int longestStreak,

    // UI state
    @Default(false) bool isLoading,
    @Default(false) bool isCheckingIn,
    String? error,
  }) = _HabitTrackerState;

  const HabitTrackerState._();

  /// Get habits by category
  List<HabitEntity> getHabitsByCategory(HabitCategory category) {
    return habits.where((h) => h.category == category && !h.isArchived).toList();
  }

  /// Get active habits (not archived)
  List<HabitEntity> get activeHabits {
    return habits.where((h) => !h.isArchived).toList();
  }

  /// Get archived habits
  List<HabitEntity> get archivedHabits {
    return habits.where((h) => h.isArchived).toList();
  }

  /// Get habits due today
  List<HabitEntity> get habitsDueToday {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;

    return activeHabits.where((habit) {
      switch (habit.frequency) {
        case HabitFrequency.daily:
          return true;
        case HabitFrequency.weekly:
          return habit.targetDaysOfWeek.isEmpty ||
              habit.targetDaysOfWeek.contains(dayOfWeek);
        case HabitFrequency.monthly:
          // Check if it's one of the target days of the month
          return true; // Simplified for now
        case HabitFrequency.custom:
          return true; // Simplified for now
      }
    }).toList();
  }

  /// Get completed habits today
  List<HabitEntity> get completedHabitsToday {
    return habitsDueToday.where((h) => h.isCompletedToday).toList();
  }

  /// Get pending habits today
  List<HabitEntity> get pendingHabitsToday {
    return habitsDueToday.where((h) => !h.isCompletedToday).toList();
  }

  /// Get habits with active streaks
  List<HabitEntity> get habitsWithStreaks {
    return activeHabits.where((h) => h.currentStreak > 0).toList()
      ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
  }

  /// Calculate overall completion rate for today
  double get overallTodayCompletionRate {
    final dueToday = habitsDueToday.length;
    if (dueToday == 0) return 0.0;
    final completed = completedHabitsToday.length;
    return (completed / dueToday) * 100;
  }

  /// Get habits by frequency
  List<HabitEntity> getHabitsByFrequency(HabitFrequency frequency) {
    return activeHabits.where((h) => h.frequency == frequency).toList();
  }
}

/// Habit View Mode
enum HabitViewMode {
  list,
  grid,
  calendar,
}

/// Habit Template
class HabitTemplate {
  final String name;
  final String? description;
  final String icon;
  final HabitCategory category;
  final HabitFrequency frequency;
  final int targetCount;
  final String color;

  const HabitTemplate({
    required this.name,
    this.description,
    required this.icon,
    required this.category,
    this.frequency = HabitFrequency.daily,
    this.targetCount = 1,
    this.color = '#4CAF50',
  });

  /// Convert template to habit entity
  HabitEntity toHabit(String id, String userId) {
    final now = DateTime.now();
    return HabitEntity(
      id: id,
      userId: userId,
      name: name,
      description: description,
      icon: icon,
      color: color,
      category: category,
      frequency: frequency,
      targetCount: targetCount,
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// Predefined Habit Templates
class HabitTemplates {
  // Health & Fitness
  static const drinkWater = HabitTemplate(
    name: 'Drink 8 glasses of water',
    icon: '💧',
    category: HabitCategory.healthFitness,
    targetCount: 8,
    color: '#2196F3',
  );

  static const exercise = HabitTemplate(
    name: 'Exercise',
    description: '30 minutes of physical activity',
    icon: '🏃',
    category: HabitCategory.healthFitness,
    color: '#FF5722',
  );

  static const meditation = HabitTemplate(
    name: 'Meditate',
    description: '10 minutes of mindfulness',
    icon: '🧘',
    category: HabitCategory.mindfulnessMentalHealth,
    color: '#9C27B0',
  );

  static const sleep = HabitTemplate(
    name: 'Sleep 8 hours',
    icon: '😴',
    category: HabitCategory.healthFitness,
    color: '#3F51B5',
  );

  static const healthyMeal = HabitTemplate(
    name: 'Eat healthy meals',
    icon: '🥗',
    category: HabitCategory.healthFitness,
    targetCount: 3,
    color: '#4CAF50',
  );

  // Personal Development
  static const reading = HabitTemplate(
    name: 'Read',
    description: 'Read for 30 minutes',
    icon: '📚',
    category: HabitCategory.personalDevelopment,
    color: '#795548',
  );

  static const learning = HabitTemplate(
    name: 'Learn something new',
    icon: '🎓',
    category: HabitCategory.personalDevelopment,
    color: '#FF9800',
  );

  static const journaling = HabitTemplate(
    name: 'Journal',
    description: 'Write daily reflections',
    icon: '📝',
    category: HabitCategory.personalDevelopment,
    color: '#607D8B',
  );

  // Work & Productivity
  static const planning = HabitTemplate(
    name: 'Plan your day',
    icon: '📅',
    category: HabitCategory.workProductivity,
    color: '#2196F3',
  );

  static const deepWork = HabitTemplate(
    name: 'Deep work session',
    description: 'Focus for 2 hours',
    icon: '💼',
    category: HabitCategory.workProductivity,
    color: '#3F51B5',
  );

  static const inbox = HabitTemplate(
    name: 'Clear inbox',
    icon: '📧',
    category: HabitCategory.workProductivity,
    color: '#00BCD4',
  );

  // Finance & Savings
  static const budgetReview = HabitTemplate(
    name: 'Review budget',
    icon: '💰',
    category: HabitCategory.financeSavings,
    frequency: HabitFrequency.weekly,
    color: '#4CAF50',
  );

  static const saveM oney = HabitTemplate(
    name: 'Save money',
    description: 'Add to savings',
    icon: '🏦',
    category: HabitCategory.financeSavings,
    color: '#009688',
  );

  // Social & Relationships
  static const callFamily = HabitTemplate(
    name: 'Call family',
    icon: '📞',
    category: HabitCategory.socialRelationships,
    frequency: HabitFrequency.weekly,
    color: '#E91E63',
  );

  static const gratitude = HabitTemplate(
    name: 'Practice gratitude',
    icon: '🙏',
    category: HabitCategory.mindfulnessMentalHealth,
    color: '#FFEB3B',
  );

  // Get all templates
  static List<HabitTemplate> get allTemplates => [
        drinkWater,
        exercise,
        meditation,
        sleep,
        healthyMeal,
        reading,
        learning,
        journaling,
        planning,
        deepWork,
        inbox,
        budgetReview,
        saveMoney,
        callFamily,
        gratitude,
      ];

  // Get templates by category
  static List<HabitTemplate> getByCategory(HabitCategory category) {
    return allTemplates.where((t) => t.category == category).toList();
  }
}
