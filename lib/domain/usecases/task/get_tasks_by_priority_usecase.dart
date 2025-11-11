import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for getting tasks by priority level
class GetTasksByPriorityUseCase {
  final TaskRepository repository;

  GetTasksByPriorityUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call({
    required String userId,
    required TaskPriority priority,
  }) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getTasksByPriority(
      userId: userId,
      priority: priority,
    );
  }
}
