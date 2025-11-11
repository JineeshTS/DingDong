import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for getting completed tasks in a date range
class GetCompletedTasksUseCase {
  final TaskRepository repository;

  GetCompletedTasksUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return Left(ValidationFailure(
          message: 'Start date cannot be after end date'));
    }

    return await repository.getCompletedTasks(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
