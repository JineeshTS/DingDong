import 'package:isar/isar.dart';

part 'activity_log_isar.g.dart';

/// Isar collection for ActivityLog entity (local storage)
@collection
class ActivityLogIsar {
  /// Isar auto-increment ID
  Id id = Isar.autoIncrement;

  /// Firebase activity log ID
  @Index(unique: true)
  late String activityId;

  /// User ID (who performed the action)
  @Index()
  late String userId;

  /// Workspace ID
  @Index()
  String? workspaceId;

  /// Action type
  @Index()
  @Enumerated(EnumType.name)
  late ActivityActionTypeIsar actionType;

  /// Entity type (task, list, comment, etc.)
  @Index()
  @Enumerated(EnumType.name)
  late ActivityEntityTypeIsar entityType;

  /// Entity ID (ID of the affected entity)
  @Index()
  late String entityId;

  /// Entity name/title (for display)
  String? entityName;

  /// Additional metadata (stored as JSON string)
  String? metadataJson;

  /// IP address
  String? ipAddress;

  /// User agent
  String? userAgent;

  /// Device type
  String? deviceType;

  /// Timestamp
  @Index()
  late DateTime timestamp;

  /// Last sync timestamp
  DateTime? lastSyncAt;

  /// Dirty flag (needs sync)
  bool isDirty = false;
}

/// Activity action type enum for Isar
enum ActivityActionTypeIsar {
  create,
  update,
  delete,
  complete,
  uncomplete,
  archive,
  unarchive,
  share,
  unshare,
  assign,
  unassign,
  comment,
  attach,
  move,
  duplicate,
}

/// Activity entity type enum for Isar
enum ActivityEntityTypeIsar {
  task,
  list,
  tag,
  comment,
  attachment,
  habit,
  focusSession,
  workspace,
  reminder,
}
