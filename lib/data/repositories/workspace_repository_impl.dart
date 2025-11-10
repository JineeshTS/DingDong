import 'dart:convert';

import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/workspace_entity.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../datasources/local/isar/isar_workspace_local_data_source.dart';
import '../datasources/local/isar/schemas/workspace_isar.dart';
import '../datasources/remote/firebase_workspace_remote_data_source.dart';
import '../models/workspace_model.dart';

/// Workspace repository implementation with offline-first architecture
class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final FirebaseWorkspaceRemoteDataSource remoteDataSource;
  final IsarWorkspaceLocalDataSource localDataSource;

  WorkspaceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, WorkspaceEntity>> createWorkspace(
      WorkspaceEntity workspace) async {
    try {
      final model = WorkspaceModel.fromEntity(workspace);

      // Save to local first
      final isarWorkspace = _modelToIsar(model);
      isarWorkspace.isDirty = true;
      await localDataSource.upsertWorkspace(isarWorkspace);

      // Try to sync to remote
      try {
        final createdModel = await remoteDataSource.createWorkspace(model);

        // Update local with server data
        final syncedIsarWorkspace = _modelToIsar(createdModel);
        await localDataSource.upsertWorkspace(syncedIsarWorkspace);
        await localDataSource.markAsSynced(createdModel.id);

        return Right(createdModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(workspace);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create workspace: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> getWorkspace(String id) async {
    try {
      // Try local first
      final localWorkspace = await localDataSource.getWorkspaceByFirebaseId(id);

      if (localWorkspace != null) {
        return Right(_isarToEntity(localWorkspace));
      }

      // Fetch from remote
      final remoteModel = await remoteDataSource.getWorkspace(id);

      // Save to local
      final isarWorkspace = _modelToIsar(remoteModel);
      await localDataSource.upsertWorkspace(isarWorkspace);
      await localDataSource.markAsSynced(id);

      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get workspace: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceEntity>>> getWorkspaces({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    try {
      // Try local first
      final localWorkspaces = await localDataSource.getWorkspacesByUser(
        userId: userId,
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );

      if (localWorkspaces.isNotEmpty) {
        return Right(localWorkspaces.map(_isarToEntity).toList());
      }

      // Fetch from remote
      final remoteModels = await remoteDataSource.getWorkspaces(
        userId: userId,
        includeArchived: includeArchived,
        includeDeleted: includeDeleted,
      );

      // Save to local
      final isarWorkspaces = remoteModels.map(_modelToIsar).toList();
      await localDataSource.batchInsertWorkspaces(isarWorkspaces);

      return Right(remoteModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get workspaces: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceEntity>>> getOwnedWorkspaces(
      String userId) async {
    try {
      // Get from local
      final localWorkspaces = await localDataSource.getWorkspacesByOwner(userId);

      return Right(localWorkspaces.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get owned workspaces: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceEntity>>> getMemberWorkspaces(
      String userId) async {
    try {
      // Get from local
      final localWorkspaces = await localDataSource.getWorkspacesByMember(userId);

      return Right(localWorkspaces.map(_isarToEntity).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get member workspaces: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> updateWorkspace(
      WorkspaceEntity workspace) async {
    try {
      final model = WorkspaceModel.fromEntity(workspace);

      // Save to local first
      final isarWorkspace = _modelToIsar(model);
      isarWorkspace.isDirty = true;
      await localDataSource.upsertWorkspace(isarWorkspace);

      // Try to sync to remote
      try {
        final updatedModel = await remoteDataSource.updateWorkspace(model);

        // Update local with synced data
        final syncedIsarWorkspace = _modelToIsar(updatedModel);
        await localDataSource.upsertWorkspace(syncedIsarWorkspace);
        await localDataSource.markAsSynced(workspace.id);

        return Right(updatedModel.toEntity());
      } on ServerException {
        // If remote fails, still return success
        return Right(workspace);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update workspace: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorkspace(String id) async {
    try {
      // Mark as deleted locally
      await localDataSource.deleteWorkspace(id);

      // Try to delete from remote
      try {
        await remoteDataSource.deleteWorkspace(id);
        await localDataSource.markAsSynced(id);
      } on ServerException {
        // If remote fails, mark as dirty for later sync
        await localDataSource.markAsDirty(id);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete workspace: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteWorkspace(String id) async {
    try {
      await remoteDataSource.permanentlyDeleteWorkspace(id);
      await localDataSource.permanentlyDeleteWorkspace(id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to permanently delete workspace: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> restoreWorkspace(String id) async {
    try {
      final model = await remoteDataSource.restoreWorkspace(id);

      // Update local
      final isarWorkspace = _modelToIsar(model);
      await localDataSource.upsertWorkspace(isarWorkspace);
      await localDataSource.markAsSynced(id);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to restore workspace: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> archiveWorkspace(String id) async {
    try {
      // Archive locally first (instant UI feedback)
      await localDataSource.archiveWorkspace(id);

      // Sync to remote in background
      remoteDataSource.archiveWorkspace(id).then((model) {
        final isarWorkspace = _modelToIsar(model);
        localDataSource.upsertWorkspace(isarWorkspace);
        localDataSource.markAsSynced(id);
      }).catchError((_) {
        localDataSource.markAsDirty(id);
      });

      final localWorkspace = await localDataSource.getWorkspaceByFirebaseId(id);
      return Right(_isarToEntity(localWorkspace!));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to archive workspace: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> unarchiveWorkspace(String id) async {
    try {
      // Unarchive locally first (instant UI feedback)
      await localDataSource.unarchiveWorkspace(id);

      // Sync to remote in background
      remoteDataSource.unarchiveWorkspace(id).then((model) {
        final isarWorkspace = _modelToIsar(model);
        localDataSource.upsertWorkspace(isarWorkspace);
        localDataSource.markAsSynced(id);
      }).catchError((_) {
        localDataSource.markAsDirty(id);
      });

      final localWorkspace = await localDataSource.getWorkspaceByFirebaseId(id);
      return Right(_isarToEntity(localWorkspace!));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to unarchive workspace: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> addMember({
    required String workspaceId,
    required String userId,
    String? email,
    required WorkspaceRole role,
    required String invitedBy,
  }) async {
    try {
      final model = await remoteDataSource.addMember(
        workspaceId: workspaceId,
        userId: userId,
        email: email,
        role: _roleToString(role),
        invitedBy: invitedBy,
      );

      // Update local
      final isarWorkspace = _modelToIsar(model);
      await localDataSource.upsertWorkspace(isarWorkspace);
      await localDataSource.markAsSynced(workspaceId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add member: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      final model = await remoteDataSource.removeMember(
        workspaceId: workspaceId,
        userId: userId,
      );

      // Update local
      final isarWorkspace = _modelToIsar(model);
      await localDataSource.upsertWorkspace(isarWorkspace);
      await localDataSource.markAsSynced(workspaceId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove member: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> updateMemberRole({
    required String workspaceId,
    required String userId,
    required WorkspaceRole role,
  }) async {
    try {
      final model = await remoteDataSource.updateMemberRole(
        workspaceId: workspaceId,
        userId: userId,
        role: _roleToString(role),
      );

      // Update local
      final isarWorkspace = _modelToIsar(model);
      await localDataSource.upsertWorkspace(isarWorkspace);
      await localDataSource.markAsSynced(workspaceId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update member role: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> acceptInvitation(
      String workspaceId) async {
    try {
      final model = await remoteDataSource.acceptInvitation(workspaceId);

      // Update local
      final isarWorkspace = _modelToIsar(model);
      await localDataSource.upsertWorkspace(isarWorkspace);
      await localDataSource.markAsSynced(workspaceId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to accept invitation: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> declineInvitation(String workspaceId) async {
    try {
      await remoteDataSource.declineInvitation(workspaceId);
      await localDataSource.permanentlyDeleteWorkspace(workspaceId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to decline invitation: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveWorkspace(String workspaceId) async {
    try {
      await remoteDataSource.leaveWorkspace(workspaceId);
      await localDataSource.permanentlyDeleteWorkspace(workspaceId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to leave workspace: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> transferOwnership({
    required String workspaceId,
    required String newOwnerId,
  }) async {
    try {
      final model = await remoteDataSource.transferOwnership(
        workspaceId: workspaceId,
        newOwnerId: newOwnerId,
      );

      // Update local
      final isarWorkspace = _modelToIsar(model);
      await localDataSource.upsertWorkspace(isarWorkspace);
      await localDataSource.markAsSynced(workspaceId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to transfer ownership: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> updateSettings({
    required String workspaceId,
    required WorkspaceSettings settings,
  }) async {
    try {
      final model = await remoteDataSource.updateSettings(
        workspaceId: workspaceId,
        settings: WorkspaceSettingsModel.fromEntity(settings),
      );

      // Update local
      final isarWorkspace = _modelToIsar(model);
      await localDataSource.upsertWorkspace(isarWorkspace);
      await localDataSource.markAsSynced(workspaceId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update settings: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkspaceEntity>> updateSubscription({
    required String workspaceId,
    required WorkspaceSubscription subscription,
  }) async {
    try {
      final model = await remoteDataSource.updateSubscription(
        workspaceId: workspaceId,
        subscription: WorkspaceSubscriptionModel.fromEntity(subscription),
      );

      // Update local
      final isarWorkspace = _modelToIsar(model);
      await localDataSource.upsertWorkspace(isarWorkspace);
      await localDataSource.markAsSynced(workspaceId);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update subscription: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceMember>>> getMembers(
      String workspaceId) async {
    try {
      final workspace = await localDataSource.getWorkspaceByFirebaseId(workspaceId);

      if (workspace != null) {
        final entity = _isarToEntity(workspace);
        return Right(entity.members);
      }

      // Fetch from remote if not in local
      final model = await remoteDataSource.getWorkspace(workspaceId);
      final isarWorkspace = _modelToIsar(model);
      await localDataSource.upsertWorkspace(isarWorkspace);
      await localDataSource.markAsSynced(workspaceId);

      return Right(model.members.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get members: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WorkspaceMember>>> getPendingInvitations(
      String workspaceId) async {
    try {
      final members = await remoteDataSource.getPendingInvitations(workspaceId);

      return Right(members.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get pending invitations: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWorkspaceStatistics(
      String workspaceId) async {
    try {
      final stats = await remoteDataSource.getWorkspaceStatistics(workspaceId);

      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to get workspace statistics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getWorkspaceActivity({
    required String workspaceId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      final activity = await remoteDataSource.getWorkspaceActivity(
        workspaceId: workspaceId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      return Right(activity);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get workspace activity: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasPermission({
    required String workspaceId,
    required String userId,
    required WorkspaceRole requiredRole,
  }) async {
    try {
      final hasAccess = await remoteDataSource.hasPermission(
        workspaceId: workspaceId,
        userId: userId,
        requiredRole: _roleToString(requiredRole),
      );

      return Right(hasAccess);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to check permission: $e'));
    }
  }

  @override
  Stream<Either<Failure, WorkspaceEntity>> watchWorkspace(String id) {
    try {
      return localDataSource.watchWorkspace(id).map((workspaceIsar) {
        if (workspaceIsar == null) {
          return Left(CacheFailure(
              message: 'Workspace not found in local database'));
        }
        return Right(_isarToEntity(workspaceIsar));
      }).handleError((error) {
        return Left(
            CacheFailure(message: 'Failed to watch workspace: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch workspace: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<WorkspaceEntity>>> watchWorkspaces({
    required String userId,
  }) {
    try {
      return localDataSource.watchWorkspaces(userId: userId).map((workspacesIsar) {
        return Right(workspacesIsar.map(_isarToEntity).toList());
      }).handleError((error) {
        return Left(
            CacheFailure(message: 'Failed to watch workspaces: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch workspaces: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<WorkspaceMember>>> watchMembers(
      String workspaceId) {
    try {
      return localDataSource.watchWorkspace(workspaceId).map((workspaceIsar) {
        if (workspaceIsar == null) {
          return Left(
              CacheFailure(message: 'Workspace not found in local database'));
        }
        final entity = _isarToEntity(workspaceIsar);
        return Right(entity.members);
      }).handleError((error) {
        return Left(CacheFailure(message: 'Failed to watch members: $error'));
      });
    } catch (e) {
      return Stream.value(
          Left(CacheFailure(message: 'Failed to watch members: $e')));
    }
  }

  // ==================== CONVERTERS ====================

  /// Convert WorkspaceModel to WorkspaceIsar
  WorkspaceIsar _modelToIsar(WorkspaceModel model) {
    return WorkspaceIsar()
      ..workspaceId = model.id
      ..name = model.name
      ..description = model.description
      ..icon = model.icon
      ..color = model.color ?? '#2196F3'
      ..workspaceType = _typeToIsar(model.type as WorkspaceType)
      ..ownerId = model.ownerId
      ..membersJson = jsonEncode(model.members
          .map((m) => {
                'userId': m.userId,
                'email': m.email,
                'role': m.role,
                'joinedAt': m.joinedAt.toIso8601String(),
                'invitedBy': m.invitedBy,
                'isActive': m.isActive,
                'hasAccepted': m.hasAccepted,
              })
          .toList())
      ..settingsJson = jsonEncode({
        'allowGuestAccess': model.settings.allowGuestAccess,
        'requireInviteApproval': model.settings.requireInviteApproval,
        'enablePublicSharing': model.settings.enablePublicSharing,
        'visibility': model.settings.visibility,
        'customSettings': model.settings.customSettings,
      })
      ..subscriptionTier =
          _subscriptionTierToIsar(model.subscription.tier as WorkspaceSubscriptionTier)
      ..subscriptionExpiresAt = model.subscription.expiresAt
      ..maxMembers = model.subscription.maxMembers
      ..isArchived = model.isArchived
      ..isDeleted = model.isDeleted
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt;
  }

  /// Convert WorkspaceIsar to WorkspaceEntity
  WorkspaceEntity _isarToEntity(WorkspaceIsar isar) {
    // Parse members
    final membersData = isar.membersJson != null
        ? jsonDecode(isar.membersJson!) as List
        : [];

    final members = membersData
        .map((data) => WorkspaceMember(
              userId: data['userId'] as String,
              email: data['email'] as String?,
              role: _roleFromString(data['role'] as String),
              joinedAt: DateTime.parse(data['joinedAt'] as String),
              invitedBy: data['invitedBy'] as String,
              isActive: data['isActive'] as bool? ?? true,
              hasAccepted: data['hasAccepted'] as bool? ?? false,
            ))
        .toList();

    // Parse settings
    final settingsData = isar.settingsJson != null
        ? jsonDecode(isar.settingsJson!) as Map<String, dynamic>
        : <String, dynamic>{};

    final settings = WorkspaceSettings(
      allowGuestAccess: settingsData['allowGuestAccess'] as bool? ?? false,
      requireInviteApproval:
          settingsData['requireInviteApproval'] as bool? ?? true,
      enablePublicSharing: settingsData['enablePublicSharing'] as bool? ?? false,
      visibility: settingsData['visibility'] != null
          ? _visibilityFromString(settingsData['visibility'] as String)
          : WorkspaceVisibility.private,
      customSettings: settingsData['customSettings'] as Map<String, dynamic>?,
    );

    final subscription = WorkspaceSubscription(
      tier: _subscriptionTierFromIsar(isar.subscriptionTier),
      expiresAt: isar.subscriptionExpiresAt,
      isActive: true,
      maxMembers: isar.maxMembers,
      features: null,
    );

    return WorkspaceEntity(
      id: isar.workspaceId,
      name: isar.name,
      description: isar.description,
      icon: isar.icon,
      color: isar.color,
      type: _typeFromIsar(isar.workspaceType),
      ownerId: isar.ownerId,
      members: members,
      settings: settings,
      subscription: subscription,
      createdAt: isar.createdAt,
      updatedAt: isar.updatedAt,
      isArchived: isar.isArchived,
      isDeleted: isar.isDeleted,
    );
  }

  /// Convert WorkspaceRole to string
  String _roleToString(WorkspaceRole role) {
    return role.toString().split('.').last;
  }

  /// Convert string to WorkspaceRole
  WorkspaceRole _roleFromString(String role) {
    switch (role) {
      case 'owner':
        return WorkspaceRole.owner;
      case 'admin':
        return WorkspaceRole.admin;
      case 'member':
        return WorkspaceRole.member;
      case 'guest':
        return WorkspaceRole.guest;
      default:
        return WorkspaceRole.member;
    }
  }

  /// Convert string to WorkspaceVisibility
  WorkspaceVisibility _visibilityFromString(String visibility) {
    switch (visibility) {
      case 'private':
        return WorkspaceVisibility.private;
      case 'unlisted':
        return WorkspaceVisibility.unlisted;
      case 'public':
        return WorkspaceVisibility.public;
      default:
        return WorkspaceVisibility.private;
    }
  }

  /// Convert WorkspaceType to WorkspaceTypeIsar
  WorkspaceTypeIsar _typeToIsar(WorkspaceType type) {
    switch (type) {
      case WorkspaceType.personal:
        return WorkspaceTypeIsar.personal;
      case WorkspaceType.team:
        return WorkspaceTypeIsar.team;
      case WorkspaceType.family:
        return WorkspaceTypeIsar.family;
      case WorkspaceType.enterprise:
        return WorkspaceTypeIsar.enterprise;
    }
  }

  /// Convert WorkspaceTypeIsar to WorkspaceType
  WorkspaceType _typeFromIsar(WorkspaceTypeIsar type) {
    switch (type) {
      case WorkspaceTypeIsar.personal:
        return WorkspaceType.personal;
      case WorkspaceTypeIsar.team:
        return WorkspaceType.team;
      case WorkspaceTypeIsar.family:
        return WorkspaceType.family;
      case WorkspaceTypeIsar.enterprise:
        return WorkspaceType.enterprise;
    }
  }

  /// Convert WorkspaceSubscriptionTier to WorkspaceSubscriptionTierIsar
  WorkspaceSubscriptionTierIsar _subscriptionTierToIsar(
      WorkspaceSubscriptionTier tier) {
    switch (tier) {
      case WorkspaceSubscriptionTier.free:
        return WorkspaceSubscriptionTierIsar.free;
      case WorkspaceSubscriptionTier.teams:
        return WorkspaceSubscriptionTierIsar.teams;
      case WorkspaceSubscriptionTier.enterprise:
        return WorkspaceSubscriptionTierIsar.enterprise;
    }
  }

  /// Convert WorkspaceSubscriptionTierIsar to WorkspaceSubscriptionTier
  WorkspaceSubscriptionTier _subscriptionTierFromIsar(
      WorkspaceSubscriptionTierIsar tier) {
    switch (tier) {
      case WorkspaceSubscriptionTierIsar.free:
        return WorkspaceSubscriptionTier.free;
      case WorkspaceSubscriptionTierIsar.teams:
        return WorkspaceSubscriptionTier.teams;
      case WorkspaceSubscriptionTierIsar.enterprise:
        return WorkspaceSubscriptionTier.enterprise;
    }
  }
}
