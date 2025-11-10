import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/workspace_entity.dart';

/// Workspace repository interface
abstract class WorkspaceRepository {
  /// Create a new workspace
  Future<Either<Failure, WorkspaceEntity>> createWorkspace(
    WorkspaceEntity workspace,
  );

  /// Get workspace by ID
  Future<Either<Failure, WorkspaceEntity>> getWorkspace(String id);

  /// Get all workspaces for user
  Future<Either<Failure, List<WorkspaceEntity>>> getWorkspaces({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  });

  /// Get workspaces where user is owner
  Future<Either<Failure, List<WorkspaceEntity>>> getOwnedWorkspaces(
    String userId,
  );

  /// Get workspaces where user is member
  Future<Either<Failure, List<WorkspaceEntity>>> getMemberWorkspaces(
    String userId,
  );

  /// Update workspace
  Future<Either<Failure, WorkspaceEntity>> updateWorkspace(
    WorkspaceEntity workspace,
  );

  /// Delete workspace (soft delete)
  Future<Either<Failure, void>> deleteWorkspace(String id);

  /// Permanently delete workspace
  Future<Either<Failure, void>> permanentlyDeleteWorkspace(String id);

  /// Restore workspace
  Future<Either<Failure, WorkspaceEntity>> restoreWorkspace(String id);

  /// Archive workspace
  Future<Either<Failure, WorkspaceEntity>> archiveWorkspace(String id);

  /// Unarchive workspace
  Future<Either<Failure, WorkspaceEntity>> unarchiveWorkspace(String id);

  /// Add member to workspace
  Future<Either<Failure, WorkspaceEntity>> addMember({
    required String workspaceId,
    required String userId,
    String? email,
    required WorkspaceRole role,
    required String invitedBy,
  });

  /// Remove member from workspace
  Future<Either<Failure, WorkspaceEntity>> removeMember({
    required String workspaceId,
    required String userId,
  });

  /// Update member role
  Future<Either<Failure, WorkspaceEntity>> updateMemberRole({
    required String workspaceId,
    required String userId,
    required WorkspaceRole role,
  });

  /// Accept workspace invitation
  Future<Either<Failure, WorkspaceEntity>> acceptInvitation(String workspaceId);

  /// Decline workspace invitation
  Future<Either<Failure, void>> declineInvitation(String workspaceId);

  /// Leave workspace
  Future<Either<Failure, void>> leaveWorkspace(String workspaceId);

  /// Transfer ownership
  Future<Either<Failure, WorkspaceEntity>> transferOwnership({
    required String workspaceId,
    required String newOwnerId,
  });

  /// Update workspace settings
  Future<Either<Failure, WorkspaceEntity>> updateSettings({
    required String workspaceId,
    required WorkspaceSettings settings,
  });

  /// Update workspace subscription
  Future<Either<Failure, WorkspaceEntity>> updateSubscription({
    required String workspaceId,
    required WorkspaceSubscription subscription,
  });

  /// Get workspace members
  Future<Either<Failure, List<WorkspaceMember>>> getMembers(String workspaceId);

  /// Get pending invitations for workspace
  Future<Either<Failure, List<WorkspaceMember>>> getPendingInvitations(
    String workspaceId,
  );

  /// Get workspace statistics
  Future<Either<Failure, Map<String, dynamic>>> getWorkspaceStatistics(
    String workspaceId,
  );

  /// Get workspace activity
  Future<Either<Failure, List<Map<String, dynamic>>>> getWorkspaceActivity({
    required String workspaceId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// Check if user has permission
  Future<Either<Failure, bool>> hasPermission({
    required String workspaceId,
    required String userId,
    required WorkspaceRole requiredRole,
  });

  /// Watch workspace (stream)
  Stream<Either<Failure, WorkspaceEntity>> watchWorkspace(String id);

  /// Watch workspaces (stream)
  Stream<Either<Failure, List<WorkspaceEntity>>> watchWorkspaces({
    required String userId,
  });

  /// Watch workspace members (stream)
  Stream<Either<Failure, List<WorkspaceMember>>> watchMembers(
    String workspaceId,
  );
}
