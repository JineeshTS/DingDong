import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';

import '../../lib/core/errors/failures.dart';
import '../../lib/domain/entities/task_entity.dart';
import '../../lib/domain/repositories/task_repository.dart';

/// Mock implementation of TaskRepository for testing
class MockTaskRepository extends Mock implements TaskRepository {
  // Track method calls for verification
  final List<TaskEntity> _tasks = [];
  bool _shouldFail = false;
  Failure? _failureToReturn;

  /// Configure mock to return failure
  void setShouldFail(bool shouldFail, {Failure? failure}) {
    _shouldFail = shouldFail;
    _failureToReturn = failure ?? CacheFailure('Mock failure');
  }

  /// Reset mock state
  void reset() {
    _tasks.clear();
    _shouldFail = false;
    _failureToReturn = null;
  }

  /// Add tasks to mock repository
  void addTasks(List<TaskEntity> tasks) {
    _tasks.addAll(tasks);
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    if (_shouldFail) {
      return Left(_failureToReturn ?? CacheFailure('Create task failed'));
    }

    _tasks.add(task);
    return Right(task);
  }

  @override
  Future<Either<Failure, TaskEntity>> getTask(String id) async {
    if (_shouldFail) {
      return Left(_failureToReturn ?? CacheFailure('Get task failed'));
    }

    try {
      final task = _tasks.firstWhere((t) => t.id == id);
      return Right(task);
    } catch (e) {
      return Left(CacheFailure('Task not found'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks({
    String? listId,
    String? userId,
    bool includeCompleted = false,
    bool includeDeleted = false,
  }) async {
    if (_shouldFail) {
      return Left(_failureToReturn ?? CacheFailure('Get tasks failed'));
    }

    var filteredTasks = List<TaskEntity>.from(_tasks);

    if (userId != null) {
      filteredTasks = filteredTasks.where((t) => t.userId == userId).toList();
    }

    if (listId != null) {
      filteredTasks =
          filteredTasks.where((t) => t.categoryId == listId).toList();
    }

    if (!includeCompleted) {
      filteredTasks = filteredTasks
          .where((t) => t.status != TaskStatus.completed)
          .toList();
    }

    if (!includeDeleted) {
      filteredTasks =
          filteredTasks.where((t) => t.status != TaskStatus.deleted).toList();
    }

    return Right(filteredTasks);
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksDueToday(
      String userId) async {
    if (_shouldFail) {
      return Left(
          _failureToReturn ?? CacheFailure('Get tasks due today failed'));
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayTasks = _tasks.where((task) {
      if (task.userId != userId) return false;
      if (task.dueDate == null) return false;
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      return taskDate == today;
    }).toList();

    return Right(todayTasks);
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getOverdueTasks(
      String userId) async {
    if (_shouldFail) {
      return Left(_failureToReturn ?? CacheFailure('Get overdue tasks failed'));
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final overdueTasks = _tasks.where((task) {
      if (task.userId != userId) return false;
      if (task.status == TaskStatus.completed) return false;
      if (task.dueDate == null) return false;
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      return taskDate.isBefore(today);
    }).toList();

    return Right(overdueTasks);
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    if (_shouldFail) {
      return Left(_failureToReturn ?? CacheFailure('Update task failed'));
    }

    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      return Left(CacheFailure('Task not found'));
    }

    _tasks[index] = task;
    return Right(task);
  }

  @override
  Future<Either<Failure, TaskEntity>> completeTask(String id) async {
    if (_shouldFail) {
      return Left(_failureToReturn ?? CacheFailure('Complete task failed'));
    }

    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      return Left(CacheFailure('Task not found'));
    }

    final completedTask = _tasks[index].copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _tasks[index] = completedTask;
    return Right(completedTask);
  }

  @override
  Future<Either<Failure, TaskEntity>> uncompleteTask(String id) async {
    if (_shouldFail) {
      return Left(_failureToReturn ?? CacheFailure('Uncomplete task failed'));
    }

    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      return Left(CacheFailure('Task not found'));
    }

    final uncompletedTask = _tasks[index].copyWith(
      status: TaskStatus.todo,
      completedAt: null,
      updatedAt: DateTime.now(),
    );

    _tasks[index] = uncompletedTask;
    return Right(uncompletedTask);
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    if (_shouldFail) {
      return Left(_failureToReturn ?? CacheFailure('Delete task failed'));
    }

    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      return Left(CacheFailure('Task not found'));
    }

    _tasks[index] = _tasks[index].copyWith(
      status: TaskStatus.deleted,
      updatedAt: DateTime.now(),
    );

    return const Right(null);
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> searchTasks({
    required String userId,
    required String query,
    String? listId,
    List<String>? tags,
    TaskPriority? priority,
    TaskStatus? status,
  }) async {
    if (_shouldFail) {
      return Left(_failureToReturn ?? CacheFailure('Search tasks failed'));
    }

    var results = _tasks.where((t) => t.userId == userId);

    if (query.isNotEmpty) {
      results = results.where(
        (t) =>
            t.title.toLowerCase().contains(query.toLowerCase()) ||
            (t.description?.toLowerCase().contains(query.toLowerCase()) ??
                false),
      );
    }

    if (listId != null) {
      results = results.where((t) => t.categoryId == listId);
    }

    if (tags != null && tags.isNotEmpty) {
      results = results.where(
        (t) => tags.any((tag) => t.tags.contains(tag)),
      );
    }

    if (priority != null) {
      results = results.where((t) => t.priority == priority);
    }

    if (status != null) {
      results = results.where((t) => t.status == status);
    }

    return Right(results.toList());
  }

  @override
  Stream<Either<Failure, TaskEntity>> watchTask(String id) {
    if (_shouldFail) {
      return Stream.value(
          Left(_failureToReturn ?? CacheFailure('Watch task failed')));
    }

    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      try {
        final task = _tasks.firstWhere((t) => t.id == id);
        return Right(task);
      } catch (e) {
        return Left(CacheFailure('Task not found'));
      }
    });
  }

  @override
  Stream<Either<Failure, List<TaskEntity>>> watchTasks({
    String? listId,
    String? userId,
  }) {
    if (_shouldFail) {
      return Stream.value(
          Left(_failureToReturn ?? CacheFailure('Watch tasks failed')));
    }

    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      var filteredTasks = List<TaskEntity>.from(_tasks);

      if (userId != null) {
        filteredTasks =
            filteredTasks.where((t) => t.userId == userId).toList();
      }

      if (listId != null) {
        filteredTasks =
            filteredTasks.where((t) => t.categoryId == listId).toList();
      }

      return Right(filteredTasks);
    });
  }

  @override
  Stream<Either<Failure, List<TaskEntity>>> watchTasksDueToday(String userId) {
    if (_shouldFail) {
      return Stream.value(Left(
          _failureToReturn ?? CacheFailure('Watch tasks due today failed')));
    }

    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final todayTasks = _tasks.where((task) {
        if (task.userId != userId) return false;
        if (task.dueDate == null) return false;
        final taskDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        return taskDate == today;
      }).toList();

      return Right(todayTasks);
    });
  }

  // Stub implementations for other methods
  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByList(String listId) =>
      getTasks(listId: listId);

  @override
  Future<Either<Failure, List<TaskEntity>>> getSubtasks(String parentTaskId) =>
      getTasks();

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksDueTomorrow(String userId) =>
      getTasks();

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByPriority({
    required String userId,
    required TaskPriority priority,
  }) =>
      getTasks();

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByTag({
    required String userId,
    required String tag,
  }) =>
      getTasks();

  @override
  Future<Either<Failure, List<TaskEntity>>> getAssignedTasks(String userId) =>
      getTasks();

  @override
  Future<Either<Failure, List<TaskEntity>>> getCompletedTasks({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      getTasks();

  @override
  Future<Either<Failure, void>> permanentlyDeleteTask(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, TaskEntity>> restoreTask(String id) async =>
      getTask(id);

  @override
  Future<Either<Failure, TaskEntity>> moveTask({
    required String taskId,
    required String newListId,
  }) async =>
      getTask(taskId);

  @override
  Future<Either<Failure, TaskEntity>> duplicateTask(String id) async =>
      getTask(id);

  @override
  Future<Either<Failure, List<TaskEntity>>> batchUpdateTasks(
    List<TaskEntity> tasks,
  ) async =>
      Right(tasks);

  @override
  Future<Either<Failure, void>> batchDeleteTasks(List<String> taskIds) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<TaskEntity>>> batchCompleteTasks(
    List<String> taskIds,
  ) async =>
      getTasks();

  @override
  Future<Either<Failure, void>> updateSortOrder({
    required List<String> taskIds,
    required List<int> sortOrders,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<TaskEntity>>> getRecurringTaskInstances(
    String parentTaskId,
  ) async =>
      getTasks();

  @override
  Future<Either<Failure, TaskEntity>> generateNextRecurringInstance(
    String parentTaskId,
  ) async =>
      getTask(parentTaskId);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTaskStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      const Right({});
}
