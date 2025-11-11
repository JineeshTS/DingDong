import 'package:dartz/dartz.dart';
import '../../repositories/tag_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for incrementing tag usage count
///
/// Business Rules:
/// - Tag must exist
/// - Increments usageCount by 1
/// - Updates lastUsedAt to current time
/// - Used when a tag is applied to a task
class IncrementTagUsageUseCase {
  final TagRepository repository;

  IncrementTagUsageUseCase(this.repository);

  /// Execute the use case
  ///
  /// [tagId] - ID of the tag to increment usage for
  Future<Either<Failure, void>> call({
    required String tagId,
  }) async {
    try {
      // Validate tag ID
      if (tagId.trim().isEmpty) {
        return Left(ValidationFailure('Tag ID is required'));
      }

      return await repository.incrementTagUsage(tagId);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to increment tag usage: $e'));
    }
  }
}
