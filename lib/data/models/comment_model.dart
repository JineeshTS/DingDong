import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/comment_entity.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

/// Comment data model for Firestore serialization
@freezed
class CommentModel with _$CommentModel {
  const factory CommentModel({
    required String id,
    required String taskId,
    required String userId,
    String? parentCommentId,
    required String content,
    @Default([]) List<String> mentionedUserIds,
    @Default([]) List<String> attachmentIds,
    @Default({}) Map<String, int> reactions,
    @Default([]) List<String> reactedUserIds,
    @Default(false) bool isEdited,
    DateTime? editedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _CommentModel;

  const CommentModel._();

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      taskId: taskId,
      userId: userId,
      parentCommentId: parentCommentId,
      content: content,
      mentionedUserIds: mentionedUserIds,
      attachmentIds: attachmentIds,
      reactions: reactions,
      reactedUserIds: reactedUserIds,
      isEdited: isEdited,
      editedAt: editedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      taskId: entity.taskId,
      userId: entity.userId,
      parentCommentId: entity.parentCommentId,
      content: entity.content,
      mentionedUserIds: entity.mentionedUserIds,
      attachmentIds: entity.attachmentIds,
      reactions: entity.reactions,
      reactedUserIds: entity.reactedUserIds,
      isEdited: entity.isEdited,
      editedAt: entity.editedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isDeleted: entity.isDeleted,
    );
  }
}
