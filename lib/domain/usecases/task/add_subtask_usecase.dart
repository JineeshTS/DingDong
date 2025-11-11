import 'package:dartz/dartz.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for adding a subtask to a parent task
///
/// Business Rules:
/// - Subtask title must be at least 1 character
/// - Maximum subtask title length is 500 characters
/// - Parent task must exist
/// - Maximum subtask depth is 5 levels
/// - Subtask inherits listId from parent by default
class AddSubtaskUseCase {
  final TaskRepository repository;

  AddSubtaskUseCase(this.repository);

  /// Execute the use case
  ///
  /// [parentTaskId] - ID of the parent task
  /// [subtaskTitle] - Title of the subtask
  /// [subtaskDescription] - Optional description
  Future<Either<Failure, TaskEntity>> call({
    required String parentTaskId,
    required String subtaskTitle,
    String? subtaskDescription,
  }) async {
    try {
      // Validate parent task ID
      if (parentTaskId.trim().isEmpty) {
        return Left(ValidationFailure('Parent task ID is required'));
      }

      // Validate subtask title
      final trimmedTitle = subtaskTitle.trim();
      if (trimmedTitle.isEmpty) {
        return Left(ValidationFailure('Subtask title is required'));
      }
      if (trimmedTitle.length > 500) {
        return Left(ValidationFailure(
            'Subtask title must not exceed 500 characters'));
      }

      // Get parent task to verify it exists and get its properties
      final parentResult = await repository.getTaskById(parentTaskId);

      return await parentResult.fold(
        (failure) => Left(failure),
        (parentTask) async {
          // Check subtask depth (prevent infinite nesting)
          int currentDepth = 0;
          TaskEntity? currentTask = parentTask;

          while (currentTask != null && currentTask.parentTaskId != null) {
            currentDepth++;
            if (currentDepth >= 5) {
              return Left(ValidationFailure(
                  'Maximum subtask depth (5 levels) exceeded'));
            }

            // Get parent of current task
            final parentResult = await repository.getTaskById(currentTask.parentTaskId!);
            currentTask = parentResult.fold(
              (_) => null,
              (task) => task,
            );
          }

          // Create subtask entity
          final subtask = TaskEntity.create(
            title: trimmedTitle,
            description: subtaskDescription,
            parentTaskId: parentTaskId,
            listId: parentTask.listId, // Inherit list from parent
          );

          // Save the subtask
          return await repository.createTask(subtask);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to add subtask: $e'));
    }
  }
}
