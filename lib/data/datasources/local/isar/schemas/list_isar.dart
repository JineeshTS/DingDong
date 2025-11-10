import 'package:isar/isar.dart';

part 'list_isar.g.dart';

/// Isar collection for List entity (local storage)
@collection
class ListIsar {
  /// Isar auto-increment ID
  Id id = Isar.autoIncrement;

  /// Firebase list ID
  @Index(unique: true)
  late String listId;

  /// User ID (owner)
  @Index()
  late String userId;

  /// Workspace ID
  @Index()
  String? workspaceId;

  /// Parent list ID (for nested lists)
  @Index()
  String? parentListId;

  /// List name
  late String name;

  /// List description
  String? description;

  /// List color (hex code)
  String color = '#3B82F6';

  /// List icon name
  String? icon;

  /// List type
  @Enumerated(EnumType.name)
  late ListTypeIsar type;

  /// Is favorite
  @Index()
  bool isFavorite = false;

  /// Is archived
  @Index()
  bool isArchived = false;

  /// Is deleted (soft delete)
  bool isDeleted = false;

  /// Is shared with others
  bool isShared = false;

  /// Sort order
  int sortOrder = 0;

  /// Task count (cached)
  int taskCount = 0;

  /// Completed task count (cached)
  int completedTaskCount = 0;

  /// Collaborators (stored as JSON string)
  String? collaboratorsJson;

  /// Share settings (stored as JSON string)
  String? shareSettingsJson;

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

/// List type enum for Isar
enum ListTypeIsar {
  personal,
  shared,
  smart,
  template,
}

/// List permission enum for Isar
enum ListPermissionIsar {
  view,
  edit,
  admin,
}
