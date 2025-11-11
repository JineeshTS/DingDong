import 'package:dartz/dartz.dart';
import '../../entities/reminder_entity.dart';
import '../../repositories/reminder_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for updating a reminder
///
/// Business Rules:
/// - Reminder must exist
/// - Same validation rules as create reminder apply
/// - Time-based reminders must have future reminder time
/// - Location-based reminders must have valid coordinates
/// - If reminder was triggered, it can be updated to reset
class UpdateReminderUseCase {
  final ReminderRepository repository;

  UpdateReminderUseCase(this.repository);

  /// Execute the use case
  ///
  /// [reminder] - The updated reminder entity
  Future<Either<Failure, ReminderEntity>> call({
    required ReminderEntity reminder,
  }) async {
    try {
      // Validate reminder ID
      if (reminder.id.trim().isEmpty) {
        return Left(ValidationFailure('Reminder ID is required'));
      }

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

          // Check if reminder time is in the future (only if not triggered yet)
          if (!reminder.isTriggered &&
              reminder.reminderTime!.isBefore(DateTime.now())) {
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
          if (reminder.radius != null &&
              (reminder.radius! < 50 || reminder.radius! > 10000)) {
            return Left(ValidationFailure(
                'Radius must be between 50 and 10000 meters'));
          }
          break;

        case ReminderType.context:
          // Context-based reminders don't require specific validation
          break;
      }

      return await repository.updateReminder(reminder);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update reminder: $e'));
    }
  }
}
