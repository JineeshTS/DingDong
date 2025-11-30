/// Habit Tracker State Management
///
/// This module provides comprehensive habit tracking functionality including:
/// - Habit CRUD operations
/// - Check-ins and streaks tracking
/// - Habit templates (15+ predefined habits)
/// - Statistics and completion rates
/// - Multiple view modes (list, grid, calendar)
/// - Category-based organization
/// - Frequency settings (daily, weekly, monthly, custom)
///
/// Key Components:
/// - [HabitTrackerState]: Immutable state with habit data
/// - [HabitTrackerNotifier]: Business logic for habit tracking
/// - [habitTrackerNotifierProvider]: Main provider for habit state
/// - [HabitTemplates]: 15+ predefined habit templates
/// - 30+ derived providers for granular UI access
///
/// Usage:
/// ```dart
/// // Watch today's habits
/// final todayHabits = ref.watch(habitsDueTodayProvider);
///
/// // Check in a habit
/// ref.read(habitTrackerNotifierProvider.notifier).checkInHabit(habitId);
///
/// // Create habit from template
/// ref.read(habitTrackerNotifierProvider.notifier)
///   .createHabitFromTemplate(HabitTemplates.exercise);
/// ```
library habit_tracker;

export 'habit_tracker_state.dart';
export 'habit_tracker_notifier.dart';
export 'habit_tracker_providers.dart';
