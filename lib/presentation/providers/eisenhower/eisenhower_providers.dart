import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/task/get_tasks_usecase.dart';
import '../../../domain/usecases/task/update_task_usecase.dart';
import '../auth_provider.dart';
import 'eisenhower_notifier.dart';
import 'eisenhower_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================

/// Provider for GetTasksUseCase
final getTasksForEisenhowerProvider = Provider.autoDispose<GetTasksUseCase>(
  (ref) => sl<GetTasksUseCase>(),
);

/// Provider for UpdateTaskUseCase
final updateTaskForEisenhowerProvider = Provider.autoDispose<UpdateTaskUseCase>(
  (ref) => sl<UpdateTaskUseCase>(),
);

// ============================================================================
// Eisenhower State Notifier Provider
// ============================================================================

/// Main Eisenhower Matrix state notifier provider
///
/// Manages Eisenhower Matrix view state including task categorization.
///
/// Usage:
/// ```dart
/// final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
/// final eisenhowerNotifier = ref.read(eisenhowerNotifierProvider.notifier);
///
/// // Get tasks for a quadrant
/// final urgentImportantTasks = eisenhowerState.urgentImportantTasks;
///
/// // Set focus mode
/// eisenhowerNotifier.setFocusQuadrant(MatrixQuadrant.urgentImportant);
/// ```
final eisenhowerNotifierProvider =
    StateNotifierProvider<EisenhowerNotifier, EisenhowerState>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.when(
    data: (user) => user?.id ?? '',
    loading: () => '',
    error: (_, __) => '',
  );

  return EisenhowerNotifier(
    getTasksUseCase: ref.read(getTasksForEisenhowerProvider),
    updateTaskUseCase: ref.read(updateTaskForEisenhowerProvider),
    userId: userId ?? '',
  );
});

// ============================================================================
// Derived State Providers
// ============================================================================

/// Provider for focus quadrant
final eisenhowerFocusQuadrantProvider =
    Provider.autoDispose<MatrixQuadrant?>((ref) {
  final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
  return eisenhowerState.focusQuadrant;
});

/// Provider for loading state
final isEisenhowerLoadingProvider = Provider.autoDispose<bool>((ref) {
  final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
  return eisenhowerState.isLoading;
});

/// Provider for error message
final eisenhowerErrorProvider = Provider.autoDispose<String?>((ref) {
  final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
  return eisenhowerState.error;
});

/// Provider for show completed tasks setting
final eisenhowerShowCompletedTasksProvider = Provider.autoDispose<bool>((ref) {
  final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
  return eisenhowerState.showCompletedTasks;
});

/// Provider for auto-categorization setting
final eisenhowerAutoCategorization = Provider.autoDispose<bool>((ref) {
  final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
  return eisenhowerState.autoCategorization;
});

/// Provider for selected list filter
final eisenhowerSelectedListProvider = Provider.autoDispose<String?>((ref) {
  final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
  return eisenhowerState.selectedListId;
});

/// Provider for focus mode state
final isEisenhowerFocusModeProvider = Provider.autoDispose<bool>((ref) {
  final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
  return eisenhowerState.isFocusMode;
});

// ============================================================================
// Quadrant-Specific Providers (Family)
// ============================================================================

/// Provider for getting tasks in a specific quadrant
final tasksInQuadrantProvider =
    Provider.autoDispose.family<List<TaskEntity>, MatrixQuadrant>(
  (ref, quadrant) {
    final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
    return eisenhowerState.getTasksForQuadrant(quadrant);
  },
);

/// Provider for task count in a specific quadrant
final quadrantTaskCountProvider =
    Provider.autoDispose.family<int, MatrixQuadrant>((ref, quadrant) {
  final tasks = ref.watch(tasksInQuadrantProvider(quadrant));
  return tasks.length;
});

/// Provider for incomplete task count in a specific quadrant
final quadrantIncompleteCountProvider =
    Provider.autoDispose.family<int, MatrixQuadrant>((ref, quadrant) {
  final tasks = ref.watch(tasksInQuadrantProvider(quadrant));
  return tasks.where((t) => !t.isCompleted).length;
});

// ============================================================================
// Statistics Providers
// ============================================================================

/// Provider for total tasks count
final eisenhowerTotalTasksCountProvider = Provider.autoDispose<int>((ref) {
  final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
  return eisenhowerState.totalTasksCount;
});

/// Provider for completed tasks count
final eisenhowerCompletedTasksCountProvider = Provider.autoDispose<int>((ref) {
  final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
  return eisenhowerState.completedTasksCount;
});

/// Provider for incomplete tasks count
final eisenhowerIncompleteTasksCountProvider =
    Provider.autoDispose<int>((ref) {
  final eisenhowerState = ref.watch(eisenhowerNotifierProvider);
  return eisenhowerState.incompleteTasksCount;
});

/// Provider for urgent & important tasks count
final urgentImportantCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(
    quadrantTaskCountProvider(MatrixQuadrant.urgentImportant),
  );
});

/// Provider for not urgent & important tasks count
final notUrgentImportantCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(
    quadrantTaskCountProvider(MatrixQuadrant.notUrgentImportant),
  );
});

/// Provider for urgent & not important tasks count
final urgentNotImportantCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(
    quadrantTaskCountProvider(MatrixQuadrant.urgentNotImportant),
  );
});

/// Provider for not urgent & not important tasks count
final notUrgentNotImportantCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(
    quadrantTaskCountProvider(MatrixQuadrant.notUrgentNotImportant),
  );
});
