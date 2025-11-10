import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/comment_entity.dart';

/// Comment repository interface
abstract class CommentRepository {
  /// Create a new comment
  Future<Either<Failure, CommentEntity>> createComment(CommentEntity comment);

  /// Get comment by ID
  Future<Either<Failure, CommentEntity>> getComment(String id);

  /// Get all comments for task
  Future<Either<Failure, List<CommentEntity>>> getCommentsForTask({
    required String taskId,
    bool includeDeleted = false,
  });

  /// Get replies to a comment
  Future<Either<Failure, List<CommentEntity>>> getReplies(String commentId);

  /// Get comments by user
  Future<Either<Failure, List<CommentEntity>>> getCommentsByUser({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get comments mentioning user
  Future<Either<Failure, List<CommentEntity>>> getCommentsMentioningUser(
    String userId,
  );

  /// Update comment
  Future<Either<Failure, CommentEntity>> updateComment(CommentEntity comment);

  /// Delete comment (soft delete)
  Future<Either<Failure, void>> deleteComment(String id);

  /// Permanently delete comment
  Future<Either<Failure, void>> permanentlyDeleteComment(String id);

  /// Restore comment
  Future<Either<Failure, CommentEntity>> restoreComment(String id);

  /// Add reaction to comment
  Future<Either<Failure, CommentEntity>> addReaction({
    required String commentId,
    required String userId,
    required String emoji,
  });

  /// Remove reaction from comment
  Future<Either<Failure, CommentEntity>> removeReaction({
    required String commentId,
    required String userId,
    required String emoji,
  });

  /// Search comments
  Future<Either<Failure, List<CommentEntity>>> searchComments({
    required String taskId,
    required String query,
  });

  /// Batch delete comments
  Future<Either<Failure, void>> batchDeleteComments(List<String> commentIds);

  /// Delete all comments for task
  Future<Either<Failure, void>> deleteCommentsForTask(String taskId);

  /// Get comment count for task
  Future<Either<Failure, int>> getCommentCount(String taskId);

  /// Watch comment (stream)
  Stream<Either<Failure, CommentEntity>> watchComment(String id);

  /// Watch comments for task (stream)
  Stream<Either<Failure, List<CommentEntity>>> watchCommentsForTask(
    String taskId,
  );

  /// Get comment statistics
  Future<Either<Failure, Map<String, dynamic>>> getCommentStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
}
