import 'package:dartz/dartz.dart';
import '../../entities/comment_entity.dart';
import '../../repositories/comment_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for searching comments
///
/// Business Rules:
/// - Query must be at least 2 characters
/// - Searches in comment content and author names
/// - Returns matches sorted by relevance and date
/// - Can filter by task ID
/// - Case-insensitive search
class SearchCommentsUseCase {
  final CommentRepository repository;

  SearchCommentsUseCase(this.repository);

  /// Execute the use case
  ///
  /// [query] - Search query string
  /// [taskId] - Optional task ID to limit search scope
  Future<Either<Failure, List<CommentEntity>>> call({
    required String query,
    String? taskId,
  }) async {
    try {
      // Validate query
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return Left(ValidationFailure('Search query is required'));
      }
      if (trimmedQuery.length < 2) {
        return Left(ValidationFailure(
            'Search query must be at least 2 characters'));
      }
      if (trimmedQuery.length > 100) {
        return Left(ValidationFailure(
            'Search query must not exceed 100 characters'));
      }

      return await repository.searchComments(
        query: trimmedQuery,
        taskId: taskId,
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to search comments: $e'));
    }
  }
}
