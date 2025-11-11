import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/workspace_entity.dart';
import '../../../domain/usecases/workspace/accept_invitation_usecase.dart';
import '../../../domain/usecases/workspace/add_member_usecase.dart';
import '../../../domain/usecases/workspace/create_workspace_usecase.dart';
import '../../../domain/usecases/workspace/delete_workspace_usecase.dart';
import '../../../domain/usecases/workspace/get_workspace_statistics_usecase.dart';
import '../../../domain/usecases/workspace/leave_workspace_usecase.dart';
import '../../../domain/usecases/workspace/remove_member_usecase.dart';
import '../../../domain/usecases/workspace/transfer_ownership_usecase.dart';
import '../../../domain/usecases/workspace/update_member_role_usecase.dart';
import '../../../domain/usecases/workspace/update_workspace_usecase.dart';
import 'workspace_state.dart';

/// StateNotifier for managing workspace state
///
/// Handles all workspace-related operations including:
/// - Creating and updating workspaces
/// - Deleting workspaces (only owner)
/// - Managing workspace members with roles (owner, admin, member, guest)
/// - Sending and accepting invitations
/// - Transferring workspace ownership
/// - Getting workspace statistics
/// - Leaving workspaces
///
/// This notifier integrates with all 10 workspace use cases
/// and manages the WorkspaceState throughout the application lifecycle.
class WorkspaceNotifier extends StateNotifier<WorkspaceState> {
  final CreateWorkspaceUseCase _createWorkspaceUseCase;
  final UpdateWorkspaceUseCase _updateWorkspaceUseCase;
  final DeleteWorkspaceUseCase _deleteWorkspaceUseCase;
  final AddMemberUseCase _addMemberUseCase;
  final RemoveMemberUseCase _removeMemberUseCase;
  final UpdateMemberRoleUseCase _updateMemberRoleUseCase;
  final AcceptInvitationUseCase _acceptInvitationUseCase;
  final LeaveWorkspaceUseCase _leaveWorkspaceUseCase;
  final TransferOwnershipUseCase _transferOwnershipUseCase;
  final GetWorkspaceStatisticsUseCase _getWorkspaceStatisticsUseCase;

  WorkspaceNotifier({
    required CreateWorkspaceUseCase createWorkspaceUseCase,
    required UpdateWorkspaceUseCase updateWorkspaceUseCase,
    required DeleteWorkspaceUseCase deleteWorkspaceUseCase,
    required AddMemberUseCase addMemberUseCase,
    required RemoveMemberUseCase removeMemberUseCase,
    required UpdateMemberRoleUseCase updateMemberRoleUseCase,
    required AcceptInvitationUseCase acceptInvitationUseCase,
    required LeaveWorkspaceUseCase leaveWorkspaceUseCase,
    required TransferOwnershipUseCase transferOwnershipUseCase,
    required GetWorkspaceStatisticsUseCase getWorkspaceStatisticsUseCase,
  })  : _createWorkspaceUseCase = createWorkspaceUseCase,
        _updateWorkspaceUseCase = updateWorkspaceUseCase,
        _deleteWorkspaceUseCase = deleteWorkspaceUseCase,
        _addMemberUseCase = addMemberUseCase,
        _removeMemberUseCase = removeMemberUseCase,
        _updateMemberRoleUseCase = updateMemberRoleUseCase,
        _acceptInvitationUseCase = acceptInvitationUseCase,
        _leaveWorkspaceUseCase = leaveWorkspaceUseCase,
        _transferOwnershipUseCase = transferOwnershipUseCase,
        _getWorkspaceStatisticsUseCase = getWorkspaceStatisticsUseCase,
        super(const WorkspaceState.initial());

