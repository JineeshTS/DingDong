import 'package:dartz/dartz.dart';
import '../../repositories/reminder_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for deleting a reminder
///
/// Business Rules:
/// - Reminder ID must be valid
/// - Operation is idempotent (no error if reminder doesn't exist)
/// - Deleting a reminder cancels any scheduled notifications
class DeleteReminderUseCase {
  final ReminderRepository repository;

  DeleteReminderUseCase(this.repository);

  /// Execute the use case
  ///
  /// [reminderId] - ID of the reminder to delete
  Future<Either<Failure, void>> call({
    required String reminderId,
  }) async {
    try {
      // Validate reminder ID
      if (reminderId.trim().isEmpty) {
        return Left(ValidationFailure('Reminder ID is required'));
      }

      return await repository.deleteReminder(reminderId);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to delete reminder: $e'));
    }
  }
}
