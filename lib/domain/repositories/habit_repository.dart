import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/habit_entity.dart';

/// Habit repository interface
abstract class HabitRepository {
  /// Create a new habit
  Future<Either<Failure, HabitEntity>> createHabit(HabitEntity habit);

  /// Get habit by ID
  Future<Either<Failure, HabitEntity>> getHabit(String id);

  /// Get all habits for user
  Future<Either<Failure, List<HabitEntity>>> getHabits({
    required String userId,
    HabitCategory? category,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get habits by category
  Future<Either<Failure, List<HabitEntity>>> getHabitsByCategory({
    required String userId,
    required HabitCategory category,
  });

  /// Get active habits (not archived)
  Future<Either<Failure, List<HabitEntity>>> getActiveHabits(String userId);

  /// Update habit
  Future<Either<Failure, HabitEntity>> updateHabit(HabitEntity habit);

  /// Delete habit (soft delete)
  Future<Either<Failure, void>> deleteHabit(String id);

  /// Permanently delete habit
  Future<Either<Failure, void>> permanentlyDeleteHabit(String id);

  /// Restore habit
  Future<Either<Failure, HabitEntity>> restoreHabit(String id);

  /// Archive habit
  Future<Either<Failure, HabitEntity>> archiveHabit(String id);

  /// Unarchive habit
  Future<Either<Failure, HabitEntity>> unarchiveHabit(String id);

  /// Check in habit (mark as completed for date)
  Future<Either<Failure, HabitEntity>> checkInHabit({
    required String habitId,
    DateTime? date,
    String? note,
    int count = 1,
  });

  /// Undo check-in
  Future<Either<Failure, HabitEntity>> undoCheckIn({
    required String habitId,
    required String checkInId,
  });

  /// Get habits due today
  Future<Either<Failure, List<HabitEntity>>> getHabitsDueToday(String userId);

  /// Get habit check-in history
  Future<Either<Failure, List<HabitCheckIn>>> getCheckInHistory({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Calculate streak
  Future<Either<Failure, int>> calculateStreak(String habitId);

  /// Get habit statistics
  Future<Either<Failure, Map<String, dynamic>>> getHabitStatistics({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get all habits statistics for user
  Future<Either<Failure, Map<String, dynamic>>> getUserHabitStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get completion rate
  Future<Either<Failure, double>> getCompletionRate({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get best streak
  Future<Either<Failure, int>> getBestStreak(String habitId);

  /// Watch habit (stream)
  Stream<Either<Failure, HabitEntity>> watchHabit(String id);

  /// Watch habits (stream)
  Stream<Either<Failure, List<HabitEntity>>> watchHabits({
    required String userId,
    HabitCategory? category,
  });

  /// Watch habits due today (stream)
  Stream<Either<Failure, List<HabitEntity>>> watchHabitsDueToday(String userId);
}
