import 'package:isar/isar.dart';
import '../../../core/errors/exceptions.dart';
import 'schemas/habit_isar.dart';

/// Isar local data source for Habit operations (offline storage)
abstract class IsarHabitLocalDataSource {
  /// Initialize Isar database
  Future<void> initialize();

  /// Insert or update habit
  Future<HabitIsar> upsertHabit(HabitIsar habit);

  /// Get habit by Firebase ID
  Future<HabitIsar?> getHabitByFirebaseId(String habitId);

  /// Get habits by user ID
  Future<List<HabitIsar>> getHabitsByUser({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get habits by category
  Future<List<HabitIsar>> getHabitsByCategory({
    required String userId,
    required String category,
    bool includeArchived = false,
  });

  /// Get active habits
  Future<List<HabitIsar>> getActiveHabits({
    required String userId,
  });

  /// Get archived habits
  Future<List<HabitIsar>> getArchivedHabits({
    required String userId,
  });

  /// Get habits sorted by current streak
  Future<List<HabitIsar>> getHabitsByStreak({
    required String userId,
    bool includeArchived = false,
  });

  /// Get habits with active streaks
  Future<List<HabitIsar>> getHabitsWithActiveStreaks({
    required String userId,
  });

  /// Update habit
  Future<HabitIsar> updateHabit(HabitIsar habit);

  /// Delete habit (soft delete)
  Future<void> deleteHabit(String habitId);

  /// Permanently delete habit
  Future<void> permanentlyDeleteHabit(String habitId);

  /// Archive habit
  Future<void> archiveHabit(String habitId);

  /// Unarchive habit
  Future<void> unarchiveHabit(String habitId);

  /// Update streak
  Future<void> updateStreak({
    required String habitId,
    required int currentStreak,
    int? bestStreak,
  });

  /// Update last check-in
  Future<void> updateLastCheckIn({
    required String habitId,
    required DateTime lastCheckIn,
  });

  /// Batch insert habits
  Future<void> batchInsertHabits(List<HabitIsar> habits);

  /// Get dirty habits (need sync)
  Future<List<HabitIsar>> getDirtyHabits();

  /// Mark habit as synced
  Future<void> markAsSynced(String habitId);

  /// Mark habit as dirty (needs sync)
  Future<void> markAsDirty(String habitId);

  /// Clear habits for user
  Future<void> clearHabitsForUser(String userId);

  /// Get habit count for user
  Future<int> getHabitCountForUser(String userId);

  /// Get active habit count for user
  Future<int> getActiveHabitCountForUser(String userId);

  /// Watch habit changes (stream)
  Stream<HabitIsar?> watchHabit(String habitId);

  /// Watch habits for user (stream)
  Stream<List<HabitIsar>> watchHabitsForUser({
    required String userId,
  });

  /// Watch active habits (stream)
  Stream<List<HabitIsar>> watchActiveHabits({
    required String userId,
  });
}

/// Isar implementation of habit local data source
class IsarHabitLocalDataSourceImpl implements IsarHabitLocalDataSource {
  Isar? _isar;

  IsarHabitLocalDataSourceImpl();

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    try {
      _isar = await Isar.open([
        HabitIsarSchema,
      ], directory: await _getIsarPath());
    } catch (e) {
      throw CacheException(
        message: 'Failed to initialize Isar database',
        originalException: e,
      );
    }
  }

  Future<String> _getIsarPath() async {
    // In production, use path_provider to get app directory
    // For now, return current directory
    return '.';
  }

  Isar get _db {
    if (_isar == null) {
      throw const CacheException(
        message: 'Isar database not initialized. Call initialize() first.',
      );
    }
    return _isar!;
  }

  @override
  Future<HabitIsar> upsertHabit(HabitIsar habit) async {
    try {
      await _db.writeTxn(() async {
        await _db.habitIsars.put(habit);
      });

      // Return the inserted/updated habit
      final savedHabit = await getHabitByFirebaseId(habit.habitId);
      if (savedHabit == null) {
        throw const CacheException(
          message: 'Failed to save habit to local database',
        );
      }

      return savedHabit;
    } catch (e) {
      throw CacheException(
        message: 'Failed to upsert habit',
        originalException: e,
      );
    }
  }

  @override
  Future<HabitIsar?> getHabitByFirebaseId(String habitId) async {
    try {
      final habit = await _db.habitIsars
          .filter()
          .habitIdEqualTo(habitId)
          .findFirst();

      return habit;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get habit by Firebase ID',
        originalException: e,
      );
    }
  }

