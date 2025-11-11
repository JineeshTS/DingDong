import 'package:dartz/dartz.dart';
import '../../repositories/comment_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for deleting a comment
///
/// Business Rules:
/// - Comment ID must be valid
/// - Only author or admins can delete
/// - Operation is soft delete (marks as deleted)
/// - Replies are preserved but show "[deleted]"
/// - Operation is idempotent
class DeleteCommentUseCase {
  final CommentRepository repository;

  DeleteCommentUseCase(this.repository);

  /// Execute the use case
  ///
  /// [commentId] - ID of the comment to delete
  Future<Either<Failure, void>> call({
    required String commentId,
  }) async {
    try {
      // Validate comment ID
      if (commentId.trim().isEmpty) {
        return Left(ValidationFailure('Comment ID is required'));
      }

      return await repository.deleteComment(commentId);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to delete comment: $e'));
    }
  }
}
