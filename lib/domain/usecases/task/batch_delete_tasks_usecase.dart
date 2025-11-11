import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/task_repository.dart';

/// Use case for batch deleting multiple tasks
class BatchDeleteTasksUseCase {
  final TaskRepository repository;

  BatchDeleteTasksUseCase(this.repository);

  Future<Either<Failure, void>> call(List<String> taskIds) async {
    if (taskIds.isEmpty) {
      return Left(ValidationFailure(message: 'Task IDs list cannot be empty'));
    }

    if (taskIds.length > 100) {
      return Left(ValidationFailure(
          message: 'Cannot delete more than 100 tasks at once'));
    }

    return await repository.batchDeleteTasks(taskIds);
  }
}
