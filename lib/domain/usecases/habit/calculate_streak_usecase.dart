import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/habit_repository.dart';

/// Use case for calculating the current streak for a habit
///
/// Business Rules:
/// - Calculates the current consecutive days the habit has been completed
/// - Streak breaks if a day is missed (no check-in for a day)
/// - For daily habits: checks consecutive calendar days
/// - For weekly habits: checks if target days per week were met
/// - For monthly habits: checks if target was met each month
/// - Habit must exist
/// - Returns 0 if no check-ins exist or streak is broken
class CalculateStreakUseCase {
  final HabitRepository repository;

  CalculateStreakUseCase(this.repository);

  /// Execute the use case
  ///
  /// [habitId] - ID of the habit to calculate streak for
  ///
  /// Returns [Either<Failure, int>]:
  /// - Left: ValidationFailure if habitId is invalid, NotFoundFailure if habit doesn't exist
  /// - Right: Current streak count (number of consecutive periods)
  Future<Either<Failure, int>> call(String habitId) async {
    // Validate habit ID
    if (habitId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Habit ID cannot be empty'));
    }

    // Verify habit exists
    final habitResult = await repository.getHabit(habitId);
    final verificationResult = habitResult.fold(
      (failure) => Left(failure),
      (habit) => Right(habit),
    );

    if (verificationResult.isLeft()) {
      return verificationResult as Either<Failure, int>;
    }

    // Calculate streak (repository implements the logic based on frequency)
    return await repository.calculateStreak(habitId);
  }
}
