import 'package:dartz/dartz.dart';
import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for removing assignment(s) from a task
///
/// Business Rules:
/// - Task must exist
/// - At least one user ID must be provided to unassign
/// - If user is not assigned, operation succeeds (idempotent)
/// - Can unassign specific users or all users
class UnassignTaskUseCase {
  final TaskRepository repository;

  UnassignTaskUseCase(this.repository);

  /// Execute the use case
  ///
  /// [taskId] - ID of the task
  /// [userIds] - List of user IDs to unassign. If null or empty, unassigns all users
  Future<Either<Failure, TaskEntity>> call({
    required String taskId,
    List<String>? userIds,
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
          final currentAssignees = task.assignedTo ?? [];

          List<String> updatedAssignees;

          if (userIds == null || userIds.isEmpty) {
            // Unassign all users
            updatedAssignees = [];
          } else {
            // Unassign specific users
            final usersToRemove = userIds
                .where((id) => id.trim().isNotEmpty)
                .toSet();

            updatedAssignees = currentAssignees
                .where((id) => !usersToRemove.contains(id))
                .toList();
          }

          // Update task with new assignee list
          final updatedTask = task.copyWith(
            assignedTo: updatedAssignees.isEmpty ? null : updatedAssignees,
          );

          return await repository.updateTask(updatedTask);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to unassign task: $e'));
    }
  }
}
