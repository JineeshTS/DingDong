import 'package:dartz/dartz.dart';
import '../../entities/reminder_entity.dart';
import '../../repositories/reminder_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for retrieving reminders due soon
///
/// Business Rules:
/// - Returns reminders due within specified minutes
/// - Only returns active (enabled) reminders
/// - Only returns time-based reminders
/// - Excludes already triggered reminders
/// - Default window is 60 minutes
class GetRemindersDueSoonUseCase {
  final ReminderRepository repository;

  GetRemindersDueSoonUseCase(this.repository);

  /// Execute the use case
  ///
  /// [withinMinutes] - Get reminders due within this many minutes (default: 60)
  Future<Either<Failure, List<ReminderEntity>>> call({
    int withinMinutes = 60,
  }) async {
    try {
      // Validate input
      if (withinMinutes < 1) {
        return Left(ValidationFailure('Minutes must be at least 1'));
      }
      if (withinMinutes > 1440) { // 24 hours
        return Left(ValidationFailure('Minutes cannot exceed 1440 (24 hours)'));
      }

      final now = DateTime.now();
      final endTime = now.add(Duration(minutes: withinMinutes));

      return await repository.getRemindersDueSoon(
        startTime: now,
        endTime: endTime,
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get reminders due soon: $e'));
    }
  }
}
