import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// Use case for searching tasks with filters
class SearchTasksUseCase {
  final TaskRepository repository;

  SearchTasksUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call({
    required String userId,
    required String query,
    String? listId,
    List<String>? tags,
    TaskPriority? priority,
    TaskStatus? status,
  }) async {
    if (userId.isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    if (query.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Search query cannot be empty'));
    }

    if (query.trim().length < 2) {
      return Left(ValidationFailure(
          message: 'Search query must be at least 2 characters'));
    }

    return await repository.searchTasks(
      userId: userId,
      query: query.trim(),
      listId: listId,
      tags: tags,
      priority: priority,
      status: status,
    );
  }
}
