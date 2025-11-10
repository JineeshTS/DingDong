import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/attachment_entity.dart';

/// Attachment repository interface
abstract class AttachmentRepository {
  /// Upload and create attachment
  Future<Either<Failure, AttachmentEntity>> uploadAttachment({
    required String userId,
    String? taskId,
    String? commentId,
    required String fileName,
    required Uint8List fileData,
    required String mimeType,
  });

  /// Get attachment by ID
  Future<Either<Failure, AttachmentEntity>> getAttachment(String id);

  /// Get all attachments for task
  Future<Either<Failure, List<AttachmentEntity>>> getAttachmentsForTask(
    String taskId,
  );

  /// Get all attachments for comment
  Future<Either<Failure, List<AttachmentEntity>>> getAttachmentsForComment(
    String commentId,
  );

  /// Get all attachments for user
  Future<Either<Failure, List<AttachmentEntity>>> getAttachments({
    required String userId,
    AttachmentType? type,
    bool includeDeleted = false,
  });

  /// Get attachments by type
  Future<Either<Failure, List<AttachmentEntity>>> getAttachmentsByType({
    required String userId,
    required AttachmentType type,
  });

  /// Update attachment
  Future<Either<Failure, AttachmentEntity>> updateAttachment(
    AttachmentEntity attachment,
  );

  /// Delete attachment (soft delete)
  Future<Either<Failure, void>> deleteAttachment(String id);

  /// Permanently delete attachment (removes from storage)
  Future<Either<Failure, void>> permanentlyDeleteAttachment(String id);

  /// Restore attachment
  Future<Either<Failure, AttachmentEntity>> restoreAttachment(String id);

  /// Download attachment data
  Future<Either<Failure, Uint8List>> downloadAttachment(String id);

  /// Get download URL
  Future<Either<Failure, String>> getDownloadUrl(String id);

  /// Generate thumbnail for image/video
  Future<Either<Failure, String>> generateThumbnail(String attachmentId);

  /// Batch delete attachments
  Future<Either<Failure, void>> batchDeleteAttachments(
    List<String> attachmentIds,
  );

  /// Delete all attachments for task
  Future<Either<Failure, void>> deleteAttachmentsForTask(String taskId);

  /// Delete all attachments for comment
  Future<Either<Failure, void>> deleteAttachmentsForComment(String commentId);

  /// Get total storage used by user
  Future<Either<Failure, int>> getTotalStorageUsed(String userId);

  /// Get storage statistics
  Future<Either<Failure, Map<String, dynamic>>> getStorageStatistics(
    String userId,
  );

  /// Clean up expired attachments
  Future<Either<Failure, int>> cleanupExpiredAttachments();

  /// Watch attachments for task (stream)
  Stream<Either<Failure, List<AttachmentEntity>>> watchAttachmentsForTask(
    String taskId,
  );

  /// Watch attachments for comment (stream)
  Stream<Either<Failure, List<AttachmentEntity>>> watchAttachmentsForComment(
    String commentId,
  );
}
