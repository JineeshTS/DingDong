import 'package:dartz/dartz.dart';
import '../../entities/tag_entity.dart';
import '../../repositories/tag_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for updating a tag
///
/// Business Rules:
/// - Tag must exist
/// - Same validation rules as create tag apply
/// - Tag name must remain unique (case-insensitive)
/// - Tag name format must be valid
/// - Color must be valid hex code if provided
class UpdateTagUseCase {
  final TagRepository repository;

  UpdateTagUseCase(this.repository);

  /// Execute the use case
  ///
  /// [tag] - The updated tag entity
  Future<Either<Failure, TagEntity>> call({
    required TagEntity tag,
  }) async {
    try {
      // Validate tag ID
      if (tag.id.trim().isEmpty) {
        return Left(ValidationFailure('Tag ID is required'));
      }

      // Validate tag name
      final trimmedName = tag.name.trim();
      if (trimmedName.isEmpty) {
        return Left(ValidationFailure('Tag name is required'));
      }
      if (trimmedName.length > 50) {
        return Left(ValidationFailure('Tag name must not exceed 50 characters'));
      }

      // Validate tag name format (alphanumeric, hyphens, underscores only)
      final validNameRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
      if (!validNameRegex.hasMatch(trimmedName)) {
        return Left(ValidationFailure(
            'Tag name can only contain letters, numbers, hyphens, and underscores'));
      }

      // Validate color (hex format)
      if (tag.color != null) {
        final validColorRegex = RegExp(r'^#[0-9A-Fa-f]{6}$');
        if (!validColorRegex.hasMatch(tag.color!)) {
          return Left(ValidationFailure(
              'Tag color must be a valid hex color code (e.g., #FF5733)'));
        }
      }

      // Check for duplicate tag name (case-insensitive, excluding current tag)
      final existingTagsResult = await repository.getTags();

      return await existingTagsResult.fold(
        (failure) => Left(failure),
        (existingTags) async {
          // Check for duplicate (case-insensitive, excluding current tag)
          final isDuplicate = existingTags.any(
            (t) =>
                t.id != tag.id &&
                t.name.toLowerCase() == trimmedName.toLowerCase(),
          );

          if (isDuplicate) {
            return Left(ValidationFailure(
                'Tag with name "$trimmedName" already exists'));
          }

          // Update tag with normalized name
          final normalizedTag = tag.copyWith(name: trimmedName);

          return await repository.updateTag(normalizedTag);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update tag: $e'));
    }
  }
}
