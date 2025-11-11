import 'package:dartz/dartz.dart';
import '../../repositories/task_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for removing a subtask from its parent task
///
/// Business Rules:
/// - Subtask must exist
/// - Subtask must have a parent task
/// - Converts subtask to a standalone task (removes parent link)
/// - Does NOT delete the task, only removes parent relationship
class RemoveSubtaskUseCase {
  final TaskRepository repository;

  RemoveSubtaskUseCase(this.repository);

  /// Execute the use case
  ///
  /// [subtaskId] - ID of the subtask to remove from parent
  ///
  /// Returns the updated task (now standalone)
  Future<Either<Failure, void>> call({
    required String subtaskId,
  }) async {
    try {
      // Validate subtask ID
      if (subtaskId.trim().isEmpty) {
        return Left(ValidationFailure('Subtask ID is required'));
      }

      // Get the subtask
      final subtaskResult = await repository.getTaskById(subtaskId);

      return await subtaskResult.fold(
        (failure) => Left(failure),
        (subtask) async {
          // Verify it has a parent
          if (subtask.parentTaskId == null) {
            return Left(ValidationFailure(
                'Task is not a subtask (has no parent)'));
          }

          // Remove parent link by updating the task
          final updatedTask = subtask.copyWith(
            parentTaskId: null,
          );

          final updateResult = await repository.updateTask(updatedTask);

          return updateResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to remove subtask: $e'));
    }
  }
}
