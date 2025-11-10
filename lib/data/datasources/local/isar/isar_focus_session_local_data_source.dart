import 'package:isar/isar.dart';
import '../../../core/errors/exceptions.dart';
import 'schemas/focus_session_isar.dart';

/// Isar local data source for FocusSession operations (offline storage)
abstract class IsarFocusSessionLocalDataSource {
  /// Initialize Isar database
  Future<void> initialize();

  /// Insert or update focus session
  Future<FocusSessionIsar> upsertFocusSession(FocusSessionIsar session);

  /// Get focus session by Firebase ID
  Future<FocusSessionIsar?> getFocusSessionByFirebaseId(String sessionId);

  /// Get focus sessions by user ID
  Future<List<FocusSessionIsar>> getFocusSessionsByUser({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus sessions by task ID
  Future<List<FocusSessionIsar>> getFocusSessionsByTask({
    required String taskId,
  });

  /// Get focus sessions by list ID
  Future<List<FocusSessionIsar>> getFocusSessionsByList({
    required String listId,
  });

  /// Get focus sessions by type
  Future<List<FocusSessionIsar>> getFocusSessionsByType({
    required String userId,
    required FocusSessionTypeIsar type,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus sessions by status
  Future<List<FocusSessionIsar>> getFocusSessionsByStatus({
    required String userId,
    required FocusSessionStatusIsar status,
  });

  /// Get active focus session
  Future<FocusSessionIsar?> getActiveFocusSession({
    required String userId,
  });

  /// Get completed focus sessions
  Future<List<FocusSessionIsar>> getCompletedFocusSessions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus sessions for today
  Future<List<FocusSessionIsar>> getTodayFocusSessions({
    required String userId,
  });

  /// Get recent focus sessions
  Future<List<FocusSessionIsar>> getRecentFocusSessions({
    required String userId,
    int limit = 20,
  });

  /// Update focus session
  Future<FocusSessionIsar> updateFocusSession(FocusSessionIsar session);

  /// Delete focus session (soft delete)
  Future<void> deleteFocusSession(String sessionId);

  /// Permanently delete focus session
  Future<void> permanentlyDeleteFocusSession(String sessionId);

  /// Update session status
  Future<void> updateSessionStatus({
    required String sessionId,
    required FocusSessionStatusIsar status,
  });

  /// Pause session
  Future<void> pauseSession(String sessionId);

  /// Resume session
  Future<void> resumeSession(String sessionId);

  /// Complete session
  Future<void> completeSession({
    required String sessionId,
    required int actualDuration,
    double? focusQualityScore,
  });

  /// Batch insert focus sessions
  Future<void> batchInsertFocusSessions(List<FocusSessionIsar> sessions);

  /// Get dirty focus sessions (need sync)
  Future<List<FocusSessionIsar>> getDirtyFocusSessions();

  /// Mark focus session as synced
  Future<void> markAsSynced(String sessionId);

  /// Mark focus session as dirty (needs sync)
  Future<void> markAsDirty(String sessionId);

  /// Clear focus sessions for user
  Future<void> clearFocusSessionsForUser(String userId);

  /// Get focus session count for user
  Future<int> getFocusSessionCountForUser(String userId);

  /// Get total focus time for user (in minutes)
  Future<int> getTotalFocusTime({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get average focus quality score
  Future<double> getAverageFocusQualityScore({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Watch focus session changes (stream)
  Stream<FocusSessionIsar?> watchFocusSession(String sessionId);

  /// Watch focus sessions for user (stream)
  Stream<List<FocusSessionIsar>> watchFocusSessionsForUser({
    required String userId,
  });

  /// Watch active focus session (stream)
  Stream<FocusSessionIsar?> watchActiveFocusSession({
    required String userId,
  });
}

/// Isar implementation of focus session local data source
class IsarFocusSessionLocalDataSourceImpl implements IsarFocusSessionLocalDataSource {
  Isar? _isar;

  IsarFocusSessionLocalDataSourceImpl();

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    try {
      _isar = await Isar.open([
        FocusSessionIsarSchema,
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
  Future<FocusSessionIsar> upsertFocusSession(FocusSessionIsar session) async {
    try {
      await _db.writeTxn(() async {
        await _db.focusSessionIsars.put(session);
      });

      // Return the inserted/updated session
      final savedSession = await getFocusSessionByFirebaseId(session.sessionId);
      if (savedSession == null) {
        throw const CacheException(
          message: 'Failed to save focus session to local database',
        );
      }

      return savedSession;
    } catch (e) {
      throw CacheException(
        message: 'Failed to upsert focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<FocusSessionIsar?> getFocusSessionByFirebaseId(String sessionId) async {
    try {
      final session = await _db.focusSessionIsars
          .filter()
          .sessionIdEqualTo(sessionId)
          .findFirst();

      return session;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get focus session by Firebase ID',
        originalException: e,
      );
    }
  }

  @override
  Future<List<FocusSessionIsar>> getFocusSessionsByUser({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _db.focusSessionIsars
          .filter()
          .userIdEqualTo(userId);

      if (startDate != null) {
        query = query.startTimeGreaterThan(startDate);
      }

      if (endDate != null) {
        query = query.startTimeLessThan(endDate);
      }

      final sessions = await query
          .sortByStartTimeDesc()
          .findAll();

      return sessions;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get focus sessions by user',
        originalException: e,
      );
    }
  }

  @override
  Future<List<FocusSessionIsar>> getFocusSessionsByTask({
    required String taskId,
  }) async {
    try {
      final sessions = await _db.focusSessionIsars
          .filter()
          .taskIdEqualTo(taskId)
          .sortByStartTimeDesc()
          .findAll();

      return sessions;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get focus sessions by task',
        originalException: e,
      );
    }
  }

  @override
  Future<List<FocusSessionIsar>> getFocusSessionsByList({
    required String listId,
  }) async {
    try {
      final sessions = await _db.focusSessionIsars
          .filter()
          .listIdEqualTo(listId)
          .sortByStartTimeDesc()
          .findAll();

      return sessions;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get focus sessions by list',
        originalException: e,
      );
    }
  }

  @override
  Future<List<FocusSessionIsar>> getFocusSessionsByType({
    required String userId,
    required FocusSessionTypeIsar type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _db.focusSessionIsars
          .filter()
          .userIdEqualTo(userId)
          .typeEqualTo(type);

      if (startDate != null) {
        query = query.startTimeGreaterThan(startDate);
      }

      if (endDate != null) {
        query = query.startTimeLessThan(endDate);
      }

      final sessions = await query
          .sortByStartTimeDesc()
          .findAll();

      return sessions;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get focus sessions by type',
        originalException: e,
      );
    }
  }

  @override
  Future<List<FocusSessionIsar>> getFocusSessionsByStatus({
    required String userId,
    required FocusSessionStatusIsar status,
  }) async {
    try {
      final sessions = await _db.focusSessionIsars
          .filter()
          .userIdEqualTo(userId)
          .statusEqualTo(status)
          .sortByStartTimeDesc()
          .findAll();

      return sessions;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get focus sessions by status',
        originalException: e,
      );
    }
  }

  @override
  Future<FocusSessionIsar?> getActiveFocusSession({
    required String userId,
  }) async {
    try {
      final session = await _db.focusSessionIsars
          .filter()
          .userIdEqualTo(userId)
          .statusEqualTo(FocusSessionStatusIsar.active)
          .or()
          .statusEqualTo(FocusSessionStatusIsar.paused)
          .sortByStartTimeDesc()
          .findFirst();

      return session;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get active focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<List<FocusSessionIsar>> getCompletedFocusSessions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _db.focusSessionIsars
          .filter()
          .userIdEqualTo(userId)
          .statusEqualTo(FocusSessionStatusIsar.completed);

      if (startDate != null) {
        query = query.startTimeGreaterThan(startDate);
      }

      if (endDate != null) {
        query = query.startTimeLessThan(endDate);
      }

      final sessions = await query
          .sortByStartTimeDesc()
          .findAll();

      return sessions;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get completed focus sessions',
        originalException: e,
      );
    }
  }

  @override
  Future<List<FocusSessionIsar>> getTodayFocusSessions({
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final sessions = await _db.focusSessionIsars
          .filter()
          .userIdEqualTo(userId)
          .startTimeBetween(startOfDay, endOfDay)
          .sortByStartTime()
          .findAll();

      return sessions;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get today focus sessions',
        originalException: e,
      );
    }
  }

  @override
  Future<List<FocusSessionIsar>> getRecentFocusSessions({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final sessions = await _db.focusSessionIsars
          .filter()
          .userIdEqualTo(userId)
          .sortByStartTimeDesc()
          .limit(limit)
          .findAll();

      return sessions;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get recent focus sessions',
        originalException: e,
      );
    }
  }

  @override
  Future<FocusSessionIsar> updateFocusSession(FocusSessionIsar session) async {
    try {
      final existingSession = await getFocusSessionByFirebaseId(session.sessionId);
      if (existingSession == null) {
        throw const CacheException(
          message: 'Focus session not found in local database',
        );
      }

      // Update timestamp
      session.updatedAt = DateTime.now();
      session.isDirty = true;

      return await upsertFocusSession(session);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteFocusSession(String sessionId) async {
    try {
      final session = await getFocusSessionByFirebaseId(sessionId);
      if (session == null) return;

      // Hard delete for focus sessions (no soft delete)
      await _db.writeTxn(() async {
        await _db.focusSessionIsars.delete(session.id);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteFocusSession(String sessionId) async {
    try {
      await deleteFocusSession(sessionId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to permanently delete focus session',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateSessionStatus({
    required String sessionId,
    required FocusSessionStatusIsar status,
  }) async {
    try {
      final session = await getFocusSessionByFirebaseId(sessionId);
      if (session == null) return;

      session.status = status;
      session.updatedAt = DateTime.now();
      session.isDirty = true;

      await _db.writeTxn(() async {
        await _db.focusSessionIsars.put(session);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to update session status',
        originalException: e,
      );
    }
  }

  @override
  Future<void> pauseSession(String sessionId) async {
    try {
      final session = await getFocusSessionByFirebaseId(sessionId);
      if (session == null) return;

      session.status = FocusSessionStatusIsar.paused;
      session.pausedAt = DateTime.now();
      session.updatedAt = DateTime.now();
      session.isDirty = true;

      await _db.writeTxn(() async {
        await _db.focusSessionIsars.put(session);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to pause session',
        originalException: e,
      );
    }
  }

  @override
  Future<void> resumeSession(String sessionId) async {
    try {
      final session = await getFocusSessionByFirebaseId(sessionId);
      if (session == null) return;

      session.status = FocusSessionStatusIsar.active;
      session.resumedAt = DateTime.now();
      session.updatedAt = DateTime.now();
      session.isDirty = true;

      await _db.writeTxn(() async {
        await _db.focusSessionIsars.put(session);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to resume session',
        originalException: e,
      );
    }
  }

  @override
  Future<void> completeSession({
    required String sessionId,
    required int actualDuration,
    double? focusQualityScore,
  }) async {
    try {
      final session = await getFocusSessionByFirebaseId(sessionId);
      if (session == null) return;

      session.status = FocusSessionStatusIsar.completed;
      session.endTime = DateTime.now();
      session.actualDuration = actualDuration;
      session.focusQualityScore = focusQualityScore;
      session.updatedAt = DateTime.now();
      session.isDirty = true;

      await _db.writeTxn(() async {
        await _db.focusSessionIsars.put(session);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to complete session',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchInsertFocusSessions(List<FocusSessionIsar> sessions) async {
    try {
      await _db.writeTxn(() async {
        await _db.focusSessionIsars.putAll(sessions);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to batch insert focus sessions',
        originalException: e,
      );
    }
  }

  @override
  Future<List<FocusSessionIsar>> getDirtyFocusSessions() async {
    try {
      final sessions = await _db.focusSessionIsars
          .filter()
          .isDirtyEqualTo(true)
          .findAll();

      return sessions;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get dirty focus sessions',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String sessionId) async {
    try {
      final session = await getFocusSessionByFirebaseId(sessionId);
      if (session == null) return;

      session.isDirty = false;
      session.lastSyncAt = DateTime.now();

      await _db.writeTxn(() async {
        await _db.focusSessionIsars.put(session);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark focus session as synced',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDirty(String sessionId) async {
    try {
      final session = await getFocusSessionByFirebaseId(sessionId);
      if (session == null) return;

      session.isDirty = true;

      await _db.writeTxn(() async {
        await _db.focusSessionIsars.put(session);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark focus session as dirty',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearFocusSessionsForUser(String userId) async {
    try {
      final sessions = await getFocusSessionsByUser(userId: userId);

      await _db.writeTxn(() async {
        for (final session in sessions) {
          await _db.focusSessionIsars.delete(session.id);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear focus sessions for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getFocusSessionCountForUser(String userId) async {
    try {
      final count = await _db.focusSessionIsars
          .filter()
          .userIdEqualTo(userId)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get focus session count for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getTotalFocusTime({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sessions = await getCompletedFocusSessions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Sum up all actual durations
      int totalMinutes = 0;
      for (final session in sessions) {
        if (session.actualDuration != null) {
          totalMinutes += session.actualDuration!;
        }
      }

      return totalMinutes;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get total focus time',
        originalException: e,
      );
    }
  }

  @override
  Future<double> getAverageFocusQualityScore({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sessions = await getCompletedFocusSessions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Filter sessions with quality scores
      final sessionsWithScores = sessions.where((s) => s.focusQualityScore != null).toList();

      if (sessionsWithScores.isEmpty) {
        return 0.0;
      }

      // Calculate average
      double totalScore = 0.0;
      for (final session in sessionsWithScores) {
        totalScore += session.focusQualityScore!;
      }

      return totalScore / sessionsWithScores.length;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get average focus quality score',
        originalException: e,
      );
    }
  }

  @override
  Stream<FocusSessionIsar?> watchFocusSession(String sessionId) {
    try {
      return _db.focusSessionIsars
          .filter()
          .sessionIdEqualTo(sessionId)
          .watch(fireImmediately: true)
          .map((sessions) => sessions.isNotEmpty ? sessions.first : null);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch focus session',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<FocusSessionIsar>> watchFocusSessionsForUser({
    required String userId,
  }) {
    try {
      return _db.focusSessionIsars
          .filter()
          .userIdEqualTo(userId)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch focus sessions for user',
        originalException: e,
      );
    }
  }

  @override
  Stream<FocusSessionIsar?> watchActiveFocusSession({
    required String userId,
  }) {
    try {
      return _db.focusSessionIsars
          .filter()
          .userIdEqualTo(userId)
          .watch(fireImmediately: true)
          .map((sessions) {
            // Find first active or paused session
            final activeSession = sessions.firstWhere(
              (s) => s.status == FocusSessionStatusIsar.active ||
                     s.status == FocusSessionStatusIsar.paused,
              orElse: () => FocusSessionIsar()..sessionId = '',
            );
            return activeSession.sessionId.isEmpty ? null : activeSession;
          });
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch active focus session',
        originalException: e,
      );
    }
  }
}
