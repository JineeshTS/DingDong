import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
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
import 'workspace_notifier.dart';
import 'workspace_state.dart';

// ============================================================================
// Use Case Providers
// ============================================================================
// These providers expose individual use cases from the DI container.
// They are auto-disposed when no longer needed for optimal memory management.

/// Provider for CreateWorkspaceUseCase
///
/// Handles creating new team workspaces with validation
final createWorkspaceProvider = Provider.autoDispose<CreateWorkspaceUseCase>(
  (ref) => sl<CreateWorkspaceUseCase>(),
);

/// Provider for UpdateWorkspaceUseCase
///
/// Handles updating existing workspace details
final updateWorkspaceProvider = Provider.autoDispose<UpdateWorkspaceUseCase>(
  (ref) => sl<UpdateWorkspaceUseCase>(),
);

/// Provider for DeleteWorkspaceUseCase
///
/// Handles deleting workspaces (only owner can delete)
final deleteWorkspaceProvider = Provider.autoDispose<DeleteWorkspaceUseCase>(
  (ref) => sl<DeleteWorkspaceUseCase>(),
);

/// Provider for AddMemberUseCase
///
/// Handles inviting members to workspaces with role assignment
final addMemberProvider = Provider.autoDispose<AddMemberUseCase>(
  (ref) => sl<AddMemberUseCase>(),
);

/// Provider for RemoveMemberUseCase
///
/// Handles removing members from workspaces
final removeMemberProvider = Provider.autoDispose<RemoveMemberUseCase>(
  (ref) => sl<RemoveMemberUseCase>(),
);

/// Provider for UpdateMemberRoleUseCase
///
/// Handles changing member roles (admin, member, guest)
final updateMemberRoleProvider = Provider.autoDispose<UpdateMemberRoleUseCase>(
  (ref) => sl<UpdateMemberRoleUseCase>(),
);

/// Provider for AcceptInvitationUseCase
///
/// Handles accepting workspace invitations
final acceptInvitationProvider = Provider.autoDispose<AcceptInvitationUseCase>(
  (ref) => sl<AcceptInvitationUseCase>(),
);

/// Provider for LeaveWorkspaceUseCase
///
/// Handles users leaving workspaces
final leaveWorkspaceProvider = Provider.autoDispose<LeaveWorkspaceUseCase>(
  (ref) => sl<LeaveWorkspaceUseCase>(),
);

/// Provider for TransferOwnershipUseCase
///
/// Handles transferring workspace ownership to another admin
final transferOwnershipProvider = Provider.autoDispose<TransferOwnershipUseCase>(
  (ref) => sl<TransferOwnershipUseCase>(),
);

/// Provider for GetWorkspaceStatisticsUseCase
///
/// Handles retrieving workspace statistics (members, tasks, lists, activity)
final getWorkspaceStatisticsProvider =
    Provider.autoDispose<GetWorkspaceStatisticsUseCase>(
  (ref) => sl<GetWorkspaceStatisticsUseCase>(),
);

// ============================================================================
// Workspace State Notifier Provider
// ============================================================================

/// Main workspace state notifier provider
///
/// This is the primary provider for workspace state management.
/// It should NOT be auto-disposed as we want to maintain workspace
/// state throughout the app lifecycle.
///
/// Usage:
/// ```dart
/// // In a ConsumerWidget
/// final workspaceState = ref.watch(workspaceNotifierProvider);
/// final workspaceNotifier = ref.read(workspaceNotifierProvider.notifier);
///
/// // Load workspaces
/// await workspaceNotifier.loadWorkspaces(userId: currentUserId);
///
/// // Access workspaces
/// if (workspaceState.isLoaded) {
///   final workspaces = workspaceState.activeWorkspaces;
///   // Display workspaces
/// }
///
/// // Create a new workspace
/// final newWorkspace = WorkspaceEntity(
///   id: uuid.v4(),
///   name: 'My Team',
///   type: WorkspaceType.team,
///   ownerId: currentUserId,
///   settings: WorkspaceSettings(),
///   subscription: WorkspaceSubscription(
///     tier: WorkspaceSubscriptionTier.free,
///   ),
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
/// );
/// await workspaceNotifier.createWorkspace(
///   workspace: newWorkspace,
///   userId: currentUserId,
/// );
/// ```
final workspaceNotifierProvider = StateNotifierProvider<WorkspaceNotifier, WorkspaceState>(
  (ref) {
    return WorkspaceNotifier(
      createWorkspaceUseCase: ref.read(createWorkspaceProvider),
      updateWorkspaceUseCase: ref.read(updateWorkspaceProvider),
      deleteWorkspaceUseCase: ref.read(deleteWorkspaceProvider),
      addMemberUseCase: ref.read(addMemberProvider),
      removeMemberUseCase: ref.read(removeMemberProvider),
      updateMemberRoleUseCase: ref.read(updateMemberRoleProvider),
      acceptInvitationUseCase: ref.read(acceptInvitationProvider),
      leaveWorkspaceUseCase: ref.read(leaveWorkspaceProvider),
      transferOwnershipUseCase: ref.read(transferOwnershipProvider),
      getWorkspaceStatisticsUseCase: ref.read(getWorkspaceStatisticsProvider),
    );
  },
);

