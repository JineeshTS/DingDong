import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/workspace_entity.dart';
import '../../repositories/workspace_repository.dart';

/// Use case for updating a member's role in a workspace
///
/// Business rules:
/// - Only workspace owner can change member roles
/// - Admins can promote members to admin or demote guests, but not change admin roles
/// - Cannot change owner role (use transfer ownership instead)
/// - Cannot change your own role
/// - Valid roles: owner, admin, member, guest
/// - Guest role requires guest access to be enabled in workspace settings
/// - Cannot update roles in archived or deleted workspaces
class UpdateMemberRoleUseCase {
  final WorkspaceRepository repository;

  UpdateMemberRoleUseCase(this.repository);

  /// Updates a member's role in the workspace
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace
  /// - [userId]: The ID of the user whose role is being updated
  /// - [newRole]: The new role to assign
  /// - [updatedBy]: The ID of the user performing the update
  ///
  /// Returns:
  /// - Right(WorkspaceEntity): The updated workspace
  /// - Left(ValidationFailure): If validation fails
  /// - Left(AuthorizationFailure): If user doesn't have permission
  /// - Left(NotFoundFailure): If workspace or member doesn't exist
  Future<Either<Failure, WorkspaceEntity>> call({
    required String workspaceId,
    required String userId,
    required WorkspaceRole newRole,
    required String updatedBy,
  }) async {
    // Validate workspace ID
    if (workspaceId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Workspace ID cannot be empty'));
    }

    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Validate updatedBy
    if (updatedBy.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Updater ID cannot be empty'));
    }

    // Cannot update your own role
    if (userId == updatedBy) {
      return Left(ValidationFailure(
          message:
              'Cannot change your own role. Ask another admin or owner.'));
    }

    // Get the workspace to check permissions
    final workspaceResult = await repository.getWorkspace(workspaceId);

    return workspaceResult.fold(
      (failure) => Left(failure),
      (workspace) async {
        // Check if workspace is archived or deleted
        if (workspace.isArchived) {
          return Left(ValidationFailure(
              message: 'Cannot update member roles in an archived workspace'));
        }

        if (workspace.isDeleted) {
          return Left(ValidationFailure(
              message: 'Cannot update member roles in a deleted workspace'));
        }

        // Get the member whose role is being updated
        final memberToUpdate = workspace.getMember(userId);
        if (memberToUpdate == null) {
          return Left(
              NotFoundFailure(message: 'User is not a member of this workspace'));
        }

        if (!memberToUpdate.isActive) {
          return Left(ValidationFailure(
              message: 'Cannot update role of inactive member'));
        }

        // Cannot change owner role through this use case
        if (newRole == WorkspaceRole.owner ||
            memberToUpdate.role == WorkspaceRole.owner) {
          return Left(ValidationFailure(
              message:
                  'Cannot assign or change owner role. Use transfer ownership instead.'));
        }

        // Check if updater has permission
        final isOwner = workspace.isOwner(updatedBy);
        final isAdmin = workspace.isAdmin(updatedBy);

        if (!isOwner && !isAdmin) {
          return Left(AuthorizationFailure(
              message:
                  'Only workspace owner or admin can update member roles'));
        }

        // If updater is admin (not owner), validate permissions
        if (isAdmin && !isOwner) {
          // Admins cannot change roles of other admins
          if (memberToUpdate.role == WorkspaceRole.admin) {
            return Left(AuthorizationFailure(
                message:
                    'Admins cannot change roles of other admins. Only the owner can do this.'));
          }

          // Admins cannot promote members to admin
          if (newRole == WorkspaceRole.admin) {
            return Left(AuthorizationFailure(
                message: 'Only the workspace owner can promote members to admin'));
          }
        }

        // Check if guest access is enabled if assigning guest role
        if (newRole == WorkspaceRole.guest &&
            !workspace.settings.allowGuestAccess) {
          return Left(ValidationFailure(
              message:
                  'Guest access is not enabled for this workspace. Please enable it in settings.'));
        }

        // Check if role is actually changing
        if (memberToUpdate.role == newRole) {
          return Left(ValidationFailure(
              message: 'Member already has the role: ${newRole.name}'));
        }

        // Update the member's role
        return await repository.updateMemberRole(
          workspaceId: workspaceId,
          userId: userId,
          role: newRole,
        );
      },
    );
  }
}
