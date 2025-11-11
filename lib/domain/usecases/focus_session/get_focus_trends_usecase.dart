import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/focus_session_repository.dart';

/// Use case for getting focus session trends over time
///
/// Returns trend data showing how focus patterns change over time:
/// - Daily trends: Session count and total time per day
/// - Weekly trends: Session count and total time per week
/// - Monthly trends: Session count and total time per month
/// - Quality score trends over time
/// - Completion rate trends
///
/// Business Rules:
/// - User ID is required
/// - Date range is required (start and end dates)
/// - Start date cannot be after end date
/// - Data is aggregated by the requested granularity (daily/weekly/monthly)
/// - Only completed sessions are included in time calculations
class GetFocusTrendsUseCase {
  final FocusSessionRepository repository;

  GetFocusTrendsUseCase(this.repository);

  /// Gets focus session trends for a user
  ///
  /// Parameters:
  /// - [userId]: The ID of the user
  /// - [startDate]: Start date for the trend analysis
  /// - [endDate]: End date for the trend analysis
  /// - [granularity]: The granularity of the trend data (daily/weekly/monthly)
  ///
  /// Returns:
  /// - Right(FocusTrends): Trends object containing time-series data
  /// - Left(ValidationFailure): If validation fails
  /// - Left(Failure): For other errors
  Future<Either<Failure, FocusTrends>> call({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    TrendGranularity granularity = TrendGranularity.daily,
  }) async {
    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'User ID is required',
      ));
    }

    // Validate date range
    if (startDate.isAfter(endDate)) {
      return Left(ValidationFailure(
        message: 'Start date cannot be after end date',
      ));
    }

    // Validate date range is not too large (prevent excessive data)
    final daysDifference = endDate.difference(startDate).inDays;
    if (granularity == TrendGranularity.daily && daysDifference > 365) {
      return Left(ValidationFailure(
        message: 'Daily trends cannot span more than 365 days',
      ));
    }

    if (granularity == TrendGranularity.weekly && daysDifference > 730) {
      return Left(ValidationFailure(
        message: 'Weekly trends cannot span more than 2 years',
      ));
    }

    // Get trends from repository
    final trendsResult = await repository.getFocusTrends(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    return trendsResult.fold(
      (failure) => Left(failure),
      (trendsMap) {
        // Parse and validate the trends
        try {
          return Right(FocusTrends.fromMap(trendsMap, granularity));
        } catch (e) {
          return Left(UnknownFailure(
            message: 'Failed to parse focus trends: ${e.toString()}',
            exception: e,
          ));
        }
      },
    );
  }
}

/// Trend granularity options
enum TrendGranularity {
  daily,
  weekly,
  monthly,
}

/// Focus trends data class
class FocusTrends {
  final List<TrendDataPoint> dataPoints;
  final TrendGranularity granularity;
  final DateTime startDate;
  final DateTime endDate;

  FocusTrends({
    required this.dataPoints,
    required this.granularity,
    required this.startDate,
    required this.endDate,
  });

  factory FocusTrends.fromMap(
    Map<String, dynamic> map,
    TrendGranularity granularity,
  ) {
    final List<dynamic> dataPointsList = map['dataPoints'] ?? [];
    final dataPoints = dataPointsList
        .map((point) => TrendDataPoint.fromMap(point as Map<String, dynamic>))
        .toList();

    return FocusTrends(
      dataPoints: dataPoints,
      granularity: granularity,
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dataPoints': dataPoints.map((point) => point.toMap()).toList(),
      'granularity': granularity.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

/// Individual data point in the trend
class TrendDataPoint {
  final DateTime date;
  final int sessionCount;
  final Duration totalTime;
  final double averageQualityScore;
  final double completionRate;

  TrendDataPoint({
    required this.date,
    required this.sessionCount,
    required this.totalTime,
    required this.averageQualityScore,
    required this.completionRate,
  });

  factory TrendDataPoint.fromMap(Map<String, dynamic> map) {
    return TrendDataPoint(
      date: DateTime.parse(map['date']),
      sessionCount: map['sessionCount'] ?? 0,
      totalTime: Duration(seconds: map['totalTimeSeconds'] ?? 0),
      averageQualityScore: (map['averageQualityScore'] ?? 0.0).toDouble(),
      completionRate: (map['completionRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'sessionCount': sessionCount,
      'totalTimeSeconds': totalTime.inSeconds,
      'averageQualityScore': averageQualityScore,
      'completionRate': completionRate,
    };
  }
}