// ============================================================================
// Derived State Providers
// ============================================================================
// These providers derive specific values from the workspace state for convenience

/// Provider that exposes all workspaces
///
/// Returns empty list if workspaces are not loaded
///
/// Usage:
/// ```dart
/// final workspaces = ref.watch(allWorkspacesProvider);
/// ListView.builder(
///   itemCount: workspaces.length,
///   itemBuilder: (context, index) => WorkspaceTile(workspace: workspaces[index]),
/// );
/// ```
final allWorkspacesProvider = Provider.autoDispose<List<WorkspaceEntity>>((ref) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.workspacesOrEmpty;
});

/// Provider that exposes only active (non-archived, non-deleted) workspaces
///
/// Usage:
/// ```dart
/// final activeWorkspaces = ref.watch(activeWorkspacesProvider);
/// // Display only active workspaces in main navigation
/// ```
final activeWorkspacesProvider = Provider.autoDispose<List<WorkspaceEntity>>((ref) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.activeWorkspaces;
});

/// Provider that exposes only team workspaces
///
/// Usage:
/// ```dart
/// final teamWorkspaces = ref.watch(teamWorkspacesProvider);
/// // Display team collaboration spaces
/// ```
final teamWorkspacesProvider = Provider.autoDispose<List<WorkspaceEntity>>((ref) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.teamWorkspaces;
});

/// Provider that exposes only personal workspaces
///
/// Usage:
/// ```dart
/// final personalWorkspaces = ref.watch(personalWorkspacesProvider);
/// // Display personal workspace
/// ```
final personalWorkspacesProvider = Provider.autoDispose<List<WorkspaceEntity>>((ref) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.personalWorkspaces;
});

/// Provider that exposes only archived workspaces
///
/// Usage:
/// ```dart
/// final archivedWorkspaces = ref.watch(archivedWorkspacesProvider);
/// // Display archived workspaces in archive section
/// ```
final archivedWorkspacesProvider = Provider.autoDispose<List<WorkspaceEntity>>((ref) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.archivedWorkspaces;
});

/// Provider that exposes the loading state
///
/// Useful for showing loading indicators
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(isWorkspaceLoadingProvider);
/// if (isLoading) {
///   CircularProgressIndicator();
/// }
/// ```
final isWorkspaceLoadingProvider = Provider.autoDispose<bool>((ref) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.isLoading;
});

/// Provider that exposes workspace errors
///
/// Returns null if no error
///
/// Usage:
/// ```dart
/// final error = ref.watch(workspaceErrorProvider);
/// if (error != null) {
///   SnackBar(content: Text(error.message));
/// }
/// ```
final workspaceErrorProvider = Provider.autoDispose((ref) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.errorOrNull;
});

/// Provider for total count of active workspaces
///
/// Usage:
/// ```dart
/// final activeCount = ref.watch(activeWorkspacesCountProvider);
/// Text('You have $activeCount active workspaces');
/// ```
final activeWorkspacesCountProvider = Provider.autoDispose<int>((ref) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.activeWorkspacesCount;
});

/// Provider for total count of team workspaces
///
/// Usage:
/// ```dart
/// final teamCount = ref.watch(teamWorkspacesCountProvider);
/// Badge(count: teamCount);
/// ```
final teamWorkspacesCountProvider = Provider.autoDispose<int>((ref) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.teamWorkspacesCount;
});

/// Provider for total count of personal workspaces
///
/// Usage:
/// ```dart
/// final personalCount = ref.watch(personalWorkspacesCountProvider);
/// Text('$personalCount personal workspace');
/// ```
final personalWorkspacesCountProvider = Provider.autoDispose<int>((ref) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.personalWorkspacesCount;
});

/// Provider for total count of archived workspaces
///
/// Usage:
/// ```dart
/// final archivedCount = ref.watch(archivedWorkspacesCountProvider);
/// if (archivedCount > 0) {
///   ListTile(
///     title: Text('Archived ($archivedCount)'),
///     onTap: () => navigateToArchivedWorkspaces(),
///   );
/// }
/// ```
final archivedWorkspacesCountProvider = Provider.autoDispose<int>((ref) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.archivedWorkspacesCount;
});

