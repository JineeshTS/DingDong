import 'package:dartz/dartz.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for unarchiving a task
///
/// Business Rules:
/// - Task must exist
/// - Task must be archived to unarchive it
/// - Unarchived tasks return to normal views
/// - Preserves all task properties except archive status
class UnarchiveTaskUseCase {
  final TaskRepository repository;

  UnarchiveTaskUseCase(this.repository);

  /// Execute the use case
  ///
  /// [taskId] - ID of the task to unarchive
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
          // Check if not archived
          if (!task.isArchived) {
            // Already active - idempotent operation
            return Right(task);
          }

          // Unarchive the task
          final unarchivedTask = task.copyWith(
            isArchived: false,
            archivedAt: null,
          );

          return await repository.updateTask(unarchivedTask);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to unarchive task: $e'));
    }
  }
}
