import 'package:dartz/dartz.dart';
import '../../entities/reminder_entity.dart';
import '../../repositories/reminder_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for enabling a reminder
///
/// Business Rules:
/// - Reminder must exist
/// - Enabling schedules the reminder for notification
/// - Operation is idempotent (no error if already enabled)
/// - For time-based reminders, reminder time must still be in the future
class EnableReminderUseCase {
  final ReminderRepository repository;

  EnableReminderUseCase(this.repository);

  /// Execute the use case
  ///
  /// [reminderId] - ID of the reminder to enable
  Future<Either<Failure, ReminderEntity>> call({
    required String reminderId,
  }) async {
    try {
      // Validate reminder ID
      if (reminderId.trim().isEmpty) {
        return Left(ValidationFailure('Reminder ID is required'));
      }

      // Get the reminder
      final reminderResult = await repository.getReminderById(reminderId);

      return await reminderResult.fold(
        (failure) => Left(failure),
        (reminder) async {
          // Check if already enabled
          if (reminder.isEnabled) {
            // Already enabled - idempotent operation
            return Right(reminder);
          }

          // For time-based reminders, verify the time is still in the future
          if (reminder.type == ReminderType.time &&
              reminder.reminderTime != null &&
              reminder.reminderTime!.isBefore(DateTime.now())) {
            return Left(ValidationFailure(
                'Cannot enable time-based reminder with past reminder time'));
          }

          // Enable the reminder
          final enabledReminder = reminder.copyWith(
            isEnabled: true,
          );

          return await repository.updateReminder(enabledReminder);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to enable reminder: $e'));
    }
  }
}
