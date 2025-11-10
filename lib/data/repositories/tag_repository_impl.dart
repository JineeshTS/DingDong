import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/tag_entity.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/local/isar/isar_tag_local_data_source.dart';
import '../datasources/local/isar/schemas/tag_isar.dart';
import '../datasources/remote/firebase_tag_remote_data_source.dart';
import '../models/tag_model.dart';

/// Tag repository implementation with offline-first architecture
class TagRepositoryImpl implements TagRepository {
  final FirebaseTagRemoteDataSource remoteDataSource;
  final IsarTagLocalDataSource localDataSource;

  TagRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, TagEntity>> createTag(TagEntity tag) async {
    try {
      final model = TagModel.fromEntity(tag);

      // Save to local first
      final isarTag = _modelToIsar(model);
      isarTag.isDirty = true;
      await localDataSource.upsertTag(isarTag);

      // Try to sync to remote
      try {
        final createdModel = await remoteDataSource.createTag(model);

        // Update local with server data
        final syncedIsarTag = _modelToIsar(createdModel);
        await localDataSource.upsertTag(syncedIsarTag);
        await localDataSource.markAsSynced(createdModel.id);

        return Right(createdModel.toEntity());
      } on ServerException {
        // If remote fails, still return success (will sync later)
        return Right(tag);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create tag: $e'));
    }
  }

  @override
  Future<Either<Failure, TagEntity>> getTag(String id) async {
    try {
      // Try local first (offline-first)
      final localTag = await localDataSource.getTagByFirebaseId(id);

      if (localTag != null) {
        return Right(_isarToEntity(localTag));
      }

      // If not in local, fetch from remote
      final remoteModel = await remoteDataSource.getTag(id);

      // Save to local
      final isarTag = _modelToIsar(remoteModel);
      await localDataSource.upsertTag(isarTag);
      await localDataSource.markAsSynced(id);

      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get tag: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TagEntity>>> getTags({
    required String userId,
    String? workspaceId,
    bool includeDeleted = false,
  }) async {
    try {
      // Try local first
      final localTags = workspaceId != null
          ? await localDataSource.getTagsByWorkspace(
              workspaceId: workspaceId,
              includeDeleted: includeDeleted,
            )
          : await localDataSource.getTagsByUser(
              userId: userId,
              includeDeleted: includeDeleted,
            );

      if (localTags.isNotEmpty) {
        return Right(localTags.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getTags(
        userId: userId,
        workspaceId: workspaceId,
        includeDeleted: includeDeleted,
      );

      // Save to local
      final isarTags = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertTags(isarTags);

      // Mark all as synced
      for (final model in remoteModels) {
        await localDataSource.markAsSynced(model.id);
      }

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      // Return local data if remote fails
      try {
        final localTags = workspaceId != null
            ? await localDataSource.getTagsByWorkspace(
                workspaceId: workspaceId,
                includeDeleted: includeDeleted,
              )
            : await localDataSource.getTagsByUser(
                userId: userId,
                includeDeleted: includeDeleted,
              );

        if (localTags.isNotEmpty) {
          return Right(localTags.map(_isarToEntity).toList());
        }
      } catch (_) {}

      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get tags: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TagEntity>>> getTagsByParent(
      String parentTagId) async {
    try {
      // Try local first
      final localTags = await localDataSource.getChildTags(
        parentTagId: parentTagId,
        includeDeleted: false,
      );

      if (localTags.isNotEmpty) {
        return Right(localTags.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels =
          await remoteDataSource.getTagsByParent(parentTagId);

      // Save to local
      final isarTags = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertTags(isarTags);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get tags by parent: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TagEntity>>> getMostUsedTags({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // Get from local (this is derived data, local is source of truth)
      final localTags = await localDataSource.getPopularTags(
        userId: userId,
        limit: limit,
      );

      return Right(localTags.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get most used tags: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TagEntity>>> searchTags({
    required String userId,
    required String query,
  }) async {
    try {
      // Try local first
      final localTags = await localDataSource.searchTags(
        userId: userId,
        query: query,
        includeDeleted: false,
      );

      return Right(localTags.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search tags: $e'));
    }
  }

  @override
  Future<Either<Failure, TagEntity>> updateTag(TagEntity tag) async {
    try {
      final model = TagModel.fromEntity(tag);

      // Save to local first
      final isarTag = _modelToIsar(model);
      isarTag.isDirty = true;
      await localDataSource.upsertTag(isarTag);

      // Try to sync to remote
      try {
        final updatedModel = await remoteDataSource.updateTag(model);

        // Update local with synced data
        final syncedIsarTag = _modelToIsar(updatedModel);
        await localDataSource.upsertTag(syncedIsarTag);
        await localDataSource.markAsSynced(tag.id);

        return Right(updatedModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(tag);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update tag: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTag(String id) async {
    try {
      // Mark as deleted locally
      await localDataSource.deleteTag(id);

      // Try to delete from remote
      try {
        await remoteDataSource.deleteTag(id);
        await localDataSource.markAsSynced(id);
      } on ServerException {
        // If remote fails, mark as dirty for later sync
        await localDataSource.markAsDirty(id);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete tag: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteTag(String id) async {
    try {
      await remoteDataSource.permanentlyDeleteTag(id);
      await localDataSource.permanentlyDeleteTag(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to permanently delete tag: $e'));
    }
  }

  @override
  Future<Either<Failure, TagEntity>> restoreTag(String id) async {
    try {
      final model = await remoteDataSource.restoreTag(id);

      // Update local
      final isarTag = _modelToIsar(model);
      await localDataSource.upsertTag(isarTag);
      await localDataSource.markAsSynced(id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to restore tag: $e'));
    }
  }

  @override
  Future<Either<Failure, TagEntity>> mergeTags({
    required List<String> sourceTagIds,
    required String targetTagId,
  }) async {
    try {
      final model = await remoteDataSource.mergeTags(
        sourceTagIds: sourceTagIds,
        targetTagId: targetTagId,
      );

      // Update local: remove source tags and update target
      for (final sourceId in sourceTagIds) {
        await localDataSource.permanentlyDeleteTag(sourceId);
      }

      final isarTag = _modelToIsar(model);
      await localDataSource.upsertTag(isarTag);
      await localDataSource.markAsSynced(targetTagId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to merge tags: $e'));
    }
  }

  @override
  Future<Either<Failure, TagEntity>> incrementUsageCount(String tagId) async {
    try {
      // Increment locally (this is derived data)
      await localDataSource.incrementUsage(tagId);

      // Get updated tag
      final localTag = await localDataSource.getTagByFirebaseId(tagId);
      if (localTag == null) {
        return Left(CacheFailure(message: 'Tag not found'));
      }

      // Sync to remote in background (don't wait)
      remoteDataSource.incrementUsageCount(tagId).then((model) {
        final isarTag = _modelToIsar(model);
        localDataSource.upsertTag(isarTag);
        localDataSource.markAsSynced(tagId);
      }).catchError((_) {
        // Mark as dirty if sync fails
        localDataSource.markAsDirty(tagId);
      });

      return Right(_isarToEntity(localTag));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to increment usage count: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTagStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await remoteDataSource.getTagStatistics(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get tag statistics: $e'));
    }
  }

  @override
  Stream<Either<Failure, TagEntity>> watchTag(String id) {
    try {
      return localDataSource.watchTag(id).map((tagIsar) {
        if (tagIsar == null) {
          return Left(CacheFailure(message: 'Tag not found in local database'));
        }
        return Right(_isarToEntity(tagIsar));
      }).handleError((error) {
        return Left(CacheFailure(message: 'Failed to watch tag: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch tag: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<TagEntity>>> watchTags({
    required String userId,
    String? workspaceId,
  }) {
    try {
      return localDataSource.watchTagsForUser(userId: userId).map((tagsIsar) {
        return Right(tagsIsar.map(_isarToEntity).toList());
      }).handleError((error) {
        return Left(CacheFailure(message: 'Failed to watch tags: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch tags: $e')));
    }
  }

  // ==================== CONVERTERS ====================

  /// Convert TagModel to TagIsar
  TagIsar _modelToIsar(TagModel model) {
    return TagIsar()
      ..tagId = model.id
      ..userId = model.userId
      ..workspaceId = model.workspaceId
      ..name = model.name
      ..color = model.color
      ..parentTagId = model.parentTagId
      ..usageCount = model.usageCount
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt
      ..isDeleted = model.isDeleted;
  }

  /// Convert TagIsar to TagEntity
  TagEntity _isarToEntity(TagIsar isar) {
    return TagEntity(
      id: isar.tagId,
      userId: isar.userId,
      workspaceId: isar.workspaceId,
      name: isar.name,
      description: null, // Not stored in Isar for simplicity
      color: isar.color,
      icon: null, // Not stored in Isar for simplicity
      parentTagId: isar.parentTagId,
      sortOrder: 0, // Not stored in Isar
      usageCount: isar.usageCount,
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
      isDeleted: isar.isDeleted,
    );
  }
}
