import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/workspace_entity.dart';
import '../../repositories/workspace_repository.dart';

/// Use case for removing a member from a workspace
///
/// Business rules:
/// - Only workspace owner or admin can remove members
/// - Workspace owner cannot be removed
/// - Admins can only remove regular members and guests, not other admins
/// - Owner can remove anyone except themselves
/// - Cannot remove members from archived or deleted workspaces
/// - Member's tasks and lists are not deleted, just access is revoked
class RemoveMemberUseCase {
  final WorkspaceRepository repository;

  RemoveMemberUseCase(this.repository);

  /// Removes a member from the workspace
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace
  /// - [userId]: The ID of the user to remove
  /// - [removedBy]: The ID of the user performing the removal
  ///
  /// Returns:
  /// - Right(WorkspaceEntity): The updated workspace without the member
  /// - Left(ValidationFailure): If validation fails
  /// - Left(AuthorizationFailure): If user doesn't have permission
  /// - Left(NotFoundFailure): If workspace or member doesn't exist
  Future<Either<Failure, WorkspaceEntity>> call({
    required String workspaceId,
    required String userId,
    required String removedBy,
  }) async {
    // Validate workspace ID
    if (workspaceId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Workspace ID cannot be empty'));
    }

    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Validate removedBy
    if (removedBy.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Remover ID cannot be empty'));
    }

    // Cannot remove yourself (use leave workspace instead)
    if (userId == removedBy) {
      return Left(ValidationFailure(
          message:
              'Cannot remove yourself from the workspace. Use leave workspace instead.'));
    }

    // Get the workspace to check permissions
    final workspaceResult = await repository.getWorkspace(workspaceId);

    return workspaceResult.fold(
      (failure) => Left(failure),
      (workspace) async {
        // Check if workspace is archived or deleted
        if (workspace.isArchived) {
          return Left(ValidationFailure(
              message: 'Cannot remove members from an archived workspace'));
        }

        if (workspace.isDeleted) {
          return Left(ValidationFailure(
              message: 'Cannot remove members from a deleted workspace'));
        }

        // Check if the user to be removed is the owner
        if (workspace.isOwner(userId)) {
          return Left(ValidationFailure(
              message:
                  'Cannot remove the workspace owner. Transfer ownership first.'));
        }

        // Get the member to be removed
        final memberToRemove = workspace.getMember(userId);
        if (memberToRemove == null) {
          return Left(
              NotFoundFailure(message: 'User is not a member of this workspace'));
        }

        if (!memberToRemove.isActive) {
          return Left(ValidationFailure(
              message: 'User is already removed from this workspace'));
        }

        // Check if remover has permission
        final isOwner = workspace.isOwner(removedBy);
        final isAdmin = workspace.isAdmin(removedBy);

        if (!isOwner && !isAdmin) {
          return Left(AuthorizationFailure(
              message: 'Only workspace owner or admin can remove members'));
        }

        // If remover is admin (not owner), validate they can only remove regular members and guests
        if (isAdmin && !isOwner) {
          // Check if member to remove is admin or owner
          if (memberToRemove.role == WorkspaceRole.admin) {
            return Left(AuthorizationFailure(
                message:
                    'Admins cannot remove other admins. Only the owner can do this.'));
          }
        }

        // Remove the member
        return await repository.removeMember(
          workspaceId: workspaceId,
          userId: userId,
        );
      },
    );
  }
}
