import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/habit_repository.dart';

/// Use case for deleting a habit (soft delete)
///
/// Business Rules:
/// - Performs soft delete (sets isDeleted flag to true)
/// - Habit data and check-in history are preserved
/// - Deleted habits are excluded from normal queries
/// - Idempotent operation - deleting an already deleted habit succeeds
/// - Habit ID must be valid and non-empty
class DeleteHabitUseCase {
  final HabitRepository repository;

  DeleteHabitUseCase(this.repository);

  /// Execute the use case
  ///
  /// [habitId] - ID of the habit to delete
  ///
  /// Returns [Either<Failure, void>]:
  /// - Left: ValidationFailure if habitId is invalid
  /// - Right: void on success (idempotent)
  Future<Either<Failure, void>> call(String habitId) async {
    // Validate habit ID
    if (habitId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Habit ID cannot be empty'));
    }

    // Perform soft delete
    // The repository handles the idempotent nature of the operation
    return await repository.deleteHabit(habitId);
  }
}
