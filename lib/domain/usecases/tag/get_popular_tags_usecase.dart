import 'package:dartz/dartz.dart';
import '../../entities/tag_entity.dart';
import '../../repositories/tag_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for retrieving popular tags
///
/// Business Rules:
/// - Returns tags sorted by usage count (descending)
/// - Limit specifies maximum number of tags to return
/// - Only returns non-deleted tags
/// - Default limit is 10 tags
/// - Maximum limit is 100 tags
class GetPopularTagsUseCase {
  final TagRepository repository;

  GetPopularTagsUseCase(this.repository);

  /// Execute the use case
  ///
  /// [limit] - Maximum number of tags to return (default: 10, max: 100)
  Future<Either<Failure, List<TagEntity>>> call({
    int limit = 10,
  }) async {
    try {
      // Validate limit
      if (limit < 1) {
        return Left(ValidationFailure('Limit must be at least 1'));
      }
      if (limit > 100) {
        return Left(ValidationFailure('Limit cannot exceed 100'));
      }

      return await repository.getPopularTags(limit);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get popular tags: $e'));
    }
  }
}
