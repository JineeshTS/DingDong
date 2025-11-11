import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/workspace_entity.dart';

part 'workspace_state.freezed.dart';

/// Workspace management state for the application
///
/// Manages the state of workspaces, members, invitations, and workspace operations.
/// This state is used by [WorkspaceNotifier] to track workspace-related operations.
///
/// States:
/// - [initial]: App just started, workspaces not yet loaded
/// - [loading]: Workspace operation in progress
/// - [loaded]: Workspaces successfully loaded
/// - [error]: Workspace operation failed
@freezed
class WorkspaceState with _$WorkspaceState {
  /// Initial state when workspaces haven't been loaded yet
  ///
  /// Used before fetching user's workspaces
  const factory WorkspaceState.initial() = _Initial;

  /// Workspace operation in progress
  ///
  /// Preserves current workspaces during the operation and optionally shows a message
  const factory WorkspaceState.loading({
    @Default([]) List<WorkspaceEntity> workspaces,
    String? message,
  }) = _Loading;

  /// Workspaces successfully loaded
  ///
  /// Contains all workspaces for the current user
  const factory WorkspaceState.loaded({
    required List<WorkspaceEntity> workspaces,
  }) = _Loaded;

  /// Workspace operation failed
  ///
  /// Contains the failure and preserves current workspaces
  const factory WorkspaceState.error({
    required Failure failure,
    @Default([]) List<WorkspaceEntity> workspaces,
  }) = _Error;

  const WorkspaceState._();

  /// Check if state is loading
  bool get isLoading => this is _Loading;

  /// Check if state has error
  bool get hasError => this is _Error;

  /// Check if state is initial
  bool get isInitial => this is _Initial;

  /// Check if workspaces are loaded
  bool get isLoaded => this is _Loaded;

  /// Get current workspaces or empty list
  List<WorkspaceEntity> get workspacesOrEmpty => maybeWhen(
        loading: (workspaces, _) => workspaces,
        loaded: (workspaces) => workspaces,
        error: (_, workspaces) => workspaces,
        orElse: () => [],
      );

  /// Get error or null
  Failure? get errorOrNull => maybeWhen(
        error: (failure, _) => failure,
        orElse: () => null,
      );

  /// Get loading message or null
  String? get loadingMessageOrNull => maybeWhen(
        loading: (_, message) => message,
        orElse: () => null,
      );

  /// Get non-archived, non-deleted workspaces
  List<WorkspaceEntity> get activeWorkspaces =>
      workspacesOrEmpty.where((w) => !w.isArchived && !w.isDeleted).toList();

  /// Get personal workspaces
  List<WorkspaceEntity> get personalWorkspaces =>
      activeWorkspaces.where((w) => w.type == WorkspaceType.personal).toList();

  /// Get team workspaces
  List<WorkspaceEntity> get teamWorkspaces =>
      activeWorkspaces.where((w) => w.type == WorkspaceType.team).toList();

  /// Get archived workspaces
  List<WorkspaceEntity> get archivedWorkspaces =>
      workspacesOrEmpty.where((w) => w.isArchived && !w.isDeleted).toList();

  /// Get workspaces by type
  List<WorkspaceEntity> getWorkspacesByType(WorkspaceType type) =>
      activeWorkspaces.where((w) => w.type == type).toList();

  /// Find a workspace by ID
  WorkspaceEntity? findWorkspaceById(String workspaceId) {
    try {
      return workspacesOrEmpty.firstWhere((w) => w.id == workspaceId);
    } catch (e) {
      return null;
    }
  }

  /// Get workspaces where user is owner
  List<WorkspaceEntity> getOwnedWorkspaces(String userId) =>
      activeWorkspaces.where((w) => w.isOwner(userId)).toList();

  /// Get workspaces where user is admin
  List<WorkspaceEntity> getAdminWorkspaces(String userId) =>
      activeWorkspaces.where((w) => w.isAdmin(userId)).toList();

  /// Get workspaces where user has specific role
  List<WorkspaceEntity> getWorkspacesByRole(String userId, WorkspaceRole role) =>
      activeWorkspaces.where((w) {
        final member = w.getMember(userId);
        return member != null && member.role == role;
      }).toList();

  /// Get members of a specific workspace
  List<WorkspaceMember> getWorkspaceMembers(String workspaceId) {
    final workspace = findWorkspaceById(workspaceId);
    return workspace?.members ?? [];
  }

  /// Get pending members (not yet accepted invitation)
  List<WorkspaceMember> getPendingMembers(String workspaceId) {
    final workspace = findWorkspaceById(workspaceId);
    return workspace?.members.where((m) => !m.hasAccepted).toList() ?? [];
  }

  /// Get active members (accepted and active)
  List<WorkspaceMember> getActiveMembers(String workspaceId) {
    final workspace = findWorkspaceById(workspaceId);
    return workspace?.members.where((m) => m.isActive && m.hasAccepted).toList() ?? [];
  }

  /// Get members by role in a workspace
  List<WorkspaceMember> getMembersByRole(String workspaceId, WorkspaceRole role) {
    final workspace = findWorkspaceById(workspaceId);
    return workspace?.members.where((m) => m.role == role).toList() ?? [];
  }

  /// Get total count of active workspaces
  int get activeWorkspacesCount => activeWorkspaces.length;

  /// Get total count of team workspaces
  int get teamWorkspacesCount => teamWorkspaces.length;

  /// Get total count of personal workspaces
  int get personalWorkspacesCount => personalWorkspaces.length;

  /// Get total count of archived workspaces
  int get archivedWorkspacesCount => archivedWorkspaces.length;

  /// Get total member count across all workspaces
  int getTotalMemberCount(String workspaceId) {
    final workspace = findWorkspaceById(workspaceId);
    return workspace?.memberCount ?? 0;
  }

  /// Check if user is member of any workspace
  bool isMemberOfAnyWorkspace(String userId) {
    return activeWorkspaces.any((w) => w.getMember(userId) != null);
  }

  /// Check if user is member of specific workspace
  bool isMemberOfWorkspace(String userId, String workspaceId) {
    final workspace = findWorkspaceById(workspaceId);
    return workspace?.getMember(userId) != null;
  }
}
