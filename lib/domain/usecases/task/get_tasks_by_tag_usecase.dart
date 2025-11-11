import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for getting tasks by tag
class GetTasksByTagUseCase {
  final TaskRepository repository;

  GetTasksByTagUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call({
    required String userId,
    required String tag,
  }) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    if (tag.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Tag cannot be empty'));
    }

    return await repository.getTasksByTag(
      userId: userId,
      tag: tag.trim(),
    );
  }
}
