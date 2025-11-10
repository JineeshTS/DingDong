import 'package:equatable/equatable.dart';

/// Attachment entity representing a file attached to a task or comment
class AttachmentEntity extends Equatable {
  final String id;
  final String userId;
  final String? taskId;
  final String? commentId;
  final String fileName;
  final String fileExtension;
  final int fileSizeBytes;
  final String mimeType;
  final AttachmentType type;
  final String storageUrl; // URL in cloud storage
  final String? thumbnailUrl; // For images/videos
  final Map<String, dynamic>? metadata; // Additional metadata (dimensions, duration, etc.)
  final DateTime uploadedAt;
  final DateTime? expiresAt; // For temporary attachments
  final bool isDeleted;

  const AttachmentEntity({
    required this.id,
    required this.userId,
    this.taskId,
    this.commentId,
    required this.fileName,
    required this.fileExtension,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.type,
    required this.storageUrl,
    this.thumbnailUrl,
    this.metadata,
    required this.uploadedAt,
    this.expiresAt,
    this.isDeleted = false,
  });

  /// Get file size in human-readable format
  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Check if attachment is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if attachment has thumbnail
  bool get hasThumbnail => thumbnailUrl != null;

  /// Copy with method
  AttachmentEntity copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? commentId,
    String? fileName,
    String? fileExtension,
    int? fileSizeBytes,
    String? mimeType,
    AttachmentType? type,
    String? storageUrl,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    DateTime? uploadedAt,
    DateTime? expiresAt,
    bool? isDeleted,
  }) {
    return AttachmentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      commentId: commentId ?? this.commentId,
      fileName: fileName ?? this.fileName,
      fileExtension: fileExtension ?? this.fileExtension,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      mimeType: mimeType ?? this.mimeType,
      type: type ?? this.type,
      storageUrl: storageUrl ?? this.storageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      metadata: metadata ?? this.metadata,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        taskId,
        commentId,
        fileName,
        fileExtension,
        fileSizeBytes,
        mimeType,
        type,
        storageUrl,
        thumbnailUrl,
        metadata,
        uploadedAt,
        expiresAt,
        isDeleted,
      ];
}

/// Attachment types
enum AttachmentType {
  image,
  video,
  audio,
  document, // PDF, Word, Excel, etc.
  archive, // ZIP, RAR, etc.
  other,
}
