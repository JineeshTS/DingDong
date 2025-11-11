import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/habit_entity.dart';
import '../../repositories/habit_repository.dart';

/// Use case for undoing a habit check-in
///
/// Business Rules:
/// - Habit must exist and not be deleted
/// - Check-in must exist for the habit
/// - Automatically recalculates current and longest streaks after removal
/// - Idempotent operation - undoing a non-existent check-in returns NotFoundFailure
/// - Recalculates lastCheckInDate to the most recent remaining check-in
class UndoCheckInUseCase {
  final HabitRepository repository;

  UndoCheckInUseCase(this.repository);

  /// Execute the use case
  ///
  /// [habitId] - ID of the habit
  /// [checkInId] - ID of the check-in to remove
  ///
  /// Returns [Either<Failure, HabitEntity>]:
  /// - Left: ValidationFailure if validation fails, NotFoundFailure if check-in doesn't exist
  /// - Right: Updated HabitEntity with recalculated streaks
  Future<Either<Failure, HabitEntity>> call({
    required String habitId,
    required String checkInId,
  }) async {
    // Validate habit ID
    if (habitId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Habit ID cannot be empty'));
    }

    // Validate check-in ID
    if (checkInId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Check-in ID cannot be empty'));
    }

    // Verify habit exists and is not deleted
    final habitResult = await repository.getHabit(habitId);
    final verificationResult = habitResult.fold(
      (failure) => Left(failure),
      (habit) {
        if (habit.isDeleted) {
          return Left(
            ValidationFailure(message: 'Cannot undo check-in for deleted habit'),
          );
        }

        // Verify check-in exists
        final checkInExists = habit.checkIns.any((checkIn) => checkIn.id == checkInId);
        if (!checkInExists) {
          return Left(
            NotFoundFailure(
              message: 'Check-in not found for this habit',
            ),
          );
        }

        return Right(habit);
      },
    );

    if (verificationResult.isLeft()) {
      return verificationResult as Either<Failure, HabitEntity>;
    }

    // Undo check-in (repository will handle streak recalculation)
    return await repository.undoCheckIn(
      habitId: habitId,
      checkInId: checkInId,
    );
  }
}
