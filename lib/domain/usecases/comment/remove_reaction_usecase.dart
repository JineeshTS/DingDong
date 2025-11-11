import 'package:dartz/dartz.dart';
import '../../entities/comment_entity.dart';
import '../../repositories/comment_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for removing a reaction from a comment
///
/// Business Rules:
/// - Comment must exist
/// - User ID must be valid
/// - Emoji must match an existing reaction
/// - Operation is idempotent (no error if reaction doesn't exist)
class RemoveReactionUseCase {
  final CommentRepository repository;

  RemoveReactionUseCase(this.repository);

  /// Execute the use case
  ///
  /// [commentId] - ID of the comment
  /// [userId] - ID of the user removing the reaction
  /// [emoji] - The emoji reaction to remove
  Future<Either<Failure, CommentEntity>> call({
    required String commentId,
    required String userId,
    required String emoji,
  }) async {
    try {
      // Validate comment ID
      if (commentId.trim().isEmpty) {
        return Left(ValidationFailure('Comment ID is required'));
      }

      // Validate user ID
      if (userId.trim().isEmpty) {
        return Left(ValidationFailure('User ID is required'));
      }

      // Validate emoji
      if (emoji.trim().isEmpty) {
        return Left(ValidationFailure('Emoji is required'));
      }

      // Remove reaction
      return await repository.removeReaction(
        commentId: commentId,
        userId: userId,
        emoji: emoji,
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to remove reaction: $e'));
    }
  }
}
