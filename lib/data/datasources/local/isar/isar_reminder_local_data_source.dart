import 'package:isar/isar.dart';
import '../../../core/errors/exceptions.dart';
import 'schemas/reminder_isar.dart';

/// Isar local data source for Reminder operations (offline storage)
abstract class IsarReminderLocalDataSource {
  /// Initialize Isar database
  Future<void> initialize();

  /// Insert or update reminder
  Future<ReminderIsar> upsertReminder(ReminderIsar reminder);

  /// Get reminder by Firebase ID
  Future<ReminderIsar?> getReminderByFirebaseId(String reminderId);

  /// Get reminders by user ID
  Future<List<ReminderIsar>> getRemindersByUser({
    required String userId,
    bool includeTriggered = false,
    bool includeDeleted = false,
  });

  /// Get reminders by task ID
  Future<List<ReminderIsar>> getRemindersByTask({
    required String taskId,
    bool includeTriggered = false,
    bool includeDeleted = false,
  });

  /// Get upcoming reminders (not triggered, enabled, future time)
  Future<List<ReminderIsar>> getUpcomingReminders({
    required String userId,
    DateTime? beforeTime,
  });

  /// Get triggered reminders
  Future<List<ReminderIsar>> getTriggeredReminders({
    required String userId,
    DateTime? afterTime,
  });

  /// Get enabled reminders
  Future<List<ReminderIsar>> getEnabledReminders({
    required String userId,
    bool includeTriggered = false,
  });

  /// Get reminders by type
  Future<List<ReminderIsar>> getRemindersByType({
    required String userId,
    required ReminderTypeIsar type,
    bool includeTriggered = false,
    bool includeDeleted = false,
  });

  /// Get due reminders (past time, enabled, not triggered)
  Future<List<ReminderIsar>> getDueReminders({
    required String userId,
  });

  /// Update reminder
  Future<ReminderIsar> updateReminder(ReminderIsar reminder);

  /// Delete reminder (soft delete)
  Future<void> deleteReminder(String reminderId);

  /// Permanently delete reminder
  Future<void> permanentlyDeleteReminder(String reminderId);

  /// Mark reminder as triggered
  Future<void> markAsTriggered(String reminderId);

  /// Reset trigger (mark as not triggered)
  Future<void> resetTrigger(String reminderId);

  /// Enable reminder
  Future<void> enableReminder(String reminderId);

  /// Disable reminder
  Future<void> disableReminder(String reminderId);

  /// Toggle reminder enabled state
  Future<void> toggleEnabled(String reminderId);

  /// Batch insert reminders
  Future<void> batchInsertReminders(List<ReminderIsar> reminders);

  /// Delete all reminders for task
  Future<void> deleteRemindersForTask(String taskId);

  /// Get dirty reminders (need sync)
  Future<List<ReminderIsar>> getDirtyReminders();

  /// Mark reminder as synced
  Future<void> markAsSynced(String reminderId);

  /// Mark reminder as dirty (needs sync)
  Future<void> markAsDirty(String reminderId);

  /// Clear reminders for user
  Future<void> clearRemindersForUser(String userId);

  /// Get reminder count for user
  Future<int> getReminderCountForUser(String userId);

  /// Get reminder count for task
  Future<int> getReminderCountForTask(String taskId);

  /// Watch reminder changes (stream)
  Stream<ReminderIsar?> watchReminder(String reminderId);

  /// Watch reminders for user (stream)
  Stream<List<ReminderIsar>> watchRemindersForUser({
    required String userId,
  });

  /// Watch reminders for task (stream)
  Stream<List<ReminderIsar>> watchRemindersForTask({
    required String taskId,
  });

  /// Watch upcoming reminders (stream)
  Stream<List<ReminderIsar>> watchUpcomingReminders({
    required String userId,
  });
}

/// Isar implementation of reminder local data source
class IsarReminderLocalDataSourceImpl implements IsarReminderLocalDataSource {
  Isar? _isar;

