import 'package:dartz/dartz.dart';
import '../../entities/reminder_entity.dart';
import '../../repositories/reminder_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for snoozing a reminder
///
/// Business Rules:
/// - Reminder must exist and be a time-based reminder
/// - Snooze duration must be between 1 and 1440 minutes (1 minute to 24 hours)
/// - Snoozing updates the reminder time to current time + snooze duration
/// - Resets the triggered state
/// - Ensures the reminder is enabled after snoozing
class SnoozeReminderUseCase {
  final ReminderRepository repository;

  SnoozeReminderUseCase(this.repository);

  /// Execute the use case
  ///
  /// [reminderId] - ID of the reminder to snooze
  /// [snoozeMinutes] - Number of minutes to snooze (default: 10)
  Future<Either<Failure, ReminderEntity>> call({
    required String reminderId,
    int snoozeMinutes = 10,
  }) async {
    try {
      // Validate reminder ID
      if (reminderId.trim().isEmpty) {
        return Left(ValidationFailure('Reminder ID is required'));
      }

      // Validate snooze duration
      if (snoozeMinutes < 1) {
        return Left(ValidationFailure('Snooze duration must be at least 1 minute'));
      }
      if (snoozeMinutes > 1440) { // 24 hours
        return Left(ValidationFailure(
            'Snooze duration cannot exceed 1440 minutes (24 hours)'));
      }

      // Get the reminder
      final reminderResult = await repository.getReminderById(reminderId);

      return await reminderResult.fold(
        (failure) => Left(failure),
        (reminder) async {
          // Verify it's a time-based reminder
          if (reminder.type != ReminderType.time) {
            return Left(ValidationFailure(
                'Only time-based reminders can be snoozed'));
          }

          // Calculate new reminder time
          final newReminderTime = DateTime.now().add(
            Duration(minutes: snoozeMinutes),
          );

          // Update the reminder
          final snoozedReminder = reminder.copyWith(
            reminderTime: newReminderTime,
            isTriggered: false,
            isEnabled: true, // Ensure it's enabled
            lastSnoozedAt: DateTime.now(),
            snoozeCount: (reminder.snoozeCount ?? 0) + 1,
          );

          return await repository.updateReminder(snoozedReminder);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to snooze reminder: $e'));
    }
  }
}
