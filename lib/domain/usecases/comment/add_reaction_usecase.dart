import 'package:dartz/dartz.dart';
import '../../entities/comment_entity.dart';
import '../../repositories/comment_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for adding a reaction to a comment
///
/// Business Rules:
/// - Comment must exist
/// - User ID must be valid
/// - Emoji must be valid Unicode emoji
/// - User can add multiple different reactions
/// - User can only add same reaction once (idempotent)
/// - Maximum 50 reactions per comment
class AddReactionUseCase {
  final CommentRepository repository;

  AddReactionUseCase(this.repository);

  /// Execute the use case
  ///
  /// [commentId] - ID of the comment
  /// [userId] - ID of the user adding the reaction
  /// [emoji] - The emoji reaction (e.g., "👍", "❤️", "😊")
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

      // Get the comment
      final commentResult = await repository.getCommentById(commentId);

      return await commentResult.fold(
        (failure) => Left(failure),
        (comment) async {
          // Check maximum reactions
          final totalReactions = comment.reactions?.values
              .fold<int>(0, (sum, users) => sum + users.length) ?? 0;

          if (totalReactions >= 50) {
            return Left(ValidationFailure(
                'Maximum 50 reactions per comment exceeded'));
          }

          // Add reaction
          return await repository.addReaction(
            commentId: commentId,
            userId: userId,
            emoji: emoji,
          );
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to add reaction: $e'));
    }
  }
}
