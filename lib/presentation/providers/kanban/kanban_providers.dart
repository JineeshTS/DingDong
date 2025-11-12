import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/usecases/task/get_tasks_usecase.dart';
import '../../../domain/usecases/task/update_task_usecase.dart';
import '../auth_provider.dart';
import 'kanban_notifier.dart';
import 'kanban_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================

/// Provider for GetTasksUseCase
final getTasksForKanbanProvider = Provider.autoDispose<GetTasksUseCase>(
  (ref) => sl<GetTasksUseCase>(),
);

/// Provider for UpdateTaskUseCase
final updateTaskForKanbanProvider = Provider.autoDispose<UpdateTaskUseCase>(
  (ref) => sl<UpdateTaskUseCase>(),
);

// ============================================================================
// Kanban State Notifier Provider
// ============================================================================

/// Main Kanban board state notifier provider
///
/// Manages Kanban board view state including columns, tasks, and drag-and-drop.
///
/// Usage:
/// ```dart
/// final kanbanState = ref.watch(kanbanNotifierProvider);
/// final kanbanNotifier = ref.read(kanbanNotifierProvider.notifier);
///
/// // Move task between columns
/// await kanbanNotifier.moveTask(task, fromColumnId, toColumnId);
///
/// // Toggle completed tasks
/// kanbanNotifier.toggleShowCompletedTasks();
/// ```
final kanbanNotifierProvider =
    StateNotifierProvider<KanbanNotifier, KanbanState>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.when(
    data: (user) => user?.id ?? '',
    loading: () => '',
    error: (_, __) => '',
  );

  return KanbanNotifier(
    getTasksUseCase: ref.read(getTasksForKanbanProvider),
    updateTaskUseCase: ref.read(updateTaskForKanbanProvider),
    userId: userId ?? '',
  );
});

// ============================================================================
// Derived State Providers
// ============================================================================

/// Provider for current view mode
final kanbanViewModeProvider = Provider.autoDispose<KanbanViewMode>((ref) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.viewMode;
});

/// Provider for all board columns
final kanbanColumnsProvider = Provider.autoDispose<List<KanbanColumn>>((ref) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.columns;
});

/// Provider for visible columns
final visibleKanbanColumnsProvider =
    Provider.autoDispose<List<KanbanColumn>>((ref) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.visibleColumns;
});

/// Provider for loading state
final isKanbanLoadingProvider = Provider.autoDispose<bool>((ref) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.isLoading;
});

/// Provider for error message
final kanbanErrorProvider = Provider.autoDispose<String?>((ref) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.error;
});

/// Provider for show completed tasks setting
final kanbanShowCompletedTasksProvider = Provider.autoDispose<bool>((ref) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.showCompletedTasks;
});

/// Provider for selected list filter
final kanbanSelectedListProvider = Provider.autoDispose<String?>((ref) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.selectedListId;
});

// ============================================================================
// Column-Specific Providers (Family)
// ============================================================================

/// Provider for getting a specific column by ID
final kanbanColumnProvider =
    Provider.autoDispose.family<KanbanColumn?, String>((ref, columnId) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.getColumn(columnId);
});

/// Provider for getting tasks in a specific column
final tasksInColumnProvider =
    Provider.autoDispose.family<List<dynamic>, String>((ref, columnId) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.getTasksForColumn(columnId);
});

/// Provider for checking if column is at WIP limit
final isColumnAtWipLimitProvider =
    Provider.autoDispose.family<bool, String>((ref, columnId) {
  final column = ref.watch(kanbanColumnProvider(columnId));
  return column?.isAtWipLimit ?? false;
});

/// Provider for column task count
final columnTaskCountProvider =
    Provider.autoDispose.family<int, String>((ref, columnId) {
  final column = ref.watch(kanbanColumnProvider(columnId));
  return column?.taskCount ?? 0;
});

/// Provider for column incomplete task count
final columnIncompleteCountProvider =
    Provider.autoDispose.family<int, String>((ref, columnId) {
  final column = ref.watch(kanbanColumnProvider(columnId));
  return column?.incompleteCount ?? 0;
});

// ============================================================================
// Statistics Providers
// ============================================================================

/// Provider for total tasks count
final kanbanTotalTasksCountProvider = Provider.autoDispose<int>((ref) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.totalTasksCount;
});

/// Provider for completed tasks count
final kanbanCompletedTasksCountProvider = Provider.autoDispose<int>((ref) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.completedTasksCount;
});

/// Provider for incomplete tasks count
final kanbanIncompleteTasksCountProvider = Provider.autoDispose<int>((ref) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.incompleteTasksCount;
});

/// Provider for checking if any column is at WIP limit
final hasWipLimitReachedProvider = Provider.autoDispose<bool>((ref) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  return kanbanState.hasWipLimitReached;
});

/// Provider for active filters count
final kanbanActiveFiltersCountProvider = Provider.autoDispose<int>((ref) {
  final kanbanState = ref.watch(kanbanNotifierProvider);
  int count = 0;

  if (kanbanState.selectedListId != null) count++;
  if (kanbanState.selectedTags.isNotEmpty) count++;
  if (kanbanState.selectedPriority != null) count++;

  return count;
});
