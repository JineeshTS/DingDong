import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/habit_repository.dart';

/// Use case for getting comprehensive statistics for a habit
///
/// Business Rules:
/// - Returns statistics for the specified date range or all-time if not specified
/// - Statistics include:
///   - Completion rate (percentage of days/periods completed)
///   - Current streak
///   - Longest streak (best streak ever)
///   - Total check-ins
///   - Total days tracked
///   - Average completions per week
///   - Check-in history for the period
///   - Best day of week (for weekly habits)
///   - Best time of day (if target times are used)
/// - Habit must exist
/// - Date range validation: start date must be before end date
/// - If no date range specified, uses all-time statistics
class GetHabitStatisticsUseCase {
  final HabitRepository repository;

  GetHabitStatisticsUseCase(this.repository);

  /// Execute the use case
  ///
  /// [habitId] - ID of the habit to get statistics for
  /// [startDate] - Optional start date for the statistics period
  /// [endDate] - Optional end date for the statistics period
  ///
  /// Returns [Either<Failure, Map<String, dynamic>>]:
  /// - Left: ValidationFailure if validation fails, NotFoundFailure if habit doesn't exist
  /// - Right: Map containing statistics data:
  ///   - 'completionRate': double (0-100)
  ///   - 'currentStreak': int
  ///   - 'longestStreak': int
  ///   - 'totalCheckIns': int
  ///   - 'totalDaysTracked': int
  ///   - 'averagePerWeek': double
  ///   - 'checkInHistory': List<HabitCheckIn>
  ///   - Additional frequency-specific statistics
  Future<Either<Failure, Map<String, dynamic>>> call({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validate habit ID
    if (habitId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Habit ID cannot be empty'));
    }

    // Validate date range if both dates are provided
    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        return Left(
          ValidationFailure(message: 'Start date must be before end date'),
        );
      }

      // Validate dates are not in the future
      final now = DateTime.now();
      if (endDate.isAfter(now)) {
        return Left(
          ValidationFailure(message: 'End date cannot be in the future'),
        );
      }
    }

    // If only end date is provided, validate it's not in the future
    if (endDate != null && startDate == null) {
      final now = DateTime.now();
      if (endDate.isAfter(now)) {
        return Left(
          ValidationFailure(message: 'End date cannot be in the future'),
        );
      }
    }

    // Verify habit exists
    final habitResult = await repository.getHabit(habitId);
    final verificationResult = habitResult.fold(
      (failure) => Left(failure),
      (habit) => Right(habit),
    );

    if (verificationResult.isLeft()) {
      return verificationResult as Either<Failure, Map<String, dynamic>>;
    }

    // Get statistics from repository
    return await repository.getHabitStatistics(
      habitId: habitId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
