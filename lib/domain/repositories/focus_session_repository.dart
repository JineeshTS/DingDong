import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/focus_session_entity.dart';

/// Focus session repository interface
abstract class FocusSessionRepository {
  /// Create a new focus session
  Future<Either<Failure, FocusSessionEntity>> createFocusSession(
    FocusSessionEntity session,
  );

  /// Get focus session by ID
  Future<Either<Failure, FocusSessionEntity>> getFocusSession(String id);

  /// Get all focus sessions for user
  Future<Either<Failure, List<FocusSessionEntity>>> getFocusSessions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    FocusSessionType? type,
    FocusSessionStatus? status,
  });

  /// Get focus sessions for task
  Future<Either<Failure, List<FocusSessionEntity>>> getFocusSessionsForTask(
    String taskId,
  );

  /// Get active focus session for user
  Future<Either<Failure, FocusSessionEntity?>> getActiveFocusSession(
    String userId,
  );

  /// Get focus sessions for today
  Future<Either<Failure, List<FocusSessionEntity>>> getFocusSessionsToday(
    String userId,
  );

  /// Update focus session
  Future<Either<Failure, FocusSessionEntity>> updateFocusSession(
    FocusSessionEntity session,
  );

  /// Complete focus session
  Future<Either<Failure, FocusSessionEntity>> completeFocusSession({
    required String sessionId,
    String? notes,
  });

  /// Cancel focus session
  Future<Either<Failure, FocusSessionEntity>> cancelFocusSession(String sessionId);

  /// Pause focus session
  Future<Either<Failure, FocusSessionEntity>> pauseFocusSession(String sessionId);

  /// Resume focus session
  Future<Either<Failure, FocusSessionEntity>> resumeFocusSession(String sessionId);

  /// Add interruption to session
  Future<Either<Failure, FocusSessionEntity>> addInterruption({
    required String sessionId,
    required Duration pauseDuration,
    String? reason,
  });

  /// Delete focus session
  Future<Either<Failure, void>> deleteFocusSession(String id);

  /// Get total focus time
  Future<Either<Failure, Duration>> getTotalFocusTime({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus session count
  Future<Either<Failure, int>> getFocusSessionCount({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get average session duration
  Future<Either<Failure, Duration>> getAverageFocusDuration({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus quality score (average)
  Future<Either<Failure, double>> getAverageFocusQuality({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus time by task
  Future<Either<Failure, Map<String, Duration>>> getFocusTimeByTask({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus time by list
  Future<Either<Failure, Map<String, Duration>>> getFocusTimeByList({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get longest focus streak (consecutive days)
  Future<Either<Failure, int>> getLongestFocusStreak(String userId);

  /// Get current focus streak
  Future<Either<Failure, int>> getCurrentFocusStreak(String userId);

  /// Get focus statistics
  Future<Either<Failure, Map<String, dynamic>>> getFocusStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get focus trends (daily/weekly/monthly)
  Future<Either<Failure, Map<String, dynamic>>> getFocusTrends({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Watch active focus session (stream)
  Stream<Either<Failure, FocusSessionEntity?>> watchActiveFocusSession(
    String userId,
  );

  /// Watch focus sessions (stream)
  Stream<Either<Failure, List<FocusSessionEntity>>> watchFocusSessions({
    required String userId,
    DateTime? startDate,
  });
}
