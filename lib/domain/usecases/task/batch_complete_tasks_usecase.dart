import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for batch completing multiple tasks
class BatchCompleteTasksUseCase {
  final TaskRepository repository;

  BatchCompleteTasksUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call(List<String> taskIds) async {
    if (taskIds.isEmpty) {
      return Left(
          ValidationFailure(message: 'Task IDs list cannot be empty'));
    }

    if (taskIds.length > 100) {
      return Left(ValidationFailure(
          message: 'Cannot complete more than 100 tasks at once'));
    }

    return await repository.batchCompleteTasks(taskIds);
  }
}