/// Provider family for getting a specific workspace by ID
///
/// Auto-disposes when not in use
///
/// Usage:
/// ```dart
/// final workspace = ref.watch(workspaceByIdProvider(workspaceId));
/// if (workspace != null) {
///   Text(workspace.name);
/// } else {
///   Text('Workspace not found');
/// }
/// ```
final workspaceByIdProvider =
    Provider.autoDispose.family<WorkspaceEntity?, String>((ref, workspaceId) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.findWorkspaceById(workspaceId);
});

/// Provider family for getting workspaces by type
///
/// Usage:
/// ```dart
/// final teamWorkspaces = ref.watch(workspacesByTypeProvider(WorkspaceType.team));
/// // Display only team workspaces
/// ```
final workspacesByTypeProvider =
    Provider.autoDispose.family<List<WorkspaceEntity>, WorkspaceType>((ref, type) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.getWorkspacesByType(type);
});

/// Provider family for getting workspaces where user is owner
///
/// Usage:
/// ```dart
/// final ownedWorkspaces = ref.watch(ownedWorkspacesProvider(userId));
/// // Display workspaces user owns
/// ```
final ownedWorkspacesProvider =
    Provider.autoDispose.family<List<WorkspaceEntity>, String>((ref, userId) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.getOwnedWorkspaces(userId);
});

/// Provider family for getting workspaces where user is admin
///
/// Usage:
/// ```dart
/// final adminWorkspaces = ref.watch(adminWorkspacesProvider(userId));
/// // Display workspaces where user is admin
/// ```
final adminWorkspacesProvider =
    Provider.autoDispose.family<List<WorkspaceEntity>, String>((ref, userId) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.getAdminWorkspaces(userId);
});

/// Provider family for getting members of a specific workspace
///
/// Usage:
/// ```dart
/// final members = ref.watch(workspaceMembersProvider(workspaceId));
/// ListView.builder(
///   itemCount: members.length,
///   itemBuilder: (context, index) => MemberTile(member: members[index]),
/// );
/// ```
final workspaceMembersProvider = Provider.autoDispose
    .family<List<WorkspaceMember>, String>((ref, workspaceId) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.getWorkspaceMembers(workspaceId);
});

/// Provider family for getting pending members (not yet accepted invitation)
///
/// Usage:
/// ```dart
/// final pendingMembers = ref.watch(pendingMembersProvider(workspaceId));
/// // Display pending invitations
/// ```
final pendingMembersProvider = Provider.autoDispose
    .family<List<WorkspaceMember>, String>((ref, workspaceId) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.getPendingMembers(workspaceId);
});

/// Provider family for getting active members (accepted and active)
///
/// Usage:
/// ```dart
/// final activeMembers = ref.watch(activeMembersProvider(workspaceId));
/// Text('${activeMembers.length} active members');
/// ```
final activeMembersProvider = Provider.autoDispose
    .family<List<WorkspaceMember>, String>((ref, workspaceId) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.getActiveMembers(workspaceId);
});

/// Provider family for getting members by role in a workspace
///
/// Usage:
/// ```dart
/// final admins = ref.watch(membersByRoleProvider(
///   (workspaceId, WorkspaceRole.admin)
/// ));
/// // Display all admins in workspace
/// ```
final membersByRoleProvider = Provider.autoDispose.family<
    List<WorkspaceMember>,
    ({String workspaceId, WorkspaceRole role})>((ref, params) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.getMembersByRole(params.workspaceId, params.role);
});

/// Provider family for getting total member count of a workspace
///
/// Usage:
/// ```dart
/// final memberCount = ref.watch(workspaceMemberCountProvider(workspaceId));
/// Text('$memberCount members');
/// ```
final workspaceMemberCountProvider =
    Provider.autoDispose.family<int, String>((ref, workspaceId) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.getTotalMemberCount(workspaceId);
});

/// Provider family for getting pending member count
///
/// Usage:
/// ```dart
/// final pendingCount = ref.watch(pendingMemberCountProvider(workspaceId));
/// Badge(count: pendingCount);
/// ```
final pendingMemberCountProvider =
    Provider.autoDispose.family<int, String>((ref, workspaceId) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  final pendingMembers = workspaceState.getPendingMembers(workspaceId);
  return pendingMembers.length;
});

