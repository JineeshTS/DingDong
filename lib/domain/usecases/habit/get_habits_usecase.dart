import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/habit_entity.dart';
import '../../repositories/habit_repository.dart';

/// Use case for getting all habits with optional filters
///
/// Business Rules:
/// - Returns all habits for a user by default
/// - Can filter by category
/// - Can include/exclude archived habits (default: exclude)
/// - Can include/exclude deleted habits (default: exclude)
/// - User ID is required
/// - Active habits are non-archived, non-deleted habits
class GetHabitsUseCase {
  final HabitRepository repository;

  GetHabitsUseCase(this.repository);

  /// Execute the use case
  ///
  /// [userId] - ID of the user whose habits to retrieve
  /// [category] - Optional category filter
  /// [includeArchived] - Whether to include archived habits (default: false)
  /// [includeDeleted] - Whether to include deleted habits (default: false)
  ///
  /// Returns [Either<Failure, List<HabitEntity>>]:
  /// - Left: ValidationFailure if userId is invalid
  /// - Right: List of HabitEntity matching the filters
  Future<Either<Failure, List<HabitEntity>>> call({
    required String userId,
    HabitCategory? category,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // If category is specified, use category-specific query
    if (category != null) {
      return await repository.getHabitsByCategory(
        userId: userId,
        category: category,
      );
    }

    // Get habits with filters
    return await repository.getHabits(
      userId: userId,
      category: category,
      includeArchived: includeArchived,
      includeDeleted: includeDeleted,
    );
  }
}
