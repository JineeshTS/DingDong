import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/timebox_entity.dart';
import '../../repositories/timebox_repository.dart';

/// Get Daily Timebox Use Case
///
/// Retrieves the timebox (daily agenda) for a specific date.
/// Creates a new timebox if one doesn't exist for the date.
///
/// WBS: 3.7.3.1
class GetDailyTimeboxUseCase {
  final TimeboxRepository _repository;

  const GetDailyTimeboxUseCase(this._repository);

  /// Execute the use case
  ///
  /// Returns [TimeboxEntity] on success, or [Failure] on error.
  Future<Either<Failure, TimeboxEntity>> call(GetDailyTimeboxParams params) async {
    // Validate parameters
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID is required'));
    }

    return await _repository.getTimeboxForDate(
      userId: params.userId,
      date: params.date,
    );
  }
}

/// Parameters for GetDailyTimeboxUseCase
class GetDailyTimeboxParams extends Equatable {
  final String userId;
  final DateTime date;

  const GetDailyTimeboxParams({
    required this.userId,
    required this.date,
  });

  /// Get params for today
  factory GetDailyTimeboxParams.today(String userId) {
    return GetDailyTimeboxParams(
      userId: userId,
      date: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [userId, date];
}