/// Provider family for getting active member count
///
/// Usage:
/// ```dart
/// final activeCount = ref.watch(activeMemberCountProvider(workspaceId));
/// Text('$activeCount active');
/// ```
final activeMemberCountProvider =
    Provider.autoDispose.family<int, String>((ref, workspaceId) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  final activeMembers = workspaceState.getActiveMembers(workspaceId);
  return activeMembers.length;
});

/// Provider for sorting workspaces by name
///
/// Usage:
/// ```dart
/// final sortedWorkspaces = ref.watch(workspacesSortedByNameProvider);
/// // Display alphabetically sorted workspaces
/// ```
final workspacesSortedByNameProvider =
    Provider.autoDispose<List<WorkspaceEntity>>((ref) {
  final workspaces = ref.watch(activeWorkspacesProvider);
  final sortedWorkspaces = List<WorkspaceEntity>.from(workspaces);
  sortedWorkspaces
      .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return sortedWorkspaces;
});

/// Provider for sorting workspaces by creation date (newest first)
///
/// Usage:
/// ```dart
/// final recentWorkspaces = ref.watch(workspacesSortedByCreationDateProvider);
/// // Display recently created workspaces first
/// ```
final workspacesSortedByCreationDateProvider =
    Provider.autoDispose<List<WorkspaceEntity>>((ref) {
  final workspaces = ref.watch(activeWorkspacesProvider);
  final sortedWorkspaces = List<WorkspaceEntity>.from(workspaces);
  sortedWorkspaces.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sortedWorkspaces;
});

/// Provider for sorting workspaces by update date (most recently updated first)
///
/// Usage:
/// ```dart
/// final recentlyUpdatedWorkspaces = ref.watch(workspacesSortedByUpdateDateProvider);
/// // Display recently modified workspaces first
/// ```
final workspacesSortedByUpdateDateProvider =
    Provider.autoDispose<List<WorkspaceEntity>>((ref) {
  final workspaces = ref.watch(activeWorkspacesProvider);
  final sortedWorkspaces = List<WorkspaceEntity>.from(workspaces);
  sortedWorkspaces.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sortedWorkspaces;
});

/// Provider for checking if there are any team workspaces
///
/// Usage:
/// ```dart
/// final hasTeamWorkspaces = ref.watch(hasTeamWorkspacesProvider);
/// if (hasTeamWorkspaces) {
///   // Show team collaboration section
/// }
/// ```
final hasTeamWorkspacesProvider = Provider.autoDispose<bool>((ref) {
  final count = ref.watch(teamWorkspacesCountProvider);
  return count > 0;
});

/// Provider for checking if there are any archived workspaces
///
/// Usage:
/// ```dart
/// final hasArchived = ref.watch(hasArchivedWorkspacesProvider);
/// if (hasArchived) {
///   // Show archived workspaces option in menu
/// }
/// ```
final hasArchivedWorkspacesProvider = Provider.autoDispose<bool>((ref) {
  final count = ref.watch(archivedWorkspacesCountProvider);
  return count > 0;
});

/// Provider family for checking if user is member of a specific workspace
///
/// Usage:
/// ```dart
/// final isMember = ref.watch(isMemberOfWorkspaceProvider(
///   (userId, workspaceId)
/// ));
/// if (isMember) {
///   // Show workspace-specific UI
/// }
/// ```
final isMemberOfWorkspaceProvider = Provider.autoDispose.family<
    bool,
    ({String userId, String workspaceId})>((ref, params) {
  final workspaceState = ref.watch(workspaceNotifierProvider);
  return workspaceState.isMemberOfWorkspace(params.userId, params.workspaceId);
});

/// Provider family for checking if user is owner of a workspace
///
/// Usage:
/// ```dart
/// final isOwner = ref.watch(isWorkspaceOwnerProvider(
///   (userId, workspaceId)
/// ));
/// if (isOwner) {
///   // Show owner-only options
/// }
/// ```
final isWorkspaceOwnerProvider = Provider.autoDispose.family<
    bool,
    ({String userId, String workspaceId})>((ref, params) {
  final workspace = ref.watch(workspaceByIdProvider(params.workspaceId));
  return workspace?.isOwner(params.userId) ?? false;
});

/// Provider family for checking if user is admin of a workspace
///
/// Usage:
/// ```dart
/// final isAdmin = ref.watch(isWorkspaceAdminProvider(
///   (userId, workspaceId)
/// ));
/// if (isAdmin) {
///   // Show admin options
/// }
/// ```
final isWorkspaceAdminProvider = Provider.autoDispose.family<
    bool,
    ({String userId, String workspaceId})>((ref, params) {
  final workspace = ref.watch(workspaceByIdProvider(params.workspaceId));
  return workspace?.isAdmin(params.userId) ?? false;
});
