import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/attachment_repository.dart';

/// Use case for downloading an attachment
///
/// Validates:
/// - Attachment ID
/// - Attachment exists and is not deleted
/// - Attachment is not expired
///
/// Returns the file data as Uint8List
class DownloadAttachmentUseCase {
  final AttachmentRepository repository;

  DownloadAttachmentUseCase(this.repository);

  Future<Either<Failure, Uint8List>> call(String attachmentId) async {
    // Validate attachment ID
    if (attachmentId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Attachment ID cannot be empty'));
    }

    // Get attachment to validate it exists and check its status
    final attachmentResult = await repository.getAttachment(attachmentId);
    if (attachmentResult.isLeft()) {
      return Left(NotFoundFailure(message: 'Attachment not found'));
    }

    final attachment = attachmentResult.getOrElse(
      () => throw Exception('Unexpected error'),
    );

    // Check if attachment is deleted
    if (attachment.isDeleted) {
      return Left(ValidationFailure(
          message: 'Cannot download deleted attachment'));
    }

    // Check if attachment is expired
    if (attachment.isExpired) {
      return Left(ValidationFailure(
          message: 'Attachment has expired and can no longer be downloaded'));
    }

    // Download attachment
    return await repository.downloadAttachment(attachmentId);
  }
}
