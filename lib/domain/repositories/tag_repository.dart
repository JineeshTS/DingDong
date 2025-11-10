import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/tag_entity.dart';

/// Tag repository interface
abstract class TagRepository {
  /// Create a new tag
  Future<Either<Failure, TagEntity>> createTag(TagEntity tag);

  /// Get tag by ID
  Future<Either<Failure, TagEntity>> getTag(String id);

  /// Get all tags for user
  Future<Either<Failure, List<TagEntity>>> getTags({
    required String userId,
    String? workspaceId,
    bool includeDeleted = false,
  });

  /// Get tags by parent (nested tags)
  Future<Either<Failure, List<TagEntity>>> getTagsByParent(String parentTagId);

  /// Get most used tags
  Future<Either<Failure, List<TagEntity>>> getMostUsedTags({
    required String userId,
    int limit = 10,
  });

  /// Search tags
  Future<Either<Failure, List<TagEntity>>> searchTags({
    required String userId,
    required String query,
  });

  /// Update tag
  Future<Either<Failure, TagEntity>> updateTag(TagEntity tag);

  /// Delete tag (soft delete)
  Future<Either<Failure, void>> deleteTag(String id);

  /// Permanently delete tag
  Future<Either<Failure, void>> permanentlyDeleteTag(String id);

  /// Restore tag
  Future<Either<Failure, TagEntity>> restoreTag(String id);

  /// Merge tags (combine multiple tags into one)
  Future<Either<Failure, TagEntity>> mergeTags({
    required List<String> sourceTagIds,
    required String targetTagId,
  });

  /// Update usage count
  Future<Either<Failure, TagEntity>> incrementUsageCount(String tagId);

  /// Get tag statistics
  Future<Either<Failure, Map<String, dynamic>>> getTagStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Watch tag (stream)
  Stream<Either<Failure, TagEntity>> watchTag(String id);

  /// Watch tags (stream)
  Stream<Either<Failure, List<TagEntity>>> watchTags({
    required String userId,
    String? workspaceId,
  });
}
