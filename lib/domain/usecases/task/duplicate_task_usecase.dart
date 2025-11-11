import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for duplicating a task
class DuplicateTaskUseCase {
  final TaskRepository repository;

  DuplicateTaskUseCase(this.repository);

  Future<Either<Failure, TaskEntity>> call(String taskId) async {
    if (taskId.isEmpty) {
      return Left(ValidationFailure(message: 'Task ID cannot be empty'));
    }

    return await repository.duplicateTask(taskId);
  }
}
