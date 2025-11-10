import 'package:isar/isar.dart';

part 'attachment_isar.g.dart';

/// Isar collection for Attachment entity (local storage)
@collection
class AttachmentIsar {
  /// Isar auto-increment ID
  Id id = Isar.autoIncrement;

  /// Firebase attachment ID
  @Index(unique: true)
  late String attachmentId;

  /// User ID (uploader)
  @Index()
  late String userId;

  /// Task ID (optional)
  @Index()
  String? taskId;

  /// Comment ID (optional)
  @Index()
  String? commentId;

  /// File name
  late String fileName;

  /// File size (in bytes)
  late int fileSize;

  /// MIME type
  late String mimeType;

  /// Attachment type
  @Index()
  @Enumerated(EnumType.name)
  late AttachmentTypeIsar type;

  /// File URL (from Firebase Storage)
  String? url;

  /// Local file path (for offline access)
  String? localPath;

  /// Storage path (Firebase Storage path)
  String? storagePath;

  /// Thumbnail URL
  String? thumbnailUrl;

  /// Thumbnail local path
  String? thumbnailLocalPath;

  /// Thumbnail storage path
  String? thumbnailPath;

  /// Is downloaded locally
  bool isDownloaded = false;

  /// Is deleted (soft delete)
  bool isDeleted = false;

  /// Creation timestamp
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

/// Attachment type enum for Isar
enum AttachmentTypeIsar {
  image,
  video,
  audio,
  document,
  spreadsheet,
  presentation,
  other,
}
