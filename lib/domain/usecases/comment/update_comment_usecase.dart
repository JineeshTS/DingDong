import 'package:dartz/dartz.dart';
import '../../entities/comment_entity.dart';
import '../../repositories/comment_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for updating a comment
///
/// Business Rules:
/// - Comment must exist
/// - Only author or admins can update
/// - Content must be 1-5000 characters
/// - Marks comment as edited
/// - Cannot change task or parent comment
class UpdateCommentUseCase {
  final CommentRepository repository;

  UpdateCommentUseCase(this.repository);

  /// Execute the use case
  ///
  /// [comment] - The updated comment entity
  Future<Either<Failure, CommentEntity>> call({
    required CommentEntity comment,
  }) async {
    try {
      // Validate comment ID
      if (comment.id.trim().isEmpty) {
        return Left(ValidationFailure('Comment ID is required'));
      }

      // Validate content
      final trimmedContent = comment.content.trim();
      if (trimmedContent.isEmpty) {
        return Left(ValidationFailure('Comment content is required'));
      }
      if (trimmedContent.length > 5000) {
        return Left(ValidationFailure(
            'Comment content must not exceed 5000 characters'));
      }

      // Update the comment with normalized content and edited flag
      final updatedComment = comment.copyWith(
        content: trimmedContent,
        isEdited: true,
        editedAt: DateTime.now(),
      );

      return await repository.updateComment(updatedComment);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update comment: $e'));
    }
  }
}
