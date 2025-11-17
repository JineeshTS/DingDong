import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task/get_tasks_usecase.dart';
import '../auth_provider.dart';
import 'focus_notifier.dart';
import 'focus_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================

/// Provider for GetTasksUseCase
final getTasksForFocusProvider = Provider.autoDispose<GetTasksUseCase>(
  (ref) => sl<GetTasksUseCase>(),
);

// ============================================================================
// Focus State Notifier Provider
// ============================================================================

/// Main Focus/Today view state notifier provider
///
/// Manages Focus/Today view state including today's tasks and smart suggestions.
///
/// Usage:
/// ```dart
/// final focusState = ref.watch(focusNotifierProvider);
/// final focusNotifier = ref.read(focusNotifierProvider.notifier);
///
/// // Get today's tasks
/// final todayTasks = focusState.todayTasks;
///
/// // Get next suggested task
/// final nextTask = focusState.nextSuggestedTask;
/// ```
final focusNotifierProvider =
    StateNotifierProvider<FocusNotifier, FocusState>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.when(
    data: (user) => user?.id ?? '',
    loading: () => '',
    error: (_, __) => '',
  );

  return FocusNotifier(
    getTasksUseCase: ref.read(getTasksForFocusProvider),
    userId: userId ?? '',
  );
});

// ============================================================================
// Derived State Providers
// ============================================================================

/// Provider for today's tasks
final todayTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.todayTasks;
});

/// Provider for overdue tasks
final overdueTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.overdueTasks;
});

/// Provider for completed tasks today
final completedTasksTodayProvider =
    Provider.autoDispose<List<TaskEntity>>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.completedTasks;
});

/// Provider for all incomplete tasks
final allIncompleteTasksProvider =
    Provider.autoDispose<List<TaskEntity>>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.allIncompleteTasks;
});

/// Provider for next suggested task
final nextSuggestedTaskProvider = Provider.autoDispose<TaskEntity?>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.nextSuggestedTask;
});

/// Provider for current view mode
final focusViewModeProvider = Provider.autoDispose<FocusViewMode>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.viewMode;
});

/// Provider for show completed tasks setting
final focusShowCompletedTasksProvider = Provider.autoDispose<bool>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.showCompletedTasks;
});

/// Provider for loading state
final isFocusLoadingProvider = Provider.autoDispose<bool>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.isLoading;
});

/// Provider for error message
final focusErrorProvider = Provider.autoDispose<String?>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.error;
});

// ============================================================================
// Statistics Providers
// ============================================================================

/// Provider for total tasks count
final focusTotalTasksCountProvider = Provider.autoDispose<int>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.totalTasksCount;
});

/// Provider for incomplete tasks count
final focusIncompleteTasksCountProvider = Provider.autoDispose<int>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.incompleteTasksCount;
});

/// Provider for completed tasks count today
final focusCompletedTasksCountProvider = Provider.autoDispose<int>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.completedTasksCount;
});

/// Provider for completion percentage
final focusCompletionPercentageProvider = Provider.autoDispose<double>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.completionPercentage;
});

/// Provider for overdue tasks count
final overdueTasksCountProvider = Provider.autoDispose<int>((ref) {
  final overdueTasks = ref.watch(overdueTasksProvider);
  return overdueTasks.where((t) => !t.isCompleted).length;
});

/// Provider for greeting message
final focusGreetingProvider = Provider.autoDispose<String>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.greeting;
});

/// Provider for morning prompt visibility
final showMorningPromptProvider = Provider.autoDispose<bool>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.showMorningPrompt;
});

/// Provider for evening prompt visibility
final showEveningPromptProvider = Provider.autoDispose<bool>((ref) {
  final focusState = ref.watch(focusNotifierProvider);
  return focusState.showEveningPrompt;
});

// ============================================================================
// Time of Day Providers (Family)
// ============================================================================

/// Provider for tasks in a specific time of day
final tasksForTimeOfDayProvider =
    Provider.autoDispose.family<List<TaskEntity>, TimeOfDay>(
  (ref, timeOfDay) {
    final focusState = ref.watch(focusNotifierProvider);
    return focusState.getTasksForTimeOfDay(timeOfDay);
  },
);

/// Provider for task count in a specific time of day
final taskCountForTimeOfDayProvider =
    Provider.autoDispose.family<int, TimeOfDay>(
  (ref, timeOfDay) {
    final tasks = ref.watch(tasksForTimeOfDayProvider(timeOfDay));
    return tasks.length;
  },
);
