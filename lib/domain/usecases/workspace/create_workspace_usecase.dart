import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/workspace_entity.dart';
import '../../repositories/workspace_repository.dart';

/// Use case for creating a new workspace
///
/// Business rules:
/// - Workspace name must be between 1-100 characters
/// - Description is optional but limited to 500 characters
/// - Users can have maximum 10 workspaces
/// - Workspace name must be unique per user
/// - Only users with active accounts can create workspaces
class CreateWorkspaceUseCase {
  final WorkspaceRepository repository;

  CreateWorkspaceUseCase(this.repository);

  /// Creates a new workspace with the given details
  ///
  /// Parameters:
  /// - [workspace]: The workspace entity to create
  /// - [userId]: The ID of the user creating the workspace
  ///
  /// Returns:
  /// - Right(WorkspaceEntity): The created workspace
  /// - Left(ValidationFailure): If validation fails
  /// - Left(ServerFailure): If workspace limit is exceeded or name is not unique
  Future<Either<Failure, WorkspaceEntity>> call({
    required WorkspaceEntity workspace,
    required String userId,
  }) async {
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

    // Validate owner ID matches user ID
    if (workspace.ownerId != userId) {
      return Left(ValidationFailure(
          message: 'Workspace owner must be the creating user'));
    }

    // Get user's existing workspaces to check limits
    final workspacesResult = await repository.getWorkspaces(
      userId: userId,
      includeArchived: false,
      includeDeleted: false,
    );

    return workspacesResult.fold(
      (failure) => Left(failure),
      (existingWorkspaces) async {
        // Check workspace limit (max 10 per user)
        if (existingWorkspaces.length >= 10) {
          return Left(ValidationFailure(
              message:
                  'Maximum workspace limit reached. You can have up to 10 workspaces.'));
        }

        // Check for duplicate workspace names
        final duplicateName = existingWorkspaces.any(
          (w) => w.name.toLowerCase() == workspace.name.trim().toLowerCase(),
        );

        if (duplicateName) {
          return Left(ValidationFailure(
              message:
                  'A workspace with this name already exists. Please choose a different name.'));
        }

        // Create the workspace
        return await repository.createWorkspace(workspace);
      },
    );
  }
}
