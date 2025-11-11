import 'package:dartz/dartz.dart';
import '../../entities/tag_entity.dart';
import '../../repositories/tag_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for restoring a deleted tag
///
/// Business Rules:
/// - Tag must exist and be deleted
/// - Clears the isDeleted flag and deletedAt timestamp
/// - Tag becomes available for use again
/// - Operation is idempotent (no error if already restored)
/// - Must check for name uniqueness in case another tag with same name was created
class RestoreTagUseCase {
  final TagRepository repository;

  RestoreTagUseCase(this.repository);

  /// Execute the use case
  ///
  /// [tagId] - ID of the tag to restore
  Future<Either<Failure, TagEntity>> call({
    required String tagId,
  }) async {
    try {
      // Validate tag ID
      if (tagId.trim().isEmpty) {
        return Left(ValidationFailure('Tag ID is required'));
      }

      // Get the tag
      final tagResult = await repository.getTagById(tagId);

      return await tagResult.fold(
        (failure) => Left(failure),
        (tag) async {
          // Check if already restored
          if (!tag.isDeleted) {
            // Already active - idempotent operation
            return Right(tag);
          }

          // Check for name conflicts with existing active tags
          final existingTagsResult = await repository.getTags();

          return await existingTagsResult.fold(
            (failure) => Left(failure),
            (existingTags) async {
              // Check for duplicate name (case-insensitive, excluding current tag)
              final hasConflict = existingTags.any(
                (t) =>
                    t.id != tag.id &&
                    !t.isDeleted &&
                    t.name.toLowerCase() == tag.name.toLowerCase(),
              );

              if (hasConflict) {
                return Left(ValidationFailure(
                    'Cannot restore tag: Another active tag with name "${tag.name}" already exists'));
              }

              // Restore the tag
              final restoredTag = tag.copyWith(
                isDeleted: false,
                deletedAt: null,
              );

              return await repository.updateTag(restoredTag);
            },
          );
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to restore tag: $e'));
    }
  }
}
