import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/workspace_entity.dart';
import '../../repositories/workspace_repository.dart';

/// Use case for transferring workspace ownership
///
/// Business rules:
/// - Only current workspace owner can transfer ownership
/// - New owner must be an active member of the workspace
/// - New owner must have accepted their invitation
/// - New owner is recommended to be an admin, but can be any active member
/// - Current owner becomes an admin after transfer
/// - Cannot transfer ownership to yourself
/// - Cannot transfer ownership in archived or deleted workspaces
/// - Ownership transfer is irreversible without another transfer
class TransferOwnershipUseCase {
  final WorkspaceRepository repository;

  TransferOwnershipUseCase(this.repository);

  /// Transfers workspace ownership to another member
  ///
  /// Parameters:
  /// - [workspaceId]: The ID of the workspace
  /// - [newOwnerId]: The ID of the user who will become the new owner
  /// - [currentOwnerId]: The ID of the current owner (for validation)
  ///
  /// Returns:
  /// - Right(WorkspaceEntity): The updated workspace with new ownership
  /// - Left(ValidationFailure): If validation fails
  /// - Left(AuthorizationFailure): If user is not the current owner
  /// - Left(NotFoundFailure): If workspace or new owner doesn't exist
  Future<Either<Failure, WorkspaceEntity>> call({
    required String workspaceId,
    required String newOwnerId,
    required String currentOwnerId,
  }) async {
    // Validate workspace ID
    if (workspaceId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Workspace ID cannot be empty'));
    }

    // Validate new owner ID
    if (newOwnerId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'New owner ID cannot be empty'));
    }

    // Validate current owner ID
    if (currentOwnerId.trim().isEmpty) {
      return Left(
          ValidationFailure(message: 'Current owner ID cannot be empty'));
    }

    // Cannot transfer to yourself
    if (newOwnerId == currentOwnerId) {
      return Left(ValidationFailure(
          message: 'You are already the owner of this workspace'));
    }

    // Get the workspace to check ownership and membership
    final workspaceResult = await repository.getWorkspace(workspaceId);

    return workspaceResult.fold(
      (failure) => Left(failure),
      (workspace) async {
        // Check if workspace is archived or deleted
        if (workspace.isArchived) {
          return Left(ValidationFailure(
              message: 'Cannot transfer ownership of an archived workspace'));
        }

        if (workspace.isDeleted) {
          return Left(ValidationFailure(
              message: 'Cannot transfer ownership of a deleted workspace'));
        }

        // Verify that the requester is the current owner
        if (!workspace.isOwner(currentOwnerId)) {
          return Left(AuthorizationFailure(
              message: 'Only the workspace owner can transfer ownership'));
        }

        // Verify workspace owner matches the provided current owner ID
        if (workspace.ownerId != currentOwnerId) {
          return Left(AuthorizationFailure(
              message: 'You are not the current owner of this workspace'));
        }

        // Check if new owner is a member
        final newOwnerMember = workspace.getMember(newOwnerId);

        if (newOwnerMember == null) {
          return Left(NotFoundFailure(
              message:
                  'New owner must be a member of the workspace. Please add them first.'));
        }

        // Check if new owner is an active member
        if (!newOwnerMember.isActive) {
          return Left(ValidationFailure(
              message:
                  'Cannot transfer ownership to an inactive member. Please re-invite them first.'));
        }

        // Check if new owner has accepted their invitation
        if (!newOwnerMember.hasAccepted) {
          return Left(ValidationFailure(
              message:
                  'New owner must accept their invitation before receiving ownership'));
        }

        // Warn if new owner is not an admin (but allow it)
        if (newOwnerMember.role != WorkspaceRole.admin &&
            newOwnerMember.role != WorkspaceRole.owner) {
          // This is just a warning, not blocking the transfer
          // The repository should handle promoting the new owner
        }

        // Transfer ownership
        return await repository.transferOwnership(
          workspaceId: workspaceId,
          newOwnerId: newOwnerId,
        );
      },
    );
  }
}
