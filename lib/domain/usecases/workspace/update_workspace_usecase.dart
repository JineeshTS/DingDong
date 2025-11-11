import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/workspace_entity.dart';
import '../../repositories/workspace_repository.dart';

/// Use case for updating an existing workspace
///
/// Business rules:
/// - Workspace name must be between 1-100 characters
/// - Description is optional but limited to 500 characters
/// - Workspace name must be unique per user (excluding current workspace)
/// - Only workspace owner or admin can update workspace details
/// - Cannot update archived or deleted workspaces
class UpdateWorkspaceUseCase {
  final WorkspaceRepository repository;

  UpdateWorkspaceUseCase(this.repository);

  /// Updates an existing workspace with the given details
  ///
  /// Parameters:
  /// - [workspace]: The workspace entity with updated details
  /// - [userId]: The ID of the user updating the workspace
  ///
  /// Returns:
  /// - Right(WorkspaceEntity): The updated workspace
  /// - Left(ValidationFailure): If validation fails
  /// - Left(AuthorizationFailure): If user doesn't have permission
  /// - Left(NotFoundFailure): If workspace doesn't exist
  Future<Either<Failure, WorkspaceEntity>> call({
    required WorkspaceEntity workspace,
    required String userId,
  }) async {
    // Validate workspace ID
    if (workspace.id.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Workspace ID cannot be empty'));
    }

    // Validate workspace name
    if (workspace.name.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Workspace name cannot be empty'));
    }

    if (workspace.name.trim().length > 100) {
      return Left(ValidationFailure(
          message: 'Workspace name cannot exceed 100 characters'));
    }

    if (workspace.name.trim().length < 1) {
      return Left(ValidationFailure(
          message: 'Workspace name must be at least 1 character'));
    }

    // Validate description if provided
    if (workspace.description != null &&
        workspace.description!.trim().isNotEmpty &&
        workspace.description!.length > 500) {
      return Left(ValidationFailure(
          message: 'Workspace description cannot exceed 500 characters'));
    }

    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Get the existing workspace to check permissions
    final existingWorkspaceResult = await repository.getWorkspace(workspace.id);

    return existingWorkspaceResult.fold(
      (failure) => Left(failure),
      (existingWorkspace) async {
        // Check if workspace is archived or deleted
        if (existingWorkspace.isArchived) {
          return Left(ValidationFailure(
              message: 'Cannot update an archived workspace'));
        }

        if (existingWorkspace.isDeleted) {
          return Left(
              ValidationFailure(message: 'Cannot update a deleted workspace'));
        }

        // Check if user has permission (must be owner or admin)
        final isOwner = existingWorkspace.isOwner(userId);
        final isAdmin = existingWorkspace.isAdmin(userId);

        if (!isOwner && !isAdmin) {
          return Left(AuthorizationFailure(
              message:
                  'Only workspace owner or admin can update workspace details'));
        }

        // Check for duplicate workspace names (excluding current workspace)
        final workspacesResult = await repository.getWorkspaces(
          userId: existingWorkspace.ownerId,
          includeArchived: false,
          includeDeleted: false,
        );

        return workspacesResult.fold(
          (failure) => Left(failure),
          (userWorkspaces) async {
            // Check for duplicate names (excluding the current workspace)
            final duplicateName = userWorkspaces.any(
              (w) =>
                  w.id != workspace.id &&
                  w.name.toLowerCase() == workspace.name.trim().toLowerCase(),
            );

            if (duplicateName) {
              return Left(ValidationFailure(
                  message:
                      'A workspace with this name already exists. Please choose a different name.'));
            }

            // Update the workspace
            return await repository.updateWorkspace(workspace);
          },
        );
      },
    );
  }
}
