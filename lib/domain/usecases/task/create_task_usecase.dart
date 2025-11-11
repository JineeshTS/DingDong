import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for creating a new task
class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

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

    // Validate due date (cannot be in the past for new tasks)
    if (task.dueDate != null && task.dueDate!.isBefore(DateTime.now())) {
      return Left(ValidationFailure(
          message: 'Due date cannot be in the past'));
    }

    // Validate start date vs due date
    if (task.startDate != null &&
        task.dueDate != null &&
        task.startDate!.isAfter(task.dueDate!)) {
      return Left(ValidationFailure(
          message: 'Start date cannot be after due date'));
    }

    return await repository.createTask(task);
  }
}
