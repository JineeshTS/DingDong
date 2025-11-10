import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/task_entity.dart';
import '../../models/task_model.dart';

/// Firebase remote data source for task operations
abstract class FirebaseTaskRemoteDataSource {
  /// Create a new task
  Future<TaskModel> createTask(TaskModel task);

  /// Get task by ID
  Future<TaskModel> getTask(String id);

  /// Get all tasks for user
  Future<List<TaskModel>> getTasks({
    String? listId,
    String? userId,
    bool includeCompleted = false,
    bool includeDeleted = false,
  });

  /// Get tasks by list ID
  Future<List<TaskModel>> getTasksByList(String listId);

  /// Get subtasks
  Future<List<TaskModel>> getSubtasks(String parentTaskId);

  /// Get tasks due today
  Future<List<TaskModel>> getTasksDueToday(String userId);

  /// Get tasks due tomorrow
  Future<List<TaskModel>> getTasksDueTomorrow(String userId);

  /// Get overdue tasks
  Future<List<TaskModel>> getOverdueTasks(String userId);

  /// Get tasks by priority
  Future<List<TaskModel>> getTasksByPriority({
    required String userId,
    required String priority,
  });

  /// Get tasks by tag
  Future<List<TaskModel>> getTasksByTag({
    required String userId,
    required String tag,
  });

  /// Get tasks assigned to user
  Future<List<TaskModel>> getAssignedTasks(String userId);

  /// Get completed tasks
  Future<List<TaskModel>> getCompletedTasks({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Search tasks
  Future<List<TaskModel>> searchTasks({
    required String userId,
    required String query,
    String? listId,
    List<String>? tags,
    String? priority,
    String? status,
  });

  /// Update task
  Future<TaskModel> updateTask(TaskModel task);

  /// Complete task
  Future<TaskModel> completeTask(String id);

  /// Uncomplete task
  Future<TaskModel> uncompleteTask(String id);

  /// Delete task (soft delete)
  Future<void> deleteTask(String id);

  /// Permanently delete task
  Future<void> permanentlyDeleteTask(String id);

  /// Restore deleted task
  Future<TaskModel> restoreTask(String id);

  /// Move task to different list
  Future<TaskModel> moveTask({
    required String taskId,
    required String newListId,
  });

  /// Duplicate task
  Future<TaskModel> duplicateTask(String id);

  /// Batch update tasks
  Future<List<TaskModel>> batchUpdateTasks(List<TaskModel> tasks);

  /// Batch delete tasks
  Future<void> batchDeleteTasks(List<String> taskIds);

  /// Batch complete tasks
  Future<List<TaskModel>> batchCompleteTasks(List<String> taskIds);

  /// Update sort order
  Future<void> updateSortOrder({
    required List<String> taskIds,
    required List<int> sortOrders,
  });

  /// Get recurring task instances
  Future<List<TaskModel>> getRecurringTaskInstances(String parentTaskId);

  /// Generate next recurring instance
  Future<TaskModel> generateNextRecurringInstance(String parentTaskId);

  /// Watch task (stream)
  Stream<TaskModel> watchTask(String id);

  /// Watch tasks (stream)
  Stream<List<TaskModel>> watchTasks({
    String? listId,
    String? userId,
  });

  /// Watch tasks due today (stream)
  Stream<List<TaskModel>> watchTasksDueToday(String userId);

  /// Get task statistics
  Future<Map<String, dynamic>> getTaskStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Firebase implementation of task remote data source
class FirebaseTaskRemoteDataSourceImpl implements FirebaseTaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseTaskRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final taskRef = _firestore.collection('tasks').doc(task.id);
      final taskData = task.toJson();
      taskData['createdAt'] = FieldValue.serverTimestamp();
      taskData['updatedAt'] = FieldValue.serverTimestamp();

      await taskRef.set(taskData);

      // Get the created task with server timestamps
      final snapshot = await taskRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to create task',
        );
      }

