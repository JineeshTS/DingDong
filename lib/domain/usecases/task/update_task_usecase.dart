import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for updating an existing task
class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<Either<Failure, TaskEntity>> call(TaskEntity task) async {
    // Validate task title
    if (task.title.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Task title cannot be empty'));
    }

    if (task.title.trim().length > 500) {
      return Left(
          ValidationFailure(message: 'Task title cannot exceed 500 characters'));
    }

    // Validate description if provided
    if (task.description != null && task.description!.length > 5000) {
      return Left(ValidationFailure(
          message: 'Task description cannot exceed 5000 characters'));
    }

    // Validate start date vs due date
    if (task.startDate != null &&
        task.dueDate != null &&
        task.startDate!.isAfter(task.dueDate!)) {
      return Left(ValidationFailure(
          message: 'Start date cannot be after due date'));
    }

    return await repository.updateTask(task);
  }
}
