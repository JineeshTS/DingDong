import 'package:isar/isar.dart';

part 'workspace_isar.g.dart';

/// Isar collection for Workspace entity (local storage)
@collection
class WorkspaceIsar {
  /// Isar auto-increment ID
  Id id = Isar.autoIncrement;

  /// Firebase workspace ID
  @Index(unique: true)
  late String workspaceId;

  /// Owner user ID
  @Index()
  late String ownerId;

  /// Workspace name
  late String name;

  /// Workspace description
  String? description;

  /// Workspace icon
  String? icon;

  /// Workspace color (hex code)
  String color = '#8B5CF6';

  /// Member count
  int memberCount = 1;

  /// Members (stored as JSON string)
  String? membersJson;

  /// Settings (stored as JSON string)
  String? settingsJson;

  /// Subscription (stored as JSON string)
  String? subscriptionJson;

  /// Is archived
  @Index()
  bool isArchived = false;

  /// Is deleted (soft delete)
  bool isDeleted = false;

  /// Creation timestamp
  late DateTime createdAt;

  /// Update timestamp
  late DateTime updatedAt;

  /// Archived timestamp
  DateTime? archivedAt;

  /// Deleted timestamp
  DateTime? deletedAt;

  /// Last sync timestamp
  DateTime? lastSyncAt;

  /// Dirty flag (needs sync)
  bool isDirty = false;
}

/// Workspace role enum for Isar
enum WorkspaceRoleIsar {
  owner,
  admin,
  member,
  viewer,
}
