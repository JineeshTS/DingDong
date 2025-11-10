import 'package:isar/isar.dart';
import '../../../core/errors/exceptions.dart';
import 'schemas/tag_isar.dart';

/// Isar local data source for Tag operations (offline storage)
abstract class IsarTagLocalDataSource {
  /// Initialize Isar database
  Future<void> initialize();

  /// Insert or update tag
  Future<TagIsar> upsertTag(TagIsar tag);

  /// Get tag by Firebase ID
  Future<TagIsar?> getTagByFirebaseId(String tagId);

  /// Get tag by name
  Future<TagIsar?> getTagByName({
    required String userId,
    required String name,
  });

  /// Get tags by user ID
  Future<List<TagIsar>> getTagsByUser({
    required String userId,
    bool includeDeleted = false,
  });

  /// Get tags by workspace ID
  Future<List<TagIsar>> getTagsByWorkspace({
    required String workspaceId,
    bool includeDeleted = false,
  });

  /// Get child tags (for hierarchical tags)
  Future<List<TagIsar>> getChildTags({
    required String parentTagId,
    bool includeDeleted = false,
  });

  /// Get popular tags (sorted by usage count)
  Future<List<TagIsar>> getPopularTags({
    required String userId,
    int limit = 10,
  });

  /// Get recently used tags
  Future<List<TagIsar>> getRecentlyUsedTags({
    required String userId,
    int limit = 10,
  });

  /// Search tags by name
  Future<List<TagIsar>> searchTags({
    required String userId,
    required String query,
    bool includeDeleted = false,
  });

  /// Get all tags (for sync)
  Future<List<TagIsar>> getAllTags({
    required String userId,
    bool includeDeleted = false,
  });

  /// Update tag
  Future<TagIsar> updateTag(TagIsar tag);

  /// Delete tag (soft delete)
  Future<void> deleteTag(String tagId);

  /// Permanently delete tag
  Future<void> permanentlyDeleteTag(String tagId);

  /// Increment usage count
  Future<void> incrementUsage(String tagId);

  /// Decrement usage count
  Future<void> decrementUsage(String tagId);

  /// Update last used timestamp
  Future<void> updateLastUsed(String tagId);

  /// Batch insert tags
  Future<void> batchInsertTags(List<TagIsar> tags);

  /// Get dirty tags (need sync)
  Future<List<TagIsar>> getDirtyTags();

  /// Mark tag as synced
  Future<void> markAsSynced(String tagId);

  /// Mark tag as dirty (needs sync)
  Future<void> markAsDirty(String tagId);

  /// Clear tags for user
  Future<void> clearTagsForUser(String userId);

  /// Get tag count for user
  Future<int> getTagCountForUser(String userId);

  /// Get tag count for workspace
  Future<int> getTagCountForWorkspace(String workspaceId);

  /// Watch tag changes (stream)
  Stream<TagIsar?> watchTag(String tagId);

  /// Watch tags for user (stream)
  Stream<List<TagIsar>> watchTagsForUser({
    required String userId,
  });

  /// Watch popular tags (stream)
  Stream<List<TagIsar>> watchPopularTags({
    required String userId,
    int limit = 10,
  });
}

/// Isar implementation of tag local data source
class IsarTagLocalDataSourceImpl implements IsarTagLocalDataSource {
  Isar? _isar;

