import 'package:isar/isar.dart';
import '../../../core/errors/exceptions.dart';
import '../schemas/task_isar.dart';

/// Isar local data source for Task operations (offline storage)
abstract class IsarTaskLocalDataSource {
  /// Insert or update task
  Future<TaskIsar> upsertTask(TaskIsar task);

  /// Get task by Firebase ID
  Future<TaskIsar?> getTaskByFirebaseId(String taskId);

  /// Get all tasks for user
  Future<List<TaskIsar>> getTasks({
    required String userId,
    String? listId,
    bool includeCompleted = false,
    bool includeDeleted = false,
  });

  /// Get tasks by list
  Future<List<TaskIsar>> getTasksByList(String listId);

  /// Get subtasks
  Future<List<TaskIsar>> getSubtasks(String parentTaskId);

  /// Get tasks due today
  Future<List<TaskIsar>> getTasksDueToday(String userId);

  /// Get overdue tasks
  Future<List<TaskIsar>> getOverdueTasks(String userId);

  /// Get tasks by priority
  Future<List<TaskIsar>> getTasksByPriority({
    required String userId,
    required TaskPriorityIsar priority,
  });

  /// Get completed tasks
  Future<List<TaskIsar>> getCompletedTasks({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Search tasks
  Future<List<TaskIsar>> searchTasks({
    required String userId,
    required String query,
  });

  /// Update task
  Future<TaskIsar> updateTask(TaskIsar task);

  /// Delete task (soft delete)
  Future<void> deleteTask(String taskId);

  /// Permanently delete task
  Future<void> permanentlyDeleteTask(String taskId);

  /// Batch insert tasks
  Future<void> batchInsertTasks(List<TaskIsar> tasks);

  /// Get dirty tasks (need sync)
  Future<List<TaskIsar>> getDirtyTasks();

  /// Mark task as synced
  Future<void> markAsSynced(String taskId);

  /// Mark task as dirty (needs sync)
  Future<void> markAsDirty(String taskId);

  /// Clear all tasks for user
  Future<void> clearTasksForUser(String userId);

  /// Get task count for list
  Future<int> getTaskCountForList(String listId);

  /// Watch task
  Stream<TaskIsar?> watchTask(String taskId);

  /// Watch tasks for list
  Stream<List<TaskIsar>> watchTasksForList(String listId);

  /// Watch tasks due today
  Stream<List<TaskIsar>> watchTasksDueToday(String userId);
}

/// Isar implementation of task local data source
class IsarTaskLocalDataSourceImpl implements IsarTaskLocalDataSource {
  final Isar _isar;

  IsarTaskLocalDataSourceImpl(this._isar);

  @override
  Future<TaskIsar> upsertTask(TaskIsar task) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.taskIsars.put(task);
      });

      final savedTask = await getTaskByFirebaseId(task.taskId);
      if (savedTask == null) {
        throw const CacheException(
          message: 'Failed to save task to local database',
        );
      }

