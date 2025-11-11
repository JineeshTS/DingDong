import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/workspace_repository.dart';

/// Use case for getting workspace statistics
///
/// Returns comprehensive workspace statistics including:
/// - Member count (total, active, pending invitations)
/// - Task count (total, active, completed, overdue)
/// - List count (total, active, archived)
/// - Activity metrics (recent activity count, last activity date)
/// - Storage usage (if applicable)
/// - Subscription information
///
/// Business rules:
/// - User must be a member of the workspace to view statistics
/// - Archived and deleted workspaces can still provide statistics
/// - Statistics are calculated in real-time
class GetWorkspaceStatisticsUseCase {
  final WorkspaceRepository repository;

  GetWorkspaceStatisticsUseCase(this.repository);

  /// Gets comprehensive statistics for a workspace
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace
  /// - [userId]: The ID of the user requesting statistics (for permission check)
  ///
  /// Returns:
  /// - Right(Map<String, dynamic>): A map containing workspace statistics with keys:
  ///   - memberCount: Total number of members
  ///   - activeMemberCount: Number of active members
  ///   - pendingInvitations: Number of pending invitations
  ///   - taskCount: Total number of tasks
  ///   - activeTasks: Number of active (not completed) tasks
  ///   - completedTasks: Number of completed tasks
  ///   - overdueTasks: Number of overdue tasks
  ///   - listCount: Total number of lists
  ///   - activeLists: Number of active (not archived) lists
  ///   - archivedLists: Number of archived lists
  ///   - recentActivityCount: Number of recent activities (last 7 days)
  ///   - lastActivityDate: DateTime of last activity
  ///   - storageUsed: Storage used in bytes (optional)
  ///   - subscriptionTier: Current subscription tier
  ///   - maxMembers: Maximum members allowed by subscription
  /// - Left(ValidationFailure): If validation fails
  /// - Left(AuthorizationFailure): If user doesn't have permission
  /// - Left(NotFoundFailure): If workspace doesn't exist
  Future<Either<Failure, Map<String, dynamic>>> call({
    required String workspaceId,
    required String userId,
  }) async {
    // Validate workspace ID
    if (workspaceId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Workspace ID cannot be empty'));
    }

    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Get the workspace to check membership
    final workspaceResult = await repository.getWorkspace(workspaceId);

    return workspaceResult.fold(
      (failure) => Left(failure),
      (workspace) async {
        // Check if user is a member of the workspace
        final member = workspace.getMember(userId);

        if (member == null) {
          return Left(AuthorizationFailure(
              message:
                  'You must be a member of the workspace to view statistics'));
        }

        // Allow inactive members to view statistics if they're owner
        if (!member.isActive && !workspace.isOwner(userId)) {
          return Left(AuthorizationFailure(
              message:
                  'You are no longer a member of this workspace and cannot view statistics'));
        }

        // Get statistics from repository
        final statisticsResult =
            await repository.getWorkspaceStatistics(workspaceId);

        return statisticsResult.fold(
          (failure) => Left(failure),
          (statistics) {
            // Enhance statistics with workspace information
            final enhancedStatistics = <String, dynamic>{
              ...statistics,
              // Add workspace metadata
              'workspaceId': workspace.id,
              'workspaceName': workspace.name,
              'workspaceType': workspace.type.name,
              'ownerId': workspace.ownerId,
              'isArchived': workspace.isArchived,
              'isDeleted': workspace.isDeleted,
              'createdAt': workspace.createdAt.toIso8601String(),
              'updatedAt': workspace.updatedAt.toIso8601String(),
              // Add subscription information
              'subscriptionTier': workspace.subscription.tier.name,
              'maxMembers': workspace.subscription.maxMembers,
              'subscriptionActive': workspace.subscription.isActive,
              // Calculate member statistics from workspace entity
              'totalMembers': workspace.members.length,
              'activeMembersFromEntity': workspace.members
                  .where((m) => m.isActive && m.hasAccepted)
                  .length,
              'pendingInvitationsFromEntity':
                  workspace.members.where((m) => !m.hasAccepted).length,
              'inactiveMembersFromEntity':
                  workspace.members.where((m) => !m.isActive).length,
              // Add member role breakdown
              'ownerCount':
                  workspace.members.where((m) => m.role == WorkspaceRole.owner).length,
              'adminCount':
                  workspace.members.where((m) => m.role == WorkspaceRole.admin).length,
              'memberCount': workspace.members
                  .where((m) => m.role == WorkspaceRole.member)
                  .length,
              'guestCount':
                  workspace.members.where((m) => m.role == WorkspaceRole.guest).length,
            };

            return Right(enhancedStatistics);
          },
        );
      },
    );
  }
}
