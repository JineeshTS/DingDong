import 'package:isar/isar.dart';

part 'comment_isar.g.dart';

/// Isar collection for Comment entity (local storage)
@collection
class CommentIsar {
  /// Isar auto-increment ID
  Id id = Isar.autoIncrement;

  /// Firebase comment ID
  @Index(unique: true)
  late String commentId;

  /// User ID (author)
  @Index()
  late String userId;

  /// Task ID
  @Index()
  late String taskId;

  /// Parent comment ID (for threaded comments)
  @Index()
  String? parentCommentId;

  /// Comment content (can be rich text/HTML)
  late String content;

  /// Mentioned user IDs
  List<String> mentions = [];

  /// Attachment IDs
  List<String> attachmentIds = [];

  /// Reactions (stored as JSON string - emoji -> user IDs map)
  String? reactionsJson;

  /// Is edited
  bool isEdited = false;

  /// Is deleted (soft delete)
  bool isDeleted = false;

  /// Creation timestamp
  @Index()
  late DateTime createdAt;

  /// Update timestamp
  late DateTime updatedAt;

  /// Deleted timestamp
  DateTime? deletedAt;

  /// Last sync timestamp
  DateTime? lastSyncAt;

  /// Dirty flag (needs sync)
  bool isDirty = false;
}
