import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/reminder_entity.dart';

/// Reminder repository interface
abstract class ReminderRepository {
  /// Create a new reminder
  Future<Either<Failure, ReminderEntity>> createReminder(ReminderEntity reminder);

  /// Get reminder by ID
  Future<Either<Failure, ReminderEntity>> getReminder(String id);

  /// Get all reminders for task
  Future<Either<Failure, List<ReminderEntity>>> getRemindersForTask(
    String taskId,
  );

  /// Get all reminders for user
  Future<Either<Failure, List<ReminderEntity>>> getReminders({
    required String userId,
    bool includeDeleted = false,
  });

  /// Get active reminders (enabled and not triggered)
  Future<Either<Failure, List<ReminderEntity>>> getActiveReminders(
    String userId,
  );

  /// Get reminders due soon (within next X hours)
  Future<Either<Failure, List<ReminderEntity>>> getRemindersDueSoon({
    required String userId,
    required Duration within,
  });

  /// Get overdue reminders
  Future<Either<Failure, List<ReminderEntity>>> getOverdueReminders(
    String userId,
  );

  /// Get location-based reminders
  Future<Either<Failure, List<ReminderEntity>>> getLocationReminders(
    String userId,
  );

  /// Update reminder
  Future<Either<Failure, ReminderEntity>> updateReminder(ReminderEntity reminder);

  /// Delete reminder
  Future<Either<Failure, void>> deleteReminder(String id);

  /// Permanently delete reminder
  Future<Either<Failure, void>> permanentlyDeleteReminder(String id);

  /// Enable/disable reminder
  Future<Either<Failure, ReminderEntity>> setReminderEnabled({
    required String reminderId,
    required bool enabled,
  });

  /// Mark reminder as triggered
  Future<Either<Failure, ReminderEntity>> markAsTriggered(String reminderId);

  /// Snooze reminder (reschedule for later)
  Future<Either<Failure, ReminderEntity>> snoozeReminder({
    required String reminderId,
    required Duration duration,
  });

  /// Batch create reminders
  Future<Either<Failure, List<ReminderEntity>>> batchCreateReminders(
    List<ReminderEntity> reminders,
  );

  /// Batch delete reminders
  Future<Either<Failure, void>> batchDeleteReminders(List<String> reminderIds);

  /// Delete all reminders for task
  Future<Either<Failure, void>> deleteRemindersForTask(String taskId);

  /// Watch reminder (stream)
  Stream<Either<Failure, ReminderEntity>> watchReminder(String id);

  /// Watch reminders for task (stream)
  Stream<Either<Failure, List<ReminderEntity>>> watchRemindersForTask(
    String taskId,
  );

  /// Watch active reminders (stream) - for notification service
  Stream<Either<Failure, List<ReminderEntity>>> watchActiveReminders(
    String userId,
  );
}