  IsarReminderLocalDataSourceImpl();

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    try {
      _isar = await Isar.open([
        ReminderIsarSchema,
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
  Future<ReminderIsar> upsertReminder(ReminderIsar reminder) async {
    try {
      await _db.writeTxn(() async {
        await _db.reminderIsars.put(reminder);
      });

      // Return the inserted/updated reminder
      final savedReminder = await getReminderByFirebaseId(reminder.reminderId);
      if (savedReminder == null) {
        throw const CacheException(
          message: 'Failed to save reminder to local database',
        );
      }

      return savedReminder;
    } catch (e) {
      throw CacheException(
        message: 'Failed to upsert reminder',
        originalException: e,
      );
    }
  }

  @override
  Future<ReminderIsar?> getReminderByFirebaseId(String reminderId) async {
    try {
      final reminder = await _db.reminderIsars
          .filter()
          .reminderIdEqualTo(reminderId)
          .findFirst();

      return reminder;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get reminder by Firebase ID',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderIsar>> getRemindersByUser({
    required String userId,
    bool includeTriggered = false,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.reminderIsars
          .filter()
          .userIdEqualTo(userId);

      if (!includeTriggered) {
        query = query.isTriggeredEqualTo(false);
      }

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final reminders = await query
          .sortByReminderTime()
          .findAll();

      return reminders;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get reminders by user',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderIsar>> getRemindersByTask({
    required String taskId,
    bool includeTriggered = false,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.reminderIsars
          .filter()
          .taskIdEqualTo(taskId);

      if (!includeTriggered) {
        query = query.isTriggeredEqualTo(false);
      }

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final reminders = await query
          .sortByReminderTime()
          .findAll();

      return reminders;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get reminders by task',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderIsar>> getUpcomingReminders({
    required String userId,
    DateTime? beforeTime,
  }) async {
    try {
      final now = DateTime.now();
      final endTime = beforeTime ?? now.add(const Duration(days: 7));

      final reminders = await _db.reminderIsars
          .filter()
          .userIdEqualTo(userId)
          .isEnabledEqualTo(true)
          .isTriggeredEqualTo(false)
          .isDeletedEqualTo(false)
          .reminderTimeGreaterThan(now)
          .reminderTimeLessThan(endTime)
          .sortByReminderTime()
          .findAll();

      return reminders;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get upcoming reminders',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderIsar>> getTriggeredReminders({
    required String userId,
    DateTime? afterTime,
  }) async {
    try {
      var query = _db.reminderIsars
          .filter()
          .userIdEqualTo(userId)
          .isTriggeredEqualTo(true)
          .isDeletedEqualTo(false);

      if (afterTime != null) {
        query = query.triggeredAtGreaterThan(afterTime);
      }

      final reminders = await query
          .sortByTriggeredAtDesc()
          .findAll();

      return reminders;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get triggered reminders',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderIsar>> getEnabledReminders({
    required String userId,
    bool includeTriggered = false,
  }) async {
    try {
      var query = _db.reminderIsars
          .filter()
          .userIdEqualTo(userId)
          .isEnabledEqualTo(true)
          .isDeletedEqualTo(false);

      if (!includeTriggered) {
        query = query.isTriggeredEqualTo(false);
      }

      final reminders = await query
          .sortByReminderTime()
          .findAll();

      return reminders;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get enabled reminders',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderIsar>> getRemindersByType({
    required String userId,
    required ReminderTypeIsar type,
    bool includeTriggered = false,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.reminderIsars
          .filter()
          .userIdEqualTo(userId)
          .typeEqualTo(type);

      if (!includeTriggered) {
        query = query.isTriggeredEqualTo(false);
      }

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final reminders = await query
          .sortByReminderTime()
          .findAll();

      return reminders;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get reminders by type',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderIsar>> getDueReminders({
    required String userId,
  }) async {
    try {
      final now = DateTime.now();

      final reminders = await _db.reminderIsars
          .filter()
          .userIdEqualTo(userId)
          .isEnabledEqualTo(true)
          .isTriggeredEqualTo(false)
          .isDeletedEqualTo(false)
          .reminderTimeLessThan(now)
          .sortByReminderTime()
          .findAll();

      return reminders;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get due reminders',
        originalException: e,
      );
    }
  }

  @override
  Future<ReminderIsar> updateReminder(ReminderIsar reminder) async {
    try {
      final existingReminder = await getReminderByFirebaseId(reminder.reminderId);
      if (existingReminder == null) {
        throw const CacheException(
          message: 'Reminder not found in local database',
        );
      }

      // Update timestamp
      reminder.updatedAt = DateTime.now();
      reminder.isDirty = true;

      return await upsertReminder(reminder);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update reminder',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    try {
      final reminder = await getReminderByFirebaseId(reminderId);
      if (reminder == null) return;

      reminder.isDeleted = true;
      reminder.deletedAt = DateTime.now();
      reminder.updatedAt = DateTime.now();
      reminder.isDirty = true;

      await _db.writeTxn(() async {
        await _db.reminderIsars.put(reminder);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete reminder',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteReminder(String reminderId) async {
    try {
      final reminder = await getReminderByFirebaseId(reminderId);
      if (reminder == null) return;

      await _db.writeTxn(() async {
        await _db.reminderIsars.delete(reminder.id);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to permanently delete reminder',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsTriggered(String reminderId) async {
    try {
      final reminder = await getReminderByFirebaseId(reminderId);
      if (reminder == null) return;

      reminder.isTriggered = true;
      reminder.triggeredAt = DateTime.now();
      reminder.updatedAt = DateTime.now();
      reminder.isDirty = true;

      await _db.writeTxn(() async {
        await _db.reminderIsars.put(reminder);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark reminder as triggered',
        originalException: e,
      );
    }
  }

  @override
  Future<void> resetTrigger(String reminderId) async {
    try {
      final reminder = await getReminderByFirebaseId(reminderId);
      if (reminder == null) return;

      reminder.isTriggered = false;
      reminder.triggeredAt = null;
      reminder.updatedAt = DateTime.now();
      reminder.isDirty = true;

      await _db.writeTxn(() async {
        await _db.reminderIsars.put(reminder);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to reset trigger',
        originalException: e,
      );
    }
  }

  @override
  Future<void> enableReminder(String reminderId) async {
    try {
      final reminder = await getReminderByFirebaseId(reminderId);
      if (reminder == null) return;

      reminder.isEnabled = true;
      reminder.updatedAt = DateTime.now();
      reminder.isDirty = true;

      await _db.writeTxn(() async {
        await _db.reminderIsars.put(reminder);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to enable reminder',
        originalException: e,
      );
    }
  }

  @override
  Future<void> disableReminder(String reminderId) async {
    try {
      final reminder = await getReminderByFirebaseId(reminderId);
      if (reminder == null) return;

      reminder.isEnabled = false;
      reminder.updatedAt = DateTime.now();
      reminder.isDirty = true;

      await _db.writeTxn(() async {
        await _db.reminderIsars.put(reminder);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to disable reminder',
        originalException: e,
      );
    }
  }

  @override
  Future<void> toggleEnabled(String reminderId) async {
    try {
      final reminder = await getReminderByFirebaseId(reminderId);
      if (reminder == null) return;

      reminder.isEnabled = !reminder.isEnabled;
      reminder.updatedAt = DateTime.now();
      reminder.isDirty = true;

      await _db.writeTxn(() async {
        await _db.reminderIsars.put(reminder);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to toggle enabled state',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchInsertReminders(List<ReminderIsar> reminders) async {
    try {
      await _db.writeTxn(() async {
        await _db.reminderIsars.putAll(reminders);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to batch insert reminders',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteRemindersForTask(String taskId) async {
    try {
      final reminders = await getRemindersByTask(
        taskId: taskId,
        includeTriggered: true,
        includeDeleted: true,
      );

      await _db.writeTxn(() async {
        for (final reminder in reminders) {
          reminder.isDeleted = true;
          reminder.deletedAt = DateTime.now();
          reminder.updatedAt = DateTime.now();
          reminder.isDirty = true;
          await _db.reminderIsars.put(reminder);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete reminders for task',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ReminderIsar>> getDirtyReminders() async {
    try {
      final reminders = await _db.reminderIsars
          .filter()
          .isDirtyEqualTo(true)
          .findAll();

      return reminders;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get dirty reminders',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String reminderId) async {
    try {
      final reminder = await getReminderByFirebaseId(reminderId);
      if (reminder == null) return;

      reminder.isDirty = false;
      reminder.lastSyncAt = DateTime.now();

      await _db.writeTxn(() async {
        await _db.reminderIsars.put(reminder);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark reminder as synced',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDirty(String reminderId) async {
    try {
      final reminder = await getReminderByFirebaseId(reminderId);
      if (reminder == null) return;

      reminder.isDirty = true;

      await _db.writeTxn(() async {
        await _db.reminderIsars.put(reminder);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark reminder as dirty',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearRemindersForUser(String userId) async {
    try {
      final reminders = await getRemindersByUser(
        userId: userId,
        includeTriggered: true,
        includeDeleted: true,
      );

      await _db.writeTxn(() async {
        for (final reminder in reminders) {
          await _db.reminderIsars.delete(reminder.id);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear reminders for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getReminderCountForUser(String userId) async {
    try {
      final count = await _db.reminderIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get reminder count for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getReminderCountForTask(String taskId) async {
    try {
      final count = await _db.reminderIsars
          .filter()
          .taskIdEqualTo(taskId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get reminder count for task',
        originalException: e,
      );
    }
  }

  @override
  Stream<ReminderIsar?> watchReminder(String reminderId) {
    try {
      return _db.reminderIsars
          .filter()
          .reminderIdEqualTo(reminderId)
          .watch(fireImmediately: true)
          .map((reminders) => reminders.isNotEmpty ? reminders.first : null);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch reminder',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<ReminderIsar>> watchRemindersForUser({
    required String userId,
  }) {
    try {
      return _db.reminderIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch reminders for user',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<ReminderIsar>> watchRemindersForTask({
    required String taskId,
  }) {
    try {
      return _db.reminderIsars
          .filter()
          .taskIdEqualTo(taskId)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch reminders for task',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<ReminderIsar>> watchUpcomingReminders({
    required String userId,
  }) {
    try {
      final now = DateTime.now();

      return _db.reminderIsars
          .filter()
          .userIdEqualTo(userId)
          .isEnabledEqualTo(true)
          .isTriggeredEqualTo(false)
          .isDeletedEqualTo(false)
          .reminderTimeGreaterThan(now)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch upcoming reminders',
        originalException: e,
      );
    }
  }
}
