import 'package:equatable/equatable.dart';

/// Comment entity representing a comment on a task
class CommentEntity extends Equatable {
  final String id;
  final String taskId;
  final String userId;
  final String? parentCommentId; // For threaded comments/replies
  final String content;
  final List<String> mentionedUserIds; // @mentions
  final List<String> attachmentIds;
  final Map<String, int> reactions; // emoji → count (e.g., {"👍": 5, "❤️": 3})
  final List<String> reactedUserIds; // Users who reacted
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const CommentEntity({
    required this.id,
    required this.taskId,
    required this.userId,
    this.parentCommentId,
    required this.content,
    this.mentionedUserIds = const [],
    this.attachmentIds = const [],
    this.reactions = const {},
    this.reactedUserIds = const [],
    this.isEdited = false,
    this.editedAt,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Check if comment is a reply
  bool get isReply => parentCommentId != null;

  /// Get total reaction count
  int get totalReactions => reactions.values.fold(0, (sum, count) => sum + count);

  /// Check if comment has attachments
  bool get hasAttachments => attachmentIds.isNotEmpty;

  /// Check if comment has mentions
  bool get hasMentions => mentionedUserIds.isNotEmpty;

  /// Copy with method
  CommentEntity copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? parentCommentId,
    String? content,
    List<String>? mentionedUserIds,
    List<String>? attachmentIds,
    Map<String, int>? reactions,
    List<String>? reactedUserIds,
    bool? isEdited,
    DateTime? editedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      mentionedUserIds: mentionedUserIds ?? this.mentionedUserIds,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      reactions: reactions ?? this.reactions,
      reactedUserIds: reactedUserIds ?? this.reactedUserIds,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        userId,
        parentCommentId,
        content,
        mentionedUserIds,
        attachmentIds,
        reactions,
        reactedUserIds,
        isEdited,
        editedAt,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}
