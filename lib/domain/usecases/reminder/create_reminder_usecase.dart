import 'package:dartz/dartz.dart';
import '../../entities/reminder_entity.dart';
import '../../repositories/reminder_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for creating a reminder
///
/// Business Rules:
/// - Task ID must be valid and exist
/// - Time-based reminders must have a future reminder time
/// - Location-based reminders must have valid coordinates
/// - Maximum 10 reminders per task
/// - Reminder type must be specified
class CreateReminderUseCase {
  final ReminderRepository repository;

  CreateReminderUseCase(this.repository);

  /// Execute the use case
  ///
  /// [reminder] - The reminder entity to create
  Future<Either<Failure, ReminderEntity>> call({
    required ReminderEntity reminder,
  }) async {
    try {
      // Validate task ID
      if (reminder.taskId.trim().isEmpty) {
        return Left(ValidationFailure('Task ID is required'));
      }

      // Validate based on reminder type
      switch (reminder.type) {
        case ReminderType.time:
          if (reminder.reminderTime == null) {
            return Left(ValidationFailure(
                'Reminder time is required for time-based reminders'));
          }

          // Check if reminder time is in the future
          if (reminder.reminderTime!.isBefore(DateTime.now())) {
            return Left(ValidationFailure(
                'Reminder time must be in the future'));
          }
          break;

        case ReminderType.location:
          if (reminder.location == null) {
            return Left(ValidationFailure(
                'Location is required for location-based reminders'));
          }

          // Validate coordinates
          if (reminder.latitude == null || reminder.longitude == null) {
            return Left(ValidationFailure(
                'Valid coordinates are required for location-based reminders'));
          }

          // Validate latitude range
          if (reminder.latitude! < -90 || reminder.latitude! > 90) {
            return Left(ValidationFailure(
                'Latitude must be between -90 and 90 degrees'));
          }

          // Validate longitude range
          if (reminder.longitude! < -180 || reminder.longitude! > 180) {
            return Left(ValidationFailure(
                'Longitude must be between -180 and 180 degrees'));
          }

          // Validate radius
          if (reminder.radius != null && (reminder.radius! < 50 || reminder.radius! > 10000)) {
            return Left(ValidationFailure(
                'Radius must be between 50 and 10000 meters'));
          }
          break;

        case ReminderType.context:
          // Context-based reminders don't require specific validation
          break;
      }

      // Check maximum reminders per task (10)
      final existingReminders = await repository.getRemindersByTaskId(reminder.taskId);

      return await existingReminders.fold(
        (failure) => Left(failure),
        (reminders) async {
          if (reminders.length >= 10) {
            return Left(ValidationFailure(
                'Maximum 10 reminders per task exceeded'));
          }

          return await repository.createReminder(reminder);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to create reminder: $e'));
    }
  }
}
