import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/isar/isar_task_local_data_source.dart';
import '../datasources/local/isar/schemas/task_isar.dart';
import '../datasources/remote/firebase_task_remote_data_source.dart';
import '../models/task_model.dart';

/// Task repository implementation with offline-first architecture
class TaskRepositoryImpl implements TaskRepository {
  final FirebaseTaskRemoteDataSource remoteDataSource;
  final IsarTaskLocalDataSource localDataSource;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    try {
      final model = TaskModel.fromEntity(task);

      // Save to local first
      final isarTask = _modelToIsar(model);
      isarTask.isDirty = true;
      await localDataSource.upsertTask(isarTask);

      // Try to sync to remote
      try {
        final createdModel = await remoteDataSource.createTask(model);

        // Update local with server data
        final syncedIsarTask = _modelToIsar(createdModel);
        await localDataSource.upsertTask(syncedIsarTask);
        await localDataSource.markAsSynced(createdModel.id);

        return Right(createdModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(task);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create task: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getTask(String id) async {
    try {
      // Try local first
      final localTask = await localDataSource.getTaskByFirebaseId(id);

      if (localTask != null) {
        return Right(_isarToEntity(localTask));
      }

      // Fetch from remote
      final remoteModel = await remoteDataSource.getTask(id);

      // Save to local
      final isarTask = _modelToIsar(remoteModel);
      await localDataSource.upsertTask(isarTask);
      await localDataSource.markAsSynced(id);

      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get task: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks({
    String? listId,
    String? userId,
    bool includeCompleted = false,
    bool includeDeleted = false,
  }) async {
    try {
      // Try local first
      final localTasks = userId != null
          ? await localDataSource.getTasksByUser(
              userId: userId,
              includeCompleted: includeCompleted,
              includeDeleted: includeDeleted,
            )
          : await localDataSource.getAllTasks();

      if (localTasks.isNotEmpty) {
        var filtered = localTasks;

        if (listId != null) {
          filtered = filtered.where((t) => t.listId == listId).toList();
        }

        return Right(filtered.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getTasks(
        listId: listId,
        userId: userId,
        includeCompleted: includeCompleted,
        includeDeleted: includeDeleted,
      );

      // Save to local
      final isarTasks = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertTasks(isarTasks);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByList(String listId) async {
    try {
      // Get from local
      final localTasks = await localDataSource.getTasksByList(
        listId: listId,
        includeCompleted: false,
      );

      return Right(localTasks.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get tasks by list: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getSubtasks(
      String parentTaskId) async {
    try {
      // Get from local
      final localTasks = await localDataSource.getSubtasks(
        parentTaskId: parentTaskId,
      );

      return Right(localTasks.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get subtasks: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksDueToday(
      String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Get from local
      final localTasks = await localDataSource.getTasksByDueDate(
        userId: userId,
        startDate: startOfDay,
        endDate: endOfDay,
      );

      return Right(localTasks.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get tasks due today: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksDueTomorrow(
      String userId) async {
    try {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final startOfDay = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      final endOfDay =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59);

      // Get from local
      final localTasks = await localDataSource.getTasksByDueDate(
        userId: userId,
        startDate: startOfDay,
        endDate: endOfDay,
      );

      return Right(localTasks.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get tasks due tomorrow: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getOverdueTasks(
      String userId) async {
    try {
      // Get from local
      final localTasks = await localDataSource.getOverdueTasks(userId: userId);

      return Right(localTasks.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get overdue tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByPriority({
    required String userId,
    required TaskPriority priority,
  }) async {
    try {
      // Get from local
      final localTasks = await localDataSource.getTasksByPriority(
        userId: userId,
        priority: _priorityToIsar(priority),
      );

      return Right(localTasks.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get tasks by priority: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByTag({
    required String userId,
    required String tag,
  }) async {
    try {
      // Get from local
      final localTasks = await localDataSource.getTasksByTag(
        userId: userId,
        tag: tag,
      );

      return Right(localTasks.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get tasks by tag: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getAssignedTasks(
      String userId) async {
    try {
      // Get from local
      final localTasks =
          await localDataSource.getTasksAssignedToUser(userId: userId);

      return Right(localTasks.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get assigned tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getCompletedTasks({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get from local
      final localTasks = await localDataSource.getCompletedTasks(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(localTasks.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get completed tasks: $e'));
    }
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
    try {
      // Search in local
      final localTasks = await localDataSource.getTasksByUser(
        userId: userId,
        includeCompleted: status == TaskStatus.completed,
        includeDeleted: false,
      );

      // Client-side filtering
      final lowerQuery = query.toLowerCase();
      var filtered = localTasks.where((task) {
        final titleMatch = task.title.toLowerCase().contains(lowerQuery);
        final descMatch =
            task.description?.toLowerCase().contains(lowerQuery) ?? false;
        return titleMatch || descMatch;
      }).toList();

      if (listId != null) {
        filtered = filtered.where((t) => t.listId == listId).toList();
      }

      if (tags != null && tags.isNotEmpty) {
        filtered = filtered.where((t) {
          return tags.any((tag) => t.tagsJson?.contains(tag) ?? false);
        }).toList();
      }

      if (priority != null) {
        filtered = filtered
            .where((t) => t.priority == _priorityToIsar(priority))
            .toList();
      }

      if (status != null) {
        filtered = filtered
            .where((t) => t.status == _statusToIsar(status))
            .toList();
      }

      return Right(filtered.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    try {
      final model = TaskModel.fromEntity(task);

      // Save to local first
      final isarTask = _modelToIsar(model);
      isarTask.isDirty = true;
      await localDataSource.upsertTask(isarTask);

      // Try to sync to remote
      try {
        final updatedModel = await remoteDataSource.updateTask(model);

        // Update local with synced data
        final syncedIsarTask = _modelToIsar(updatedModel);
        await localDataSource.upsertTask(syncedIsarTask);
        await localDataSource.markAsSynced(task.id);

        return Right(updatedModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(task);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update task: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> completeTask(String id) async {
    try {
      // Update locally first (instant feedback)
      await localDataSource.completeTask(id);

      // Sync to remote in background
      remoteDataSource.completeTask(id).then((model) {
        final isarTask = _modelToIsar(model);
        localDataSource.upsertTask(isarTask);
        localDataSource.markAsSynced(id);
      }).catchError((_) {
        localDataSource.markAsDirty(id);
      });

      final localTask = await localDataSource.getTaskByFirebaseId(id);
      return Right(_isarToEntity(localTask!));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to complete task: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> uncompleteTask(String id) async {
    try {
      // Update locally first (instant feedback)
      await localDataSource.uncompleteTask(id);

      // Sync to remote in background
      remoteDataSource.uncompleteTask(id).then((model) {
        final isarTask = _modelToIsar(model);
        localDataSource.upsertTask(isarTask);
        localDataSource.markAsSynced(id);
      }).catchError((_) {
        localDataSource.markAsDirty(id);
      });

      final localTask = await localDataSource.getTaskByFirebaseId(id);
      return Right(_isarToEntity(localTask!));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to uncomplete task: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      // Mark as deleted locally
      await localDataSource.deleteTask(id);

      // Try to delete from remote
      try {
        await remoteDataSource.deleteTask(id);
        await localDataSource.markAsSynced(id);
      } on ServerException {
        // If remote fails, mark as dirty for later sync
        await localDataSource.markAsDirty(id);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete task: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteTask(String id) async {
    try {
      await remoteDataSource.permanentlyDeleteTask(id);
      await localDataSource.permanentlyDeleteTask(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to permanently delete task: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> restoreTask(String id) async {
    try {
      final model = await remoteDataSource.restoreTask(id);

      // Update local
      final isarTask = _modelToIsar(model);
      await localDataSource.upsertTask(isarTask);
      await localDataSource.markAsSynced(id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to restore task: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> moveTask({
    required String taskId,
    required String newListId,
  }) async {
    try {
      final model = await remoteDataSource.moveTask(
        taskId: taskId,
        newListId: newListId,
      );

      // Update local
      final isarTask = _modelToIsar(model);
      await localDataSource.upsertTask(isarTask);
      await localDataSource.markAsSynced(taskId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to move task: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> duplicateTask(String id) async {
    try {
      final model = await remoteDataSource.duplicateTask(id);

      // Save duplicate to local
      final isarTask = _modelToIsar(model);
      await localDataSource.upsertTask(isarTask);
      await localDataSource.markAsSynced(model.id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to duplicate task: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> batchUpdateTasks(
      List<TaskEntity> tasks) async {
    try {
      final models = tasks.map((t) => TaskModel.fromEntity(t)).toList();

      // Update locally first
      final isarTasks = models.map(_modelToIsar).toList();
      for (final task in isarTasks) {
        task.isDirty = true;
      }
      await localDataSource.batchInsertTasks(isarTasks);

      // Try to sync to remote
      try {
        final updatedModels = await remoteDataSource.batchUpdateTasks(models);

        // Update local with synced data
        final syncedIsarTasks = updatedModels.map(_modelToIsar).toList();
        await localDataSource.batchInsertTasks(syncedIsarTasks);

        for (final model in updatedModels) {
          await localDataSource.markAsSynced(model.id);
        }

        return Right(updatedModels.map((m) => m.toEntity()).toList());
      } on ServerException {
        // If remote fails, still return success
        return Right(tasks);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to batch update tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> batchDeleteTasks(List<String> taskIds) async {
    try {
      // Delete locally
      for (final id in taskIds) {
        await localDataSource.deleteTask(id);
      }

      // Try to delete from remote
      try {
        await remoteDataSource.batchDeleteTasks(taskIds);
      } on ServerException {
        // If remote fails, mark as dirty
        for (final id in taskIds) {
          await localDataSource.markAsDirty(id);
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to batch delete tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> batchCompleteTasks(
      List<String> taskIds) async {
    try {
      // Complete locally first
      for (final id in taskIds) {
        await localDataSource.completeTask(id);
      }

      // Sync to remote in background
      remoteDataSource.batchCompleteTasks(taskIds).then((models) {
        final isarTasks = models.map(_modelToIsar).toList();
        localDataSource.batchInsertTasks(isarTasks);

        for (final id in taskIds) {
          localDataSource.markAsSynced(id);
        }
      }).catchError((_) {
        for (final id in taskIds) {
          localDataSource.markAsDirty(id);
        }
      });

      final completedTasks = <TaskEntity>[];
      for (final id in taskIds) {
        final task = await localDataSource.getTaskByFirebaseId(id);
        if (task != null) {
          completedTasks.add(_isarToEntity(task));
        }
      }

      return Right(completedTasks);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to batch complete tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSortOrder({
    required List<String> taskIds,
    required List<int> sortOrders,
  }) async {
    try {
      // Update locally first
      await localDataSource.updateSortOrders(
        taskIds: taskIds,
        sortOrders: sortOrders,
      );

      // Sync to remote in background
      remoteDataSource.updateSortOrder(
        taskIds: taskIds,
        sortOrders: sortOrders,
      ).then((_) {
        for (final id in taskIds) {
          localDataSource.markAsSynced(id);
        }
      }).catchError((_) {
        for (final id in taskIds) {
          localDataSource.markAsDirty(id);
        }
      });

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update sort order: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getRecurringTaskInstances(
      String parentTaskId) async {
    try {
      final models =
          await remoteDataSource.getRecurringTaskInstances(parentTaskId);

      // Save to local
      final isarTasks = models.map(_modelToIsar).toList();
      await localDataSource.batchInsertTasks(isarTasks);

      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to get recurring task instances: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> generateNextRecurringInstance(
      String parentTaskId) async {
    try {
      final model =
          await remoteDataSource.generateNextRecurringInstance(parentTaskId);

      // Save to local
      final isarTask = _modelToIsar(model);
      await localDataSource.upsertTask(isarTask);
      await localDataSource.markAsSynced(model.id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to generate next recurring instance: $e'));
    }
  }

  @override
  Stream<Either<Failure, TaskEntity>> watchTask(String id) {
    try {
      return localDataSource.watchTask(id).map((taskIsar) {
        if (taskIsar == null) {
          return Left(
              CacheFailure(message: 'Task not found in local database'));
        }
        return Right(_isarToEntity(taskIsar));
      }).handleError((error) {
        return Left(CacheFailure(message: 'Failed to watch task: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch task: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<TaskEntity>>> watchTasks({
    String? listId,
    String? userId,
  }) {
    try {
      Stream<List<TaskIsar>> stream;

      if (listId != null) {
        stream = localDataSource.watchTasksByList(listId: listId);
      } else if (userId != null) {
        stream = localDataSource.watchTasksByUser(userId: userId);
      } else {
        stream = localDataSource.watchAllTasks();
      }

      return stream.map((tasksIsar) {
        return Right(tasksIsar.map(_isarToEntity).toList());
      }).handleError((error) {
        return Left(CacheFailure(message: 'Failed to watch tasks: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch tasks: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<TaskEntity>>> watchTasksDueToday(String userId) {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return localDataSource.watchTasksByUser(userId: userId).map((tasksIsar) {
        // Filter for tasks due today
        final dueToday = tasksIsar.where((task) {
          if (task.dueDate == null) return false;
          return task.dueDate!.isAfter(startOfDay) &&
              task.dueDate!.isBefore(endOfDay);
        }).toList();

        return Right(dueToday.map(_isarToEntity).toList());
      }).handleError((error) {
        return Left(
            CacheFailure(message: 'Failed to watch tasks due today: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch tasks due today: $e')));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTaskStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await remoteDataSource.getTaskStatistics(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get task statistics: $e'));
    }
  }

  // ==================== CONVERTERS ====================

  /// Convert TaskModel to TaskIsar
  TaskIsar _modelToIsar(TaskModel model) {
    return TaskIsar()
      ..taskId = model.id
      ..userId = model.userId
      ..listId = model.listId
      ..parentTaskId = model.parentTaskId
      ..title = model.title
      ..description = model.description
      ..status = _statusToIsar(model.status as TaskStatus)
      ..priority = _priorityToIsar(model.priority as TaskPriority)
      ..dueDate = model.dueDate
      ..startDate = model.startDate
      ..completedAt = model.completedAt
      ..estimatedMinutes = model.estimatedDurationSeconds != null
          ? model.estimatedDurationSeconds! ~/ 60
          : null
      ..actualMinutes = model.actualDurationSeconds != null
          ? model.actualDurationSeconds! ~/ 60
          : null
      ..tagsJson = model.tags.isNotEmpty ? jsonEncode(model.tags) : null
      ..assigneesJson = model.assigneeIds.isNotEmpty
          ? jsonEncode(model.assigneeIds)
          : null
      ..location = model.location
      ..latitude = model.latitude
      ..longitude = model.longitude
      ..sortOrder = model.sortOrder
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt
      ..createdBy = model.createdBy
      ..isDeleted = model.isDeleted;
  }

  /// Convert TaskIsar to TaskEntity
  TaskEntity _isarToEntity(TaskIsar isar) {
    // Parse tags
    final tags = isar.tagsJson != null
        ? List<String>.from(jsonDecode(isar.tagsJson!) as List)
        : <String>[];

    // Parse assignees
    final assigneeIds = isar.assigneesJson != null
        ? List<String>.from(jsonDecode(isar.assigneesJson!) as List)
        : <String>[];

    return TaskEntity(
      id: isar.taskId,
      userId: isar.userId,
      listId: isar.listId,
      parentTaskId: isar.parentTaskId,
      title: isar.title,
      description: isar.description,
      status: _statusFromIsar(isar.status),
      priority: _priorityFromIsar(isar.priority),
      dueDate: isar.dueDate,
      startDate: isar.startDate,
      completedAt: isar.completedAt,
      estimatedDuration: isar.estimatedMinutes != null
          ? Duration(minutes: isar.estimatedMinutes!)
          : null,
      actualDuration: isar.actualMinutes != null
          ? Duration(minutes: isar.actualMinutes!)
          : null,
      tags: tags,
      assigneeIds: assigneeIds,
      collaboratorIds: [],
      location: isar.location,
      latitude: isar.latitude,
      longitude: isar.longitude,
      energyLevel: null,
      contextTags: [],
      customFields: null,
      sortOrder: isar.sortOrder,
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
      createdBy: isar.createdBy,
      lastModifiedBy: null,
      isDeleted: isar.isDeleted,
      dependencies: [],
      recurrenceRule: null,
      recurrenceParentId: null,
    );
  }

  /// Convert TaskStatus to TaskStatusIsar
  TaskStatusIsar _statusToIsar(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return TaskStatusIsar.todo;
      case TaskStatus.inProgress:
        return TaskStatusIsar.inProgress;
      case TaskStatus.completed:
        return TaskStatusIsar.completed;
      case TaskStatus.cancelled:
        return TaskStatusIsar.cancelled;
    }
  }

  /// Convert TaskStatusIsar to TaskStatus
  TaskStatus _statusFromIsar(TaskStatusIsar status) {
    switch (status) {
      case TaskStatusIsar.todo:
        return TaskStatus.todo;
      case TaskStatusIsar.inProgress:
        return TaskStatus.inProgress;
      case TaskStatusIsar.completed:
        return TaskStatus.completed;
      case TaskStatusIsar.cancelled:
        return TaskStatus.cancelled;
    }
  }

  /// Convert TaskPriority to TaskPriorityIsar
  TaskPriorityIsar _priorityToIsar(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.none:
        return TaskPriorityIsar.none;
      case TaskPriority.low:
        return TaskPriorityIsar.low;
      case TaskPriority.medium:
        return TaskPriorityIsar.medium;
      case TaskPriority.high:
        return TaskPriorityIsar.high;
      case TaskPriority.urgent:
        return TaskPriorityIsar.urgent;
    }
  }

  /// Convert TaskPriorityIsar to TaskPriority
  TaskPriority _priorityFromIsar(TaskPriorityIsar priority) {
    switch (priority) {
      case TaskPriorityIsar.none:
        return TaskPriority.none;
      case TaskPriorityIsar.low:
        return TaskPriority.low;
      case TaskPriorityIsar.medium:
        return TaskPriority.medium;
      case TaskPriorityIsar.high:
        return TaskPriority.high;
      case TaskPriorityIsar.urgent:
        return TaskPriority.urgent;
    }
  }
}