  @override
  Future<List<HabitIsar>> getHabitsByUser({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.habitIsars
          .filter()
          .userIdEqualTo(userId);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final habits = await query
          .sortByCreatedAt()
          .findAll();

      return habits;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get habits by user',
        originalException: e,
      );
    }
  }

  @override
  Future<List<HabitIsar>> getHabitsByCategory({
    required String userId,
    required String category,
    bool includeArchived = false,
  }) async {
    try {
      var query = _db.habitIsars
          .filter()
          .userIdEqualTo(userId)
          .categoryEqualTo(category)
          .isDeletedEqualTo(false);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      final habits = await query
          .sortByCreatedAt()
          .findAll();

      return habits;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get habits by category',
        originalException: e,
      );
    }
  }

  @override
  Future<List<HabitIsar>> getActiveHabits({
    required String userId,
  }) async {
    try {
      final habits = await _db.habitIsars
          .filter()
          .userIdEqualTo(userId)
          .isArchivedEqualTo(false)
          .isDeletedEqualTo(false)
          .sortByCreatedAt()
          .findAll();

      return habits;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get active habits',
        originalException: e,
      );
    }
  }

  @override
  Future<List<HabitIsar>> getArchivedHabits({
    required String userId,
  }) async {
    try {
      final habits = await _db.habitIsars
          .filter()
          .userIdEqualTo(userId)
          .isArchivedEqualTo(true)
          .isDeletedEqualTo(false)
          .sortByArchivedAt()
          .findAll();

      return habits;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get archived habits',
        originalException: e,
      );
    }
  }

  @override
  Future<List<HabitIsar>> getHabitsByStreak({
    required String userId,
    bool includeArchived = false,
  }) async {
    try {
      var query = _db.habitIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      final habits = await query
          .sortByCurrentStreakDesc()
          .findAll();

      return habits;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get habits by streak',
        originalException: e,
      );
    }
  }

  @override
  Future<List<HabitIsar>> getHabitsWithActiveStreaks({
    required String userId,
  }) async {
    try {
      final habits = await _db.habitIsars
          .filter()
          .userIdEqualTo(userId)
          .isArchivedEqualTo(false)
          .isDeletedEqualTo(false)
          .currentStreakGreaterThan(0)
          .sortByCurrentStreakDesc()
          .findAll();

      return habits;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get habits with active streaks',
        originalException: e,
      );
    }
  }

  @override
  Future<HabitIsar> updateHabit(HabitIsar habit) async {
    try {
      final existingHabit = await getHabitByFirebaseId(habit.habitId);
      if (existingHabit == null) {
        throw const CacheException(
          message: 'Habit not found in local database',
        );
      }

      // Update timestamp
      habit.updatedAt = DateTime.now();
      habit.isDirty = true;

      return await upsertHabit(habit);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update habit',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      final habit = await getHabitByFirebaseId(habitId);
      if (habit == null) return;

      habit.isDeleted = true;
      habit.deletedAt = DateTime.now();
      habit.updatedAt = DateTime.now();
      habit.isDirty = true;

      await _db.writeTxn(() async {
        await _db.habitIsars.put(habit);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete habit',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteHabit(String habitId) async {
    try {
      final habit = await getHabitByFirebaseId(habitId);
      if (habit == null) return;

      await _db.writeTxn(() async {
        await _db.habitIsars.delete(habit.id);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to permanently delete habit',
        originalException: e,
      );
    }
  }

  @override
  Future<void> archiveHabit(String habitId) async {
    try {
      final habit = await getHabitByFirebaseId(habitId);
      if (habit == null) return;

      habit.isArchived = true;
      habit.archivedAt = DateTime.now();
      habit.updatedAt = DateTime.now();
      habit.isDirty = true;

      await _db.writeTxn(() async {
        await _db.habitIsars.put(habit);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to archive habit',
        originalException: e,
      );
    }
  }

  @override
  Future<void> unarchiveHabit(String habitId) async {
    try {
      final habit = await getHabitByFirebaseId(habitId);
      if (habit == null) return;

      habit.isArchived = false;
      habit.archivedAt = null;
      habit.updatedAt = DateTime.now();
      habit.isDirty = true;

      await _db.writeTxn(() async {
        await _db.habitIsars.put(habit);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to unarchive habit',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateStreak({
    required String habitId,
    required int currentStreak,
    int? bestStreak,
  }) async {
    try {
      final habit = await getHabitByFirebaseId(habitId);
      if (habit == null) return;

      habit.currentStreak = currentStreak;
      if (bestStreak != null) {
        habit.bestStreak = bestStreak;
      }
      habit.updatedAt = DateTime.now();
      habit.isDirty = true;

      await _db.writeTxn(() async {
        await _db.habitIsars.put(habit);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to update streak',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateLastCheckIn({
    required String habitId,
    required DateTime lastCheckIn,
  }) async {
    try {
      final habit = await getHabitByFirebaseId(habitId);
      if (habit == null) return;

      habit.lastCheckIn = lastCheckIn;
      habit.updatedAt = DateTime.now();
      habit.isDirty = true;

      await _db.writeTxn(() async {
        await _db.habitIsars.put(habit);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to update last check-in',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchInsertHabits(List<HabitIsar> habits) async {
    try {
      await _db.writeTxn(() async {
        await _db.habitIsars.putAll(habits);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to batch insert habits',
        originalException: e,
      );
    }
  }

  @override
  Future<List<HabitIsar>> getDirtyHabits() async {
    try {
      final habits = await _db.habitIsars
          .filter()
          .isDirtyEqualTo(true)
          .findAll();

      return habits;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get dirty habits',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String habitId) async {
    try {
      final habit = await getHabitByFirebaseId(habitId);
      if (habit == null) return;

      habit.isDirty = false;
      habit.lastSyncAt = DateTime.now();

      await _db.writeTxn(() async {
        await _db.habitIsars.put(habit);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark habit as synced',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDirty(String habitId) async {
    try {
      final habit = await getHabitByFirebaseId(habitId);
      if (habit == null) return;

      habit.isDirty = true;

      await _db.writeTxn(() async {
        await _db.habitIsars.put(habit);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark habit as dirty',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearHabitsForUser(String userId) async {
    try {
      final habits = await getHabitsByUser(
        userId: userId,
        includeArchived: true,
        includeDeleted: true,
      );

      await _db.writeTxn(() async {
        for (final habit in habits) {
          await _db.habitIsars.delete(habit.id);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear habits for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getHabitCountForUser(String userId) async {
    try {
      final count = await _db.habitIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get habit count for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getActiveHabitCountForUser(String userId) async {
    try {
      final count = await _db.habitIsars
          .filter()
          .userIdEqualTo(userId)
          .isArchivedEqualTo(false)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get active habit count for user',
        originalException: e,
      );
    }
  }

  @override
  Stream<HabitIsar?> watchHabit(String habitId) {
    try {
      return _db.habitIsars
          .filter()
          .habitIdEqualTo(habitId)
          .watch(fireImmediately: true)
          .map((habits) => habits.isNotEmpty ? habits.first : null);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch habit',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<HabitIsar>> watchHabitsForUser({
    required String userId,
  }) {
    try {
      return _db.habitIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch habits for user',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<HabitIsar>> watchActiveHabits({
    required String userId,
  }) {
    try {
      return _db.habitIsars
          .filter()
          .userIdEqualTo(userId)
          .isArchivedEqualTo(false)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch active habits',
        originalException: e,
      );
    }
  }
}
