import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/attachment_repository.dart';

/// Use case for batch deleting multiple attachments
///
/// Validates:
/// - Attachment IDs list
/// - Maximum batch size (50 attachments)
/// - User permissions for each attachment
/// - All attachments exist
class BatchDeleteAttachmentsUseCase {
  final AttachmentRepository repository;

  BatchDeleteAttachmentsUseCase(this.repository);

  /// Batch delete attachments
  ///
  /// [attachmentIds] - List of attachment IDs to delete
  /// [userId] - ID of the user performing the deletion
  /// [permanent] - If true, permanently delete from storage, otherwise soft delete
  Future<Either<Failure, BatchDeleteResult>> call({
    required List<String> attachmentIds,
    required String userId,
    bool permanent = false,
  }) async {
    // Validate attachment IDs list
    if (attachmentIds.isEmpty) {
      return Left(ValidationFailure(
          message: 'Attachment IDs list cannot be empty'));
    }

    // Validate maximum batch size
    if (attachmentIds.length > 50) {
      return Left(ValidationFailure(
          message: 'Cannot delete more than 50 attachments at once'));
    }

    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Check for duplicate IDs
    final uniqueIds = attachmentIds.toSet();
    if (uniqueIds.length != attachmentIds.length) {
      return Left(ValidationFailure(
          message: 'Attachment IDs list contains duplicates'));
    }

    // Validate each attachment ID
    for (final id in attachmentIds) {
      if (id.trim().isEmpty) {
        return Left(ValidationFailure(
            message: 'Attachment ID cannot be empty'));
      }
    }

    // Verify user has permission to delete all attachments
    final List<String> successfulDeletes = [];
    final List<String> failedDeletes = [];
    final Map<String, String> errors = {};

    for (final attachmentId in attachmentIds) {
      // Get attachment to verify ownership
      final attachmentResult = await repository.getAttachment(attachmentId);

      if (attachmentResult.isLeft()) {
        failedDeletes.add(attachmentId);
        errors[attachmentId] = 'Attachment not found';
        continue;
      }

      final attachment = attachmentResult.getOrElse(
        () => throw Exception('Unexpected error'),
      );

      // Check ownership
      if (attachment.userId != userId) {
        failedDeletes.add(attachmentId);
        errors[attachmentId] = 'Permission denied';
        continue;
      }

      // Check if already deleted (for soft delete)
      if (!permanent && attachment.isDeleted) {
        failedDeletes.add(attachmentId);
        errors[attachmentId] = 'Already deleted';
        continue;
      }

      successfulDeletes.add(attachmentId);
    }

    // If no attachments can be deleted, return error
    if (successfulDeletes.isEmpty) {
      return Left(ValidationFailure(
          message: 'No attachments could be deleted',
          errors: {'attachments': errors.values.toList()}));
    }

    // Perform batch deletion for valid attachments
    final deleteResult = await repository.batchDeleteAttachments(successfulDeletes);

    if (deleteResult.isLeft()) {
      return Left(deleteResult.fold(
        (failure) => failure,
        (_) => throw Exception('Unexpected error'),
      ));
    }

    // Return detailed result
    return Right(BatchDeleteResult(
      totalRequested: attachmentIds.length,
      successCount: successfulDeletes.length,
      failureCount: failedDeletes.length,
      successfulIds: successfulDeletes,
      failedIds: failedDeletes,
      errors: errors,
      isPermanent: permanent,
    ));
  }
}

/// Result of batch delete operation
class BatchDeleteResult {
  final int totalRequested;
  final int successCount;
  final int failureCount;
  final List<String> successfulIds;
  final List<String> failedIds;
  final Map<String, String> errors;
  final bool isPermanent;

  BatchDeleteResult({
    required this.totalRequested,
    required this.successCount,
    required this.failureCount,
    required this.successfulIds,
    required this.failedIds,
    required this.errors,
    required this.isPermanent,
  });

  /// Check if all deletions were successful
  bool get isFullSuccess => failureCount == 0;

  /// Check if all deletions failed
  bool get isFullFailure => successCount == 0;

  /// Check if partially successful
  bool get isPartialSuccess => successCount > 0 && failureCount > 0;

  /// Get success rate as percentage
  double get successRate => (successCount / totalRequested) * 100;

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'totalRequested': totalRequested,
      'successCount': successCount,
      'failureCount': failureCount,
      'successfulIds': successfulIds,
      'failedIds': failedIds,
      'errors': errors,
      'isPermanent': isPermanent,
      'isFullSuccess': isFullSuccess,
      'isFullFailure': isFullFailure,
      'isPartialSuccess': isPartialSuccess,
      'successRate': successRate,
    };
  }

  @override
  String toString() {
    return 'BatchDeleteResult(total: $totalRequested, success: $successCount, failed: $failureCount, permanent: $isPermanent)';
  }
}
