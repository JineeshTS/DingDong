import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/task_entity.dart';

/// Task repository interface
///
/// Defines contracts for task operations
abstract class TaskRepository {
  /// Create a new task
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task);

  /// Get task by ID
  Future<Either<Failure, TaskEntity>> getTask(String id);

  /// Get all tasks for user
  Future<Either<Failure, List<TaskEntity>>> getTasks({
    String? listId,
    String? userId,
    bool includeCompleted = false,
    bool includeDeleted = false,
  });

  /// Get tasks by list ID
  Future<Either<Failure, List<TaskEntity>>> getTasksByList(String listId);

  /// Get subtasks
  Future<Either<Failure, List<TaskEntity>>> getSubtasks(String parentTaskId);

  /// Get tasks due today
  Future<Either<Failure, List<TaskEntity>>> getTasksDueToday(String userId);

  /// Get tasks due tomorrow
  Future<Either<Failure, List<TaskEntity>>> getTasksDueTomorrow(String userId);

  /// Get overdue tasks
  Future<Either<Failure, List<TaskEntity>>> getOverdueTasks(String userId);

  /// Get tasks by priority
  Future<Either<Failure, List<TaskEntity>>> getTasksByPriority({
    required String userId,
    required TaskPriority priority,
  });

  /// Get tasks by tag
  Future<Either<Failure, List<TaskEntity>>> getTasksByTag({
    required String userId,
    required String tag,
  });

  /// Get tasks assigned to user
  Future<Either<Failure, List<TaskEntity>>> getAssignedTasks(String userId);

  /// Get completed tasks
  Future<Either<Failure, List<TaskEntity>>> getCompletedTasks({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Search tasks
  Future<Either<Failure, List<TaskEntity>>> searchTasks({
    required String userId,
    required String query,
    String? listId,
    List<String>? tags,
    TaskPriority? priority,
    TaskStatus? status,
  });

  /// Update task
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);

  /// Complete task
  Future<Either<Failure, TaskEntity>> completeTask(String id);

  /// Uncomplete task
  Future<Either<Failure, TaskEntity>> uncompleteTask(String id);

  /// Delete task (soft delete)
  Future<Either<Failure, void>> deleteTask(String id);

  /// Permanently delete task
  Future<Either<Failure, void>> permanentlyDeleteTask(String id);

  /// Restore deleted task
  Future<Either<Failure, TaskEntity>> restoreTask(String id);

  /// Move task to different list
  Future<Either<Failure, TaskEntity>> moveTask({
    required String taskId,
    required String newListId,
  });

  /// Duplicate task
  Future<Either<Failure, TaskEntity>> duplicateTask(String id);

  /// Batch update tasks
  Future<Either<Failure, List<TaskEntity>>> batchUpdateTasks(
    List<TaskEntity> tasks,
  );

  /// Batch delete tasks
  Future<Either<Failure, void>> batchDeleteTasks(List<String> taskIds);

  /// Batch complete tasks
  Future<Either<Failure, List<TaskEntity>>> batchCompleteTasks(
    List<String> taskIds,
  );

  /// Update sort order
  Future<Either<Failure, void>> updateSortOrder({
    required List<String> taskIds,
    required List<int> sortOrders,
  });

  /// Get recurring task instances
  Future<Either<Failure, List<TaskEntity>>> getRecurringTaskInstances(
    String parentTaskId,
  );

  /// Generate next recurring instance
  Future<Either<Failure, TaskEntity>> generateNextRecurringInstance(
    String parentTaskId,
  );

  /// Watch task (stream)
  Stream<Either<Failure, TaskEntity>> watchTask(String id);

  /// Watch tasks (stream)
  Stream<Either<Failure, List<TaskEntity>>> watchTasks({
    String? listId,
    String? userId,
  });

  /// Watch tasks due today (stream)
  Stream<Either<Failure, List<TaskEntity>>> watchTasksDueToday(String userId);

  /// Get task statistics
  Future<Either<Failure, Map<String, dynamic>>> getTaskStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
}
