import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/timebox_service.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/timebox_entity.dart';
import '../../domain/repositories/timebox_repository.dart';
import '../datasources/local/isar/isar_timebox_local_data_source.dart';
import '../datasources/local/isar/schemas/timebox_isar.dart';
import '../datasources/remote/firebase_timebox_remote_data_source.dart';
import '../models/timebox_model.dart';

/// Timebox repository implementation with offline-first architecture
class TimeboxRepositoryImpl implements TimeboxRepository {
  final FirebaseTimeboxRemoteDataSource remoteDataSource;
  final IsarTimeboxLocalDataSource localDataSource;
  final TimeboxService timeboxService;
  final Uuid uuid = const Uuid();

  TimeboxRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.timeboxService,
  });

  // ============================================================
  // TIMEBOX CRUD OPERATIONS
  // ============================================================

  @override
  Future<Either<Failure, TimeboxEntity>> getTimeboxForDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      // Normalize date to midnight
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Try local first
      final localTimebox = await localDataSource.getTimeboxForDate(
        userId: userId,
        date: normalizedDate,
      );

      if (localTimebox != null) {
        return Right(_isarToEntity(localTimebox));
      }

      // Try remote
      try {
        final remoteModel = await remoteDataSource.getTimeboxForDate(
          userId: userId,
          date: normalizedDate,
        );

        // Save to local
        final isarTimebox = localDataSource.modelToIsar(remoteModel);
        await localDataSource.upsertTimebox(isarTimebox);
        await localDataSource.markAsSynced(remoteModel.id);

        return Right(remoteModel.toEntity());
      } on CacheException {
        // Timebox doesn't exist, create a new one
        final newTimebox = _createDefaultTimebox(userId, normalizedDate);
        final created = await createTimebox(newTimebox);
        return created;
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get timebox for date: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxEntity>> getTimeboxById(String timeboxId) async {
    try {
      // Try local first
      final localTimebox =
          await localDataSource.getTimeboxByFirebaseId(timeboxId);

      if (localTimebox != null) {
        return Right(_isarToEntity(localTimebox));
      }

      // Fetch from remote
      final remoteModel = await remoteDataSource.getTimebox(timeboxId);

      // Save to local
      final isarTimebox = localDataSource.modelToIsar(remoteModel);
      await localDataSource.upsertTimebox(isarTimebox);
      await localDataSource.markAsSynced(timeboxId);

      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get timebox: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxEntity>> createTimebox(
      TimeboxEntity timebox) async {
    try {
      final model = TimeboxModel.fromEntity(timebox);

      // Save to local first
      final isarTimebox = localDataSource.modelToIsar(model);
      isarTimebox.isDirty = true;
      await localDataSource.upsertTimebox(isarTimebox);

      // Try to sync to remote
      try {
        final createdModel = await remoteDataSource.createTimebox(model);

        // Update local with server data
        final syncedIsarTimebox = localDataSource.modelToIsar(createdModel);
        await localDataSource.upsertTimebox(syncedIsarTimebox);
        await localDataSource.markAsSynced(createdModel.id);

        return Right(createdModel.toEntity());
      } on ServerException {
        // If remote fails, still return success with local data
        return Right(timebox);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create timebox: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxEntity>> updateTimebox(
      TimeboxEntity timebox) async {
    try {
      final model = TimeboxModel.fromEntity(timebox);

      // Update local first
      final isarTimebox = localDataSource.modelToIsar(model);
      isarTimebox.isDirty = true;
      await localDataSource.updateTimebox(isarTimebox);

      // Try to sync to remote
      try {
        final updatedModel = await remoteDataSource.updateTimebox(model);

        // Update local with server data
        final syncedIsarTimebox = localDataSource.modelToIsar(updatedModel);
        await localDataSource.upsertTimebox(syncedIsarTimebox);
        await localDataSource.markAsSynced(updatedModel.id);

        return Right(updatedModel.toEntity());
      } on ServerException {
        // If remote fails, still return success with local data
        return Right(timebox);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update timebox: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTimebox(String timeboxId) async {
    try {
      // Delete from local first
      await localDataSource.deleteTimebox(timeboxId);

      // Try to delete from remote
      try {
        await remoteDataSource.deleteTimebox(timeboxId);
      } on ServerException {
        // If remote fails, mark as dirty for later sync
        // In a real implementation, you might queue this for deletion sync
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete timebox: $e'));
    }
  }

  // ============================================================
  // TIMEBOX SLOT OPERATIONS
  // ============================================================

  @override
  Future<Either<Failure, TimeboxEntity>> addSlot({
    required String timeboxId,
    required TimeboxSlot slot,
  }) async {
    try {
      final slotModel = TimeboxSlotModel.fromEntity(slot);

      // Update local first
      final localTimebox =
          await localDataSource.getTimeboxByFirebaseId(timeboxId);
      if (localTimebox == null) {
        return const Left(
            CacheFailure(message: 'Timebox not found in local database'));
      }

      final currentModel = localDataSource.isarToModel(localTimebox);
      final updatedSlots = [...currentModel.slots, slotModel];
      final updatedModel = currentModel.copyWith(slots: updatedSlots);

      final isarTimebox = localDataSource.modelToIsar(updatedModel);
      isarTimebox.isDirty = true;
      await localDataSource.updateTimebox(isarTimebox);

      // Try to sync to remote
      try {
        final remoteModel = await remoteDataSource.addSlot(
          timeboxId: timeboxId,
          slot: slotModel,
        );

        // Update local with server data
        final syncedIsarTimebox = localDataSource.modelToIsar(remoteModel);
        await localDataSource.upsertTimebox(syncedIsarTimebox);
        await localDataSource.markAsSynced(remoteModel.id);

        return Right(remoteModel.toEntity());
      } on ServerException {
        // If remote fails, still return success with local data
        return Right(updatedModel.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add slot: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxEntity>> updateSlot({
    required String timeboxId,
    required TimeboxSlot slot,
  }) async {
    try {
      final slotModel = TimeboxSlotModel.fromEntity(slot);

      // Update local first
      final localTimebox =
          await localDataSource.getTimeboxByFirebaseId(timeboxId);
      if (localTimebox == null) {
        return const Left(
            CacheFailure(message: 'Timebox not found in local database'));
      }

      final currentModel = localDataSource.isarToModel(localTimebox);
      final updatedSlots = currentModel.slots.map((s) {
        return s.id == slot.id ? slotModel : s;
      }).toList();
      final updatedModel = currentModel.copyWith(slots: updatedSlots);

      final isarTimebox = localDataSource.modelToIsar(updatedModel);
      isarTimebox.isDirty = true;
      await localDataSource.updateTimebox(isarTimebox);

      // Try to sync to remote
      try {
        final remoteModel = await remoteDataSource.updateSlot(
          timeboxId: timeboxId,
          slot: slotModel,
        );

        // Update local with server data
        final syncedIsarTimebox = localDataSource.modelToIsar(remoteModel);
        await localDataSource.upsertTimebox(syncedIsarTimebox);
        await localDataSource.markAsSynced(remoteModel.id);

        return Right(remoteModel.toEntity());
      } on ServerException {
        // If remote fails, still return success with local data
        return Right(updatedModel.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update slot: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxEntity>> removeSlot({
    required String timeboxId,
    required String slotId,
  }) async {
    try {
      // Update local first
      final localTimebox =
          await localDataSource.getTimeboxByFirebaseId(timeboxId);
      if (localTimebox == null) {
        return const Left(
            CacheFailure(message: 'Timebox not found in local database'));
      }

      final currentModel = localDataSource.isarToModel(localTimebox);
      final updatedSlots =
          currentModel.slots.where((s) => s.id != slotId).toList();
      final updatedModel = currentModel.copyWith(slots: updatedSlots);

      final isarTimebox = localDataSource.modelToIsar(updatedModel);
      isarTimebox.isDirty = true;
      await localDataSource.updateTimebox(isarTimebox);

      // Try to sync to remote
      try {
        final remoteModel = await remoteDataSource.deleteSlot(
          timeboxId: timeboxId,
          slotId: slotId,
        );

        // Update local with server data
        final syncedIsarTimebox = localDataSource.modelToIsar(remoteModel);
        await localDataSource.upsertTimebox(syncedIsarTimebox);
        await localDataSource.markAsSynced(remoteModel.id);

        return Right(remoteModel.toEntity());
      } on ServerException {
        // If remote fails, still return success with local data
        return Right(updatedModel.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove slot: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxEntity>> reorderSlots({
    required String timeboxId,
    required List<String> slotIds,
  }) async {
    try {
      // Get current timebox
      final localTimebox =
          await localDataSource.getTimeboxByFirebaseId(timeboxId);
      if (localTimebox == null) {
        return const Left(
            CacheFailure(message: 'Timebox not found in local database'));
      }

      final currentModel = localDataSource.isarToModel(localTimebox);

      // Reorder slots based on slotIds order
      final reorderedSlots = <TimeboxSlotModel>[];
      for (final slotId in slotIds) {
        final slot = currentModel.slots.firstWhere((s) => s.id == slotId);
        reorderedSlots.add(slot);
      }

      final updatedModel = currentModel.copyWith(slots: reorderedSlots);

      return await updateTimebox(updatedModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to reorder slots: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxEntity>> rescheduleSlot({
    required String timeboxId,
    required String slotId,
    required DateTime newStartTime,
    required DateTime newEndTime,
  }) async {
    try {
      // Update local first
      final localTimebox =
          await localDataSource.getTimeboxByFirebaseId(timeboxId);
      if (localTimebox == null) {
        return const Left(
            CacheFailure(message: 'Timebox not found in local database'));
      }

      final currentModel = localDataSource.isarToModel(localTimebox);
      final updatedSlots = currentModel.slots.map((s) {
        if (s.id == slotId) {
          return s.copyWith(
            startTime: newStartTime,
            endTime: newEndTime,
          );
        }
        return s;
      }).toList();
      final updatedModel = currentModel.copyWith(slots: updatedSlots);

      final isarTimebox = localDataSource.modelToIsar(updatedModel);
      isarTimebox.isDirty = true;
      await localDataSource.updateTimebox(isarTimebox);

      // Try to sync to remote
      try {
        final remoteModel = await remoteDataSource.rescheduleSlot(
          timeboxId: timeboxId,
          slotId: slotId,
          newStartTime: newStartTime,
          newEndTime: newEndTime,
        );

        // Update local with server data
        final syncedIsarTimebox = localDataSource.modelToIsar(remoteModel);
        await localDataSource.upsertTimebox(syncedIsarTimebox);
        await localDataSource.markAsSynced(remoteModel.id);

        return Right(remoteModel.toEntity());
      } on ServerException {
        // If remote fails, still return success with local data
        return Right(updatedModel.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to reschedule slot: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxEntity>> completeSlot({
    required String timeboxId,
    required String slotId,
  }) async {
    try {
      // Update local first
      final localTimebox =
          await localDataSource.getTimeboxByFirebaseId(timeboxId);
      if (localTimebox == null) {
        return const Left(
            CacheFailure(message: 'Timebox not found in local database'));
      }

      final currentModel = localDataSource.isarToModel(localTimebox);
      final updatedSlots = currentModel.slots.map((s) {
        if (s.id == slotId) {
          return s.copyWith(status: 'completed');
        }
        return s;
      }).toList();
      final updatedModel = currentModel.copyWith(slots: updatedSlots);

      final isarTimebox = localDataSource.modelToIsar(updatedModel);
      isarTimebox.isDirty = true;
      await localDataSource.updateTimebox(isarTimebox);

      // Try to sync to remote
      try {
        final remoteModel = await remoteDataSource.completeSlot(
          timeboxId: timeboxId,
          slotId: slotId,
        );

        // Update local with server data
        final syncedIsarTimebox = localDataSource.modelToIsar(remoteModel);
        await localDataSource.upsertTimebox(syncedIsarTimebox);
        await localDataSource.markAsSynced(remoteModel.id);

        return Right(remoteModel.toEntity());
      } on ServerException {
        // If remote fails, still return success with local data
        return Right(updatedModel.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to complete slot: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxEntity>> skipSlot({
    required String timeboxId,
    required String slotId,
  }) async {
    try {
      // Update local first
      final localTimebox =
          await localDataSource.getTimeboxByFirebaseId(timeboxId);
      if (localTimebox == null) {
        return const Left(
            CacheFailure(message: 'Timebox not found in local database'));
      }

      final currentModel = localDataSource.isarToModel(localTimebox);
      final updatedSlots = currentModel.slots.map((s) {
        if (s.id == slotId) {
          return s.copyWith(status: 'skipped');
        }
        return s;
      }).toList();
      final updatedModel = currentModel.copyWith(slots: updatedSlots);

      final isarTimebox = localDataSource.modelToIsar(updatedModel);
      isarTimebox.isDirty = true;
      await localDataSource.updateTimebox(isarTimebox);

      // Try to sync to remote
      try {
        final remoteModel = await remoteDataSource.skipSlot(
          timeboxId: timeboxId,
          slotId: slotId,
        );

        // Update local with server data
        final syncedIsarTimebox = localDataSource.modelToIsar(remoteModel);
        await localDataSource.upsertTimebox(syncedIsarTimebox);
        await localDataSource.markAsSynced(remoteModel.id);

        return Right(remoteModel.toEntity());
      } on ServerException {
        // If remote fails, still return success with local data
        return Right(updatedModel.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to skip slot: $e'));
    }
  }

  // ============================================================
  // CONFLICT DETECTION
  // ============================================================

  @override
  Future<Either<Failure, List<TimeConflict>>> detectConflicts({
    required String timeboxId,
  }) async {
    try {
      final timebox = await getTimeboxById(timeboxId);

      return timebox.fold(
        (failure) => Left(failure),
        (entity) {
          final conflicts = timeboxService.detectConflicts(
            slots: entity.slots,
            settings: entity.settings,
          );
          return Right(conflicts);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to detect conflicts: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TimeConflict>>> detectConflictsForSlot({
    required String timeboxId,
    required TimeboxSlot slot,
  }) async {
    try {
      final timebox = await getTimeboxById(timeboxId);

      return timebox.fold(
        (failure) => Left(failure),
        (entity) {
          final allSlots = [...entity.slots, slot];
          final conflicts = timeboxService.detectConflicts(
            slots: allSlots,
            settings: entity.settings,
          );

          // Filter to only conflicts involving the new slot
          final relevantConflicts = conflicts.where((c) =>
              c.slot1Id == slot.id || c.slot2Id == slot.id).toList();

          return Right(relevantConflicts);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to detect conflicts for slot: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxEntity>> resolveConflict({
    required String timeboxId,
    required String conflictId,
    required ConflictResolution resolution,
  }) async {
    try {
      final timebox = await getTimeboxById(timeboxId);

      return timebox.fold(
        (failure) => Left(failure),
        (entity) async {
          final conflict = entity.conflicts.firstWhere((c) => c.id == conflictId);

          // Apply resolution based on type
          TimeboxEntity updatedTimebox = entity;

          switch (resolution.type) {
            case ConflictResolutionType.removeFirst:
              updatedTimebox = TimeboxEntity(
                id: entity.id,
                userId: entity.userId,
                date: entity.date,
                slots: entity.slots.where((s) => s.id != conflict.slot1Id).toList(),
                conflicts: entity.conflicts.where((c) => c.id != conflictId).toList(),
                summary: entity.summary,
                settings: entity.settings,
                createdAt: entity.createdAt,
                updatedAt: DateTime.now(),
              );
              break;

            case ConflictResolutionType.removeSecond:
              if (conflict.slot2Id != null) {
                updatedTimebox = TimeboxEntity(
                  id: entity.id,
                  userId: entity.userId,
                  date: entity.date,
                  slots: entity.slots.where((s) => s.id != conflict.slot2Id).toList(),
                  conflicts: entity.conflicts.where((c) => c.id != conflictId).toList(),
                  summary: entity.summary,
                  settings: entity.settings,
                  createdAt: entity.createdAt,
                  updatedAt: DateTime.now(),
                );
              }
              break;

            case ConflictResolutionType.manual:
              if (resolution.movedSlotId != null &&
                  resolution.newStartTime != null &&
                  resolution.newEndTime != null) {
                final updatedSlots = entity.slots.map((s) {
                  if (s.id == resolution.movedSlotId) {
                    return TimeboxSlot(
                      id: s.id,
                      taskId: s.taskId,
                      taskTitle: s.taskTitle,
                      taskDescription: s.taskDescription,
                      startTime: resolution.newStartTime!,
                      endTime: resolution.newEndTime!,
                      category: s.category,
                      priority: s.priority,
                      status: s.status,
                      listId: s.listId,
                      listName: s.listName,
                      listColor: s.listColor,
                      tags: s.tags,
                      isRecurring: s.isRecurring,
                      isAllDay: s.isAllDay,
                      notes: s.notes,
                    );
                  }
                  return s;
                }).toList();

                updatedTimebox = TimeboxEntity(
                  id: entity.id,
                  userId: entity.userId,
                  date: entity.date,
                  slots: updatedSlots,
                  conflicts: entity.conflicts.where((c) => c.id != conflictId).toList(),
                  summary: entity.summary,
                  settings: entity.settings,
                  createdAt: entity.createdAt,
                  updatedAt: DateTime.now(),
                );
              }
              break;

            case ConflictResolutionType.ignore:
              updatedTimebox = TimeboxEntity(
                id: entity.id,
                userId: entity.userId,
                date: entity.date,
                slots: entity.slots,
                conflicts: entity.conflicts.where((c) => c.id != conflictId).toList(),
                summary: entity.summary,
                settings: entity.settings,
                createdAt: entity.createdAt,
                updatedAt: DateTime.now(),
              );
              break;

            default:
              return Left(
                  const ValidationFailure(message: 'Unsupported resolution type'));
          }

          return await updateTimebox(updatedTimebox);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to resolve conflict: $e'));
    }
  }

  // ============================================================
  // TASK SCHEDULING
  // ============================================================

  @override
  Future<Either<Failure, TimeboxEntity>> scheduleTask({
    required String timeboxId,
    required TaskEntity task,
    required DateTime startTime,
    required DateTime endTime,
    required TaskCategory category,
  }) async {
    try {
      final slot = TimeboxSlot(
        id: uuid.v4(),
        taskId: task.id,
        taskTitle: task.title,
        taskDescription: task.description,
        startTime: startTime,
        endTime: endTime,
        category: category,
        priority: task.priority,
        status: TimeboxSlotStatus.scheduled,
        listId: task.listId,
        tags: task.tags,
        isRecurring: task.recurrenceRule != null,
        isAllDay: false,
      );

      return await addSlot(timeboxId: timeboxId, slot: slot);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to schedule task: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxEntity>> autoScheduleTasks({
    required String userId,
    required DateTime date,
    required List<TaskEntity> tasks,
    TimeboxSettings? settings,
  }) async {
    try {
      // Get or create timebox for date
      final timeboxResult = await getTimeboxForDate(
        userId: userId,
        date: date,
      );

      return await timeboxResult.fold(
        (failure) async => Left(failure),
        (timebox) async {
          final effectiveSettings = settings ?? timebox.settings;

          // Use timebox service to auto-schedule
          final scheduledSlots = timeboxService.autoScheduleTasks(
            tasks: tasks,
            existingSlots: timebox.slots,
            date: date,
            settings: effectiveSettings,
          );

          // Update timebox with new slots
          final updatedTimebox = TimeboxEntity(
            id: timebox.id,
            userId: timebox.userId,
            date: timebox.date,
            slots: [...timebox.slots, ...scheduledSlots],
            conflicts: timebox.conflicts,
            summary: timebox.summary,
            settings: timebox.settings,
            createdAt: timebox.createdAt,
            updatedAt: DateTime.now(),
          );

          return await updateTimebox(updatedTimebox);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to auto-schedule tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, AvailableSlot?>> getSuggestedSlot({
    required String timeboxId,
    required int durationMinutes,
    TaskPriority? priority,
  }) async {
    try {
      final timebox = await getTimeboxById(timeboxId);

      return timebox.fold(
        (failure) => Left(failure),
        (entity) {
          final suggestion = timeboxService.suggestTimeSlot(
            existingSlots: entity.slots,
            durationMinutes: durationMinutes,
            priority: priority,
            date: entity.date,
            settings: entity.settings,
          );

          return Right(suggestion);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get suggested slot: $e'));
    }
  }

  // ============================================================
  // QUERIES
  // ============================================================

  @override
  Future<Either<Failure, List<TimeboxEntity>>> getTimeboxesForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Try local first
      final localTimeboxes = await localDataSource.getTimeboxesForDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (localTimeboxes.isNotEmpty) {
        return Right(localTimeboxes.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getTimeboxesForDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Save to local
      for (final model in remoteModels) {
        final isarTimebox = localDataSource.modelToIsar(model);
        await localDataSource.upsertTimebox(isarTimebox);
        await localDataSource.markAsSynced(model.id);
      }

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get timeboxes for date range: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxSummary>> getSummaryForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final timeboxesResult = await getTimeboxesForDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return timeboxesResult.fold(
        (failure) => Left(failure),
        (timeboxes) {
          // Aggregate summaries
          int totalTasks = 0;
          int completedTasks = 0;
          int pendingTasks = 0;
          int skippedTasks = 0;
          double totalScheduledHours = 0.0;
          int personalTasks = 0;
          int professionalTasks = 0;
          int healthTasks = 0;
          int learningTasks = 0;
          int errandsTasks = 0;
          int socialTasks = 0;
          int otherTasks = 0;
          int highPriorityTasks = 0;
          int criticalPriorityTasks = 0;
          int conflictCount = 0;

          for (final timebox in timeboxes) {
            totalTasks += timebox.summary.totalTasks;
            completedTasks += timebox.summary.completedTasks;
            pendingTasks += timebox.summary.pendingTasks;
            skippedTasks += timebox.summary.skippedTasks;
            totalScheduledHours += timebox.summary.totalScheduledHours;
            personalTasks += timebox.summary.personalTasks;
            professionalTasks += timebox.summary.professionalTasks;
            healthTasks += timebox.summary.healthTasks;
            learningTasks += timebox.summary.learningTasks;
            errandsTasks += timebox.summary.errandsTasks;
            socialTasks += timebox.summary.socialTasks;
            otherTasks += timebox.summary.otherTasks;
            highPriorityTasks += timebox.summary.highPriorityTasks;
            criticalPriorityTasks += timebox.summary.criticalPriorityTasks;
            conflictCount += timebox.summary.conflictCount;
          }

          final summary = TimeboxSummary(
            totalTasks: totalTasks,
            completedTasks: completedTasks,
            pendingTasks: pendingTasks,
            skippedTasks: skippedTasks,
            totalScheduledHours: totalScheduledHours,
            personalTasks: personalTasks,
            professionalTasks: professionalTasks,
            healthTasks: healthTasks,
            learningTasks: learningTasks,
            errandsTasks: errandsTasks,
            socialTasks: socialTasks,
            otherTasks: otherTasks,
            highPriorityTasks: highPriorityTasks,
            criticalPriorityTasks: criticalPriorityTasks,
            conflictCount: conflictCount,
            completionRate:
                totalTasks > 0 ? completedTasks / totalTasks : 0.0,
            utilizationRate: 0.0, // Would need to calculate based on available hours
          );

          return Right(summary);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get summary for date range: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TimeboxSlot>>> getTodayPrioritySlots({
    required String userId,
  }) async {
    try {
      final todayResult = await getTimeboxForDate(
        userId: userId,
        date: DateTime.now(),
      );

      return todayResult.fold(
        (failure) => Left(failure),
        (timebox) {
          final prioritySlots = timebox.prioritySlots;
          return Right(prioritySlots);
        },
      );
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get today priority slots: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TimeboxSlot>>> getUpcomingSlots({
    required String userId,
    required int limit,
  }) async {
    try {
      final now = DateTime.now();
      final upcomingSlotsResult = await getTimeboxesForDateRange(
        userId: userId,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
      );

      return upcomingSlotsResult.fold(
        (failure) => Left(failure),
        (timeboxes) {
          final allSlots = <TimeboxSlot>[];
          for (final timebox in timeboxes) {
            allSlots.addAll(timebox.slots);
          }

          // Filter upcoming slots and sort by start time
          final upcoming = allSlots
              .where((slot) =>
                  slot.startTime.isAfter(now) &&
                  slot.status == TimeboxSlotStatus.scheduled)
              .toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

          return Right(upcoming.take(limit).toList());
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get upcoming slots: $e'));
    }
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  @override
  Future<Either<Failure, TimeboxSettings>> getSettings(String userId) async {
    try {
      // Get today's timebox to retrieve settings
      final todayResult = await getTimeboxForDate(
        userId: userId,
        date: DateTime.now(),
      );

      return todayResult.fold(
        (failure) => Left(failure),
        (timebox) => Right(timebox.settings),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get settings: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeboxSettings>> updateSettings({
    required String userId,
    required TimeboxSettings settings,
  }) async {
    try {
      // Update settings for all timeboxes of the user
      final allTimeboxes = await localDataSource.getAllTimeboxes(userId);

      for (final timebox in allTimeboxes) {
        final model = localDataSource.isarToModel(timebox);
        final updatedModel = model.copyWith(
          settings: TimeboxSettingsModel.fromEntity(settings),
        );

        final isarTimebox = localDataSource.modelToIsar(updatedModel);
        isarTimebox.isDirty = true;
        await localDataSource.updateTimebox(isarTimebox);
      }

      return Right(settings);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update settings: $e'));
    }
  }

  // ============================================================
  // SYNC & REAL-TIME
  // ============================================================

  @override
  Stream<Either<Failure, TimeboxEntity>> watchTimebox(String timeboxId) {
    try {
      return localDataSource.watchTimebox(timeboxId).map((timeboxIsar) {
        if (timeboxIsar == null) {
          return const Left(
              CacheFailure(message: 'Timebox not found in local database'));
        }
        return Right(_isarToEntity(timeboxIsar));
      }).handleError((error) {
        return Left(CacheFailure(message: 'Failed to watch timebox: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch timebox: $e')));
    }
  }

  @override
  Stream<Either<Failure, TimeboxEntity>> watchTodayTimebox(String userId) {
    try {
      final today = DateTime.now();
      final normalizedDate = DateTime(today.year, today.month, today.day);

      return localDataSource
          .watchTimeboxForDate(userId: userId, date: normalizedDate)
          .map((timeboxIsar) {
        if (timeboxIsar == null) {
          // Create a new timebox if none exists
          final newTimebox = _createDefaultTimebox(userId, normalizedDate);
          return Right(newTimebox);
        }
        return Right(_isarToEntity(timeboxIsar));
      }).handleError((error) {
        return Left(
            CacheFailure(message: 'Failed to watch today timebox: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch today timebox: $e')));
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Convert TimeboxIsar to TimeboxEntity
  TimeboxEntity _isarToEntity(TimeboxIsar isar) {
    final model = localDataSource.isarToModel(isar);
    return model.toEntity();
  }

  /// Create a default timebox for a specific date
  TimeboxEntity _createDefaultTimebox(String userId, DateTime date) {
    return TimeboxEntity(
      id: uuid.v4(),
      userId: userId,
      date: date,
      slots: const [],
      conflicts: const [],
      summary: const TimeboxSummary(
        totalTasks: 0,
        completedTasks: 0,
        pendingTasks: 0,
        skippedTasks: 0,
        totalScheduledHours: 0.0,
        personalTasks: 0,
        professionalTasks: 0,
        healthTasks: 0,
        learningTasks: 0,
        errandsTasks: 0,
        socialTasks: 0,
        otherTasks: 0,
        highPriorityTasks: 0,
        criticalPriorityTasks: 0,
        conflictCount: 0,
        completionRate: 0.0,
        utilizationRate: 0.0,
      ),
      settings: const TimeboxSettings(
        dayStartHour: 8,
        dayEndHour: 20,
        workStartHour: 9,
        workEndHour: 17,
        peakHoursStart: 10,
        peakHoursEnd: 12,
        bufferMinutes: 15,
        allowConflicts: false,
        autoDetectConflicts: true,
        showSkippedTasks: false,
        groupByCategory: true,
        highlightPriorityTasks: true,
        defaultCategory: TaskCategory.personal,
        themeColor: '#2196F3',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