      return TaskModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to create task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create task',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskModel> getTask(String id) async {
    try {
      final snapshot = await _firestore.collection('tasks').doc(id).get();

      if (!snapshot.exists) {
        throw const CacheException(
          message: 'Task not found',
        );
      }

      return TaskModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException(
        message: 'Failed to get task',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> getTasks({
    String? listId,
    String? userId,
    bool includeCompleted = false,
    bool includeDeleted = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('tasks');

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (listId != null) {
        query = query.where('listId', isEqualTo: listId);
      }

      if (!includeCompleted) {
        query = query.where('status', isNotEqualTo: 'completed');
      }

      if (!includeDeleted) {
        query = query.where('isDeleted', isEqualTo: false);
      }

      query = query.orderBy('sortOrder');

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get tasks',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> getTasksByList(String listId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('listId', isEqualTo: listId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('sortOrder')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get tasks by list',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tasks by list',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> getSubtasks(String parentTaskId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('parentTaskId', isEqualTo: parentTaskId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('sortOrder')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get subtasks',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get subtasks',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> getTasksDueToday(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('isDeleted', isEqualTo: false)
          .where('status', isNotEqualTo: 'completed')
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get tasks due today',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tasks due today',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> getTasksDueTomorrow(String userId) async {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final startOfDay = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      final endOfDay = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('isDeleted', isEqualTo: false)
          .where('status', isNotEqualTo: 'completed')
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get tasks due tomorrow',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tasks due tomorrow',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> getOverdueTasks(String userId) async {
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);

      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('dueDate', isLessThan: Timestamp.fromDate(startOfToday))
          .where('isDeleted', isEqualTo: false)
          .where('status', isNotEqualTo: 'completed')
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get overdue tasks',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get overdue tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> getTasksByPriority({
    required String userId,
    required String priority,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('priority', isEqualTo: priority)
          .where('isDeleted', isEqualTo: false)
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get tasks by priority',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tasks by priority',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> getTasksByTag({
    required String userId,
    required String tag,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('tags', arrayContains: tag)
          .where('isDeleted', isEqualTo: false)
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get tasks by tag',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tasks by tag',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> getAssignedTasks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('assignedToIds', arrayContains: userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get assigned tasks',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get assigned tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> getCompletedTasks({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .where('isDeleted', isEqualTo: false);

      if (startDate != null) {
        query = query.where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('completedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('completedAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get completed tasks',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get completed tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> searchTasks({
    required String userId,
    required String query,
    String? listId,
    List<String>? tags,
    String? priority,
    String? status,
  }) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation - for production, consider using Algolia or similar
      Query<Map<String, dynamic>> firestoreQuery = _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false);

      if (listId != null) {
        firestoreQuery = firestoreQuery.where('listId', isEqualTo: listId);
      }

      if (priority != null) {
        firestoreQuery = firestoreQuery.where('priority', isEqualTo: priority);
      }

      if (status != null) {
        firestoreQuery = firestoreQuery.where('status', isEqualTo: status);
      }

      final snapshot = await firestoreQuery.get();

      // Client-side filtering for title and description search
      final lowerQuery = query.toLowerCase();
      var tasks = snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .where((task) =>
              task.title.toLowerCase().contains(lowerQuery) ||
              (task.description?.toLowerCase().contains(lowerQuery) ?? false))
          .toList();

      // Filter by tags if provided
      if (tags != null && tags.isNotEmpty) {
        tasks = tasks.where((task) =>
            tags.any((tag) => task.tags.contains(tag))).toList();
      }

      return tasks;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to search tasks',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to search tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final taskRef = _firestore.collection('tasks').doc(task.id);
      final taskData = task.toJson();
      taskData['updatedAt'] = FieldValue.serverTimestamp();

      await taskRef.update(taskData);

      // Get the updated task with server timestamps
      final snapshot = await taskRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to update task',
        );
      }

      return TaskModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update task',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskModel> completeTask(String id) async {
    try {
      final taskRef = _firestore.collection('tasks').doc(id);

      await taskRef.update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await taskRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to complete task',
        );
      }

      return TaskModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to complete task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to complete task',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskModel> uncompleteTask(String id) async {
    try {
      final taskRef = _firestore.collection('tasks').doc(id);

      await taskRef.update({
        'status': 'active',
        'completedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await taskRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to uncomplete task',
        );
      }

      return TaskModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to uncomplete task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to uncomplete task',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _firestore.collection('tasks').doc(id).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete task',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteTask(String id) async {
    try {
      await _firestore.collection('tasks').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to permanently delete task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to permanently delete task',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskModel> restoreTask(String id) async {
    try {
      final taskRef = _firestore.collection('tasks').doc(id);

      await taskRef.update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await taskRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to restore task',
        );
      }

      return TaskModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to restore task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to restore task',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskModel> moveTask({
    required String taskId,
    required String newListId,
  }) async {
    try {
      final taskRef = _firestore.collection('tasks').doc(taskId);

      await taskRef.update({
        'listId': newListId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await taskRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to move task',
        );
      }

      return TaskModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to move task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to move task',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskModel> duplicateTask(String id) async {
    try {
      final originalTask = await getTask(id);

      // Create a new task with copied data
      final newTaskRef = _firestore.collection('tasks').doc();
      final newTask = originalTask.copyWith(
        id: newTaskRef.id,
        title: '${originalTask.title} (Copy)',
        status: 'active',
        completedAt: null,
        // Don't copy parent task ID for subtasks
        parentTaskId: null,
      );

      final taskData = newTask.toJson();
      taskData['createdAt'] = FieldValue.serverTimestamp();
      taskData['updatedAt'] = FieldValue.serverTimestamp();

      await newTaskRef.set(taskData);

      final snapshot = await newTaskRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to duplicate task',
        );
      }

      return TaskModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to duplicate task',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to duplicate task',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> batchUpdateTasks(List<TaskModel> tasks) async {
    try {
      final batch = _firestore.batch();

      for (final task in tasks) {
        final taskRef = _firestore.collection('tasks').doc(task.id);
        final taskData = task.toJson();
        taskData['updatedAt'] = FieldValue.serverTimestamp();
        batch.update(taskRef, taskData);
      }

      await batch.commit();

      // Fetch updated tasks
      final updatedTasks = <TaskModel>[];
      for (final task in tasks) {
        final snapshot = await _firestore.collection('tasks').doc(task.id).get();
        if (snapshot.exists) {
          updatedTasks.add(TaskModel.fromJson(snapshot.data()!));
        }
      }

      return updatedTasks;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to batch update tasks',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to batch update tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchDeleteTasks(List<String> taskIds) async {
    try {
      final batch = _firestore.batch();

      for (final taskId in taskIds) {
        final taskRef = _firestore.collection('tasks').doc(taskId);
        batch.update(taskRef, {
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to batch delete tasks',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to batch delete tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> batchCompleteTasks(List<String> taskIds) async {
    try {
      final batch = _firestore.batch();

      for (final taskId in taskIds) {
        final taskRef = _firestore.collection('tasks').doc(taskId);
        batch.update(taskRef, {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Fetch updated tasks
      final updatedTasks = <TaskModel>[];
      for (final taskId in taskIds) {
        final snapshot = await _firestore.collection('tasks').doc(taskId).get();
        if (snapshot.exists) {
          updatedTasks.add(TaskModel.fromJson(snapshot.data()!));
        }
      }

      return updatedTasks;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to batch complete tasks',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to batch complete tasks',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateSortOrder({
    required List<String> taskIds,
    required List<int> sortOrders,
  }) async {
    try {
      if (taskIds.length != sortOrders.length) {
        throw const ValidationException(
          message: 'Task IDs and sort orders must have the same length',
        );
      }

      final batch = _firestore.batch();

      for (var i = 0; i < taskIds.length; i++) {
        final taskRef = _firestore.collection('tasks').doc(taskIds[i]);
        batch.update(taskRef, {
          'sortOrder': sortOrders[i],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to update sort order',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(
        message: 'Failed to update sort order',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TaskModel>> getRecurringTaskInstances(String parentTaskId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('recurringParentId', isEqualTo: parentTaskId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get recurring task instances',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get recurring task instances',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskModel> generateNextRecurringInstance(String parentTaskId) async {
    try {
      final parentTask = await getTask(parentTaskId);

      if (parentTask.recurrenceRule == null) {
        throw const ValidationException(
          message: 'Task is not a recurring task',
        );
      }

      // Calculate next occurrence based on recurrence rule
      // This is a simplified implementation - production should use proper date calculation
      DateTime? nextDueDate;
      if (parentTask.dueDate != null) {
        final rule = parentTask.recurrenceRule!;
        switch (rule.frequency) {
          case 'daily':
            nextDueDate = parentTask.dueDate!.add(Duration(days: rule.interval));
            break;
          case 'weekly':
            nextDueDate = parentTask.dueDate!.add(Duration(days: 7 * rule.interval));
            break;
          case 'monthly':
            nextDueDate = DateTime(
              parentTask.dueDate!.year,
              parentTask.dueDate!.month + rule.interval,
              parentTask.dueDate!.day,
            );
            break;
          case 'yearly':
            nextDueDate = DateTime(
              parentTask.dueDate!.year + rule.interval,
              parentTask.dueDate!.month,
              parentTask.dueDate!.day,
            );
            break;
        }
      }

      // Create new instance
      final newTaskRef = _firestore.collection('tasks').doc();
      final newTask = parentTask.copyWith(
        id: newTaskRef.id,
        status: 'active',
        completedAt: null,
        dueDate: nextDueDate,
        recurringParentId: parentTaskId,
      );

      final taskData = newTask.toJson();
      taskData['createdAt'] = FieldValue.serverTimestamp();
      taskData['updatedAt'] = FieldValue.serverTimestamp();

      await newTaskRef.set(taskData);

      final snapshot = await newTaskRef.get();
      if (!snapshot.exists) {
        throw const ServerException(
          message: 'Failed to generate recurring instance',
        );
      }

      return TaskModel.fromJson(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to generate recurring instance',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(
        message: 'Failed to generate recurring instance',
        originalException: e,
      );
    }
  }

  @override
  Stream<TaskModel> watchTask(String id) {
    try {
      return _firestore
          .collection('tasks')
          .doc(id)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          throw const CacheException(
            message: 'Task not found',
          );
        }
        return TaskModel.fromJson(snapshot.data()!);
      });
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch task',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<TaskModel>> watchTasks({
    String? listId,
    String? userId,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('tasks');

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (listId != null) {
        query = query.where('listId', isEqualTo: listId);
      }

      query = query
          .where('isDeleted', isEqualTo: false)
          .orderBy('sortOrder');

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch tasks',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<TaskModel>> watchTasksDueToday(String userId) {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('isDeleted', isEqualTo: false)
          .where('status', isNotEqualTo: 'completed')
          .orderBy('dueDate')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList());
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch tasks due today',
        originalException: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getTaskStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false);

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();

      final totalTasks = tasks.length;
      final completedTasks = tasks.where((t) => t.status == 'completed').length;
      final activeTasks = tasks.where((t) => t.status == 'active').length;
      final overdueTasks = tasks.where((t) {
        if (t.dueDate == null || t.status == 'completed') return false;
        return t.dueDate!.isBefore(DateTime.now());
      }).length;

      final highPriorityTasks = tasks.where((t) => t.priority == 'high').length;
      final mediumPriorityTasks = tasks.where((t) => t.priority == 'medium').length;
      final lowPriorityTasks = tasks.where((t) => t.priority == 'low').length;

      final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

      return {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'activeTasks': activeTasks,
        'overdueTasks': overdueTasks,
        'highPriorityTasks': highPriorityTasks,
        'mediumPriorityTasks': mediumPriorityTasks,
        'lowPriorityTasks': lowPriorityTasks,
        'completionRate': completionRate,
      };
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get task statistics',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get task statistics',
        originalException: e,
      );
    }
  }
}
