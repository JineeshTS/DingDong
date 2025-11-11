import 'package:dartz/dartz.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for retrieving tasks within a specific date range
///
/// Business Rules:
/// - Start date must be before or equal to end date
/// - Maximum range is 1 year (365 days)
/// - Returns tasks ordered by due date
class GetTasksByDateRangeUseCase {
  final TaskRepository repository;

  GetTasksByDateRangeUseCase(this.repository);

  /// Execute the use case
  ///
  /// [startDate] - Start of the date range (inclusive)
  /// [endDate] - End of the date range (inclusive)
  Future<Either<Failure, List<TaskEntity>>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Validate date range
      if (endDate.isBefore(startDate)) {
        return Left(
            ValidationFailure('End date must be after or equal to start date'));
      }

      // Check maximum range (1 year)
      final daysDifference = endDate.difference(startDate).inDays;
      if (daysDifference > 365) {
        return Left(
            ValidationFailure('Date range cannot exceed 365 days'));
      }

      return await repository.getTasksByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get tasks by date range: $e'));
    }
  }
}
