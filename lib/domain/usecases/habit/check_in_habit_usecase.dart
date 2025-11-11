import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/habit_entity.dart';
import '../../repositories/habit_repository.dart';

/// Use case for checking in a habit (marking as completed for a specific date)
///
/// Business Rules:
/// - Habit must exist and not be deleted
/// - Check-in date cannot be in the future
/// - Check-in date defaults to today if not specified
/// - Count must be positive and not exceed target count
/// - Updates current streak if checking in for consecutive days
/// - Updates longest streak if current streak exceeds it
/// - Note is optional and can be up to 500 characters
/// - Can check in multiple times per day if targetCount > 1
class CheckInHabitUseCase {
  final HabitRepository repository;

  CheckInHabitUseCase(this.repository);

  /// Execute the use case
  ///
  /// [habitId] - ID of the habit to check in
  /// [date] - Date of the check-in (defaults to today if not specified)
  /// [note] - Optional note about the check-in
  /// [count] - Number of times completed (default: 1)
  ///
  /// Returns [Either<Failure, HabitEntity>]:
  /// - Left: ValidationFailure if validation fails
  /// - Right: Updated HabitEntity with new check-in and updated streaks
  Future<Either<Failure, HabitEntity>> call({
    required String habitId,
    DateTime? date,
    String? note,
    int count = 1,
  }) async {
    // Validate habit ID
    if (habitId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Habit ID cannot be empty'));
    }

    // Use current date if not specified
    final checkInDate = date ?? DateTime.now();

    // Validate check-in date (cannot be in the future)
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedCheckInDate = DateTime(
      checkInDate.year,
      checkInDate.month,
      checkInDate.day,
    );

    if (normalizedCheckInDate.isAfter(normalizedNow)) {
      return Left(
        ValidationFailure(message: 'Check-in date cannot be in the future'),
      );
    }

    // Validate count
    if (count <= 0) {
      return Left(
        ValidationFailure(message: 'Count must be greater than 0'),
      );
    }

    if (count > 100) {
      return Left(
        ValidationFailure(message: 'Count cannot exceed 100'),
      );
    }

    // Validate note if provided
    if (note != null && note.length > 500) {
      return Left(
        ValidationFailure(message: 'Note cannot exceed 500 characters'),
      );
    }

    // Verify habit exists and is not deleted
    final habitResult = await repository.getHabit(habitId);
    final verificationResult = await habitResult.fold(
      (failure) => Left(failure),
      (habit) async {
        if (habit.isDeleted) {
          return Left(
            ValidationFailure(message: 'Cannot check in a deleted habit'),
          );
        }

        // Validate count against target count
        if (count > habit.targetCount) {
          return Left(
            ValidationFailure(
              message:
                  'Count ($count) cannot exceed target count (${habit.targetCount})',
            ),
          );
        }

        return Right(habit);
      },
    );

    if (verificationResult.isLeft()) {
      return verificationResult as Either<Failure, HabitEntity>;
    }

    // Perform check-in (repository will handle streak calculation)
    return await repository.checkInHabit(
      habitId: habitId,
      date: checkInDate,
      note: note,
      count: count,
    );
  }
}
