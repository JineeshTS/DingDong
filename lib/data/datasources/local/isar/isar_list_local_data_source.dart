import 'package:isar/isar.dart';
import '../../../core/errors/exceptions.dart';
import 'schemas/list_isar.dart';

/// Isar local data source for List operations (offline storage)
abstract class IsarListLocalDataSource {
  /// Initialize Isar database
  Future<void> initialize();

  /// Insert or update list
  Future<ListIsar> upsertList(ListIsar list);

  /// Get list by Firebase ID
  Future<ListIsar?> getListByFirebaseId(String listId);

  /// Get lists by user ID
  Future<List<ListIsar>> getListsByUser({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get lists by workspace ID
  Future<List<ListIsar>> getListsByWorkspace({
    required String workspaceId,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get nested lists (children of a parent list)
  Future<List<ListIsar>> getNestedLists({
    required String parentListId,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get favorite lists
  Future<List<ListIsar>> getFavoriteLists({
    required String userId,
    bool includeArchived = false,
  });

  /// Get shared lists
  Future<List<ListIsar>> getSharedLists({
    required String userId,
    bool includeArchived = false,
  });

  /// Get archived lists
  Future<List<ListIsar>> getArchivedLists({
    required String userId,
  });

  /// Search lists by name or description
  Future<List<ListIsar>> searchLists({
    required String userId,
    required String query,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get lists by type
  Future<List<ListIsar>> getListsByType({
    required String userId,
    required ListTypeIsar type,
    bool includeArchived = false,
  });

  /// Update list
  Future<ListIsar> updateList(ListIsar list);

  /// Delete list (soft delete)
  Future<void> deleteList(String listId);

  /// Permanently delete list
  Future<void> permanentlyDeleteList(String listId);

  /// Archive list
  Future<void> archiveList(String listId);

  /// Unarchive list
  Future<void> unarchiveList(String listId);

  /// Toggle favorite
  Future<void> toggleFavorite(String listId);

  /// Update task counts
  Future<void> updateTaskCounts({
    required String listId,
    required int taskCount,
    required int completedTaskCount,
  });

  /// Batch insert lists
  Future<void> batchInsertLists(List<ListIsar> lists);

  /// Get dirty lists (need sync)
  Future<List<ListIsar>> getDirtyLists();

  /// Mark list as synced
  Future<void> markAsSynced(String listId);

  /// Mark list as dirty (needs sync)
  Future<void> markAsDirty(String listId);

  /// Clear lists for user
  Future<void> clearListsForUser(String userId);

  /// Get list count for user
  Future<int> getListCountForUser(String userId);

  /// Get list count for workspace
  Future<int> getListCountForWorkspace(String workspaceId);

  /// Watch list changes (stream)
  Stream<ListIsar?> watchList(String listId);

  /// Watch lists for user (stream)
  Stream<List<ListIsar>> watchListsForUser({
    required String userId,
    bool includeArchived = false,
  });

  /// Watch lists for workspace (stream)
  Stream<List<ListIsar>> watchListsForWorkspace({
    required String workspaceId,
    bool includeArchived = false,
  });

  /// Watch favorite lists (stream)
  Stream<List<ListIsar>> watchFavoriteLists({
    required String userId,
  });
}

/// Isar implementation of list local data source
class IsarListLocalDataSourceImpl implements IsarListLocalDataSource {
  Isar? _isar;

  IsarListLocalDataSourceImpl();

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    try {
      _isar = await Isar.open([
        ListIsarSchema,
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
  Future<ListIsar> upsertList(ListIsar list) async {
    try {
      await _db.writeTxn(() async {
        await _db.listIsars.put(list);
      });

      // Return the inserted/updated list
      final savedList = await getListByFirebaseId(list.listId);
      if (savedList == null) {
        throw const CacheException(
          message: 'Failed to save list to local database',
        );
      }

      return savedList;
    } catch (e) {
      throw CacheException(
        message: 'Failed to upsert list',
        originalException: e,
      );
    }
  }

  @override
  Future<ListIsar?> getListByFirebaseId(String listId) async {
    try {
      final list = await _db.listIsars
          .filter()
          .listIdEqualTo(listId)
          .findFirst();

      return list;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get list by Firebase ID',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListIsar>> getListsByUser({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.listIsars
          .filter()
          .userIdEqualTo(userId);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final lists = await query
          .sortBySortOrder()
          .thenByCreatedAt()
          .findAll();

      return lists;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get lists by user',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListIsar>> getListsByWorkspace({
    required String workspaceId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.listIsars
          .filter()
          .workspaceIdEqualTo(workspaceId);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final lists = await query
          .sortBySortOrder()
          .thenByCreatedAt()
          .findAll();

      return lists;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get lists by workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListIsar>> getNestedLists({
    required String parentListId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.listIsars
          .filter()
          .parentListIdEqualTo(parentListId);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final lists = await query
          .sortBySortOrder()
          .thenByCreatedAt()
          .findAll();

      return lists;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get nested lists',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListIsar>> getFavoriteLists({
    required String userId,
    bool includeArchived = false,
  }) async {
    try {
      var query = _db.listIsars
          .filter()
          .userIdEqualTo(userId)
          .isFavoriteEqualTo(true)
          .isDeletedEqualTo(false);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      final lists = await query
          .sortBySortOrder()
          .thenByCreatedAt()
          .findAll();

      return lists;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get favorite lists',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListIsar>> getSharedLists({
    required String userId,
    bool includeArchived = false,
  }) async {
    try {
      var query = _db.listIsars
          .filter()
          .userIdEqualTo(userId)
          .isSharedEqualTo(true)
          .isDeletedEqualTo(false);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      final lists = await query
          .sortBySortOrder()
          .thenByCreatedAt()
          .findAll();

      return lists;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get shared lists',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListIsar>> getArchivedLists({
    required String userId,
  }) async {
    try {
      final lists = await _db.listIsars
          .filter()
          .userIdEqualTo(userId)
          .isArchivedEqualTo(true)
          .isDeletedEqualTo(false)
          .sortByArchivedAt()
          .findAll();

      return lists;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get archived lists',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListIsar>> searchLists({
    required String userId,
    required String query,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      var queryBuilder = _db.listIsars
          .filter()
          .userIdEqualTo(userId);

      if (!includeArchived) {
        queryBuilder = queryBuilder.isArchivedEqualTo(false);
      }

      if (!includeDeleted) {
        queryBuilder = queryBuilder.isDeletedEqualTo(false);
      }

      final lists = await queryBuilder.findAll();

      // Client-side filtering for name and description
      final lowerQuery = query.toLowerCase();
      final filtered = lists.where((list) =>
        list.name.toLowerCase().contains(lowerQuery) ||
        (list.description?.toLowerCase().contains(lowerQuery) ?? false)
      ).toList();

      return filtered;
    } catch (e) {
      throw CacheException(
        message: 'Failed to search lists',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListIsar>> getListsByType({
    required String userId,
    required ListTypeIsar type,
    bool includeArchived = false,
  }) async {
    try {
      var query = _db.listIsars
          .filter()
          .userIdEqualTo(userId)
          .typeEqualTo(type)
          .isDeletedEqualTo(false);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      final lists = await query
          .sortBySortOrder()
          .thenByCreatedAt()
          .findAll();

      return lists;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get lists by type',
        originalException: e,
      );
    }
  }

  @override
  Future<ListIsar> updateList(ListIsar list) async {
    try {
      final existingList = await getListByFirebaseId(list.listId);
      if (existingList == null) {
        throw const CacheException(
          message: 'List not found in local database',
        );
      }

      // Update timestamp
      list.updatedAt = DateTime.now();
      list.isDirty = true;

      return await upsertList(list);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update list',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteList(String listId) async {
    try {
      final list = await getListByFirebaseId(listId);
      if (list == null) return;

      list.isDeleted = true;
      list.deletedAt = DateTime.now();
      list.updatedAt = DateTime.now();
      list.isDirty = true;

      await _db.writeTxn(() async {
        await _db.listIsars.put(list);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete list',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteList(String listId) async {
    try {
      final list = await getListByFirebaseId(listId);
      if (list == null) return;

      await _db.writeTxn(() async {
        await _db.listIsars.delete(list.id);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to permanently delete list',
        originalException: e,
      );
    }
  }

  @override
  Future<void> archiveList(String listId) async {
    try {
      final list = await getListByFirebaseId(listId);
      if (list == null) return;

      list.isArchived = true;
      list.archivedAt = DateTime.now();
      list.updatedAt = DateTime.now();
      list.isDirty = true;

      await _db.writeTxn(() async {
        await _db.listIsars.put(list);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to archive list',
        originalException: e,
      );
    }
  }

  @override
  Future<void> unarchiveList(String listId) async {
    try {
      final list = await getListByFirebaseId(listId);
      if (list == null) return;

      list.isArchived = false;
      list.archivedAt = null;
      list.updatedAt = DateTime.now();
      list.isDirty = true;

      await _db.writeTxn(() async {
        await _db.listIsars.put(list);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to unarchive list',
        originalException: e,
      );
    }
  }

  @override
  Future<void> toggleFavorite(String listId) async {
    try {
      final list = await getListByFirebaseId(listId);
      if (list == null) return;

      list.isFavorite = !list.isFavorite;
      list.updatedAt = DateTime.now();
      list.isDirty = true;

      await _db.writeTxn(() async {
        await _db.listIsars.put(list);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to toggle favorite',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateTaskCounts({
    required String listId,
    required int taskCount,
    required int completedTaskCount,
  }) async {
    try {
      final list = await getListByFirebaseId(listId);
      if (list == null) return;

      list.taskCount = taskCount;
      list.completedTaskCount = completedTaskCount;
      list.updatedAt = DateTime.now();
      // Don't mark as dirty for count updates - these are derived values

      await _db.writeTxn(() async {
        await _db.listIsars.put(list);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to update task counts',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchInsertLists(List<ListIsar> lists) async {
    try {
      await _db.writeTxn(() async {
        await _db.listIsars.putAll(lists);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to batch insert lists',
        originalException: e,
      );
    }
  }

  @override
  Future<List<ListIsar>> getDirtyLists() async {
    try {
      final lists = await _db.listIsars
          .filter()
          .isDirtyEqualTo(true)
          .findAll();

      return lists;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get dirty lists',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String listId) async {
    try {
      final list = await getListByFirebaseId(listId);
      if (list == null) return;

      list.isDirty = false;
      list.lastSyncAt = DateTime.now();

      await _db.writeTxn(() async {
        await _db.listIsars.put(list);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark list as synced',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDirty(String listId) async {
    try {
      final list = await getListByFirebaseId(listId);
      if (list == null) return;

      list.isDirty = true;

      await _db.writeTxn(() async {
        await _db.listIsars.put(list);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark list as dirty',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearListsForUser(String userId) async {
    try {
      final lists = await getListsByUser(
        userId: userId,
        includeArchived: true,
        includeDeleted: true,
      );

      await _db.writeTxn(() async {
        for (final list in lists) {
          await _db.listIsars.delete(list.id);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear lists for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getListCountForUser(String userId) async {
    try {
      final count = await _db.listIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get list count for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getListCountForWorkspace(String workspaceId) async {
    try {
      final count = await _db.listIsars
          .filter()
          .workspaceIdEqualTo(workspaceId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get list count for workspace',
        originalException: e,
      );
    }
  }

  @override
  Stream<ListIsar?> watchList(String listId) {
    try {
      return _db.listIsars
          .filter()
          .listIdEqualTo(listId)
          .watch(fireImmediately: true)
          .map((lists) => lists.isNotEmpty ? lists.first : null);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch list',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<ListIsar>> watchListsForUser({
    required String userId,
    bool includeArchived = false,
  }) {
    try {
      var query = _db.listIsars
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      return query.watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch lists for user',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<ListIsar>> watchListsForWorkspace({
    required String workspaceId,
    bool includeArchived = false,
  }) {
    try {
      var query = _db.listIsars
          .filter()
          .workspaceIdEqualTo(workspaceId)
          .isDeletedEqualTo(false);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      return query.watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch lists for workspace',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<ListIsar>> watchFavoriteLists({
    required String userId,
  }) {
    try {
      return _db.listIsars
          .filter()
          .userIdEqualTo(userId)
          .isFavoriteEqualTo(true)
          .isDeletedEqualTo(false)
          .isArchivedEqualTo(false)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch favorite lists',
        originalException: e,
      );
    }
  }
}
