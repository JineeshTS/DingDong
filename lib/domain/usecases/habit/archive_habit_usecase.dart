import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/habit_entity.dart';
import '../../repositories/habit_repository.dart';

/// Use case for archiving a habit
///
/// Business Rules:
/// - Habit must exist and not be deleted
/// - Archived habits are hidden from active views but not deleted
/// - All check-in history and statistics are preserved
/// - Archived habits do not appear in "due today" or active habit lists
/// - Can be unarchived later to restore to active view
/// - Idempotent operation - archiving an already archived habit succeeds
/// - Archiving does not affect existing streaks or check-ins
class ArchiveHabitUseCase {
  final HabitRepository repository;

  ArchiveHabitUseCase(this.repository);

  /// Execute the use case
  ///
  /// [habitId] - ID of the habit to archive
  ///
  /// Returns [Either<Failure, HabitEntity>]:
  /// - Left: ValidationFailure if habitId is invalid, NotFoundFailure if habit doesn't exist
  /// - Right: Updated HabitEntity with isArchived set to true
  Future<Either<Failure, HabitEntity>> call(String habitId) async {
    // Validate habit ID
    if (habitId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Habit ID cannot be empty'));
    }

    // Verify habit exists and is not deleted
    final habitResult = await repository.getHabit(habitId);
    final verificationResult = habitResult.fold(
      (failure) => Left(failure),
      (habit) {
        if (habit.isDeleted) {
          return Left(
            ValidationFailure(message: 'Cannot archive a deleted habit'),
          );
        }

        // If already archived, return as-is (idempotent)
        if (habit.isArchived) {
          return Right(habit);
        }

        return Right(habit);
      },
    );

    if (verificationResult.isLeft()) {
      return verificationResult as Either<Failure, HabitEntity>;
    }

    // If already archived, return the habit (from verification)
    final existingHabit = verificationResult.getOrElse(() => throw Exception());
    if (existingHabit.isArchived) {
      return Right(existingHabit);
    }

    // Archive the habit
    return await repository.archiveHabit(habitId);
  }
}
