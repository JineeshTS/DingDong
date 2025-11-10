import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/local/isar/isar_habit_local_data_source.dart';
import '../datasources/local/isar/schemas/habit_isar.dart';
import '../datasources/remote/firebase_habit_remote_data_source.dart';
import '../models/habit_model.dart';

/// Habit repository implementation with offline-first architecture
class HabitRepositoryImpl implements HabitRepository {
  final FirebaseHabitRemoteDataSource remoteDataSource;
  final IsarHabitLocalDataSource localDataSource;

  HabitRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, HabitEntity>> createHabit(HabitEntity habit) async {
    try {
      final model = HabitModel.fromEntity(habit);

      // Save to local first
      final isarHabit = _modelToIsar(model);
      isarHabit.isDirty = true;
      await localDataSource.upsertHabit(isarHabit);

      // Try to sync to remote
      try {
        final createdModel = await remoteDataSource.createHabit(model);

        // Update local with server data
        final syncedIsarHabit = _modelToIsar(createdModel);
        await localDataSource.upsertHabit(syncedIsarHabit);
        await localDataSource.markAsSynced(createdModel.id);

        return Right(createdModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(habit);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create habit: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> getHabit(String id) async {
    try {
      // Try local first
      final localHabit = await localDataSource.getHabitByFirebaseId(id);

      if (localHabit != null) {
        return Right(_isarToEntity(localHabit));
      }

      // Fetch from remote
      final remoteModel = await remoteDataSource.getHabit(id);

      // Save to local
      final isarHabit = _modelToIsar(remoteModel);
      await localDataSource.upsertHabit(isarHabit);
      await localDataSource.markAsSynced(id);

      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get habit: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HabitEntity>>> getHabits({
    required String userId,
    HabitCategory? category,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      // Try local first
      final localHabits = await localDataSource.getHabitsByUser(
        userId: userId,
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );

      if (localHabits.isNotEmpty) {
        final filtered = category != null
            ? localHabits
                .where((h) => h.category == _categoryToString(category))
                .toList()
            : localHabits;
        return Right(filtered.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getHabits(
        userId: userId,
        category: category != null ? _categoryToString(category) : null,
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );

      // Save to local
      final isarHabits = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertHabits(isarHabits);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      // Return local data if remote fails
      try {
        final localHabits = await localDataSource.getHabitsByUser(
          userId: userId,
          includeArchived: includeArchived,
          includeDeleted: includeDeleted,
        );

        if (localHabits.isNotEmpty) {
          final filtered = category != null
              ? localHabits
                  .where((h) => h.category == _categoryToString(category))
                  .toList()
              : localHabits;
          return Right(filtered.map(_isarToEntity).toList());
        }
      } catch (_) {}

      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get habits: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HabitEntity>>> getHabitsByCategory({
    required String userId,
    required HabitCategory category,
  }) async {
    try {
      // Try local first
      final localHabits = await localDataSource.getHabitsByCategory(
        userId: userId,
        category: _categoryToString(category),
      );

      if (localHabits.isNotEmpty) {
        return Right(localHabits.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getHabitsByCategory(
        userId: userId,
        category: _categoryToString(category),
      );

      // Save to local
      final isarHabits = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertHabits(isarHabits);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get habits by category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HabitEntity>>> getActiveHabits(
      String userId) async {
    try {
      // Get from local (fast)
      final localHabits = await localDataSource.getActiveHabits(
        userId: userId,
      );

      return Right(localHabits.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get active habits: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> updateHabit(HabitEntity habit) async {
    try {
      final model = HabitModel.fromEntity(habit);

      // Save to local first
      final isarHabit = _modelToIsar(model);
      isarHabit.isDirty = true;
      await localDataSource.upsertHabit(isarHabit);

      // Try to sync to remote
      try {
        final updatedModel = await remoteDataSource.updateHabit(model);

        // Update local with synced data
        final syncedIsarHabit = _modelToIsar(updatedModel);
        await localDataSource.upsertHabit(syncedIsarHabit);
        await localDataSource.markAsSynced(habit.id);

        return Right(updatedModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(habit);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update habit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String id) async {
    try {
      // Mark as deleted locally
      await localDataSource.deleteHabit(id);

      // Try to delete from remote
      try {
        await remoteDataSource.deleteHabit(id);
        await localDataSource.markAsSynced(id);
      } on ServerException {
        // If remote fails, mark as dirty for later sync
        await localDataSource.markAsDirty(id);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete habit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteHabit(String id) async {
    try {
      await remoteDataSource.permanentlyDeleteHabit(id);
      await localDataSource.permanentlyDeleteHabit(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to permanently delete habit: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> restoreHabit(String id) async {
    try {
      final model = await remoteDataSource.restoreHabit(id);

      // Update local
      final isarHabit = _modelToIsar(model);
      await localDataSource.upsertHabit(isarHabit);
      await localDataSource.markAsSynced(id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to restore habit: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> archiveHabit(String id) async {
    try {
      // Archive locally first (instant UI feedback)
      await localDataSource.archiveHabit(id);

      // Sync to remote in background
      remoteDataSource.archiveHabit(id).then((model) {
        final isarHabit = _modelToIsar(model);
        localDataSource.upsertHabit(isarHabit);
        localDataSource.markAsSynced(id);
      }).catchError((_) {
        localDataSource.markAsDirty(id);
      });

      final localHabit = await localDataSource.getHabitByFirebaseId(id);
      return Right(_isarToEntity(localHabit!));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to archive habit: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> unarchiveHabit(String id) async {
    try {
      // Unarchive locally first (instant UI feedback)
      await localDataSource.unarchiveHabit(id);

      // Sync to remote in background
      remoteDataSource.unarchiveHabit(id).then((model) {
        final isarHabit = _modelToIsar(model);
        localDataSource.upsertHabit(isarHabit);
        localDataSource.markAsSynced(id);
      }).catchError((_) {
        localDataSource.markAsDirty(id);
      });

      final localHabit = await localDataSource.getHabitByFirebaseId(id);
      return Right(_isarToEntity(localHabit!));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to unarchive habit: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> checkInHabit({
    required String habitId,
    DateTime? date,
    String? note,
    int count = 1,
  }) async {
    try {
      final model = await remoteDataSource.checkInHabit(
        habitId: habitId,
        date: date,
        note: note,
        count: count,
      );

      // Update local with new check-in and updated streak
      final isarHabit = _modelToIsar(model);
      await localDataSource.upsertHabit(isarHabit);
      await localDataSource.updateStreak(
        habitId: habitId,
        currentStreak: model.currentStreak,
        bestStreak: model.longestStreak,
      );
      await localDataSource.updateLastCheckIn(
        habitId: habitId,
        lastCheckIn: model.lastCheckInDate ?? DateTime.now(),
      );
      await localDataSource.markAsSynced(habitId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to check in habit: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> undoCheckIn({
    required String habitId,
    required String checkInId,
  }) async {
    try {
      final model = await remoteDataSource.undoCheckIn(
        habitId: habitId,
        checkInId: checkInId,
      );

      // Update local
      final isarHabit = _modelToIsar(model);
      await localDataSource.upsertHabit(isarHabit);
      await localDataSource.updateStreak(
        habitId: habitId,
        currentStreak: model.currentStreak,
        bestStreak: model.longestStreak,
      );
      await localDataSource.markAsSynced(habitId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to undo check-in: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HabitEntity>>> getHabitsDueToday(
      String userId) async {
    try {
      // Get from remote (requires business logic)
      final remoteModels = await remoteDataSource.getHabitsDueToday(userId);

      // Save to local
      final isarHabits = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertHabits(isarHabits);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get habits due today: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HabitCheckIn>>> getCheckInHistory({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final history = await remoteDataSource.getCheckInHistory(
        habitId: habitId,
        startDate: startDate,
        endDate: endDate,
      );

      // Convert to check-in entities
      final checkIns = history
          .map((data) => HabitCheckInModel.fromJson(data).toEntity())
          .toList();

      return Right(checkIns);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get check-in history: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> calculateStreak(String habitId) async {
    try {
      final streak = await remoteDataSource.calculateStreak(habitId);

      // Update local cache
      final localHabit = await localDataSource.getHabitByFirebaseId(habitId);
      if (localHabit != null) {
        await localDataSource.updateStreak(
          habitId: habitId,
          currentStreak: streak,
        );
      }

      return Right(streak);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to calculate streak: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getHabitStatistics({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await remoteDataSource.getHabitStatistics(
        habitId: habitId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get habit statistics: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserHabitStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await remoteDataSource.getUserHabitStatistics(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get user habit statistics: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getCompletionRate({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final rate = await remoteDataSource.getCompletionRate(
        habitId: habitId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(rate);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get completion rate: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getBestStreak(String habitId) async {
    try {
      final bestStreak = await remoteDataSource.getBestStreak(habitId);

      // Update local cache
      final localHabit = await localDataSource.getHabitByFirebaseId(habitId);
      if (localHabit != null) {
        await localDataSource.updateStreak(
          habitId: habitId,
          currentStreak: localHabit.currentStreak,
          bestStreak: bestStreak,
        );
      }

      return Right(bestStreak);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get best streak: $e'));
    }
  }

  @override
  Stream<Either<Failure, HabitEntity>> watchHabit(String id) {
    try {
      return localDataSource.watchHabit(id).map((habitIsar) {
        if (habitIsar == null) {
          return Left(
              CacheFailure(message: 'Habit not found in local database'));
        }
        return Right(_isarToEntity(habitIsar));
      }).handleError((error) {
        return Left(CacheFailure(message: 'Failed to watch habit: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch habit: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<HabitEntity>>> watchHabits({
    required String userId,
    HabitCategory? category,
  }) {
    try {
      return localDataSource.watchHabits(userId: userId).map((habitsIsar) {
        final filtered = category != null
            ? habitsIsar
                .where((h) => h.category == _categoryToString(category))
                .toList()
            : habitsIsar;
        return Right(filtered.map(_isarToEntity).toList());
      }).handleError((error) {
        return Left(CacheFailure(message: 'Failed to watch habits: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch habits: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<HabitEntity>>> watchHabitsDueToday(
      String userId) {
    try {
      return localDataSource
          .watchActiveHabits(userId: userId)
          .map((habitsIsar) {
        // Filter for habits due today (client-side filtering)
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final dueToday = habitsIsar.where((habit) {
          // Check if last check-in was before today
          if (habit.lastCheckIn == null) return true;

          final lastCheckIn = DateTime(
            habit.lastCheckIn!.year,
            habit.lastCheckIn!.month,
            habit.lastCheckIn!.day,
          );

          return lastCheckIn.isBefore(today);
        }).toList();

        return Right(dueToday.map(_isarToEntity).toList());
      }).handleError((error) {
        return Left(
            CacheFailure(message: 'Failed to watch habits due today: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch habits due today: $e')));
    }
  }

  // ==================== CONVERTERS ====================

  /// Convert HabitModel to HabitIsar
  HabitIsar _modelToIsar(HabitModel model) {
    return HabitIsar()
      ..habitId = model.id
      ..userId = model.userId
      ..name = model.name
      ..description = model.description
      ..icon = model.icon
      ..color = model.color
      ..category = model.category
      ..frequencyType = _frequencyToIsar(model.frequency)
      ..frequencyJson = jsonEncode({
        'targetCount': model.targetCount,
        'targetDaysOfWeek': model.targetDaysOfWeek,
        'targetTime': model.targetTime?.toIso8601String(),
      })
      ..targetCount = model.targetCount
      ..currentStreak = model.currentStreak
      ..bestStreak = model.longestStreak
      ..checkInsJson = jsonEncode(model.checkIns.map((c) => {
            'id': c.id,
            'checkInDate': c.checkInDate.toIso8601String(),
            'note': c.note,
            'count': c.count,
          }).toList())
      ..lastCheckIn = model.lastCheckInDate
      ..isArchived = model.isArchived
      ..isDeleted = model.isDeleted
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt;
  }

  /// Convert HabitIsar to HabitEntity
  HabitEntity _isarToEntity(HabitIsar isar) {
    // Parse frequency data
    final frequencyData = isar.frequencyJson != null
        ? jsonDecode(isar.frequencyJson!) as Map<String, dynamic>
        : <String, dynamic>{};

    // Parse check-ins
    final checkIns = isar.checkInsJson != null
        ? (jsonDecode(isar.checkInsJson!) as List)
            .map((data) => HabitCheckIn(
                  id: data['id'] as String,
                  checkInDate: DateTime.parse(data['checkInDate'] as String),
                  note: data['note'] as String?,
                  count: data['count'] as int? ?? 1,
                ))
            .toList()
        : <HabitCheckIn>[];

    return HabitEntity(
      id: isar.habitId,
      userId: isar.userId,
      name: isar.name,
      description: isar.description,
      icon: isar.icon,
      color: isar.color,
      category: _categoryFromString(isar.category ?? 'custom'),
      frequency: _frequencyFromIsar(isar.frequencyType),
      targetCount: frequencyData['targetCount'] as int? ?? isar.targetCount,
      targetDaysOfWeek: (frequencyData['targetDaysOfWeek'] as List?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      targetTime: frequencyData['targetTime'] != null
          ? DateTime.parse(frequencyData['targetTime'] as String)
          : null,
      checkIns: checkIns,
      currentStreak: isar.currentStreak,
      longestStreak: isar.bestStreak,
      lastCheckInDate: isar.lastCheckIn,
      isArchived: isar.isArchived,
      isDeleted: isar.isDeleted,
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
      settings: null,
    );
  }

  /// Convert HabitCategory to string
  String _categoryToString(HabitCategory category) {
    return category.toString().split('.').last;
  }

  /// Convert string to HabitCategory
  HabitCategory _categoryFromString(String category) {
    switch (category) {
      case 'healthFitness':
        return HabitCategory.healthFitness;
      case 'personalDevelopment':
        return HabitCategory.personalDevelopment;
      case 'workProductivity':
        return HabitCategory.workProductivity;
      case 'financeSavings':
        return HabitCategory.financeSavings;
      case 'socialRelationships':
        return HabitCategory.socialRelationships;
      case 'mindfulnessMentalHealth':
        return HabitCategory.mindfulnessMentalHealth;
      case 'hobbiesInterests':
        return HabitCategory.hobbiesInterests;
      case 'custom':
        return HabitCategory.custom;
      default:
        return HabitCategory.custom;
    }
  }

  /// Convert HabitFrequency to HabitFrequencyTypeIsar
  HabitFrequencyTypeIsar _frequencyToIsar(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return HabitFrequencyTypeIsar.daily;
      case HabitFrequency.weekly:
        return HabitFrequencyTypeIsar.weekly;
      case HabitFrequency.monthly:
        return HabitFrequencyTypeIsar.monthly;
      case HabitFrequency.custom:
        return HabitFrequencyTypeIsar.custom;
    }
  }

  /// Convert HabitFrequencyTypeIsar to HabitFrequency
  HabitFrequency _frequencyFromIsar(HabitFrequencyTypeIsar frequency) {
    switch (frequency) {
      case HabitFrequencyTypeIsar.daily:
        return HabitFrequency.daily;
      case HabitFrequencyTypeIsar.weekly:
        return HabitFrequency.weekly;
      case HabitFrequencyTypeIsar.monthly:
        return HabitFrequency.monthly;
      case HabitFrequencyTypeIsar.custom:
        return HabitFrequency.custom;
    }
  }
}
