import 'package:dartz/dartz.dart';
import '../../repositories/comment_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for getting comment count
///
/// Business Rules:
/// - Task ID must be valid
/// - Returns count of non-deleted comments
/// - Includes all comment levels (top-level and replies)
class GetCommentCountUseCase {
  final CommentRepository repository;

  GetCommentCountUseCase(this.repository);

  /// Execute the use case
  ///
  /// [taskId] - ID of the task to count comments for
  Future<Either<Failure, int>> call({
    required String taskId,
  }) async {
    try {
      // Validate task ID
      if (taskId.trim().isEmpty) {
        return Left(ValidationFailure('Task ID is required'));
      }

      return await repository.getCommentCount(taskId);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get comment count: $e'));
    }
  }
}