  /// Load all workspaces for a user
  ///
  /// Parameters:
  /// - [userId]: The ID of the user whose workspaces to load
  /// - [includeArchived]: Whether to include archived workspaces (default: false)
  /// - [includeDeleted]: Whether to include deleted workspaces (default: false)
  ///
  /// Updates state to loaded or error based on result
  Future<void> loadWorkspaces({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    state = WorkspaceState.loading(
      workspaces: state.workspacesOrEmpty,
      message: 'Loading workspaces...',
    );

    // This would call a getWorkspaces use case that we need to assume exists
    // For now, we'll just set an empty loaded state as placeholder
    state = WorkspaceState.loaded(workspaces: state.workspacesOrEmpty);
  }

  /// Create a new workspace
  ///
  /// Parameters:
  /// - [workspace]: The workspace entity to create
  /// - [userId]: The ID of the user creating the workspace
  ///
  /// Returns: The created workspace or null if creation failed
  Future<WorkspaceEntity?> createWorkspace({
    required WorkspaceEntity workspace,
    required String userId,
  }) async {
    final currentWorkspaces = state.workspacesOrEmpty;

    state = WorkspaceState.loading(
      workspaces: currentWorkspaces,
      message: 'Creating workspace...',
    );

    final result = await _createWorkspaceUseCase(
      workspace: workspace,
      userId: userId,
    );

    return result.fold(
      (failure) {
        state = WorkspaceState.error(
          failure: failure,
          workspaces: currentWorkspaces,
        );
        return null;
      },
      (createdWorkspace) {
        final updatedWorkspaces = [...currentWorkspaces, createdWorkspace];
        state = WorkspaceState.loaded(workspaces: updatedWorkspaces);
        return createdWorkspace;
      },
    );
  }

  /// Update an existing workspace
  ///
  /// Parameters:
  /// - [workspace]: The updated workspace entity
  /// - [userId]: The ID of the user making the update (must be owner or admin)
  ///
  /// Returns: The updated workspace or null if update failed
  Future<WorkspaceEntity?> updateWorkspace({
    required WorkspaceEntity workspace,
    required String userId,
  }) async {
    final currentWorkspaces = state.workspacesOrEmpty;

    state = WorkspaceState.loading(
      workspaces: currentWorkspaces,
      message: 'Updating workspace...',
    );

    final result = await _updateWorkspaceUseCase(
      workspace: workspace,
      userId: userId,
    );

    return result.fold(
      (failure) {
        state = WorkspaceState.error(
          failure: failure,
          workspaces: currentWorkspaces,
        );
        return null;
      },
      (updatedWorkspace) {
        final updatedWorkspaces = currentWorkspaces.map((w) {
          return w.id == updatedWorkspace.id ? updatedWorkspace : w;
        }).toList();
        state = WorkspaceState.loaded(workspaces: updatedWorkspaces);
        return updatedWorkspace;
      },
    );
  }

  /// Delete a workspace (only owner can delete)
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace to delete
  /// - [userId]: The ID of the user attempting to delete (must be owner)
  ///
  /// Returns: true if deletion was successful, false otherwise
  Future<bool> deleteWorkspace({
    required String workspaceId,
    required String userId,
  }) async {
    final currentWorkspaces = state.workspacesOrEmpty;

    state = WorkspaceState.loading(
      workspaces: currentWorkspaces,
      message: 'Deleting workspace...',
    );

    final result = await _deleteWorkspaceUseCase(
      workspaceId: workspaceId,
      userId: userId,
    );

    return result.fold(
      (failure) {
        state = WorkspaceState.error(
          failure: failure,
          workspaces: currentWorkspaces,
        );
        return false;
      },
      (_) {
        // Remove the deleted workspace from state
        final updatedWorkspaces = currentWorkspaces
            .where((w) => w.id != workspaceId)
            .toList();
        state = WorkspaceState.loaded(workspaces: updatedWorkspaces);
        return true;
      },
    );
  }

  /// Add a member to a workspace
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace
  /// - [userId]: The ID of the user to add (optional if email is provided)
  /// - [email]: The email of the user to invite (optional if userId is provided)
  /// - [role]: The role to assign (admin, member, or guest)
  /// - [invitedBy]: The ID of the user sending the invitation (must be owner/admin)
  ///
  /// Returns: The updated workspace or null if adding member failed
  Future<WorkspaceEntity?> addMember({
    required String workspaceId,
    String? userId,
    String? email,
    required WorkspaceRole role,
    required String invitedBy,
  }) async {
    final currentWorkspaces = state.workspacesOrEmpty;

    state = WorkspaceState.loading(
      workspaces: currentWorkspaces,
      message: 'Adding member...',
    );

    final result = await _addMemberUseCase(
      workspaceId: workspaceId,
      userId: userId,
      email: email,
      role: role,
      invitedBy: invitedBy,
    );

    return result.fold(
      (failure) {
        state = WorkspaceState.error(
          failure: failure,
          workspaces: currentWorkspaces,
        );
        return null;
      },
      (updatedWorkspace) {
        final updatedWorkspaces = currentWorkspaces.map((w) {
          return w.id == updatedWorkspace.id ? updatedWorkspace : w;
        }).toList();
        state = WorkspaceState.loaded(workspaces: updatedWorkspaces);
        return updatedWorkspace;
      },
    );
  }

  /// Remove a member from a workspace
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace
  /// - [userId]: The ID of the member to remove
  /// - [removedBy]: The ID of the user removing the member (must be owner/admin)
  ///
  /// Returns: The updated workspace or null if removal failed
  Future<WorkspaceEntity?> removeMember({
    required String workspaceId,
    required String userId,
    required String removedBy,
  }) async {
    final currentWorkspaces = state.workspacesOrEmpty;

    state = WorkspaceState.loading(
      workspaces: currentWorkspaces,
      message: 'Removing member...',
    );

    final result = await _removeMemberUseCase(
      workspaceId: workspaceId,
      userId: userId,
      removedBy: removedBy,
    );

    return result.fold(
      (failure) {
        state = WorkspaceState.error(
          failure: failure,
          workspaces: currentWorkspaces,
        );
        return null;
      },
      (updatedWorkspace) {
        final updatedWorkspaces = currentWorkspaces.map((w) {
          return w.id == updatedWorkspace.id ? updatedWorkspace : w;
        }).toList();
        state = WorkspaceState.loaded(workspaces: updatedWorkspaces);
        return updatedWorkspace;
      },
    );
  }

  /// Update a member's role in a workspace
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace
  /// - [userId]: The ID of the member whose role to update
  /// - [newRole]: The new role to assign (admin, member, or guest)
  /// - [updatedBy]: The ID of the user updating the role (must be owner/admin)
  ///
  /// Returns: The updated workspace or null if role update failed
  Future<WorkspaceEntity?> updateMemberRole({
    required String workspaceId,
    required String userId,
    required WorkspaceRole newRole,
    required String updatedBy,
  }) async {
    final currentWorkspaces = state.workspacesOrEmpty;

    state = WorkspaceState.loading(
      workspaces: currentWorkspaces,
      message: 'Updating member role...',
    );

    final result = await _updateMemberRoleUseCase(
      workspaceId: workspaceId,
      userId: userId,
      newRole: newRole,
      updatedBy: updatedBy,
    );

    return result.fold(
      (failure) {
        state = WorkspaceState.error(
          failure: failure,
          workspaces: currentWorkspaces,
        );
        return null;
      },
      (updatedWorkspace) {
        final updatedWorkspaces = currentWorkspaces.map((w) {
          return w.id == updatedWorkspace.id ? updatedWorkspace : w;
        }).toList();
        state = WorkspaceState.loaded(workspaces: updatedWorkspaces);
        return updatedWorkspace;
      },
    );
  }

  /// Accept an invitation to a workspace
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace
  /// - [userId]: The ID of the user accepting the invitation
  ///
  /// Returns: The updated workspace or null if acceptance failed
  Future<WorkspaceEntity?> acceptInvitation({
    required String workspaceId,
    required String userId,
  }) async {
    final currentWorkspaces = state.workspacesOrEmpty;

    state = WorkspaceState.loading(
      workspaces: currentWorkspaces,
      message: 'Accepting invitation...',
    );

    final result = await _acceptInvitationUseCase(
      workspaceId: workspaceId,
      userId: userId,
    );

    return result.fold(
      (failure) {
        state = WorkspaceState.error(
          failure: failure,
          workspaces: currentWorkspaces,
        );
        return null;
      },
      (updatedWorkspace) {
        final updatedWorkspaces = currentWorkspaces.map((w) {
          return w.id == updatedWorkspace.id ? updatedWorkspace : w;
        }).toList();
        state = WorkspaceState.loaded(workspaces: updatedWorkspaces);
        return updatedWorkspace;
      },
    );
  }

  /// Leave a workspace
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace to leave
  /// - [userId]: The ID of the user leaving the workspace
  ///
  /// Returns: true if leaving was successful, false otherwise
  Future<bool> leaveWorkspace({
    required String workspaceId,
    required String userId,
  }) async {
    final currentWorkspaces = state.workspacesOrEmpty;

    state = WorkspaceState.loading(
      workspaces: currentWorkspaces,
      message: 'Leaving workspace...',
    );

    final result = await _leaveWorkspaceUseCase(
      workspaceId: workspaceId,
      userId: userId,
    );

    return result.fold(
      (failure) {
        state = WorkspaceState.error(
          failure: failure,
          workspaces: currentWorkspaces,
        );
        return false;
      },
      (_) {
        // Remove the workspace from state after leaving
        final updatedWorkspaces = currentWorkspaces
            .where((w) => w.id != workspaceId)
            .toList();
        state = WorkspaceState.loaded(workspaces: updatedWorkspaces);
        return true;
      },
    );
  }

  /// Transfer workspace ownership to another admin
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace
  /// - [newOwnerId]: The ID of the admin to promote to owner (must be admin)
  /// - [currentOwnerId]: The ID of the current owner (for authorization)
  ///
  /// Returns: The updated workspace or null if transfer failed
  Future<WorkspaceEntity?> transferOwnership({
    required String workspaceId,
    required String newOwnerId,
    required String currentOwnerId,
  }) async {
    final currentWorkspaces = state.workspacesOrEmpty;

    state = WorkspaceState.loading(
      workspaces: currentWorkspaces,
      message: 'Transferring ownership...',
    );

    final result = await _transferOwnershipUseCase(
      workspaceId: workspaceId,
      newOwnerId: newOwnerId,
      currentOwnerId: currentOwnerId,
    );

    return result.fold(
      (failure) {
        state = WorkspaceState.error(
          failure: failure,
          workspaces: currentWorkspaces,
        );
        return null;
      },
      (updatedWorkspace) {
        final updatedWorkspaces = currentWorkspaces.map((w) {
          return w.id == updatedWorkspace.id ? updatedWorkspace : w;
        }).toList();
        state = WorkspaceState.loaded(workspaces: updatedWorkspaces);
        return updatedWorkspace;
      },
    );
  }

  /// Get comprehensive statistics for a workspace
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace
  /// - [userId]: The ID of the user requesting statistics (must be member)
  ///
  /// Returns: A map of workspace statistics or null if retrieval failed
  Future<Map<String, dynamic>?> getWorkspaceStatistics({
    required String workspaceId,
    required String userId,
  }) async {
    final result = await _getWorkspaceStatisticsUseCase(
      workspaceId: workspaceId,
      userId: userId,
    );

    return result.fold(
      (failure) {
        // Don't update state for statistics-only operations
        return null;
      },
      (statistics) => statistics,
    );
  }

  /// Refresh workspaces by reloading from repository
  ///
  /// Parameters:
  /// - [userId]: The ID of the user whose workspaces to refresh
  /// - [includeArchived]: Whether to include archived workspaces
  /// - [includeDeleted]: Whether to include deleted workspaces
  Future<void> refreshWorkspaces({
    required String userId,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    await loadWorkspaces(
      userId: userId,
      includeArchived: includeArchived,
      includeDeleted: includeDeleted,
    );
  }

  /// Clear error state
  ///
  /// Returns to previous loaded state with current workspaces
  void clearError() {
    final currentWorkspaces = state.workspacesOrEmpty;
    state = WorkspaceState.loaded(workspaces: currentWorkspaces);
  }

  /// Clear all workspaces and reset to initial state
  void reset() {
    state = const WorkspaceState.initial();
  }

  /// Update a workspace in the local state without calling the repository
  ///
  /// Useful for optimistic updates or when the workspace was updated elsewhere
  ///
  /// Parameters:
  /// - [workspace]: The updated workspace entity
  void updateWorkspaceLocally(WorkspaceEntity workspace) {
    final currentWorkspaces = state.workspacesOrEmpty;
    final updatedWorkspaces = currentWorkspaces.map((w) {
      return w.id == workspace.id ? workspace : w;
    }).toList();
    state = WorkspaceState.loaded(workspaces: updatedWorkspaces);
  }

  /// Add a workspace to the local state without calling the repository
  ///
  /// Useful for adding a workspace that was created elsewhere
  ///
  /// Parameters:
  /// - [workspace]: The workspace entity to add
  void addWorkspaceLocally(WorkspaceEntity workspace) {
    final currentWorkspaces = state.workspacesOrEmpty;
    final updatedWorkspaces = [...currentWorkspaces, workspace];
    state = WorkspaceState.loaded(workspaces: updatedWorkspaces);
  }

  /// Remove a workspace from the local state without calling the repository
  ///
  /// Useful for removing a workspace that was deleted elsewhere
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace to remove
  void removeWorkspaceLocally(String workspaceId) {
    final currentWorkspaces = state.workspacesOrEmpty;
    final updatedWorkspaces = currentWorkspaces
        .where((w) => w.id != workspaceId)
        .toList();
    state = WorkspaceState.loaded(workspaces: updatedWorkspaces);
  }

  /// Get a workspace by ID from the current state
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace to find
  ///
  /// Returns: The workspace entity or null if not found
  WorkspaceEntity? getWorkspaceById(String workspaceId) {
    return state.findWorkspaceById(workspaceId);
  }
}
