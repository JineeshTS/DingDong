import 'package:dartz/dartz.dart';
import '../../entities/tag_entity.dart';
import '../../repositories/tag_repository.dart';
import '../../../core/errors/failures.dart';

/// Use case for creating a tag
///
/// Business Rules:
/// - Tag name must be unique (case-insensitive)
/// - Tag name must be 1-50 characters
/// - Tag name can only contain letters, numbers, hyphens, and underscores
/// - Tag color must be a valid hex color code
/// - Maximum 500 tags per user
class CreateTagUseCase {
  final TagRepository repository;

  CreateTagUseCase(this.repository);

  /// Execute the use case
  ///
  /// [tag] - The tag entity to create
  Future<Either<Failure, TagEntity>> call({
    required TagEntity tag,
  }) async {
    try {
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

      // Check for duplicate tag name (case-insensitive)
      final existingTagsResult = await repository.getTags();

      return await existingTagsResult.fold(
        (failure) => Left(failure),
        (existingTags) async {
          // Check maximum tags limit
          if (existingTags.length >= 500) {
            return Left(ValidationFailure('Maximum 500 tags limit exceeded'));
          }

          // Check for duplicate (case-insensitive)
          final isDuplicate = existingTags.any(
            (t) => t.name.toLowerCase() == trimmedName.toLowerCase(),
          );

          if (isDuplicate) {
            return Left(ValidationFailure(
                'Tag with name "$trimmedName" already exists'));
          }

          // Create tag with normalized name
          final normalizedTag = tag.copyWith(name: trimmedName);

          return await repository.createTag(normalizedTag);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to create tag: $e'));
    }
  }
}
