import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/attachment_repository.dart';

/// Use case for deleting an attachment
///
/// Performs soft delete by default. Use permanent flag for hard delete
/// which also removes the file from storage.
///
/// Validates:
/// - Attachment ID
/// - User has permission to delete
/// - Attachment exists
class DeleteAttachmentUseCase {
  final AttachmentRepository repository;

  DeleteAttachmentUseCase(this.repository);

  /// Delete attachment
  ///
  /// [attachmentId] - ID of the attachment to delete
  /// [userId] - ID of the user performing the deletion (for permission check)
  /// [permanent] - If true, permanently delete from storage, otherwise soft delete
  Future<Either<Failure, void>> call({
    required String attachmentId,
    required String userId,
    bool permanent = false,
  }) async {
    // Validate attachment ID
    if (attachmentId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Attachment ID cannot be empty'));
    }

    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Get attachment to verify it exists and user owns it
    final attachmentResult = await repository.getAttachment(attachmentId);
    if (attachmentResult.isLeft()) {
      return Left(NotFoundFailure(message: 'Attachment not found'));
    }

    final attachment = attachmentResult.getOrElse(
      () => throw Exception('Unexpected error'),
    );

    // Check if user has permission to delete (must be the owner)
    if (attachment.userId != userId) {
      return Left(AuthorizationFailure(
          message: 'You do not have permission to delete this attachment'));
    }

    // Check if already deleted (for soft delete)
    if (!permanent && attachment.isDeleted) {
      return Left(ValidationFailure(
          message: 'Attachment is already deleted'));
    }

    // Perform deletion
    if (permanent) {
      return await repository.permanentlyDeleteAttachment(attachmentId);
    } else {
      return await repository.deleteAttachment(attachmentId);
    }
  }
}
