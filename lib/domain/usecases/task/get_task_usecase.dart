import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for getting a single task by ID
class GetTaskUseCase {
  final TaskRepository repository;

  GetTaskUseCase(this.repository);

  Future<Either<Failure, TaskEntity>> call(String taskId) async {
    if (taskId.isEmpty) {
      return Left(ValidationFailure(message: 'Task ID cannot be empty'));
    }

    return await repository.getTask(taskId);
  }
}
