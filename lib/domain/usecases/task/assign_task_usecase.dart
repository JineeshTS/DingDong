import 'package:dartz/dartz.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for assigning a task to user(s)
///
/// Business Rules:
/// - Task must exist
/// - At least one assignee is required
/// - Maximum 10 assignees per task
/// - User IDs must be valid (non-empty strings)
/// - Duplicate assignees are automatically removed
class AssignTaskUseCase {
  final TaskRepository repository;

  AssignTaskUseCase(this.repository);

  /// Execute the use case
  ///
  /// [taskId] - ID of the task to assign
  /// [assigneeIds] - List of user IDs to assign the task to
  /// [replace] - If true, replaces all existing assignees; if false, adds to existing
  Future<Either<Failure, TaskEntity>> call({
    required String taskId,
    required List<String> assigneeIds,
    bool replace = false,
  }) async {
    try {
      // Validate task ID
      if (taskId.trim().isEmpty) {
        return Left(ValidationFailure('Task ID is required'));
      }

      // Validate assignee list
      if (assigneeIds.isEmpty) {
        return Left(ValidationFailure('At least one assignee is required'));
      }

      // Remove duplicates and empty strings
      final validAssigneeIds = assigneeIds
          .where((id) => id.trim().isNotEmpty)
          .toSet()
          .toList();

      if (validAssigneeIds.isEmpty) {
        return Left(ValidationFailure('No valid assignee IDs provided'));
      }

      if (validAssigneeIds.length > 10) {
        return Left(
            ValidationFailure('Maximum 10 assignees allowed per task'));
      }

      // Get the task
      final taskResult = await repository.getTaskById(taskId);

      return await taskResult.fold(
        (failure) => Left(failure),
        (task) async {
          // Determine final assignee list
          List<String> finalAssignees;

          if (replace) {
            finalAssignees = validAssigneeIds;
          } else {
            // Merge with existing assignees
            final existingAssignees = task.assignedTo ?? [];
            final merged = {...existingAssignees, ...validAssigneeIds}.toList();

            if (merged.length > 10) {
              return Left(ValidationFailure(
                  'Adding these assignees would exceed the maximum of 10 assignees'));
            }

            finalAssignees = merged;
          }

          // Update task with new assignees
          final updatedTask = task.copyWith(
            assignedTo: finalAssignees,
          );

          return await repository.updateTask(updatedTask);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to assign task: $e'));
    }
  }
}
