import 'package:isar/isar.dart';
import '../../../../core/errors/exceptions.dart';
import 'schemas/timebox_isar.dart';
import '../../../models/timebox_model.dart';

/// Isar local data source for Timebox operations (offline storage)
abstract class IsarTimeboxLocalDataSource {
  /// Initialize Isar database
  Future<void> initialize();

  /// Insert or update timebox
  Future<TimeboxIsar> upsertTimebox(TimeboxIsar timebox);

  /// Get timebox by Firebase ID
  Future<TimeboxIsar?> getTimeboxByFirebaseId(String timeboxId);

  /// Get timebox for specific date
  Future<TimeboxIsar?> getTimeboxForDate({
    required String userId,
    required DateTime date,
  });

  /// Get timeboxes for date range
  Future<List<TimeboxIsar>> getTimeboxesForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get all timeboxes for user
  Future<List<TimeboxIsar>> getAllTimeboxes(String userId);

  /// Update timebox
  Future<TimeboxIsar> updateTimebox(TimeboxIsar timebox);

  /// Delete timebox
  Future<void> deleteTimebox(String timeboxId);

  /// Delete all timeboxes for user
  Future<void> deleteAllTimeboxes(String userId);

  /// Get dirty timeboxes (need sync)
  Future<List<TimeboxIsar>> getDirtyTimeboxes();

  /// Mark timebox as synced
  Future<void> markAsSynced(String timeboxId);

  /// Mark timebox as dirty (needs sync)
  Future<void> markAsDirty(String timeboxId);

  /// Watch timebox changes (stream)
  Stream<TimeboxIsar?> watchTimebox(String timeboxId);

  /// Watch timebox for date (stream)
  Stream<TimeboxIsar?> watchTimeboxForDate({
    required String userId,
    required DateTime date,
  });

  /// Convert TimeboxModel to TimeboxIsar
  TimeboxIsar modelToIsar(TimeboxModel model);

  /// Convert TimeboxIsar to TimeboxModel
  TimeboxModel isarToModel(TimeboxIsar isar);
}

/// Isar implementation of timebox local data source
class IsarTimeboxLocalDataSourceImpl implements IsarTimeboxLocalDataSource {
  Isar? _isar;

