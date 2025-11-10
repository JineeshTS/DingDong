import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/local/isar/isar_reminder_local_data_source.dart';
import '../datasources/local/isar/schemas/reminder_isar.dart';
import '../datasources/remote/firebase_reminder_remote_data_source.dart';
import '../models/reminder_model.dart';

/// Reminder repository implementation with offline-first architecture
class ReminderRepositoryImpl implements ReminderRepository {
  final FirebaseReminderRemoteDataSource remoteDataSource;
  final IsarReminderLocalDataSource localDataSource;

  ReminderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ReminderEntity>> createReminder(
      ReminderEntity reminder) async {
    try {
      final model = ReminderModel.fromEntity(reminder);

      // Save to local first
      final isarReminder = _modelToIsar(model);
      isarReminder.isDirty = true;
      await localDataSource.upsertReminder(isarReminder);

      // Try to sync to remote
      try {
        final createdModel = await remoteDataSource.createReminder(model);

        // Update local with server data
        final syncedIsarReminder = _modelToIsar(createdModel);
        await localDataSource.upsertReminder(syncedIsarReminder);
        await localDataSource.markAsSynced(createdModel.id);

        return Right(createdModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(reminder);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> getReminder(String id) async {
    try {
      // Try local first
      final localReminder = await localDataSource.getReminderByFirebaseId(id);

      if (localReminder != null) {
        return Right(_isarToEntity(localReminder));
      }

      // Fetch from remote
      final remoteModel = await remoteDataSource.getReminder(id);

      // Save to local
      final isarReminder = _modelToIsar(remoteModel);
      await localDataSource.upsertReminder(isarReminder);
      await localDataSource.markAsSynced(id);

      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> getRemindersForTask(
      String taskId) async {
    try {
      // Try local first
      final localReminders = await localDataSource.getRemindersByTask(
        taskId: taskId,
        includeTriggered: false,
        includeDeleted: false,
      );

      if (localReminders.isNotEmpty) {
        return Right(localReminders.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getRemindersForTask(taskId);

      // Save to local
      final isarReminders = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertReminders(isarReminders);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get reminders for task: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> getReminders({
    required String userId,
    bool includeDeleted = false,
  }) async {
    try {
      // Get from local (reminders are local-first)
      final localReminders = await localDataSource.getRemindersByUser(
        userId: userId,
        includeTriggered: false,
        includeDeleted: includeDeleted,
      );

      return Right(localReminders.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get reminders: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> getActiveReminders(
      String userId) async {
    try {
      // Get from local
      final localReminders = await localDataSource.getEnabledReminders(
        userId: userId,
        includeTriggered: false,
      );

      return Right(localReminders.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get active reminders: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> getRemindersDueSoon({
    required String userId,
    required Duration within,
  }) async {
    try {
      final now = DateTime.now();
      final endTime = now.add(within);

      final localReminders = await localDataSource.getUpcomingReminders(
        userId: userId,
        beforeTime: endTime,
      );

      return Right(localReminders.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get reminders due soon: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> getOverdueReminders(
      String userId) async {
    try {
      final localReminders = await localDataSource.getDueReminders(
        userId: userId,
      );

      return Right(localReminders.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get overdue reminders: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> getLocationReminders(
      String userId) async {
    try {
      final localReminders = await localDataSource.getRemindersByType(
        userId: userId,
        type: ReminderTypeIsar.location,
        includeTriggered: false,
        includeDeleted: false,
      );

      return Right(localReminders.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get location reminders: $e'));
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> updateReminder(
      ReminderEntity reminder) async {
    try {
      final model = ReminderModel.fromEntity(reminder);

      // Save to local first
      final isarReminder = _modelToIsar(model);
      isarReminder.isDirty = true;
      await localDataSource.upsertReminder(isarReminder);

      // Try to sync to remote
      try {
        final updatedModel = await remoteDataSource.updateReminder(model);

        // Update local with synced data
        final syncedIsarReminder = _modelToIsar(updatedModel);
        await localDataSource.upsertReminder(syncedIsarReminder);
        await localDataSource.markAsSynced(reminder.id);

        return Right(updatedModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(reminder);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReminder(String id) async {
    try {
      // Mark as deleted locally
      await localDataSource.deleteReminder(id);

      // Try to delete from remote
      try {
        await remoteDataSource.deleteReminder(id);
        await localDataSource.markAsSynced(id);
      } on ServerException {
        // If remote fails, mark as dirty for later sync
        await localDataSource.markAsDirty(id);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteReminder(String id) async {
    try {
      await remoteDataSource.permanentlyDeleteReminder(id);
      await localDataSource.permanentlyDeleteReminder(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to permanently delete reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> setReminderEnabled({
    required String reminderId,
    required bool enabled,
  }) async {
    try {
      // Update locally first (instant UI feedback)
      if (enabled) {
        await localDataSource.enableReminder(reminderId);
      } else {
        await localDataSource.disableReminder(reminderId);
      }

      // Get updated reminder
      final localReminder =
          await localDataSource.getReminderByFirebaseId(reminderId);
      if (localReminder == null) {
        return Left(CacheFailure(message: 'Reminder not found'));
      }

      // Sync to remote in background
      remoteDataSource
          .setReminderEnabled(reminderId: reminderId, enabled: enabled)
          .then((model) {
        final isarReminder = _modelToIsar(model);
        localDataSource.upsertReminder(isarReminder);
        localDataSource.markAsSynced(reminderId);
      }).catchError((_) {
        localDataSource.markAsDirty(reminderId);
      });

      return Right(_isarToEntity(localReminder));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to set reminder enabled: $e'));
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> markAsTriggered(
      String reminderId) async {
    try {
      // Mark locally first
      await localDataSource.markAsTriggered(reminderId);

      // Sync to remote
      try {
        final model = await remoteDataSource.markAsTriggered(reminderId);

        final isarReminder = _modelToIsar(model);
        await localDataSource.upsertReminder(isarReminder);
        await localDataSource.markAsSynced(reminderId);

        return Right(model.toEntity());
      } on ServerException {
        await localDataSource.markAsDirty(reminderId);

        final localReminder =
            await localDataSource.getReminderByFirebaseId(reminderId);
        if (localReminder != null) {
          return Right(_isarToEntity(localReminder));
        }
        rethrow;
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to mark as triggered: $e'));
    }
  }

  @override
  Future<Either<Failure, ReminderEntity>> snoozeReminder({
    required String reminderId,
    required Duration duration,
  }) async {
    try {
      final model = await remoteDataSource.snoozeReminder(
        reminderId: reminderId,
        duration: duration,
      );

      // Update local
      final isarReminder = _modelToIsar(model);
      await localDataSource.upsertReminder(isarReminder);
      await localDataSource.markAsSynced(reminderId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to snooze reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ReminderEntity>>> batchCreateReminders(
      List<ReminderEntity> reminders) async {
    try {
      final models = reminders.map((r) => ReminderModel.fromEntity(r)).toList();

      // Save to local first
      final isarReminders = models.map(_modelToIsar).toList();
      for (final isar in isarReminders) {
        isar.isDirty = true;
      }
      await localDataSource.batchInsertReminders(isarReminders);

      // Try to sync to remote
      try {
        final createdModels =
            await remoteDataSource.batchCreateReminders(models);

        // Update local with server data
        final syncedIsarReminders = createdModels.map(_modelToIsar).toList();
        await localDataSource.batchInsertReminders(syncedIsarReminders);

        return Right(createdModels.map((m) => m.toEntity()).toList());
      } on ServerException {
        // If remote fails, still return success
        return Right(reminders);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to batch create reminders: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> batchDeleteReminders(
      List<String> reminderIds) async {
    try {
      // Delete locally
      for (final id in reminderIds) {
        await localDataSource.deleteReminder(id);
      }

      // Try to delete from remote
      try {
        await remoteDataSource.batchDeleteReminders(reminderIds);
      } on ServerException {
        // If remote fails, mark as dirty
        for (final id in reminderIds) {
          await localDataSource.markAsDirty(id);
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to batch delete reminders: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRemindersForTask(String taskId) async {
    try {
      await remoteDataSource.deleteRemindersForTask(taskId);
      await localDataSource.deleteRemindersForTask(taskId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to delete reminders for task: $e'));
    }
  }

  @override
  Stream<Either<Failure, ReminderEntity>> watchReminder(String id) {
    try {
      return localDataSource.watchReminder(id).map((reminderIsar) {
        if (reminderIsar == null) {
          return Left(
              CacheFailure(message: 'Reminder not found in local database'));
        }
        return Right(_isarToEntity(reminderIsar));
      }).handleError((error) {
        return Left(CacheFailure(message: 'Failed to watch reminder: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch reminder: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<ReminderEntity>>> watchRemindersForTask(
      String taskId) {
    try {
      return localDataSource
          .watchRemindersForTask(taskId: taskId)
          .map((remindersIsar) {
        return Right(remindersIsar.map(_isarToEntity).toList());
      }).handleError((error) {
        return Left(
            CacheFailure(message: 'Failed to watch reminders for task: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch reminders for task: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<ReminderEntity>>> watchActiveReminders(
      String userId) {
    try {
      return localDataSource
          .watchUpcomingReminders(userId: userId)
          .map((remindersIsar) {
        return Right(remindersIsar.map(_isarToEntity).toList());
      }).handleError((error) {
        return Left(
            CacheFailure(message: 'Failed to watch active reminders: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch active reminders: $e')));
    }
  }

  // ==================== CONVERTERS ====================

  /// Convert ReminderModel to ReminderIsar
  ReminderIsar _modelToIsar(ReminderModel model) {
    return ReminderIsar()
      ..reminderId = model.id
      ..userId = model.userId
      ..taskId = model.taskId
      ..type = _typeToIsar(model.type)
      ..reminderTime = model.reminderTime
      ..isEnabled = model.isEnabled
      ..isTriggered = model.isTriggered
      ..triggeredAt = model.triggeredAt
      ..message = model.message
      ..locationTriggerJson = model.locationTrigger != null
          ? jsonEncode(model.locationTrigger!.toJson())
          : null
      ..contextTriggerJson = model.contextTrigger != null
          ? jsonEncode(model.contextTrigger!.toJson())
          : null
      ..repeatInterval = model.repeatInterval
      ..isDeleted = model.isDeleted
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt;
  }

  /// Convert ReminderIsar to ReminderEntity
  ReminderEntity _isarToEntity(ReminderIsar isar) {
    return ReminderEntity(
      id: isar.reminderId,
      userId: isar.userId,
      taskId: isar.taskId,
      type: _typeFromIsar(isar.type),
      reminderTime: isar.reminderTime,
      isEnabled: isar.isEnabled,
      isTriggered: isar.isTriggered,
      triggeredAt: isar.triggeredAt,
      message: isar.message,
      locationTrigger: isar.locationTriggerJson != null
          ? ReminderLocationTriggerModel.fromJson(
              jsonDecode(isar.locationTriggerJson!) as Map<String, dynamic>).toEntity()
          : null,
      contextTrigger: isar.contextTriggerJson != null
          ? ReminderContextTriggerModel.fromJson(
              jsonDecode(isar.contextTriggerJson!) as Map<String, dynamic>).toEntity()
          : null,
      repeatInterval: isar.repeatInterval,
      isDeleted: isar.isDeleted,
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
    );
  }

  /// Convert type string to Isar enum
  ReminderTypeIsar _typeToIsar(String type) {
    switch (type) {
      case 'time':
        return ReminderTypeIsar.time;
      case 'location':
        return ReminderTypeIsar.location;
      case 'context':
        return ReminderTypeIsar.context;
      default:
        return ReminderTypeIsar.time;
    }
  }

  /// Convert Isar type to domain enum
  ReminderType _typeFromIsar(ReminderTypeIsar type) {
    switch (type) {
      case ReminderTypeIsar.time:
        return ReminderType.time;
      case ReminderTypeIsar.location:
        return ReminderType.location;
      case ReminderTypeIsar.context:
        return ReminderType.context;
    }
  }
}
