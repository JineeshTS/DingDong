import 'package:dartz/dartz.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for retrieving upcoming tasks (next 7 days)
///
/// Business Rules:
/// - Returns tasks due within the next 7 days
/// - Excludes completed tasks
/// - Ordered by due date (ascending)
class GetUpcomingTasksUseCase {
  final TaskRepository repository;

  GetUpcomingTasksUseCase(this.repository);

  /// Execute the use case
  ///
  /// Returns tasks due in the next 7 days
  /// Default days: 7
  Future<Either<Failure, List<TaskEntity>>> call({
    int days = 7,
  }) async {
    try {
      // Validate input
      if (days < 1) {
        return Left(ValidationFailure('Days must be at least 1'));
      }
      if (days > 365) {
        return Left(ValidationFailure('Days cannot exceed 365'));
      }

      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = startDate.add(Duration(days: days));

      return await repository.getTasksByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get upcoming tasks: $e'));
    }
  }
}
