import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/workspace_repository.dart';

/// Use case for leaving a workspace
///
/// Business rules:
/// - User must be an active member of the workspace
/// - Workspace owner cannot leave without transferring ownership first
/// - User's tasks and lists remain in the workspace (assigned to owner)
/// - Cannot leave archived or deleted workspaces
/// - User can be re-invited after leaving
class LeaveWorkspaceUseCase {
  final WorkspaceRepository repository;

  LeaveWorkspaceUseCase(this.repository);

  /// Leaves a workspace
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace to leave
  /// - [userId]: The ID of the user leaving the workspace
  ///
  /// Returns:
  /// - Right(void): If successfully left the workspace
  /// - Left(ValidationFailure): If validation fails
  /// - Left(AuthorizationFailure): If user is owner and hasn't transferred ownership
  /// - Left(NotFoundFailure): If workspace doesn't exist or user is not a member
  Future<Either<Failure, void>> call({
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

    // Get the workspace to check membership and ownership
    final workspaceResult = await repository.getWorkspace(workspaceId);

    return workspaceResult.fold(
      (failure) => Left(failure),
      (workspace) async {
        // Check if workspace is archived or deleted
        if (workspace.isArchived) {
          return Left(ValidationFailure(
              message: 'Cannot leave an archived workspace'));
        }

        if (workspace.isDeleted) {
          return Left(
              ValidationFailure(message: 'Cannot leave a deleted workspace'));
        }

        // Check if user is the owner
        if (workspace.isOwner(userId)) {
          return Left(AuthorizationFailure(
              message:
                  'Workspace owner cannot leave. Please transfer ownership first or delete the workspace.'));
        }

        // Check if user is a member
        final member = workspace.getMember(userId);

        if (member == null) {
          return Left(NotFoundFailure(
              message: 'You are not a member of this workspace'));
        }

        // Check if member is active
        if (!member.isActive) {
          return Left(ValidationFailure(
              message: 'You have already left this workspace'));
        }

        // Check if member has accepted the invitation
        if (!member.hasAccepted) {
          return Left(ValidationFailure(
              message:
                  'You have not accepted the invitation yet. Decline the invitation instead.'));
        }

        // Leave the workspace
        return await repository.leaveWorkspace(workspaceId);
      },
    );
  }
}
