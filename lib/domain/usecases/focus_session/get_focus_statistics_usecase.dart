import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/focus_session_repository.dart';

/// Use case for getting focus session statistics
///
/// Returns comprehensive statistics including:
/// - Total focus time (completed sessions only)
/// - Total session count (all sessions)
/// - Completed session count
/// - Average session duration
/// - Completion rate (completed vs total sessions)
/// - Average focus quality score
/// - Current streak (consecutive days with at least one session)
/// - Longest streak
///
/// Business Rules:
/// - User ID is required
/// - Date range is optional (defaults to all time)
/// - Only completed sessions count towards total time
/// - Cancelled sessions are excluded from completion rate
/// - Statistics can be filtered by date range
class GetFocusStatisticsUseCase {
  final FocusSessionRepository repository;

  GetFocusStatisticsUseCase(this.repository);

  /// Gets focus session statistics for a user
  ///
  /// Parameters:
  /// - [userId]: The ID of the user
  /// - [startDate]: Optional start date for filtering
  /// - [endDate]: Optional end date for filtering
  ///
  /// Returns:
  /// - Right(FocusStatistics): Statistics object containing all metrics
  /// - Left(ValidationFailure): If validation fails
  /// - Left(Failure): For other errors
  Future<Either<Failure, FocusStatistics>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'User ID is required',
      ));
    }

    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return Left(ValidationFailure(
        message: 'Start date cannot be after end date',
      ));
    }

    // Get statistics from repository
    final statisticsResult = await repository.getFocusStatistics(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    return statisticsResult.fold(
      (failure) => Left(failure),
      (statisticsMap) {
        // Parse and validate the statistics
        try {
          return Right(FocusStatistics.fromMap(statisticsMap));
        } catch (e) {
          return Left(UnknownFailure(
            message: 'Failed to parse focus statistics: ${e.toString()}',
            exception: e,
          ));
        }
      },
    );
  }
}

/// Focus statistics data class
class FocusStatistics {
  final Duration totalFocusTime;
  final int totalSessionCount;
  final int completedSessionCount;
  final int cancelledSessionCount;
  final Duration averageDuration;
  final double completionRate; // 0-100
  final double averageQualityScore; // 0-100
  final int currentStreak;
  final int longestStreak;

  FocusStatistics({
    required this.totalFocusTime,
    required this.totalSessionCount,
    required this.completedSessionCount,
    required this.cancelledSessionCount,
    required this.averageDuration,
    required this.completionRate,
    required this.averageQualityScore,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory FocusStatistics.fromMap(Map<String, dynamic> map) {
    return FocusStatistics(
      totalFocusTime: Duration(seconds: map['totalFocusTimeSeconds'] ?? 0),
      totalSessionCount: map['totalSessionCount'] ?? 0,
      completedSessionCount: map['completedSessionCount'] ?? 0,
      cancelledSessionCount: map['cancelledSessionCount'] ?? 0,
      averageDuration: Duration(seconds: map['averageDurationSeconds'] ?? 0),
      completionRate: (map['completionRate'] ?? 0.0).toDouble(),
      averageQualityScore: (map['averageQualityScore'] ?? 0.0).toDouble(),
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalFocusTimeSeconds': totalFocusTime.inSeconds,
      'totalSessionCount': totalSessionCount,
      'completedSessionCount': completedSessionCount,
      'cancelledSessionCount': cancelledSessionCount,
      'averageDurationSeconds': averageDuration.inSeconds,
      'completionRate': completionRate,
      'averageQualityScore': averageQualityScore,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }
}
