import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/attachment_entity.dart';

part 'attachment_model.freezed.dart';
part 'attachment_model.g.dart';

/// Attachment data model for Firestore serialization
@freezed
class AttachmentModel with _$AttachmentModel {
  const factory AttachmentModel({
    required String id,
    required String userId,
    String? taskId,
    String? commentId,
    required String fileName,
    required String fileExtension,
    required int fileSizeBytes,
    required String mimeType,
    required String type,
    required String storageUrl,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    required DateTime uploadedAt,
    DateTime? expiresAt,
    @Default(false) bool isDeleted,
  }) = _AttachmentModel;

  const AttachmentModel._();

  factory AttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$AttachmentModelFromJson(json);

  AttachmentEntity toEntity() {
    return AttachmentEntity(
      id: id,
      userId: userId,
      taskId: taskId,
      commentId: commentId,
      fileName: fileName,
      fileExtension: fileExtension,
      fileSizeBytes: fileSizeBytes,
      mimeType: mimeType,
      type: _typeFromString(type),
      storageUrl: storageUrl,
      thumbnailUrl: thumbnailUrl,
      metadata: metadata,
      uploadedAt: uploadedAt,
      expiresAt: expiresAt,
      isDeleted: isDeleted,
    );
  }

  factory AttachmentModel.fromEntity(AttachmentEntity entity) {
    return AttachmentModel(
      id: entity.id,
      userId: entity.userId,
      taskId: entity.taskId,
      commentId: entity.commentId,
      fileName: entity.fileName,
      fileExtension: entity.fileExtension,
      fileSizeBytes: entity.fileSizeBytes,
      mimeType: entity.mimeType,
      type: _typeToString(entity.type),
      storageUrl: entity.storageUrl,
      thumbnailUrl: entity.thumbnailUrl,
      metadata: entity.metadata,
      uploadedAt: entity.uploadedAt,
      expiresAt: entity.expiresAt,
      isDeleted: entity.isDeleted,
    );
  }

  static String _typeToString(AttachmentType type) {
    return type.toString().split('.').last;
  }

  static AttachmentType _typeFromString(String type) {
    switch (type) {
      case 'image':
        return AttachmentType.image;
      case 'video':
        return AttachmentType.video;
      case 'audio':
        return AttachmentType.audio;
      case 'document':
        return AttachmentType.document;
      case 'archive':
        return AttachmentType.archive;
      case 'other':
        return AttachmentType.other;
      default:
        return AttachmentType.other;
    }
  }
}
