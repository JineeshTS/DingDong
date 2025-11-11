import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/habit_entity.dart';
import '../../repositories/habit_repository.dart';

/// Use case for updating an existing habit
///
/// Business Rules:
/// - Habit must exist (checked by repository)
/// - Same validation rules as create habit apply
/// - Habit name must be between 1 and 100 characters
/// - Frequency settings must be valid for the selected frequency type
/// - For weekly frequency, target days must be between 1-7
/// - Target count must be positive
/// - Category must be a valid HabitCategory
/// - Cannot update deleted habits
class UpdateHabitUseCase {
  final HabitRepository repository;

  UpdateHabitUseCase(this.repository);

  /// Execute the use case
  ///
  /// [habit] - The habit entity with updates
  ///
  /// Returns [Either<Failure, HabitEntity>]:
  /// - Left: ValidationFailure if validation fails or NotFoundFailure if habit doesn't exist
  /// - Right: Updated HabitEntity on success
  Future<Either<Failure, HabitEntity>> call(HabitEntity habit) async {
    // Validate habit ID
    if (habit.id.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Habit ID is required'));
    }

    // Verify habit exists and is not deleted
    final existingHabitResult = await repository.getHabit(habit.id);
    final verificationResult = existingHabitResult.fold(
      (failure) => Left(failure),
      (existingHabit) {
        if (existingHabit.isDeleted) {
          return Left(
            ValidationFailure(message: 'Cannot update a deleted habit'),
          );
        }
        return Right(existingHabit);
      },
    );

    if (verificationResult.isLeft()) {
      return verificationResult as Either<Failure, HabitEntity>;
    }

    // Validate habit name
    if (habit.name.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Habit name cannot be empty'));
    }

    if (habit.name.trim().length > 100) {
      return Left(
        ValidationFailure(message: 'Habit name cannot exceed 100 characters'),
      );
    }

    // Validate user ID
    if (habit.userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID is required'));
    }

    // Validate description if provided
    if (habit.description != null && habit.description!.length > 1000) {
      return Left(
        ValidationFailure(
          message: 'Habit description cannot exceed 1000 characters',
        ),
      );
    }

    // Validate target count
    if (habit.targetCount <= 0) {
      return Left(
        ValidationFailure(message: 'Target count must be greater than 0'),
      );
    }

    if (habit.targetCount > 100) {
      return Left(
        ValidationFailure(message: 'Target count cannot exceed 100'),
      );
    }

    // Validate frequency-specific settings
    if (habit.frequency == HabitFrequency.weekly) {
      // For weekly habits, validate target days of week
      if (habit.targetDaysOfWeek.isEmpty) {
        return Left(
          ValidationFailure(
            message: 'Weekly habits must have at least one target day',
          ),
        );
      }

      // Validate day values (1-7)
      for (final day in habit.targetDaysOfWeek) {
        if (day < 1 || day > 7) {
          return Left(
            ValidationFailure(
              message: 'Target days must be between 1 (Monday) and 7 (Sunday)',
            ),
          );
        }
      }

      // Check for duplicates
      if (habit.targetDaysOfWeek.length !=
          habit.targetDaysOfWeek.toSet().length) {
        return Left(
          ValidationFailure(message: 'Target days cannot contain duplicates'),
        );
      }
    }

    // Validate color format (hex color)
    if (!_isValidHexColor(habit.color)) {
      return Left(
        ValidationFailure(message: 'Color must be a valid hex color code'),
      );
    }

    return await repository.updateHabit(habit);
  }

  /// Validates hex color format (#RRGGBB or #RGB)
  bool _isValidHexColor(String color) {
    final hexColorRegex = RegExp(r'^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$');
    return hexColorRegex.hasMatch(color);
  }
}