      return savedTask;
    } catch (e) {
      throw CacheException(
        message: 'Failed to upsert task',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskIsar?> getTaskByFirebaseId(String taskId) async {
    try {
      final task = await _isar.taskIsars
          .filter()
          .taskIdEqualTo(taskId)
          .findFirst();

      return task;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get task by Firebase ID',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskIsar>> getTasks({
    required String userId,
    String? listId,
    bool includeCompleted = false,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _isar.taskIsars
          .filter()
          .userIdEqualTo(userId);

      if (listId != null) {
        query = query.listIdEqualTo(listId);
      }

      if (!includeCompleted) {
        query = query.statusNotEqualTo(TaskStatusIsar.completed);
      }

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final tasks = await query
          .sortBySortOrder()
          .findAll();

      return tasks;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskIsar>> getTasksByList(String listId) async {
    try {
      final tasks = await _isar.taskIsars
          .filter()
          .listIdEqualTo(listId)
          .isDeletedEqualTo(false)
          .sortBySortOrder()
          .findAll();

      return tasks;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get tasks by list',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskIsar>> getSubtasks(String parentTaskId) async {
    try {
      final tasks = await _isar.taskIsars
          .filter()
          .parentTaskIdEqualTo(parentTaskId)
          .isDeletedEqualTo(false)
          .sortBySortOrder()
          .findAll();

      return tasks;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get subtasks',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskIsar>> getTasksDueToday(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final tasks = await _isar.taskIsars
          .filter()
          .userIdEqualTo(userId)
          .dueDateBetween(startOfDay, endOfDay)
          .isDeletedEqualTo(false)
          .statusNotEqualTo(TaskStatusIsar.completed)
          .sortByDueDate()
          .findAll();

      return tasks;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get tasks due today',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskIsar>> getOverdueTasks(String userId) async {
    try {
      final now = DateTime.now();

      final tasks = await _isar.taskIsars
          .filter()
          .userIdEqualTo(userId)
          .dueDateLessThan(now)
          .isDeletedEqualTo(false)
          .statusNotEqualTo(TaskStatusIsar.completed)
          .sortByDueDate()
          .findAll();

      return tasks;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get overdue tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskIsar>> getTasksByPriority({
    required String userId,
    required TaskPriorityIsar priority,
  }) async {
    try {
      final tasks = await _isar.taskIsars
          .filter()
          .userIdEqualTo(userId)
          .priorityEqualTo(priority)
          .isDeletedEqualTo(false)
          .sortByDueDate()
          .findAll();

      return tasks;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get tasks by priority',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskIsar>> getCompletedTasks({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _isar.taskIsars
          .filter()
          .userIdEqualTo(userId)
          .statusEqualTo(TaskStatusIsar.completed)
          .isDeletedEqualTo(false);

      if (startDate != null && endDate != null) {
        query = query.completedAtBetween(startDate, endDate);
      }

      final tasks = await query
          .sortByCompletedAtDesc()
          .findAll();

      return tasks;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get completed tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskIsar>> searchTasks({
    required String userId,
    required String query,
  }) async {
    try {
      final lowerQuery = query.toLowerCase();

      final tasks = await _isar.taskIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .findAll();

      // Client-side filtering for title and description
      final filtered = tasks.where((task) =>
          task.title.toLowerCase().contains(lowerQuery) ||
          (task.description?.toLowerCase().contains(lowerQuery) ?? false)).toList();

      return filtered;
    } catch (e) {
      throw CacheException(
        message: 'Failed to search tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskIsar> updateTask(TaskIsar task) async {
    try {
      final existingTask = await getTaskByFirebaseId(task.taskId);
      if (existingTask == null) {
        throw const CacheException(
          message: 'Task not found in local database',
        );
      }

      task.updatedAt = DateTime.now();
      task.isDirty = true;

      return await upsertTask(task);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update task',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      final task = await getTaskByFirebaseId(taskId);
      if (task == null) return;

      task.isDeleted = true;
      task.deletedAt = DateTime.now();
      task.isDirty = true;

      await _isar.writeTxn(() async {
        await _isar.taskIsars.put(task);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete task',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteTask(String taskId) async {
    try {
      final task = await getTaskByFirebaseId(taskId);
      if (task == null) return;

      await _isar.writeTxn(() async {
        await _isar.taskIsars.delete(task.id);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to permanently delete task',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchInsertTasks(List<TaskIsar> tasks) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.taskIsars.putAll(tasks);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to batch insert tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskIsar>> getDirtyTasks() async {
    try {
      final tasks = await _isar.taskIsars
          .filter()
          .isDirtyEqualTo(true)
          .findAll();

      return tasks;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get dirty tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String taskId) async {
    try {
      final task = await getTaskByFirebaseId(taskId);
      if (task == null) return;

      task.isDirty = false;
      task.lastSyncAt = DateTime.now();

      await _isar.writeTxn(() async {
        await _isar.taskIsars.put(task);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark task as synced',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDirty(String taskId) async {
    try {
      final task = await getTaskByFirebaseId(taskId);
      if (task == null) return;

      task.isDirty = true;

      await _isar.writeTxn(() async {
        await _isar.taskIsars.put(task);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark task as dirty',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearTasksForUser(String userId) async {
    try {
      final tasks = await _isar.taskIsars
          .filter()
          .userIdEqualTo(userId)
          .findAll();

      final ids = tasks.map((t) => t.id).toList();

      await _isar.writeTxn(() async {
        await _isar.taskIsars.deleteAll(ids);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear tasks for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getTaskCountForList(String listId) async {
    try {
      final count = await _isar.taskIsars
          .filter()
          .listIdEqualTo(listId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get task count for list',
        originalException: e,
      );
    }
  }

  @override
  Stream<TaskIsar?> watchTask(String taskId) {
    try {
      return _isar.taskIsars
          .filter()
          .taskIdEqualTo(taskId)
          .watch(fireImmediately: true)
          .map((tasks) => tasks.isNotEmpty ? tasks.first : null);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch task',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<TaskIsar>> watchTasksForList(String listId) {
    try {
      return _isar.taskIsars
          .filter()
          .listIdEqualTo(listId)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch tasks for list',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<TaskIsar>> watchTasksDueToday(String userId) {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return _isar.taskIsars
          .filter()
          .userIdEqualTo(userId)
          .dueDateBetween(startOfDay, endOfDay)
          .isDeletedEqualTo(false)
          .statusNotEqualTo(TaskStatusIsar.completed)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch tasks due today',
        originalException: e,
      );
    }
  }
}
