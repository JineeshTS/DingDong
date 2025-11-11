import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/focus_session_repository.dart';

/// Use case for getting total focus time for a specific task
///
/// Business Rules:
/// - Task ID is required
/// - Returns total time from all completed focus sessions for the task
/// - Only completed sessions are counted
/// - Can be filtered by date range
/// - Returns zero if no sessions found for the task
class GetFocusTimeByTaskUseCase {
  final FocusSessionRepository repository;

  GetFocusTimeByTaskUseCase(this.repository);

  /// Gets total focus time for a specific task
  ///
  /// Parameters:
  /// - [taskId]: The ID of the task
  /// - [startDate]: Optional start date for filtering
  /// - [endDate]: Optional end date for filtering
  ///
  /// Returns:
  /// - Right(TaskFocusTime): Object containing task focus time data
  /// - Left(ValidationFailure): If validation fails
  /// - Left(Failure): For other errors
  Future<Either<Failure, TaskFocusTime>> call({
    required String taskId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validate task ID
    if (taskId.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Task ID is required',
      ));
    }

    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return Left(ValidationFailure(
        message: 'Start date cannot be after end date',
      ));
    }

    // Get all focus sessions for the task
    final sessionsResult = await repository.getFocusSessionsForTask(taskId);

    return sessionsResult.fold(
      (failure) => Left(failure),
      (sessions) {
        // Filter by date range if provided
        var filteredSessions = sessions;
        if (startDate != null) {
          filteredSessions = filteredSessions
              .where((session) => session.startTime.isAfter(startDate))
              .toList();
        }
        if (endDate != null) {
          filteredSessions = filteredSessions
              .where((session) => session.startTime.isBefore(endDate))
              .toList();
        }

        // Calculate total focus time from completed sessions
        Duration totalTime = Duration.zero;
        int completedSessionCount = 0;
        double totalQuality = 0.0;

        for (final session in filteredSessions) {
          if (session.isCompleted && session.actualDuration != null) {
            totalTime += session.actualDuration!;
            completedSessionCount++;
            totalQuality += session.focusQuality;
          }
        }

        final averageQuality = completedSessionCount > 0
            ? totalQuality / completedSessionCount
            : 0.0;

        return Right(TaskFocusTime(
          taskId: taskId,
          totalFocusTime: totalTime,
          sessionCount: completedSessionCount,
          averageQualityScore: averageQuality,
        ));
      },
    );
  }
}

/// Task focus time data class
class TaskFocusTime {
  final String taskId;
  final Duration totalFocusTime;
  final int sessionCount;
  final double averageQualityScore;

  TaskFocusTime({
    required this.taskId,
    required this.totalFocusTime,
    required this.sessionCount,
    required this.averageQualityScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'totalFocusTimeSeconds': totalFocusTime.inSeconds,
      'sessionCount': sessionCount,
      'averageQualityScore': averageQualityScore,
    };
  }

  factory TaskFocusTime.fromMap(Map<String, dynamic> map) {
    return TaskFocusTime(
      taskId: map['taskId'],
      totalFocusTime: Duration(seconds: map['totalFocusTimeSeconds'] ?? 0),
      sessionCount: map['sessionCount'] ?? 0,
      averageQualityScore: (map['averageQualityScore'] ?? 0.0).toDouble(),
    );
  }
}
