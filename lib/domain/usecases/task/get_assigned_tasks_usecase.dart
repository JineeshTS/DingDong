import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for getting tasks assigned to a user
class GetAssignedTasksUseCase {
  final TaskRepository repository;

  GetAssignedTasksUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call(String userId) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getAssignedTasks(userId);
  }
}
