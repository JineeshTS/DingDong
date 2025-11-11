import 'package:dartz/dartz.dart';
import '../../entities/comment_entity.dart';
import '../../repositories/comment_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for creating a comment
///
/// Business Rules:
/// - Task ID must be valid
/// - Author ID must be valid
/// - Content must be 1-5000 characters
/// - Can optionally be a reply to another comment (thread)
/// - Maximum thread depth is 5 levels
/// - Mentions are extracted from content
class CreateCommentUseCase {
  final CommentRepository repository;

  CreateCommentUseCase(this.repository);

  /// Execute the use case
  ///
  /// [comment] - The comment entity to create
  Future<Either<Failure, CommentEntity>> call({
    required CommentEntity comment,
  }) async {
    try {
      // Validate task ID
      if (comment.taskId.trim().isEmpty) {
        return Left(ValidationFailure('Task ID is required'));
      }

      // Validate author ID
      if (comment.authorId.trim().isEmpty) {
        return Left(ValidationFailure('Author ID is required'));
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

      // If it's a reply, check thread depth
      if (comment.parentCommentId != null) {
        // Get parent comment to check depth
        final parentResult = await repository.getCommentById(comment.parentCommentId!);

        return await parentResult.fold(
          (failure) => Left(failure),
          (parentComment) async {
            // Check thread depth
            int depth = 1;
            CommentEntity? currentComment = parentComment;

            while (currentComment != null && currentComment.parentCommentId != null) {
              depth++;
              if (depth >= 5) {
                return Left(ValidationFailure(
                    'Maximum comment thread depth (5 levels) exceeded'));
              }

              final parentResult = await repository.getCommentById(
                  currentComment.parentCommentId!);
              currentComment = parentResult.fold(
                (_) => null,
                (c) => c,
              );
            }

            // Create the comment with normalized content
            final normalizedComment = comment.copyWith(content: trimmedContent);
            return await repository.createComment(normalizedComment);
          },
        );
      }

      // Create the comment with normalized content
      final normalizedComment = comment.copyWith(content: trimmedContent);
      return await repository.createComment(normalizedComment);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to create comment: $e'));
    }
  }
}
