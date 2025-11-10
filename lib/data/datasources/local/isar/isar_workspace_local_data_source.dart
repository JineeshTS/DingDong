import 'package:isar/isar.dart';
import '../../../core/errors/exceptions.dart';
import 'schemas/workspace_isar.dart';

/// Isar local data source for Workspace operations (offline storage)
abstract class IsarWorkspaceLocalDataSource {
  /// Initialize Isar database
  Future<void> initialize();

  /// Insert or update workspace
  Future<WorkspaceIsar> upsertWorkspace(WorkspaceIsar workspace);

  /// Get workspace by Firebase ID
  Future<WorkspaceIsar?> getWorkspaceByFirebaseId(String workspaceId);

  /// Get workspaces by owner ID
  Future<List<WorkspaceIsar>> getWorkspacesByOwner({
    required String ownerId,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get workspaces for user (owner or member)
  Future<List<WorkspaceIsar>> getWorkspacesForUser({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get archived workspaces
  Future<List<WorkspaceIsar>> getArchivedWorkspaces({
    required String userId,
  });

  /// Update workspace
  Future<WorkspaceIsar> updateWorkspace(WorkspaceIsar workspace);

  /// Delete workspace (soft delete)
  Future<void> deleteWorkspace(String workspaceId);

  /// Permanently delete workspace
  Future<void> permanentlyDeleteWorkspace(String workspaceId);

  /// Archive workspace
  Future<void> archiveWorkspace(String workspaceId);

  /// Unarchive workspace
  Future<void> unarchiveWorkspace(String workspaceId);

  /// Update member count
  Future<void> updateMemberCount({
    required String workspaceId,
    required int memberCount,
  });

  /// Batch insert workspaces
  Future<void> batchInsertWorkspaces(List<WorkspaceIsar> workspaces);

  /// Get dirty workspaces (need sync)
  Future<List<WorkspaceIsar>> getDirtyWorkspaces();

  /// Mark workspace as synced
  Future<void> markAsSynced(String workspaceId);

  /// Mark workspace as dirty (needs sync)
  Future<void> markAsDirty(String workspaceId);

  /// Clear workspaces for user
  Future<void> clearWorkspacesForUser(String userId);

  /// Get workspace count for user
  Future<int> getWorkspaceCountForUser(String userId);

  /// Watch workspace changes (stream)
  Stream<WorkspaceIsar?> watchWorkspace(String workspaceId);

  /// Watch workspaces for user (stream)
  Stream<List<WorkspaceIsar>> watchWorkspacesForUser({
    required String userId,
  });
}

/// Isar implementation of workspace local data source
class IsarWorkspaceLocalDataSourceImpl implements IsarWorkspaceLocalDataSource {
  Isar? _isar;

  IsarWorkspaceLocalDataSourceImpl();

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    try {
      _isar = await Isar.open([
        WorkspaceIsarSchema,
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
  Future<WorkspaceIsar> upsertWorkspace(WorkspaceIsar workspace) async {
    try {
      await _db.writeTxn(() async {
        await _db.workspaceIsars.put(workspace);
      });

      // Return the inserted/updated workspace
      final savedWorkspace = await getWorkspaceByFirebaseId(workspace.workspaceId);
      if (savedWorkspace == null) {
        throw const CacheException(
          message: 'Failed to save workspace to local database',
        );
      }

      return savedWorkspace;
    } catch (e) {
      throw CacheException(
        message: 'Failed to upsert workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceIsar?> getWorkspaceByFirebaseId(String workspaceId) async {
    try {
      final workspace = await _db.workspaceIsars
          .filter()
          .workspaceIdEqualTo(workspaceId)
          .findFirst();

      return workspace;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get workspace by Firebase ID',
        originalException: e,
      );
    }
  }

  @override
  Future<List<WorkspaceIsar>> getWorkspacesByOwner({
    required String ownerId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      var query = _db.workspaceIsars
          .filter()
          .ownerIdEqualTo(ownerId);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final workspaces = await query
          .sortByCreatedAt()
          .findAll();

      return workspaces;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get workspaces by owner',
        originalException: e,
      );
    }
  }

  @override
  Future<List<WorkspaceIsar>> getWorkspacesForUser({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      // Get workspaces where user is owner
      var query = _db.workspaceIsars
          .filter()
          .ownerIdEqualTo(userId);

      if (!includeArchived) {
        query = query.isArchivedEqualTo(false);
      }

      if (!includeDeleted) {
        query = query.isDeletedEqualTo(false);
      }

      final ownedWorkspaces = await query.findAll();

      // Get workspaces where user is a member (stored in membersJson)
      // This requires parsing JSON, so we'll get all workspaces and filter
      var allQuery = _db.workspaceIsars.filter();

      if (!includeArchived) {
        allQuery = allQuery.isArchivedEqualTo(false);
      }

      if (!includeDeleted) {
        allQuery = allQuery.isDeletedEqualTo(false);
      }

      final allWorkspaces = await allQuery.findAll();

      // Filter workspaces where user is in membersJson
      // In production, you would parse membersJson and check for userId
      // For now, we'll just return owned workspaces
      // TODO: Parse membersJson to include workspaces where user is a member

      // Combine and deduplicate
      final workspaceMap = <String, WorkspaceIsar>{};
      for (final workspace in ownedWorkspaces) {
        workspaceMap[workspace.workspaceId] = workspace;
      }

      return workspaceMap.values.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      throw CacheException(
        message: 'Failed to get workspaces for user',
        originalException: e,
      );
    }
  }

  @override
  Future<List<WorkspaceIsar>> getArchivedWorkspaces({
    required String userId,
  }) async {
    try {
      final workspaces = await _db.workspaceIsars
          .filter()
          .ownerIdEqualTo(userId)
          .isArchivedEqualTo(true)
          .isDeletedEqualTo(false)
          .sortByArchivedAt()
          .findAll();

      return workspaces;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get archived workspaces',
        originalException: e,
      );
    }
  }

  @override
  Future<WorkspaceIsar> updateWorkspace(WorkspaceIsar workspace) async {
    try {
      final existingWorkspace = await getWorkspaceByFirebaseId(workspace.workspaceId);
      if (existingWorkspace == null) {
        throw const CacheException(
          message: 'Workspace not found in local database',
        );
      }

      // Update timestamp
      workspace.updatedAt = DateTime.now();
      workspace.isDirty = true;

      return await upsertWorkspace(workspace);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to update workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteWorkspace(String workspaceId) async {
    try {
      final workspace = await getWorkspaceByFirebaseId(workspaceId);
      if (workspace == null) return;

      workspace.isDeleted = true;
      workspace.deletedAt = DateTime.now();
      workspace.updatedAt = DateTime.now();
      workspace.isDirty = true;

      await _db.writeTxn(() async {
        await _db.workspaceIsars.put(workspace);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<void> permanentlyDeleteWorkspace(String workspaceId) async {
    try {
      final workspace = await getWorkspaceByFirebaseId(workspaceId);
      if (workspace == null) return;

      await _db.writeTxn(() async {
        await _db.workspaceIsars.delete(workspace.id);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to permanently delete workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<void> archiveWorkspace(String workspaceId) async {
    try {
      final workspace = await getWorkspaceByFirebaseId(workspaceId);
      if (workspace == null) return;

      workspace.isArchived = true;
      workspace.archivedAt = DateTime.now();
      workspace.updatedAt = DateTime.now();
      workspace.isDirty = true;

      await _db.writeTxn(() async {
        await _db.workspaceIsars.put(workspace);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to archive workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<void> unarchiveWorkspace(String workspaceId) async {
    try {
      final workspace = await getWorkspaceByFirebaseId(workspaceId);
      if (workspace == null) return;

      workspace.isArchived = false;
      workspace.archivedAt = null;
      workspace.updatedAt = DateTime.now();
      workspace.isDirty = true;

      await _db.writeTxn(() async {
        await _db.workspaceIsars.put(workspace);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to unarchive workspace',
        originalException: e,
      );
    }
  }

  @override
  Future<void> updateMemberCount({
    required String workspaceId,
    required int memberCount,
  }) async {
    try {
      final workspace = await getWorkspaceByFirebaseId(workspaceId);
      if (workspace == null) return;

      workspace.memberCount = memberCount;
      workspace.updatedAt = DateTime.now();
      // Don't mark as dirty for member count updates - these are derived values

      await _db.writeTxn(() async {
        await _db.workspaceIsars.put(workspace);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to update member count',
        originalException: e,
      );
    }
  }

  @override
  Future<void> batchInsertWorkspaces(List<WorkspaceIsar> workspaces) async {
    try {
      await _db.writeTxn(() async {
        await _db.workspaceIsars.putAll(workspaces);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to batch insert workspaces',
        originalException: e,
      );
    }
  }

  @override
  Future<List<WorkspaceIsar>> getDirtyWorkspaces() async {
    try {
      final workspaces = await _db.workspaceIsars
          .filter()
          .isDirtyEqualTo(true)
          .findAll();

      return workspaces;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get dirty workspaces',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsSynced(String workspaceId) async {
    try {
      final workspace = await getWorkspaceByFirebaseId(workspaceId);
      if (workspace == null) return;

      workspace.isDirty = false;
      workspace.lastSyncAt = DateTime.now();

      await _db.writeTxn(() async {
        await _db.workspaceIsars.put(workspace);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark workspace as synced',
        originalException: e,
      );
    }
  }

  @override
  Future<void> markAsDirty(String workspaceId) async {
    try {
      final workspace = await getWorkspaceByFirebaseId(workspaceId);
      if (workspace == null) return;

      workspace.isDirty = true;

      await _db.writeTxn(() async {
        await _db.workspaceIsars.put(workspace);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark workspace as dirty',
        originalException: e,
      );
    }
  }

  @override
  Future<void> clearWorkspacesForUser(String userId) async {
    try {
      final workspaces = await getWorkspacesForUser(
        userId: userId,
        includeArchived: true,
        includeDeleted: true,
      );

      await _db.writeTxn(() async {
        for (final workspace in workspaces) {
          await _db.workspaceIsars.delete(workspace.id);
        }
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear workspaces for user',
        originalException: e,
      );
    }
  }

  @override
  Future<int> getWorkspaceCountForUser(String userId) async {
    try {
      final count = await _db.workspaceIsars
          .filter()
          .ownerIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .count();

      return count;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get workspace count for user',
        originalException: e,
      );
    }
  }

  @override
  Stream<WorkspaceIsar?> watchWorkspace(String workspaceId) {
    try {
      return _db.workspaceIsars
          .filter()
          .workspaceIdEqualTo(workspaceId)
          .watch(fireImmediately: true)
          .map((workspaces) => workspaces.isNotEmpty ? workspaces.first : null);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch workspace',
        originalException: e,
      );
    }
  }

  @override
  Stream<List<WorkspaceIsar>> watchWorkspacesForUser({
    required String userId,
  }) {
    try {
      return _db.workspaceIsars
          .filter()
          .ownerIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    } catch (e) {
      throw CacheException(
        message: 'Failed to watch workspaces for user',
        originalException: e,
      );
    }
  }
}