  IsarTimeboxLocalDataSourceImpl();

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    try {
      _isar = await Isar.open(
        [TimeboxIsarSchema],
        directory: await _getIsarPath(),
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to initialize Isar database for Timebox',
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
  Future<TimeboxIsar> upsertTimebox(TimeboxIsar timebox) async {
    try {
      await _db.writeTxn(() async {
        await _db.timeboxIsars.put(timebox);
      });

      // Return the inserted/updated timebox
      final savedTimebox = await getTimeboxByFirebaseId(timebox.timeboxId);
      if (savedTimebox == null) {
        throw const CacheException(
          message: 'Failed to save timebox to local database',
        );
      }

      return savedTimebox;
    } catch (e) {
      throw CacheException(
        message: 'Failed to upsert timebox',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxIsar?> getTimeboxByFirebaseId(String timeboxId) async {
    try {
      final timebox = await _db.timeboxIsars
          .filter()
          .timeboxIdEqualTo(timeboxId)
          .findFirst();

      return timebox;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get timebox by Firebase ID',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxIsar?> getTimeboxForDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      // Normalize date to midnight
      final normalizedDate = DateTime(date.year, date.month, date.day);

      final timebox = await _db.timeboxIsars
          .filter()
          .userIdEqualTo(userId)
          .dateEqualTo(normalizedDate)
          .findFirst();

      return timebox;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get timebox for date',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TimeboxIsar>> getTimeboxesForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Normalize dates to midnight
      final normalizedStart =
          DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

      final timeboxes = await _db.timeboxIsars
          .filter()
          .userIdEqualTo(userId)
          .dateBetween(normalizedStart, normalizedEnd)
          .sortByDate()
          .findAll();

      return timeboxes;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get timeboxes for date range',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TimeboxIsar>> getAllTimeboxes(String userId) async {
    try {
      final timeboxes = await _db.timeboxIsars
          .filter()
          .userIdEqualTo(userId)
          .sortByDateDesc()
          .findAll();

      return timeboxes;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get all timeboxes',
        originalException: e,
      );
    }
  }

  @override
  Future<TimeboxIsar> updateTimebox(TimeboxIsar timebox) async {
    try {
      // Mark as dirty for sync
      timebox.isDirty = true;

      await _db.writeTxn(() async {
        await _db.timeboxIsars.put(timebox);
      });

      final updated = await getTimeboxByFirebaseId(timebox.timeboxId);
      if (updated == null) {
        throw const CacheException(
          message: 'Failed to update timebox',
        );
      }

      return updated;
    } catch (e) {
      throw CacheException(
        message: 'Failed to update timebox',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteTimebox(String timeboxId) async {
    try {
      await _db.writeTxn(() async {
        await _db.timeboxIsars
            .filter()
            .timeboxIdEqualTo(timeboxId)
            .deleteFirst();
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete timebox',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteAllTimeboxes(String userId) async {
    try {
      await _db.writeTxn(() async {
        await _db.timeboxIsars.filter().userIdEqualTo(userId).deleteAll();
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete all timeboxes',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TimeboxIsar>> getDirtyTimeboxes() async {
    try {
      final timeboxes =
          await _db.timeboxIsars.filter().isDirtyEqualTo(true).findAll();

      return timeboxes;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get dirty timeboxes',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String timeboxId) async {
    try {
      final timebox = await getTimeboxByFirebaseId(timeboxId);
      if (timebox == null) {
        throw const CacheException(
          message: 'Timebox not found',
        );
      }

      timebox.isDirty = false;
      timebox.lastSyncAt = DateTime.now();

      await _db.writeTxn(() async {
        await _db.timeboxIsars.put(timebox);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark timebox as synced',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDirty(String timeboxId) async {
    try {
      final timebox = await getTimeboxByFirebaseId(timeboxId);
      if (timebox == null) {
        throw const CacheException(
          message: 'Timebox not found',
        );
      }

      timebox.isDirty = true;

      await _db.writeTxn(() async {
        await _db.timeboxIsars.put(timebox);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark timebox as dirty',
        originalException: e,
      );
    }
  }

  @override
  Stream<TimeboxIsar?> watchTimebox(String timeboxId) {
    try {
      return _db.timeboxIsars
          .filter()
          .timeboxIdEqualTo(timeboxId)
          .watch(fireImmediately: true)
          .map((timeboxes) => timeboxes.isEmpty ? null : timeboxes.first);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch timebox',
        originalException: e,
      );
    }
  }

  @override
  Stream<TimeboxIsar?> watchTimeboxForDate({
    required String userId,
    required DateTime date,
  }) {
    try {
      // Normalize date to midnight
      final normalizedDate = DateTime(date.year, date.month, date.day);

      return _db.timeboxIsars
          .filter()
          .userIdEqualTo(userId)
          .dateEqualTo(normalizedDate)
          .watch(fireImmediately: true)
          .map((timeboxes) => timeboxes.isEmpty ? null : timeboxes.first);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch timebox for date',
        originalException: e,
      );
    }
  }

  @override
  TimeboxIsar modelToIsar(TimeboxModel model) {
    return TimeboxIsar()
      ..timeboxId = model.id
      ..userId = model.userId
      ..date = DateTime(model.date.year, model.date.month, model.date.day)
      ..slots = model.slots
          .map((slot) => TimeboxSlotIsar()
            ..id = slot.id
            ..taskId = slot.taskId
            ..taskTitle = slot.taskTitle
            ..taskDescription = slot.taskDescription
            ..startTime = slot.startTime
            ..endTime = slot.endTime
            ..category = slot.category
            ..priority = slot.priority
            ..status = slot.status
            ..listId = slot.listId
            ..listName = slot.listName
            ..listColor = slot.listColor
            ..tags = slot.tags
            ..isRecurring = slot.isRecurring
            ..isAllDay = slot.isAllDay
            ..notes = slot.notes)
          .toList()
      ..conflicts = model.conflicts
          .map((conflict) => TimeConflictIsar()
            ..id = conflict.id
            ..type = conflict.type
            ..severity = conflict.severity
            ..slot1Id = conflict.slot1Id
            ..slot2Id = conflict.slot2Id
            ..message = conflict.message
            ..suggestion = conflict.suggestion
            ..detectedAt = conflict.detectedAt)
          .toList()
      ..summary = (TimeboxSummaryIsar()
        ..totalTasks = model.summary.totalTasks
        ..completedTasks = model.summary.completedTasks
        ..pendingTasks = model.summary.pendingTasks
        ..skippedTasks = model.summary.skippedTasks
        ..totalScheduledHours = model.summary.totalScheduledHours
        ..personalTasks = model.summary.personalTasks
        ..professionalTasks = model.summary.professionalTasks
        ..healthTasks = model.summary.healthTasks
        ..learningTasks = model.summary.learningTasks
        ..errandsTasks = model.summary.errandsTasks
        ..socialTasks = model.summary.socialTasks
        ..otherTasks = model.summary.otherTasks
        ..highPriorityTasks = model.summary.highPriorityTasks
        ..criticalPriorityTasks = model.summary.criticalPriorityTasks
        ..conflictCount = model.summary.conflictCount
        ..completionRate = model.summary.completionRate
        ..utilizationRate = model.summary.utilizationRate)
      ..settings = (TimeboxSettingsIsar()
        ..dayStartHour = model.settings.dayStartHour
        ..dayEndHour = model.settings.dayEndHour
        ..workStartHour = model.settings.workStartHour
        ..workEndHour = model.settings.workEndHour
        ..peakHoursStart = model.settings.peakHoursStart
        ..peakHoursEnd = model.settings.peakHoursEnd
        ..bufferMinutes = model.settings.bufferMinutes
        ..allowConflicts = model.settings.allowConflicts
        ..autoDetectConflicts = model.settings.autoDetectConflicts
        ..showSkippedTasks = model.settings.showSkippedTasks
        ..groupByCategory = model.settings.groupByCategory
        ..highlightPriorityTasks = model.settings.highlightPriorityTasks
        ..defaultCategory = model.settings.defaultCategory
        ..themeColor = model.settings.themeColor)
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt
      ..isDirty = false;
  }

  @override
  TimeboxModel isarToModel(TimeboxIsar isar) {
    return TimeboxModel(
      id: isar.timeboxId,
      userId: isar.userId,
      date: isar.date,
      slots: (isar.slots ?? [])
          .map((slot) => TimeboxSlotModel(
                id: slot.id,
                taskId: slot.taskId,
                taskTitle: slot.taskTitle,
                taskDescription: slot.taskDescription,
                startTime: slot.startTime,
                endTime: slot.endTime,
                category: slot.category,
                priority: slot.priority,
                status: slot.status,
                listId: slot.listId,
                listName: slot.listName,
                listColor: slot.listColor,
                tags: slot.tags ?? [],
                isRecurring: slot.isRecurring,
                isAllDay: slot.isAllDay,
                notes: slot.notes,
              ))
          .toList(),
      conflicts: (isar.conflicts ?? [])
          .map((conflict) => TimeConflictModel(
                id: conflict.id,
                type: conflict.type,
                severity: conflict.severity,
                slot1Id: conflict.slot1Id,
                slot2Id: conflict.slot2Id,
                message: conflict.message,
                suggestion: conflict.suggestion,
                detectedAt: conflict.detectedAt,
              ))
          .toList(),
      summary: TimeboxSummaryModel(
        totalTasks: isar.summary?.totalTasks ?? 0,
        completedTasks: isar.summary?.completedTasks ?? 0,
        pendingTasks: isar.summary?.pendingTasks ?? 0,
        skippedTasks: isar.summary?.skippedTasks ?? 0,
        totalScheduledHours: isar.summary?.totalScheduledHours ?? 0.0,
        personalTasks: isar.summary?.personalTasks ?? 0,
        professionalTasks: isar.summary?.professionalTasks ?? 0,
        healthTasks: isar.summary?.healthTasks ?? 0,
        learningTasks: isar.summary?.learningTasks ?? 0,
        errandsTasks: isar.summary?.errandsTasks ?? 0,
        socialTasks: isar.summary?.socialTasks ?? 0,
        otherTasks: isar.summary?.otherTasks ?? 0,
        highPriorityTasks: isar.summary?.highPriorityTasks ?? 0,
        criticalPriorityTasks: isar.summary?.criticalPriorityTasks ?? 0,
        conflictCount: isar.summary?.conflictCount ?? 0,
        completionRate: isar.summary?.completionRate ?? 0.0,
        utilizationRate: isar.summary?.utilizationRate ?? 0.0,
      ),
      settings: TimeboxSettingsModel(
        dayStartHour: isar.settings?.dayStartHour ?? 8,
        dayEndHour: isar.settings?.dayEndHour ?? 20,
        workStartHour: isar.settings?.workStartHour ?? 9,
        workEndHour: isar.settings?.workEndHour ?? 17,
        peakHoursStart: isar.settings?.peakHoursStart ?? 10,
        peakHoursEnd: isar.settings?.peakHoursEnd ?? 12,
        bufferMinutes: isar.settings?.bufferMinutes ?? 15,
        allowConflicts: isar.settings?.allowConflicts ?? false,
        autoDetectConflicts: isar.settings?.autoDetectConflicts ?? true,
        showSkippedTasks: isar.settings?.showSkippedTasks ?? false,
        groupByCategory: isar.settings?.groupByCategory ?? true,
        highlightPriorityTasks: isar.settings?.highlightPriorityTasks ?? true,
        defaultCategory: isar.settings?.defaultCategory ?? 'personal',
        themeColor: isar.settings?.themeColor ?? '#2196F3',
      ),
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
    );
  }
}
