import 'package:equatable/equatable.dart';

/// List (Project) entity representing a task list in the domain layer
class ListEntity extends Equatable {
  final String id;
  final String userId;
  final String? workspaceId;
  final String? parentListId; // For nested lists/folders
  final String name;
  final String? description;
  final ListType type;
  final String? icon; // Emoji or icon name
  final String color; // Hex color code
  final ListViewType defaultViewType;
  final ListSortType defaultSortType;
  final bool sortAscending;
  final int sortOrder;
  final bool isArchived;
  final bool isDeleted;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? lastModifiedBy;
  final Map<String, dynamic>? settings; // List-specific settings
  final ListShareSettings? shareSettings;

  const ListEntity({
    required this.id,
    required this.userId,
    this.workspaceId,
    this.parentListId,
    required this.name,
    this.description,
    this.type = ListType.personal,
    this.icon,
    this.color = '#2196F3',
    this.defaultViewType = ListViewType.list,
    this.defaultSortType = ListSortType.manual,
    this.sortAscending = true,
    this.sortOrder = 0,
    this.isArchived = false,
    this.isDeleted = false,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.lastModifiedBy,
    this.settings,
    this.shareSettings,
  });

  /// Check if list is shared
  bool get isShared => type == ListType.shared || shareSettings != null;

  /// Check if list is a smart list
  bool get isSmartList => type == ListType.smart;

  /// Check if list is nested (has parent)
  bool get isNested => parentListId != null;

  /// Copy with method
  ListEntity copyWith({
    String? id,
    String? userId,
    String? workspaceId,
    String? parentListId,
    String? name,
    String? description,
    ListType? type,
    String? icon,
    String? color,
    ListViewType? defaultViewType,
    ListSortType? defaultSortType,
    bool? sortAscending,
    int? sortOrder,
    bool? isArchived,
    bool? isDeleted,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? lastModifiedBy,
    Map<String, dynamic>? settings,
    ListShareSettings? shareSettings,
  }) {
    return ListEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workspaceId: workspaceId ?? this.workspaceId,
      parentListId: parentListId ?? this.parentListId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      defaultViewType: defaultViewType ?? this.defaultViewType,
      defaultSortType: defaultSortType ?? this.defaultSortType,
      sortAscending: sortAscending ?? this.sortAscending,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      settings: settings ?? this.settings,
      shareSettings: shareSettings ?? this.shareSettings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        workspaceId,
        parentListId,
        name,
        description,
        type,
        icon,
        color,
        defaultViewType,
        defaultSortType,
        sortAscending,
        sortOrder,
        isArchived,
        isDeleted,
        isFavorite,
        createdAt,
        updatedAt,
        createdBy,
        lastModifiedBy,
        settings,
        shareSettings,
      ];
}

/// List types
enum ListType {
  personal, // Personal list
  shared, // Shared/collaborative list
  smart, // Smart list (filtered view)
  template, // Template list
}

/// List view types
enum ListViewType {
  list, // Traditional list view
  compact, // Compact list view
  detailed, // Detailed list view with metadata
  grouped, // Grouped by date/priority/tag
}

/// List sort types
enum ListSortType {
  manual, // Manual drag-and-drop ordering
  dueDate, // Sort by due date
  priority, // Sort by priority
  name, // Sort alphabetically by name
  createdDate, // Sort by creation date
  completedDate, // Sort by completion date
  custom, // Custom sort field
}

/// List share settings
class ListShareSettings extends Equatable {
  final bool isPublic;
  final String? shareLink;
  final DateTime? shareLinkExpiresAt;
  final List<ListCollaborator> collaborators;
  final bool allowGuests;
  final ListPermission defaultPermission;

  const ListShareSettings({
    this.isPublic = false,
    this.shareLink,
    this.shareLinkExpiresAt,
    this.collaborators = const [],
    this.allowGuests = false,
    this.defaultPermission = ListPermission.view,
  });

  @override
  List<Object?> get props => [
        isPublic,
        shareLink,
        shareLinkExpiresAt,
        collaborators,
        allowGuests,
        defaultPermission,
      ];
}

/// List collaborator
class ListCollaborator extends Equatable {
  final String userId;
  final String? email; // For pending invitations
  final ListPermission permission;
  final DateTime addedAt;
  final String addedBy;
  final bool isAccepted;

  const ListCollaborator({
    required this.userId,
    this.email,
    required this.permission,
    required this.addedAt,
    required this.addedBy,
    this.isAccepted = false,
  });

  @override
  List<Object?> get props => [
        userId,
        email,
        permission,
        addedAt,
        addedBy,
        isAccepted,
      ];
}

/// List permissions
enum ListPermission {
  view, // View only
  comment, // View + comment
  edit, // View + comment + edit tasks
  admin, // Full access including sharing
}
