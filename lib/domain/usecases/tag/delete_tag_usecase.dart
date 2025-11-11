import 'package:dartz/dartz.dart';
import '../../repositories/tag_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for deleting a tag (soft delete)
///
/// Business Rules:
/// - Tag ID must be valid
/// - Operation is soft delete (sets isDeleted flag)
/// - Can be restored later
/// - Tasks with this tag are not affected
/// - Operation is idempotent (no error if already deleted)
class DeleteTagUseCase {
  final TagRepository repository;

  DeleteTagUseCase(this.repository);

  /// Execute the use case
  ///
  /// [tagId] - ID of the tag to delete
  Future<Either<Failure, void>> call({
    required String tagId,
  }) async {
    try {
      // Validate tag ID
      if (tagId.trim().isEmpty) {
        return Left(ValidationFailure('Tag ID is required'));
      }

      return await repository.deleteTag(tagId);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to delete tag: $e'));
    }
  }
}
