import 'package:dartz/dartz.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for archiving a task
///
/// Business Rules:
/// - Task must exist
/// - Archived tasks are hidden from normal views but not deleted
/// - Can archive both completed and incomplete tasks
/// - Archiving a parent task does NOT automatically archive subtasks
class ArchiveTaskUseCase {
  final TaskRepository repository;

  ArchiveTaskUseCase(this.repository);

  /// Execute the use case
  ///
  /// [taskId] - ID of the task to archive
  Future<Either<Failure, TaskEntity>> call({
    required String taskId,
  }) async {
    try {
      // Validate task ID
      if (taskId.trim().isEmpty) {
        return Left(ValidationFailure('Task ID is required'));
      }

      // Get the task
      final taskResult = await repository.getTaskById(taskId);

      return await taskResult.fold(
        (failure) => Left(failure),
        (task) async {
          // Check if already archived
          if (task.isArchived) {
            // Already archived - idempotent operation
            return Right(task);
          }

          // Archive the task
          final archivedTask = task.copyWith(
            isArchived: true,
            archivedAt: DateTime.now(),
          );

          return await repository.updateTask(archivedTask);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to archive task: $e'));
    }
  }
}
