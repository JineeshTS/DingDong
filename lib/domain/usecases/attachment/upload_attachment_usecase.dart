import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/attachment_entity.dart';
import '../../entities/user_entity.dart';
import '../../repositories/attachment_repository.dart';
import '../../repositories/user_repository.dart';

/// Use case for uploading an attachment with file validation
///
/// Validates:
/// - File size based on subscription tier (free: 25MB, plus: 100MB, premium: 250MB)
/// - Allowed file types
/// - Task ID or Comment ID presence
/// - Total storage usage against quota
class UploadAttachmentUseCase {
  final AttachmentRepository attachmentRepository;
  final UserRepository userRepository;

  UploadAttachmentUseCase({
    required this.attachmentRepository,
    required this.userRepository,
  });

  /// Allowed MIME types for attachments
  static const List<String> _allowedMimeTypes = [
    // Images
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/svg+xml',
    'image/bmp',
    // Documents
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'text/plain',
    'text/csv',
    'text/html',
    'text/markdown',
    // Archives
    'application/zip',
    'application/x-zip-compressed',
    'application/x-rar-compressed',
    'application/x-7z-compressed',
    'application/gzip',
    // Audio
    'audio/mpeg',
    'audio/mp3',
    'audio/wav',
    'audio/ogg',
    'audio/aac',
    // Video
    'video/mp4',
    'video/mpeg',
    'video/quicktime',
    'video/x-msvideo',
    'video/webm',
  ];

  /// Allowed file extensions
  static const List<String> _allowedExtensions = [
    // Images
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'svg',
    'bmp',
    // Documents
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'csv',
    'html',
    'md',
    // Archives
    'zip',
    'rar',
    '7z',
    'gz',
    // Audio
    'mp3',
    'wav',
    'ogg',
    'aac',
    // Video
    'mp4',
    'mpeg',
    'mov',
    'avi',
    'webm',
  ];

  Future<Either<Failure, AttachmentEntity>> call({
    required String userId,
    String? taskId,
    String? commentId,
    required String fileName,
    required Uint8List fileData,
    required String mimeType,
  }) async {
    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Validate that either taskId or commentId is provided
    if (taskId == null && commentId == null) {
      return Left(ValidationFailure(
          message: 'Either task ID or comment ID must be provided'));
    }

    // Validate that both taskId and commentId are not provided
    if (taskId != null && commentId != null) {
      return Left(ValidationFailure(
          message: 'Cannot attach to both task and comment simultaneously'));
    }

    // Validate task ID format if provided
    if (taskId != null && taskId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Task ID cannot be empty'));
    }

    // Validate comment ID format if provided
    if (commentId != null && commentId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Comment ID cannot be empty'));
    }

    // Validate file name
    if (fileName.trim().isEmpty) {
      return Left(ValidationFailure(message: 'File name cannot be empty'));
    }

    if (fileName.length > 255) {
      return Left(ValidationFailure(
          message: 'File name cannot exceed 255 characters'));
    }

    // Extract file extension
    final fileExtension = _getFileExtension(fileName);
    if (fileExtension.isEmpty) {
      return Left(
          ValidationFailure(message: 'File must have a valid extension'));
    }

    // Validate file extension
    if (!_allowedExtensions.contains(fileExtension.toLowerCase())) {
      return Left(ValidationFailure(
          message:
              'File type not allowed. Allowed types: ${_allowedExtensions.join(", ")}'));
    }

    // Validate MIME type
    if (mimeType.trim().isEmpty) {
      return Left(ValidationFailure(message: 'MIME type cannot be empty'));
    }

    if (!_allowedMimeTypes.contains(mimeType.toLowerCase())) {
      return Left(ValidationFailure(
          message: 'MIME type not allowed: $mimeType'));
    }

    // Validate file data
    if (fileData.isEmpty) {
      return Left(ValidationFailure(message: 'File data cannot be empty'));
    }

    final fileSizeBytes = fileData.length;

    // Get user to check subscription tier
    final userResult = await userRepository.getUser(userId);
    if (userResult.isLeft()) {
      return Left(NotFoundFailure(message: 'User not found'));
    }

    final user = userResult.getOrElse(() => throw Exception('Unexpected error'));

    // Get max file size based on subscription tier
    final maxFileSizeBytes = _getMaxFileSizeForTier(user.subscriptionTier);

    // Validate file size against subscription tier limit
    if (fileSizeBytes > maxFileSizeBytes) {
      final maxSizeMB = maxFileSizeBytes / (1024 * 1024);
      return Left(ValidationFailure(
          message:
              'File size exceeds limit for ${user.subscriptionTier.name} tier. Maximum: ${maxSizeMB}MB'));
    }

    // Check total storage usage
    final storageResult = await attachmentRepository.getTotalStorageUsed(userId);
    if (storageResult.isRight()) {
      final currentStorageUsed =
          storageResult.getOrElse(() => throw Exception('Unexpected error'));
      final storageLimit = _getStorageLimitForTier(user.subscriptionTier);

      if (currentStorageUsed + fileSizeBytes > storageLimit) {
        final limitMB = storageLimit / (1024 * 1024);
        final usedMB = currentStorageUsed / (1024 * 1024);
        return Left(ValidationFailure(
            message:
                'Storage quota exceeded. Used: ${usedMB.toStringAsFixed(2)}MB, Limit: ${limitMB}MB'));
      }
    }

    // Upload attachment
    return await attachmentRepository.uploadAttachment(
      userId: userId,
      taskId: taskId,
      commentId: commentId,
      fileName: fileName,
      fileData: fileData,
      mimeType: mimeType,
    );
  }

  /// Get file extension from file name
  String _getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(lastDotIndex + 1);
  }

  /// Get maximum file size in bytes based on subscription tier
  int _getMaxFileSizeForTier(UserSubscriptionTier tier) {
    switch (tier) {
      case UserSubscriptionTier.free:
        return 25 * 1024 * 1024; // 25MB
      case UserSubscriptionTier.premiumIndividual:
      case UserSubscriptionTier.premiumFamily:
        return 100 * 1024 * 1024; // 100MB (plus tier)
      case UserSubscriptionTier.teams:
      case UserSubscriptionTier.enterprise:
      case UserSubscriptionTier.lifetime:
        return 250 * 1024 * 1024; // 250MB (premium tier)
    }
  }

  /// Get total storage limit in bytes based on subscription tier
  int _getStorageLimitForTier(UserSubscriptionTier tier) {
    switch (tier) {
      case UserSubscriptionTier.free:
        return 1024 * 1024 * 1024; // 1GB
      case UserSubscriptionTier.premiumIndividual:
      case UserSubscriptionTier.premiumFamily:
        return 10 * 1024 * 1024 * 1024; // 10GB
      case UserSubscriptionTier.teams:
      case UserSubscriptionTier.enterprise:
      case UserSubscriptionTier.lifetime:
        return 100 * 1024 * 1024 * 1024; // 100GB
    }
  }
}
