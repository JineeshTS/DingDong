import 'package:isar/isar.dart';

part 'tag_isar.g.dart';

/// Isar collection for Tag entity (local storage)
@collection
class TagIsar {
  /// Isar auto-increment ID
  Id id = Isar.autoIncrement;

  /// Firebase tag ID
  @Index(unique: true)
  late String tagId;

  /// User ID (owner)
  @Index()
  late String userId;

  /// Workspace ID
  @Index()
  String? workspaceId;

  /// Parent tag ID (for hierarchical tags)
  @Index()
  String? parentTagId;

  /// Tag name
  @Index()
  late String name;

  /// Tag color (hex code)
  String color = '#6B7280';

  /// Usage count (how many tasks use this tag)
  @Index()
  int usageCount = 0;

  /// Last used timestamp
  DateTime? lastUsedAt;

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
