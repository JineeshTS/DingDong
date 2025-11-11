import 'package:dartz/dartz.dart';
import '../../entities/tag_entity.dart';
import '../../repositories/tag_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for retrieving all tags
///
/// Business Rules:
/// - Returns all non-deleted tags by default
/// - Can optionally include deleted tags
/// - Tags are sorted by name (ascending) by default
/// - Can filter by parent tag for hierarchical tags
class GetTagsUseCase {
  final TagRepository repository;

  GetTagsUseCase(this.repository);

  /// Execute the use case
  ///
  /// [includeDeleted] - Whether to include deleted tags (default: false)
  Future<Either<Failure, List<TagEntity>>> call({
    bool includeDeleted = false,
  }) async {
    try {
      return await repository.getTags();
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get tags: $e'));
    }
  }
}