  IsarTagLocalDataSourceImpl();

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    try {
      _isar = await Isar.open([
        TagIsarSchema,
      ], directory: await _getIsarPath());
    } catch (e) {
      throw CacheException(
        message: 'Failed to initialize Isar database',
        originalException: e,
      );
    }
  }

  Future<String> _getIsarPath() async {
    // In production, use path_provider to get app directory
    // For now, return current directory
    return '.';
  }

  Isar get _db {
    if (_isar == null) {
      throw const CacheException(
        message: 'Isar database not initialized. Call initialize() first.',
      );
    }
    return _isar!;
  }

  @override
  Future<TagIsar> upsertTag(TagIsar tag) async {
    try {
      await _db.writeTxn(() async {
        await _db.tagIsars.put(tag);
      });

      // Return the inserted/updated tag
      final savedTag = await getTagByFirebaseId(tag.tagId);
      if (savedTag == null) {
        throw const CacheException(
          message: 'Failed to save tag to local database',
        );
      }

      return savedTag;
    } catch (e) {
      throw CacheException(
        message: 'Failed to upsert tag',
        originalException: e,
      );
    }
  }

  @override
  Future<TagIsar?> getTagByFirebaseId(String tagId) async {
    try {
      final tag = await _db.tagIsars
          .filter()
          .tagIdEqualTo(tagId)
          .findFirst();

      return tag;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get tag by Firebase ID',
        originalException: e,
      );
    }
  }

  @override
  Future<TagIsar?> getTagByName({
    required String userId,
    required String name,
  }) async {
    try {
      final tag = await _db.tagIsars
          .filter()
          .userIdEqualTo(userId)
          .nameEqualTo(name)
          .isDeletedEqualTo(false)
          .findFirst();

      return tag;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get tag by name',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TagIsar>> getTagsByUser({
    required String userId,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.tagIsars
          .filter()
          .userIdEqualTo(userId);

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final tags = await query
          .sortByNameDesc()
          .findAll();

      return tags;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get tags by user',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TagIsar>> getTagsByWorkspace({
    required String workspaceId,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.tagIsars
          .filter()
          .workspaceIdEqualTo(workspaceId);

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final tags = await query
          .sortByNameDesc()
          .findAll();

      return tags;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get tags by workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TagIsar>> getChildTags({
    required String parentTagId,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.tagIsars
          .filter()
          .parentTagIdEqualTo(parentTagId);

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final tags = await query
          .sortByNameDesc()
          .findAll();

      return tags;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get child tags',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TagIsar>> getPopularTags({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final tags = await _db.tagIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .sortByUsageCountDesc()
          .limit(limit)
          .findAll();

      return tags;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get popular tags',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TagIsar>> getRecentlyUsedTags({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final tags = await _db.tagIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .lastUsedAtIsNotNull()
          .sortByLastUsedAtDesc()
          .limit(limit)
          .findAll();

      return tags;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get recently used tags',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TagIsar>> searchTags({
    required String userId,
    required String query,
    bool includeDeleted = false,
  }) async {
    try {
      var queryBuilder = _db.tagIsars
          .filter()
          .userIdEqualTo(userId);

      if (!includeDeleted) {
        queryBuilder = queryBuilder.isDeletedEqualTo(false);
      }

      final tags = await queryBuilder.findAll();

      // Client-side filtering for name
      final lowerQuery = query.toLowerCase();
      final filtered = tags.where((tag) =>
        tag.name.toLowerCase().contains(lowerQuery)
      ).toList();

      return filtered;
    } catch (e) {
      throw CacheException(
        message: 'Failed to search tags',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TagIsar>> getAllTags({
    required String userId,
    bool includeDeleted = false,
  }) async {
    try {
      return await getTagsByUser(
        userId: userId,
        includeDeleted: includeDeleted,
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to get all tags',
        originalException: e,
      );
    }
  }

  @override
  Future<TagIsar> updateTag(TagIsar tag) async {
    try {
      final existingTag = await getTagByFirebaseId(tag.tagId);
      if (existingTag == null) {
        throw const CacheException(
          message: 'Tag not found in local database',
        );
      }

      // Update timestamp
      tag.updatedAt = DateTime.now();
      tag.isDirty = true;

      return await upsertTag(tag);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update tag',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteTag(String tagId) async {
    try {
      final tag = await getTagByFirebaseId(tagId);
      if (tag == null) return;

      tag.isDeleted = true;
      tag.deletedAt = DateTime.now();
      tag.updatedAt = DateTime.now();
      tag.isDirty = true;

      await _db.writeTxn(() async {
        await _db.tagIsars.put(tag);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete tag',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteTag(String tagId) async {
    try {
      final tag = await getTagByFirebaseId(tagId);
      if (tag == null) return;

      await _db.writeTxn(() async {
        await _db.tagIsars.delete(tag.id);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to permanently delete tag',
        originalException: e,
      );
    }
  }

  @override
  Future<void> incrementUsage(String tagId) async {
    try {
      final tag = await getTagByFirebaseId(tagId);
      if (tag == null) return;

      tag.usageCount += 1;
      tag.lastUsedAt = DateTime.now();
      tag.updatedAt = DateTime.now();
      // Don't mark as dirty for usage count updates - these are derived values

      await _db.writeTxn(() async {
        await _db.tagIsars.put(tag);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to increment usage count',
        originalException: e,
      );
    }
  }

  @override
  Future<void> decrementUsage(String tagId) async {
    try {
      final tag = await getTagByFirebaseId(tagId);
      if (tag == null) return;

      if (tag.usageCount > 0) {
        tag.usageCount -= 1;
      }
      tag.updatedAt = DateTime.now();
      // Don't mark as dirty for usage count updates - these are derived values

      await _db.writeTxn(() async {
        await _db.tagIsars.put(tag);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to decrement usage count',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateLastUsed(String tagId) async {
    try {
      final tag = await getTagByFirebaseId(tagId);
      if (tag == null) return;

      tag.lastUsedAt = DateTime.now();
      tag.updatedAt = DateTime.now();
      // Don't mark as dirty for last used updates - these are derived values

      await _db.writeTxn(() async {
        await _db.tagIsars.put(tag);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to update last used timestamp',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchInsertTags(List<TagIsar> tags) async {
    try {
      await _db.writeTxn(() async {
        await _db.tagIsars.putAll(tags);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to batch insert tags',
        originalException: e,
      );
    }
  }

  @override
  Future<List<TagIsar>> getDirtyTags() async {
    try {
      final tags = await _db.tagIsars
          .filter()
          .isDirtyEqualTo(true)
          .findAll();

      return tags;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get dirty tags',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String tagId) async {
    try {
      final tag = await getTagByFirebaseId(tagId);
      if (tag == null) return;

      tag.isDirty = false;
      tag.lastSyncAt = DateTime.now();

      await _db.writeTxn(() async {
        await _db.tagIsars.put(tag);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark tag as synced',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDirty(String tagId) async {
    try {
      final tag = await getTagByFirebaseId(tagId);
      if (tag == null) return;

      tag.isDirty = true;

      await _db.writeTxn(() async {
        await _db.tagIsars.put(tag);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark tag as dirty',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearTagsForUser(String userId) async {
    try {
      final tags = await getTagsByUser(
        userId: userId,
        includeDeleted: true,
      );

      await _db.writeTxn(() async {
        for (final tag in tags) {
          await _db.tagIsars.delete(tag.id);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear tags for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getTagCountForUser(String userId) async {
    try {
      final count = await _db.tagIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get tag count for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getTagCountForWorkspace(String workspaceId) async {
    try {
      final count = await _db.tagIsars
          .filter()
          .workspaceIdEqualTo(workspaceId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get tag count for workspace',
        originalException: e,
      );
    }
  }

  @override
  Stream<TagIsar?> watchTag(String tagId) {
    try {
      return _db.tagIsars
          .filter()
          .tagIdEqualTo(tagId)
          .watch(fireImmediately: true)
          .map((tags) => tags.isNotEmpty ? tags.first : null);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch tag',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<TagIsar>> watchTagsForUser({
    required String userId,
  }) {
    try {
      return _db.tagIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch tags for user',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<TagIsar>> watchPopularTags({
    required String userId,
    int limit = 10,
  }) {
    try {
      return _db.tagIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true)
          .map((tags) {
            // Sort by usage count and limit
            final sorted = tags.toList()
              ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
            return sorted.take(limit).toList();
          });
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch popular tags',
        originalException: e,
      );
    }
  }
}
