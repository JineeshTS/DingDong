import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for uncompleting a task (marking as incomplete)
class UncompleteTaskUseCase {
  final TaskRepository repository;

  UncompleteTaskUseCase(this.repository);

  Future<Either<Failure, TaskEntity>> call(String taskId) async {
    if (taskId.isEmpty) {
      return Left(ValidationFailure(message: 'Task ID cannot be empty'));
    }

    return await repository.uncompleteTask(taskId);
  }
}
