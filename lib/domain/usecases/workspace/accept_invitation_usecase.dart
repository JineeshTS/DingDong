import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/workspace_entity.dart';
import '../../repositories/workspace_repository.dart';

/// Use case for accepting a workspace invitation
///
/// Business rules:
/// - Invitation must exist for the user
/// - Invitation must not be expired
/// - User must not already be an active member
/// - Workspace must not be deleted or archived
/// - Workspace must have available slots (not exceed member limit)
/// - User account must be active
class AcceptInvitationUseCase {
  final WorkspaceRepository repository;

  AcceptInvitationUseCase(this.repository);

  /// Accepts a workspace invitation
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace
  /// - [userId]: The ID of the user accepting the invitation
  ///
  /// Returns:
  /// - Right(WorkspaceEntity): The updated workspace with the user as an active member
  /// - Left(ValidationFailure): If validation fails
  /// - Left(NotFoundFailure): If workspace or invitation doesn't exist
  /// - Left(AuthorizationFailure): If invitation is expired or invalid
  Future<Either<Failure, WorkspaceEntity>> call({
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

    // Get the workspace
    final workspaceResult = await repository.getWorkspace(workspaceId);

    return workspaceResult.fold(
      (failure) => Left(failure),
      (workspace) async {
        // Check if workspace is archived or deleted
        if (workspace.isArchived) {
          return Left(ValidationFailure(
              message: 'Cannot accept invitation to an archived workspace'));
        }

        if (workspace.isDeleted) {
          return Left(ValidationFailure(
              message: 'Cannot accept invitation to a deleted workspace'));
        }

        // Check if user has a pending invitation
        final member = workspace.getMember(userId);

        if (member == null) {
          return Left(NotFoundFailure(
              message:
                  'No invitation found for this workspace. Please request an invitation.'));
        }

        // Check if user is already an active member
        if (member.hasAccepted && member.isActive) {
          return Left(ValidationFailure(
              message: 'You are already a member of this workspace'));
        }

        // Check if member is inactive (was removed)
        if (!member.isActive) {
          return Left(ValidationFailure(
              message:
                  'Your membership was revoked. Please request a new invitation.'));
        }

        // Check if invitation has been accepted already
        if (member.hasAccepted) {
          return Left(ValidationFailure(
              message: 'Invitation has already been accepted'));
        }

        // Check if invitation is expired (invitations valid for 7 days)
        final invitationAge = DateTime.now().difference(member.joinedAt);
        final maxInvitationAge = const Duration(days: 7);

        if (invitationAge > maxInvitationAge) {
          return Left(AuthorizationFailure(
              message:
                  'Invitation has expired. Please request a new invitation.'));
        }

        // Check workspace member limit
        final activeMemberCount = workspace.members
            .where((m) => m.isActive && m.hasAccepted)
            .length;
        final maxMembers = workspace.subscription.maxMembers;

        if (activeMemberCount >= maxMembers) {
          return Left(ValidationFailure(
              message:
                  'Workspace has reached its member limit ($maxMembers). '
                  'Please contact the workspace owner.'));
        }

        // Accept the invitation
        return await repository.acceptInvitation(workspaceId);
      },
    );
  }
}
