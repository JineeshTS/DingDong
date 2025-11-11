import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/workspace_entity.dart';
import '../../repositories/workspace_repository.dart';

/// Use case for adding a member to a workspace
///
/// Business rules:
/// - Only workspace owner or admin can add members
/// - User cannot be added if already a member
/// - Maximum members based on workspace subscription plan
/// - Email is required for new invitations
/// - Invitation is created and sent to the user
/// - Cannot add members to archived or deleted workspaces
/// - Guest role requires guest access to be enabled in workspace settings
class AddMemberUseCase {
  final WorkspaceRepository repository;

  AddMemberUseCase(this.repository);

  /// Adds a member to the workspace
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace
  /// - [userId]: The ID of the user to add (can be empty for email invitations)
  /// - [email]: The email of the user to invite (required if userId is empty)
  /// - [role]: The role to assign to the new member
  /// - [invitedBy]: The ID of the user sending the invitation
  ///
  /// Returns:
  /// - Right(WorkspaceEntity): The updated workspace with the new member
  /// - Left(ValidationFailure): If validation fails
  /// - Left(AuthorizationFailure): If user doesn't have permission
  /// - Left(NotFoundFailure): If workspace doesn't exist
  Future<Either<Failure, WorkspaceEntity>> call({
    required String workspaceId,
    String? userId,
    String? email,
    required WorkspaceRole role,
    required String invitedBy,
  }) async {
    // Validate workspace ID
    if (workspaceId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Workspace ID cannot be empty'));
    }

    // Validate that either userId or email is provided
    if ((userId == null || userId.trim().isEmpty) &&
        (email == null || email.trim().isEmpty)) {
      return Left(ValidationFailure(
          message: 'Either user ID or email must be provided'));
    }

    // Validate email format if provided
    if (email != null && email.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        return Left(ValidationFailure(message: 'Invalid email format'));
      }
    }

    // Validate invitedBy
    if (invitedBy.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Inviter ID cannot be empty'));
    }

    // Get the workspace to check permissions and limits
    final workspaceResult = await repository.getWorkspace(workspaceId);

    return workspaceResult.fold(
      (failure) => Left(failure),
      (workspace) async {
        // Check if workspace is archived or deleted
        if (workspace.isArchived) {
          return Left(ValidationFailure(
              message: 'Cannot add members to an archived workspace'));
        }

        if (workspace.isDeleted) {
          return Left(ValidationFailure(
              message: 'Cannot add members to a deleted workspace'));
        }

        // Check if inviter has permission (must be owner or admin)
        final isOwner = workspace.isOwner(invitedBy);
        final isAdmin = workspace.isAdmin(invitedBy);

        if (!isOwner && !isAdmin) {
          return Left(AuthorizationFailure(
              message: 'Only workspace owner or admin can add members'));
        }

        // Check if guest access is enabled if adding a guest
        if (role == WorkspaceRole.guest &&
            !workspace.settings.allowGuestAccess) {
          return Left(ValidationFailure(
              message:
                  'Guest access is not enabled for this workspace. Please enable it in settings.'));
        }

        // Check if user is already a member
        if (userId != null && userId.trim().isNotEmpty) {
          final existingMember = workspace.getMember(userId);
          if (existingMember != null && existingMember.isActive) {
            return Left(ValidationFailure(
                message: 'User is already a member of this workspace'));
          }
        }

        // Check member limit based on subscription plan
        final maxMembers = workspace.subscription.maxMembers;
        final currentMemberCount = workspace.members
            .where((m) => m.isActive && m.hasAccepted)
            .length;

        if (currentMemberCount >= maxMembers) {
          return Left(ValidationFailure(
              message:
                  'Maximum member limit ($maxMembers) reached for your ${workspace.subscription.tier.name} plan. '
                  'Please upgrade your plan to add more members.'));
        }

        // Validate role (cannot assign owner role through add member)
        if (role == WorkspaceRole.owner) {
          return Left(ValidationFailure(
              message:
                  'Cannot assign owner role. Use transfer ownership instead.'));
        }

        // Add the member (sends invitation if needed)
        return await repository.addMember(
          workspaceId: workspaceId,
          userId: userId ?? '',
          email: email,
          role: role,
          invitedBy: invitedBy,
        );
      },
    );
  }
}
