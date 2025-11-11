import 'package:dartz/dartz.dart';
import '../../entities/reminder_entity.dart';
import '../../repositories/reminder_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for disabling a reminder
///
/// Business Rules:
/// - Reminder must exist
/// - Disabling cancels any scheduled notifications
/// - Operation is idempotent (no error if already disabled)
/// - Disabled reminders are retained but not triggered
class DisableReminderUseCase {
  final ReminderRepository repository;

  DisableReminderUseCase(this.repository);

  /// Execute the use case
  ///
  /// [reminderId] - ID of the reminder to disable
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
          // Check if already disabled
          if (!reminder.isEnabled) {
            // Already disabled - idempotent operation
            return Right(reminder);
          }

          // Disable the reminder
          final disabledReminder = reminder.copyWith(
            isEnabled: false,
          );

          return await repository.updateReminder(disabledReminder);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to disable reminder: $e'));
    }
  }
}
