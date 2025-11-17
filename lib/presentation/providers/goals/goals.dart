/// Goals & Milestones State Management
///
/// This module provides comprehensive goals tracking functionality including:
/// - Goal CRUD operations
/// - Milestone management
/// - Progress tracking with percentage
/// - Task linkage to goals
/// - SMART goals framework support
/// - 8+ predefined goal templates
/// - Category-based organization
/// - Filtering and statistics
///
/// Key Components:
/// - [GoalsState]: Immutable state with goals data
/// - [GoalsNotifier]: Business logic for goals management
/// - [goalsNotifierProvider]: Main provider for goals state
/// - [GoalTemplates]: 8+ predefined goal templates
/// - 20+ derived providers for granular UI access
///
/// Usage:
/// ```dart
/// // Watch active goals
/// final activeGoals = ref.watch(activeGoalsProvider);
///
/// // Create goal from template
/// ref.read(goalsNotifierProvider.notifier)
///   .createGoalFromTemplate(GoalTemplates.readBooks);
///
/// // Update goal progress
/// ref.read(goalsNotifierProvider.notifier)
///   .updateGoalProgress(goalId, 50.0);
///
/// // Toggle milestone completion
/// ref.read(goalsNotifierProvider.notifier)
///   .toggleMilestoneCompletion(goalId, milestoneId);
/// ```
library goals;

export 'goals_state.dart';
export 'goals_notifier.dart';
export 'goals_providers.dart';
