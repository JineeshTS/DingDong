import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for moving a task to a different list
class MoveTaskUseCase {
  final TaskRepository repository;

  MoveTaskUseCase(this.repository);

  Future<Either<Failure, TaskEntity>> call({
    required String taskId,
    required String newListId,
  }) async {
    if (taskId.isEmpty) {
      return Left(ValidationFailure(message: 'Task ID cannot be empty'));
    }

    if (newListId.isEmpty) {
      return Left(ValidationFailure(message: 'New list ID cannot be empty'));
    }

    return await repository.moveTask(
      taskId: taskId,
      newListId: newListId,
    );
  }
}
