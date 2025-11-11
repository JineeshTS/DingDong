import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/attachment_entity.dart';
import '../../repositories/attachment_repository.dart';

/// Use case for marking an attachment as downloaded locally
///
/// Tracks when attachments are downloaded for offline access.
/// Updates metadata to include:
/// - Download timestamp
/// - Download count
/// - Download status
///
/// Validates:
/// - Attachment ID
/// - Attachment exists and is not deleted
/// - Attachment is not expired
class MarkAsDownloadedUseCase {
  final AttachmentRepository repository;

  MarkAsDownloadedUseCase(this.repository);

  /// Mark attachment as downloaded
  ///
  /// [attachmentId] - ID of the attachment
  /// [userId] - ID of the user downloading (for tracking)
  /// [deviceId] - Optional device identifier for tracking downloads per device
  Future<Either<Failure, AttachmentEntity>> call({
    required String attachmentId,
    required String userId,
    String? deviceId,
  }) async {
    // Validate attachment ID
    if (attachmentId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Attachment ID cannot be empty'));
    }

    // Validate user ID
    if (userId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Validate device ID if provided
    if (deviceId != null && deviceId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Device ID cannot be empty'));
    }

    // Get attachment to verify it exists
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
          message: 'Cannot mark deleted attachment as downloaded'));
    }

    // Check if attachment is expired
    if (attachment.isExpired) {
      return Left(ValidationFailure(
          message: 'Cannot mark expired attachment as downloaded'));
    }

    // Prepare updated metadata
    final currentMetadata = attachment.metadata ?? {};
    final downloadInfo = currentMetadata['downloadInfo'] as Map<String, dynamic>? ?? {};

    // Get current download count
    final currentDownloadCount = downloadInfo['count'] as int? ?? 0;

    // Get downloads by device
    final downloadsByDevice = downloadInfo['byDevice'] as Map<String, dynamic>? ?? {};

    // Update download info
    final now = DateTime.now();
    final updatedDownloadInfo = {
      'count': currentDownloadCount + 1,
      'lastDownloadedAt': now.toIso8601String(),
      'lastDownloadedBy': userId,
      'byDevice': {
        ...downloadsByDevice,
        if (deviceId != null)
          deviceId: {
            'downloadedAt': now.toIso8601String(),
            'userId': userId,
          },
      },
    };

    // Update metadata
    final updatedMetadata = {
      ...currentMetadata,
      'downloadInfo': updatedDownloadInfo,
      'isDownloaded': true,
      'lastModified': now.toIso8601String(),
    };

    // Update attachment with new metadata
    final updatedAttachment = attachment.copyWith(
      metadata: updatedMetadata,
    );

    // Save updated attachment
    return await repository.updateAttachment(updatedAttachment);
  }

  /// Get download statistics for an attachment
  ///
  /// Returns download count, last download time, and device information
  Future<Either<Failure, DownloadStats>> getDownloadStats(
      String attachmentId) async {
    // Validate attachment ID
    if (attachmentId.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Attachment ID cannot be empty'));
    }

    // Get attachment
    final attachmentResult = await repository.getAttachment(attachmentId);
    if (attachmentResult.isLeft()) {
      return Left(NotFoundFailure(message: 'Attachment not found'));
    }

    final attachment = attachmentResult.getOrElse(
      () => throw Exception('Unexpected error'),
    );

    // Extract download info from metadata
    final metadata = attachment.metadata ?? {};
    final downloadInfo = metadata['downloadInfo'] as Map<String, dynamic>? ?? {};

    final count = downloadInfo['count'] as int? ?? 0;
    final lastDownloadedAtStr = downloadInfo['lastDownloadedAt'] as String?;
    final lastDownloadedBy = downloadInfo['lastDownloadedBy'] as String?;
    final byDevice = downloadInfo['byDevice'] as Map<String, dynamic>? ?? {};

    DateTime? lastDownloadedAt;
    if (lastDownloadedAtStr != null) {
      try {
        lastDownloadedAt = DateTime.parse(lastDownloadedAtStr);
      } catch (e) {
        // Invalid date format, ignore
      }
    }

    return Right(DownloadStats(
      attachmentId: attachmentId,
      downloadCount: count,
      lastDownloadedAt: lastDownloadedAt,
      lastDownloadedBy: lastDownloadedBy,
      deviceCount: byDevice.length,
      devices: byDevice.keys.toList(),
      isDownloaded: metadata['isDownloaded'] as bool? ?? false,
    ));
  }
}

/// Download statistics for an attachment
class DownloadStats {
  final String attachmentId;
  final int downloadCount;
  final DateTime? lastDownloadedAt;
  final String? lastDownloadedBy;
  final int deviceCount;
  final List<String> devices;
  final bool isDownloaded;

  DownloadStats({
    required this.attachmentId,
    required this.downloadCount,
    this.lastDownloadedAt,
    this.lastDownloadedBy,
    required this.deviceCount,
    required this.devices,
    required this.isDownloaded,
  });

  /// Check if downloaded recently (within last 7 days)
  bool get isRecentlyDownloaded {
    if (lastDownloadedAt == null) return false;
    final daysSinceDownload = DateTime.now().difference(lastDownloadedAt!).inDays;
    return daysSinceDownload <= 7;
  }

  /// Check if downloaded on multiple devices
  bool get isMultiDevice => deviceCount > 1;

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'attachmentId': attachmentId,
      'downloadCount': downloadCount,
      'lastDownloadedAt': lastDownloadedAt?.toIso8601String(),
      'lastDownloadedBy': lastDownloadedBy,
      'deviceCount': deviceCount,
      'devices': devices,
      'isDownloaded': isDownloaded,
      'isRecentlyDownloaded': isRecentlyDownloaded,
      'isMultiDevice': isMultiDevice,
    };
  }

  @override
  String toString() {
    return 'DownloadStats(attachmentId: $attachmentId, count: $downloadCount, devices: $deviceCount)';
  }
}
