import 'package:dartz/dartz.dart';
import '../../entities/comment_entity.dart';
import '../../repositories/comment_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for retrieving comments with mentions
///
/// Business Rules:
/// - User ID must be valid
/// - Returns comments where user is mentioned
/// - Ordered by date (newest first)
/// - Only returns non-deleted comments
class GetCommentsWithMentionsUseCase {
  final CommentRepository repository;

  GetCommentsWithMentionsUseCase(this.repository);

  /// Execute the use case
  ///
  /// [userId] - ID of the user to find mentions for
  Future<Either<Failure, List<CommentEntity>>> call({
    required String userId,
  }) async {
    try {
      // Validate user ID
      if (userId.trim().isEmpty) {
        return Left(ValidationFailure('User ID is required'));
      }

      return await repository.getCommentsWithMentions(userId);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get comments with mentions: $e'));
    }
  }
}
