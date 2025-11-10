import 'package:isar/isar.dart';
import '../../../core/errors/exceptions.dart';
import 'schemas/activity_log_isar.dart';

/// Isar local data source for ActivityLog operations (offline storage)
abstract class IsarActivityLogLocalDataSource {
  /// Initialize Isar database
  Future<void> initialize();

  /// Insert or update activity log
  Future<ActivityLogIsar> upsertActivityLog(ActivityLogIsar activityLog);

  /// Get activity log by Firebase ID
  Future<ActivityLogIsar?> getActivityLogByFirebaseId(String activityId);

  /// Get activity logs by user ID
  Future<List<ActivityLogIsar>> getActivityLogsByUser({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Get activity logs by workspace ID
  Future<List<ActivityLogIsar>> getActivityLogsByWorkspace({
    required String workspaceId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Get activity logs by action type
  Future<List<ActivityLogIsar>> getActivityLogsByActionType({
    required String userId,
    required ActivityActionTypeIsar actionType,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get activity logs by entity type
  Future<List<ActivityLogIsar>> getActivityLogsByEntityType({
    required String userId,
    required ActivityEntityTypeIsar entityType,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get activity logs for entity
  Future<List<ActivityLogIsar>> getActivityLogsForEntity({
    required String entityId,
    ActivityEntityTypeIsar? entityType,
  });

  /// Get recent activity logs
  Future<List<ActivityLogIsar>> getRecentActivityLogs({
    required String userId,
    int limit = 50,
  });

  /// Get activity logs for today
  Future<List<ActivityLogIsar>> getTodayActivityLogs({
    required String userId,
  });

  /// Delete activity log
  Future<void> deleteActivityLog(String activityId);

  /// Delete old activity logs (older than specified date)
  Future<void> deleteOldActivityLogs({
    required DateTime beforeDate,
  });

  /// Batch insert activity logs
  Future<void> batchInsertActivityLogs(List<ActivityLogIsar> activityLogs);

  /// Get dirty activity logs (need sync)
  Future<List<ActivityLogIsar>> getDirtyActivityLogs();

  /// Mark activity log as synced
  Future<void> markAsSynced(String activityId);

  /// Mark activity log as dirty (needs sync)
  Future<void> markAsDirty(String activityId);

  /// Clear activity logs for user
  Future<void> clearActivityLogsForUser(String userId);

  /// Get activity log count for user
  Future<int> getActivityLogCountForUser(String userId);

  /// Get activity log count by action type
  Future<int> getActivityLogCountByActionType({
    required String userId,
    required ActivityActionTypeIsar actionType,
  });

  /// Watch activity logs for user (stream)
  Stream<List<ActivityLogIsar>> watchActivityLogsForUser({
    required String userId,
    int limit = 50,
  });

  /// Watch recent activity logs (stream)
  Stream<List<ActivityLogIsar>> watchRecentActivityLogs({
    required String userId,
    int limit = 50,
  });
}

/// Isar implementation of activity log local data source
class IsarActivityLogLocalDataSourceImpl implements IsarActivityLogLocalDataSource {
  Isar? _isar;

  IsarActivityLogLocalDataSourceImpl();

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    try {
      _isar = await Isar.open([
        ActivityLogIsarSchema,
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
  Future<ActivityLogIsar> upsertActivityLog(ActivityLogIsar activityLog) async {
    try {
      await _db.writeTxn(() async {
        await _db.activityLogIsars.put(activityLog);
      });

      // Return the inserted/updated activity log
      final savedActivityLog = await getActivityLogByFirebaseId(activityLog.activityId);
      if (savedActivityLog == null) {
        throw const CacheException(
          message: 'Failed to save activity log to local database',
        );
      }

      return savedActivityLog;
    } catch (e) {
      throw CacheException(
        message: 'Failed to upsert activity log',
        originalException: e,
      );
    }
  }

  @override
  Future<ActivityLogIsar?> getActivityLogByFirebaseId(String activityId) async {
    try {
      final activityLog = await _db.activityLogIsars
          .filter()
          .activityIdEqualTo(activityId)
          .findFirst();

      return activityLog;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get activity log by Firebase ID',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ActivityLogIsar>> getActivityLogsByUser({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      var query = _db.activityLogIsars
          .filter()
          .userIdEqualTo(userId);

      if (startDate != null) {
        query = query.timestampGreaterThan(startDate);
      }

      if (endDate != null) {
        query = query.timestampLessThan(endDate);
      }

      var sortedQuery = query.sortByTimestampDesc();

      if (limit != null) {
        sortedQuery = sortedQuery.limit(limit);
      }

      final activityLogs = await sortedQuery.findAll();

      return activityLogs;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get activity logs by user',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ActivityLogIsar>> getActivityLogsByWorkspace({
    required String workspaceId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      var query = _db.activityLogIsars
          .filter()
          .workspaceIdEqualTo(workspaceId);

      if (startDate != null) {
        query = query.timestampGreaterThan(startDate);
      }

      if (endDate != null) {
        query = query.timestampLessThan(endDate);
      }

      var sortedQuery = query.sortByTimestampDesc();

      if (limit != null) {
        sortedQuery = sortedQuery.limit(limit);
      }

      final activityLogs = await sortedQuery.findAll();

      return activityLogs;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get activity logs by workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ActivityLogIsar>> getActivityLogsByActionType({
    required String userId,
    required ActivityActionTypeIsar actionType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _db.activityLogIsars
          .filter()
          .userIdEqualTo(userId)
          .actionTypeEqualTo(actionType);

      if (startDate != null) {
        query = query.timestampGreaterThan(startDate);
      }

      if (endDate != null) {
        query = query.timestampLessThan(endDate);
      }

      final activityLogs = await query
          .sortByTimestampDesc()
          .findAll();

      return activityLogs;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get activity logs by action type',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ActivityLogIsar>> getActivityLogsByEntityType({
    required String userId,
    required ActivityEntityTypeIsar entityType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _db.activityLogIsars
          .filter()
          .userIdEqualTo(userId)
          .entityTypeEqualTo(entityType);

      if (startDate != null) {
        query = query.timestampGreaterThan(startDate);
      }

      if (endDate != null) {
        query = query.timestampLessThan(endDate);
      }

      final activityLogs = await query
          .sortByTimestampDesc()
          .findAll();

      return activityLogs;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get activity logs by entity type',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ActivityLogIsar>> getActivityLogsForEntity({
    required String entityId,
    ActivityEntityTypeIsar? entityType,
  }) async {
    try {
      var query = _db.activityLogIsars
          .filter()
          .entityIdEqualTo(entityId);

      if (entityType != null) {
        query = query.entityTypeEqualTo(entityType);
      }

      final activityLogs = await query
          .sortByTimestampDesc()
          .findAll();

      return activityLogs;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get activity logs for entity',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ActivityLogIsar>> getRecentActivityLogs({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final activityLogs = await _db.activityLogIsars
          .filter()
          .userIdEqualTo(userId)
          .sortByTimestampDesc()
          .limit(limit)
          .findAll();

      return activityLogs;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get recent activity logs',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ActivityLogIsar>> getTodayActivityLogs({
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final activityLogs = await _db.activityLogIsars
          .filter()
          .userIdEqualTo(userId)
          .timestampBetween(startOfDay, endOfDay)
          .sortByTimestamp()
          .findAll();

      return activityLogs;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get today activity logs',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteActivityLog(String activityId) async {
    try {
      final activityLog = await getActivityLogByFirebaseId(activityId);
      if (activityLog == null) return;

      await _db.writeTxn(() async {
        await _db.activityLogIsars.delete(activityLog.id);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete activity log',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteOldActivityLogs({
    required DateTime beforeDate,
  }) async {
    try {
      final oldActivityLogs = await _db.activityLogIsars
          .filter()
          .timestampLessThan(beforeDate)
          .findAll();

      await _db.writeTxn(() async {
        for (final activityLog in oldActivityLogs) {
          await _db.activityLogIsars.delete(activityLog.id);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete old activity logs',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchInsertActivityLogs(List<ActivityLogIsar> activityLogs) async {
    try {
      await _db.writeTxn(() async {
        await _db.activityLogIsars.putAll(activityLogs);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to batch insert activity logs',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ActivityLogIsar>> getDirtyActivityLogs() async {
    try {
      final activityLogs = await _db.activityLogIsars
          .filter()
          .isDirtyEqualTo(true)
          .findAll();

      return activityLogs;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get dirty activity logs',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String activityId) async {
    try {
      final activityLog = await getActivityLogByFirebaseId(activityId);
      if (activityLog == null) return;

      activityLog.isDirty = false;
      activityLog.lastSyncAt = DateTime.now();

      await _db.writeTxn(() async {
        await _db.activityLogIsars.put(activityLog);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark activity log as synced',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDirty(String activityId) async {
    try {
      final activityLog = await getActivityLogByFirebaseId(activityId);
      if (activityLog == null) return;

      activityLog.isDirty = true;

      await _db.writeTxn(() async {
        await _db.activityLogIsars.put(activityLog);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark activity log as dirty',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearActivityLogsForUser(String userId) async {
    try {
      final activityLogs = await getActivityLogsByUser(userId: userId);

      await _db.writeTxn(() async {
        for (final activityLog in activityLogs) {
          await _db.activityLogIsars.delete(activityLog.id);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear activity logs for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getActivityLogCountForUser(String userId) async {
    try {
      final count = await _db.activityLogIsars
          .filter()
          .userIdEqualTo(userId)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get activity log count for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getActivityLogCountByActionType({
    required String userId,
    required ActivityActionTypeIsar actionType,
  }) async {
    try {
      final count = await _db.activityLogIsars
          .filter()
          .userIdEqualTo(userId)
          .actionTypeEqualTo(actionType)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get activity log count by action type',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<ActivityLogIsar>> watchActivityLogsForUser({
    required String userId,
    int limit = 50,
  }) {
    try {
      return _db.activityLogIsars
          .filter()
          .userIdEqualTo(userId)
          .watch(fireImmediately: true)
          .map((logs) {
            // Sort and limit
            final sorted = logs.toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
            return sorted.take(limit).toList();
          });
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch activity logs for user',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<ActivityLogIsar>> watchRecentActivityLogs({
    required String userId,
    int limit = 50,
  }) {
    try {
      return watchActivityLogsForUser(userId: userId, limit: limit);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch recent activity logs',
        originalException: e,
      );
    }
  }
}
