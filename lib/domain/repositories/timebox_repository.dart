import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/timebox_entity.dart';
import '../entities/task_entity.dart';

/// Timebox Repository Interface
///
/// Defines the contract for timebox data operations.
/// Implementations handle the actual data access (Firebase, Isar, etc.)
abstract class TimeboxRepository {
  // ============================================================
  // TIMEBOX CRUD OPERATIONS
  // ============================================================

  /// Get timebox for a specific date
  ///
  /// Returns the daily timebox agenda for the given date.
  /// Creates a new timebox if one doesn't exist.
  Future<Either<Failure, TimeboxEntity>> getTimeboxForDate({
    required String userId,
    required DateTime date,
  });

  /// Get timebox by ID
  Future<Either<Failure, TimeboxEntity>> getTimeboxById(String timeboxId);

  /// Create a new timebox
  Future<Either<Failure, TimeboxEntity>> createTimebox(TimeboxEntity timebox);

  /// Update an existing timebox
  Future<Either<Failure, TimeboxEntity>> updateTimebox(TimeboxEntity timebox);

  /// Delete a timebox
  Future<Either<Failure, void>> deleteTimebox(String timeboxId);

  // ============================================================
  // TIMEBOX SLOT OPERATIONS
  // ============================================================

  /// Add a slot to the timebox
  Future<Either<Failure, TimeboxEntity>> addSlot({
    required String timeboxId,
    required TimeboxSlot slot,
  });

  /// Update a slot in the timebox
  Future<Either<Failure, TimeboxEntity>> updateSlot({
    required String timeboxId,
    required TimeboxSlot slot,
  });

  /// Remove a slot from the timebox
  Future<Either<Failure, TimeboxEntity>> removeSlot({
    required String timeboxId,
    required String slotId,
  });

  /// Reorder slots in the timebox
  Future<Either<Failure, TimeboxEntity>> reorderSlots({
    required String timeboxId,
    required List<String> slotIds,
  });

  /// Reschedule a slot to a new time
  Future<Either<Failure, TimeboxEntity>> rescheduleSlot({
    required String timeboxId,
    required String slotId,
    required DateTime newStartTime,
    required DateTime newEndTime,
  });

  /// Mark a slot as completed
  Future<Either<Failure, TimeboxEntity>> completeSlot({
    required String timeboxId,
    required String slotId,
  });

  /// Mark a slot as skipped
  Future<Either<Failure, TimeboxEntity>> skipSlot({
    required String timeboxId,
    required String slotId,
  });

  // ============================================================
  // CONFLICT DETECTION
  // ============================================================

  /// Detect conflicts in the timebox
  Future<Either<Failure, List<TimeConflict>>> detectConflicts({
    required String timeboxId,
  });

  /// Detect conflicts for a specific slot
  Future<Either<Failure, List<TimeConflict>>> detectConflictsForSlot({
    required String timeboxId,
    required TimeboxSlot slot,
  });

  /// Resolve a conflict
  Future<Either<Failure, TimeboxEntity>> resolveConflict({
    required String timeboxId,
    required String conflictId,
    required ConflictResolution resolution,
  });

  // ============================================================
  // TASK SCHEDULING
  // ============================================================

  /// Schedule a task into the timebox
  Future<Either<Failure, TimeboxEntity>> scheduleTask({
    required String timeboxId,
    required TaskEntity task,
    required DateTime startTime,
    required DateTime endTime,
    required TaskCategory category,
  });

  /// Auto-schedule tasks for the day
  ///
  /// Takes a list of tasks and automatically assigns them to
  /// optimal time slots based on priority, energy levels, and availability.
  Future<Either<Failure, TimeboxEntity>> autoScheduleTasks({
    required String userId,
    required DateTime date,
    required List<TaskEntity> tasks,
    TimeboxSettings? settings,
  });

  /// Get suggested time slot for a task
  Future<Either<Failure, AvailableSlot?>> getSuggestedSlot({
    required String timeboxId,
    required int durationMinutes,
    TaskPriority? priority,
  });

  // ============================================================
  // QUERIES
  // ============================================================

  /// Get timeboxes for a date range
  Future<Either<Failure, List<TimeboxEntity>>> getTimeboxesForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get timebox summary for a date range
  Future<Either<Failure, TimeboxSummary>> getSummaryForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get all priority slots for today
  Future<Either<Failure, List<TimeboxSlot>>> getTodayPrioritySlots({
    required String userId,
  });

  /// Get upcoming slots
  Future<Either<Failure, List<TimeboxSlot>>> getUpcomingSlots({
    required String userId,
    required int limit,
  });

  // ============================================================
  // SETTINGS
  // ============================================================

  /// Get timebox settings for user
  Future<Either<Failure, TimeboxSettings>> getSettings(String userId);

  /// Update timebox settings
  Future<Either<Failure, TimeboxSettings>> updateSettings({
    required String userId,
    required TimeboxSettings settings,
  });

  // ============================================================
  // SYNC & REAL-TIME
  // ============================================================

  /// Watch timebox for real-time updates
  Stream<Either<Failure, TimeboxEntity>> watchTimebox(String timeboxId);

  /// Watch today's timebox
  Stream<Either<Failure, TimeboxEntity>> watchTodayTimebox(String userId);
}

/// Conflict Resolution
///
/// How to resolve a time conflict
class ConflictResolution {
  final ConflictResolutionType type;
  final String? movedSlotId;
  final DateTime? newStartTime;
  final DateTime? newEndTime;

  const ConflictResolution({
    required this.type,
    this.movedSlotId,
    this.newStartTime,
    this.newEndTime,
  });
}

/// Conflict Resolution Type
enum ConflictResolutionType {
  moveFirst, // Move the first conflicting task
  moveSecond, // Move the second conflicting task
  shortenFirst, // Shorten the first task
  shortenSecond, // Shorten the second task
  removeFirst, // Remove the first task
  removeSecond, // Remove the second task
  ignore, // Ignore the conflict
  manual, // Manual resolution with custom times
}
