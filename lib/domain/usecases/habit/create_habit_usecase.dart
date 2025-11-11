import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/habit_entity.dart';
import '../../repositories/habit_repository.dart';

/// Use case for creating a new habit
///
/// Business Rules:
/// - Habit name must be between 1 and 100 characters
/// - Name cannot be empty or whitespace only
/// - Frequency settings must be valid for the selected frequency type
/// - For weekly frequency, target days must be between 1-7
/// - Target count must be positive
/// - Category must be a valid HabitCategory
/// - User ID is required
class CreateHabitUseCase {
  final HabitRepository repository;

  CreateHabitUseCase(this.repository);

  /// Execute the use case
  ///
  /// [habit] - The habit entity to create
  ///
  /// Returns [Either<Failure, HabitEntity>]:
  /// - Left: ValidationFailure if validation fails
  /// - Right: Created HabitEntity on success
  Future<Either<Failure, HabitEntity>> call(HabitEntity habit) async {
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

    // Validate target time if provided (cannot be in the past for today)
    if (habit.targetTime != null) {
      final now = DateTime.now();
      final targetDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        habit.targetTime!.hour,
        habit.targetTime!.minute,
      );
      // This validation is just to ensure the time is valid, not that it's in the future
      // as target time is a preferred time, not a strict deadline
    }

    return await repository.createHabit(habit);
  }

  /// Validates hex color format (#RRGGBB or #RGB)
  bool _isValidHexColor(String color) {
    final hexColorRegex = RegExp(r'^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$');
    return hexColorRegex.hasMatch(color);
  }
}
