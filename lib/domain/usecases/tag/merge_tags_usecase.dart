import 'package:dartz/dartz.dart';
import '../../entities/tag_entity.dart';
import '../../repositories/tag_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for merging tags
///
/// Business Rules:
/// - Source and target tags must exist
/// - Source and target cannot be the same tag
/// - All tasks with source tag will be updated to use target tag
/// - Source tag usage count is added to target tag
/// - Source tag is soft deleted after merge
/// - Operation cannot be undone
class MergeTagsUseCase {
  final TagRepository repository;

  MergeTagsUseCase(this.repository);

  /// Execute the use case
  ///
  /// [sourceTagId] - ID of the tag to merge from (will be deleted)
  /// [targetTagId] - ID of the tag to merge into (will be kept)
  Future<Either<Failure, TagEntity>> call({
    required String sourceTagId,
    required String targetTagId,
  }) async {
    try {
      // Validate tag IDs
      if (sourceTagId.trim().isEmpty) {
        return Left(ValidationFailure('Source tag ID is required'));
      }
      if (targetTagId.trim().isEmpty) {
        return Left(ValidationFailure('Target tag ID is required'));
      }

      // Check they are not the same
      if (sourceTagId == targetTagId) {
        return Left(ValidationFailure(
            'Source and target tags cannot be the same'));
      }

      // Get both tags to verify they exist
      final sourceResult = await repository.getTagById(sourceTagId);
      final targetResult = await repository.getTagById(targetTagId);

      return await sourceResult.fold(
        (failure) => Left(failure),
        (sourceTag) async {
          return await targetResult.fold(
            (failure) => Left(failure),
            (targetTag) async {
              // Perform the merge
              return await repository.mergeTags(
                sourceTagId: sourceTagId,
                targetTagId: targetTagId,
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to merge tags: $e'));
    }
  }
}
