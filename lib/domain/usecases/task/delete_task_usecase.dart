import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/task_repository.dart';

/// Use case for deleting a task (soft delete)
class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<Either<Failure, void>> call(String taskId) async {
    if (taskId.isEmpty) {
      return Left(ValidationFailure(message: 'Task ID cannot be empty'));
    }

    return await repository.deleteTask(taskId);
  }
}
