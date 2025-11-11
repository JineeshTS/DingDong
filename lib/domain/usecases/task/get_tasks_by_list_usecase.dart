import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for getting tasks by list ID
class GetTasksByListUseCase {
  final TaskRepository repository;

  GetTasksByListUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call(String listId) async {
    if (listId.isEmpty) {
      return Left(ValidationFailure(message: 'List ID cannot be empty'));
    }

    return await repository.getTasksByList(listId);
  }
}
