import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection_container.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import 'auth_provider.dart';

// ============================================================================
// Stream Providers for Real-time Task Updates
// ============================================================================
// These providers use the repository's watch methods to provide real-time
// updates when tasks change in the database.

/// Provider for the task repository
///
/// Used by stream providers to access repository methods
final _taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => sl<TaskRepository>(),
);

/// Stream provider that watches all tasks for the current user
///
/// Provides real-time updates when tasks are added, modified, or deleted.
/// Automatically filters by the current user's ID.
///
/// Returns `AsyncValue<List<TaskEntity>>` which handles loading, data, and error states.
///
/// Usage:
/// ```dart
/// final tasksAsync = ref.watch(tasksStreamProvider);
/// tasksAsync.when(
///   data: (tasks) => TaskList(tasks: tasks),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final tasksStreamProvider = StreamProvider.autoDispose<List<TaskEntity>>((ref) {
  final repository = ref.watch(_taskRepositoryProvider);
  final authState = ref.watch(authStateProvider);

  final userId = authState.value?.when(
    data: (user) => user?.id,
    loading: () => null,
    error: (_, __) => null,
  );

  if (userId == null) {
    return Stream.value([]);
  }

  return repository.watchTasks(userId: userId).asyncMap((either) async {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (tasks) => tasks,
    );
  });
});

/// Stream provider that watches a single task by ID
///
/// Provides real-time updates for a specific task.
///
/// Returns `AsyncValue<TaskEntity?>` which handles loading, data, and error states.
/// Returns null if the task is not found.
///
/// Usage:
/// ```dart
/// final taskAsync = ref.watch(taskByIdProvider('task-id'));
/// taskAsync.when(
///   data: (task) {
///     if (task == null) return TaskNotFound();
///     return TaskDetail(task: task);
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final taskByIdProvider =
    StreamProvider.autoDispose.family<TaskEntity?, String>((ref, taskId) {
  final repository = ref.watch(_taskRepositoryProvider);

  return repository.watchTask(taskId).asyncMap((either) async {
    return either.fold(
      (failure) {
        // If task not found, return null instead of throwing
        if (failure.message.contains('not found')) {
          return null;
        }
        throw Exception(failure.message);
      },
      (task) => task,
    );
  });
});

/// Stream provider that watches tasks due today
///
/// Provides real-time updates for today's tasks.
///
/// Usage:
/// ```dart
/// final todayTasksAsync = ref.watch(todayTasksStreamProvider);
/// todayTasksAsync.when(
///   data: (tasks) => TodayTasksList(tasks: tasks),
///   loading: () => Loading(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final todayTasksStreamProvider =
    StreamProvider.autoDispose<List<TaskEntity>>((ref) {
  final repository = ref.watch(_taskRepositoryProvider);
  final authState = ref.watch(authStateProvider);

  final userId = authState.value?.when(
    data: (user) => user?.id,
    loading: () => null,
    error: (_, __) => null,
  );

  if (userId == null) {
    return Stream.value([]);
  }

  return repository.watchTasksDueToday(userId).asyncMap((either) async {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (tasks) => tasks,
    );
  });
});

/// Stream provider that watches tasks for a specific list
///
/// Provides real-time updates for tasks in a particular list.
///
/// Usage:
/// ```dart
/// final listTasksAsync = ref.watch(listTasksStreamProvider('list-id'));
/// listTasksAsync.when(
///   data: (tasks) => TaskList(tasks: tasks),
///   loading: () => Loading(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final listTasksStreamProvider =
    StreamProvider.autoDispose.family<List<TaskEntity>, String>((ref, listId) {
  final repository = ref.watch(_taskRepositoryProvider);

  return repository.watchTasks(listId: listId).asyncMap((either) async {
    return either.fold(
      (failure) => throw Exception(failure.message),
      (tasks) => tasks,
    );
  });
});

/// Stream provider for task count (derived from tasks stream)
///
/// Returns the total number of tasks for the current user
///
/// Usage:
/// ```dart
/// final taskCount = ref.watch(taskCountStreamProvider);
/// taskCount.when(
///   data: (count) => Badge(label: '$count'),
///   loading: () => Badge(label: '...'),
///   error: (_, __) => Badge(label: '!'),
/// );
/// ```
final taskCountStreamProvider = StreamProvider.autoDispose<int>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  return tasksAsync.when(
    data: (tasks) => Stream.value(tasks.length),
    loading: () => Stream.value(0),
    error: (error, stack) => Stream.value(0),
  );
});

/// Stream provider for today's task count
///
/// Returns the number of tasks due today
final todayTaskCountStreamProvider = StreamProvider.autoDispose<int>((ref) {
  final tasksAsync = ref.watch(todayTasksStreamProvider);
  return tasksAsync.when(
    data: (tasks) => Stream.value(tasks.length),
    loading: () => Stream.value(0),
    error: (error, stack) => Stream.value(0),
  );
});
