import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/habit_entity.dart';
import '../../repositories/habit_repository.dart';

/// Use case for getting habits that are due today
///
/// Business Rules:
/// - Returns only active (non-archived, non-deleted) habits
/// - For daily habits: all habits are due today
/// - For weekly habits: habits where today's day of week is in targetDaysOfWeek
/// - For monthly habits: habits that should be completed this month
/// - Excludes habits already completed today
/// - Ordered by target time if specified, otherwise by creation date
/// - User ID is required
class GetHabitsDueTodayUseCase {
  final HabitRepository repository;

  GetHabitsDueTodayUseCase(this.repository);

  /// Execute the use case
  ///
  /// [userId] - ID of the user whose habits to retrieve
  ///
  /// Returns [Either<Failure, List<HabitEntity>>]:
  /// - Left: ValidationFailure if userId is invalid
  /// - Right: List of HabitEntity that are due today
  Future<Either<Failure, List<HabitEntity>>> call(String userId) async {
    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Get habits due today (repository implements frequency-based logic)
    return await repository.getHabitsDueToday(userId);
  }
}
