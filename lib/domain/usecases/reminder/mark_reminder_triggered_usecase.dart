import 'package:dartz/dartz.dart';
import '../../entities/reminder_entity.dart';
import '../../repositories/reminder_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for marking a reminder as triggered
///
/// Business Rules:
/// - Reminder must exist
/// - Sets isTriggered to true and records trigger time
/// - Operation is idempotent (no error if already triggered)
/// - Used when a reminder notification is fired
class MarkReminderTriggeredUseCase {
  final ReminderRepository repository;

  MarkReminderTriggeredUseCase(this.repository);

  /// Execute the use case
  ///
  /// [reminderId] - ID of the reminder to mark as triggered
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
          // Check if already triggered
          if (reminder.isTriggered) {
            // Already triggered - idempotent operation
            return Right(reminder);
          }

          // Mark as triggered
          final triggeredReminder = reminder.copyWith(
            isTriggered: true,
            triggeredAt: DateTime.now(),
          );

          return await repository.updateReminder(triggeredReminder);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to mark reminder as triggered: $e'));
    }
  }
}
